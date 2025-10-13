import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/subscription_model.dart';
import '../providers/subscriptions_provider.dart';
import '../core/constants/app_constants.dart';
import '../widgets/subscription_card.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/update_badge.dart';
import '../services/calendar_service.dart';
import 'add_edit_subscription_screen.dart';
import 'archived_subscriptions_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allSubscriptions = ref.watch(subscriptionsProvider);
    final subscriptions = allSubscriptions.where((s) => s.isActive).toList();
    final subscriptionsNotifier = ref.read(subscriptionsProvider.notifier);
    final totalMonthlyCost = subscriptionsNotifier.getTotalMonthlyCost();
    
    final currencyFormat = NumberFormat.currency(
      symbol: AppConstants.currencySymbol,
      decimalDigits: 2,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Suscripciones'),
        actions: [
          const UpdateBadge(),
          // Badge con contador de archivadas
          Builder(
            builder: (context) {
              final archivedCount = allSubscriptions.where((s) => s.isCanceled).length;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.archive_outlined),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ArchivedSubscriptionsScreen(),
                        ),
                      );
                    },
                    tooltip: 'Suscripciones archivadas',
                  ),
                  if (archivedCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$archivedCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implementar búsqueda
            },
          ),
        ],
      ),
      body: subscriptions.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.subscriptions_outlined,
              title: 'No hay suscripciones',
              message: 'Agrega tu primera suscripción\npara comenzar a gestionar tus gastos',
            )
          : Column(
              children: [
                // Tarjeta de resumen mensual
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primaryContainer,
                        Theme.of(context).colorScheme.secondaryContainer,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gasto Mensual Total',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currencyFormat.format(totalMonthlyCost),
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 16,
                            color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${subscriptions.length} ${subscriptions.length == 1 ? 'suscripción' : 'suscripciones'}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Lista de suscripciones
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: subscriptions.length,
                    itemBuilder: (context, index) {
                      final subscription = subscriptions[index];
                      return SubscriptionCard(
                        subscription: subscription,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddEditSubscriptionScreen(
                                subscription: subscription,
                              ),
                            ),
                          );
                        },
                        onDelete: () async {
                          final confirmed = await _showDeleteDialog(context);
                          if (confirmed == true) {
                            // Eliminar recordatorios del calendario
                            if (subscription.calendarEventId != null && subscription.calendarId != null) {
                              final calendarService = CalendarService();
                              await calendarService.deleteReminder(
                                subscription.calendarEventId!,
                                calendarId: subscription.calendarId,
                              );
                            }
                            
                            // Eliminar suscripción de la base de datos
                            await subscriptionsNotifier.deleteSubscription(subscription.id);
                            
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Suscripción y recordatorios eliminados'),
                                ),
                              );
                            }
                          }
                        },
                        onMarkAsPaid: () async {
                          // Toggle: Marcar o desmarcar como pagado
                          if (subscription.isPaidThisCycle()) {
                            // Ya está pagado → Mostrar diálogo de confirmación para desmarcar
                            final confirmed = await _showUnmarkPaidDialog(context, subscription);
                            if (confirmed == true) {
                              subscription.unmarkAsPaid();
                              await subscriptionsNotifier.updateSubscription(subscription);
                              
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('↩️ ${subscription.name} desmarcado como pagado'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                            }
                          } else {
                            // No está pagado → Mostrar diálogo de confirmación para marcar
                            final confirmed = await _showMarkPaidDialog(context, subscription);
                            if (confirmed == true) {
                              subscription.markAsPaid();
                              await subscriptionsNotifier.updateSubscription(subscription);
                              
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('✅ ${subscription.name} marcado como pagado'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            }
                          }
                        },
                        onCancel: () async {
                          final result = await _showCancelDialog(context);
                          
                          if (result == 'archive') {
                            // Archivar: cambiar estado a cancelado
                            subscription.cancel();
                            await subscriptionsNotifier.updateSubscription(subscription);
                            
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('❌ ${subscription.name} archivada'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }
                          } else if (result == 'delete') {
                            // Eliminar permanentemente
                            await subscriptionsNotifier.deleteSubscription(subscription.id);
                            
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Suscripción eliminada permanentemente'),
                                ),
                              );
                            }
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditSubscriptionScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
    );
  }

  Future<bool?> _showDeleteDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar suscripción'),
        content: const Text('¿Estás seguro de que deseas eliminar esta suscripción?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<String?> _showCancelDialog(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar suscripción'),
        content: const Text(
          '¿Qué deseas hacer con esta suscripción?\n\n'
          '• Archivar: La suscripción se guardará como cancelada y podrás renovarla después\n'
          '• Eliminar: Se eliminará permanentemente',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Volver'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'archive'),
            child: const Text('Archivar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, 'delete'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showMarkPaidDialog(BuildContext context, Subscription subscription) {
    final currencyFormat = NumberFormat.currency(
      symbol: AppConstants.currencySymbol,
      decimalDigits: 2,
    );
    final nextBilling = subscription.getNextBillingDate();
    final previousBilling = subscription.getPreviousBillingDate(nextBilling);
    final dateFormat = DateFormat('dd/MMM/yyyy');

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 24),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Marcar como pagado',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subscription.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Monto:', currencyFormat.format(subscription.price)),
            _buildInfoRow('Periodo:', '${dateFormat.format(previousBilling)} - ${dateFormat.format(nextBilling)}'),
            _buildInfoRow('Próximo cobro:', dateFormat.format(nextBilling)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green, width: 1),
              ),
              child: const Text(
                'Se marcará este periodo como pagado y no se mostrará más el recordatorio de pago.',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Marcar como pagado'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showUnmarkPaidDialog(BuildContext context, Subscription subscription) {
    final dateFormat = DateFormat('dd/MMM/yyyy');
    final lastPayment = subscription.lastPaymentDate;

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.undo, color: Colors.orange, size: 24),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Desmarcar como pagado',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subscription.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (lastPayment != null)
              _buildInfoRow('Marcado como pagado el:', dateFormat.format(lastPayment)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange, width: 1),
              ),
              child: const Text(
                'Se desmarcará como pagado y volverá a aparecer como pendiente.',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Desmarcar'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
