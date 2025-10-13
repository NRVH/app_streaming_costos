import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/subscription_model.dart';
import '../providers/subscriptions_provider.dart';
import '../core/constants/app_constants.dart';
import '../widgets/empty_state_widget.dart';
import 'add_edit_subscription_screen.dart';

class ArchivedSubscriptionsScreen extends ConsumerWidget {
  const ArchivedSubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allSubscriptions = ref.watch(subscriptionsProvider);
    final archivedSubscriptions = allSubscriptions.where((s) => s.isCanceled).toList();
    final subscriptionsNotifier = ref.read(subscriptionsProvider.notifier);
    
    final currencyFormat = NumberFormat.currency(
      symbol: AppConstants.currencySymbol,
      decimalDigits: 2,
    );
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suscripciones Archivadas'),
      ),
      body: archivedSubscriptions.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.archive_outlined,
              title: 'No hay suscripciones archivadas',
              message: 'Las suscripciones canceladas\naparecerán aquí',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: archivedSubscriptions.length,
              itemBuilder: (context, index) {
                final subscription = archivedSubscriptions[index];
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Icono/Color (con opacidad)
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Color(subscription.colorValue).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.subscriptions,
                            color: Color(subscription.colorValue).withOpacity(0.5),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Información
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      subscription.name,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            decoration: TextDecoration.lineThrough,
                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                          ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.red, width: 1),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.block, size: 14, color: Colors.red),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Cancelada',
                                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                color: Colors.red,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${subscription.currency} ${subscription.price.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Cada ${subscription.billingCycle.displayName.toLowerCase()}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Acciones
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Botón Renovar
                            FilledButton.tonalIcon(
                              onPressed: () async {
                                final result = await _showRenewDialog(context);
                                
                                if (result != null && result > 0) {
                                  final newEndDate = DateTime.now().add(Duration(days: result * 30));
                                  subscription.renew(newEndDate: newEndDate);
                                  await subscriptionsNotifier.updateSubscription(subscription);
                                  
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('✅ ${subscription.name} renovada por $result meses'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                }
                              },
                              icon: const Icon(Icons.replay, size: 18),
                              label: const Text('Renovar', style: TextStyle(fontSize: 12)),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Botón Eliminar permanentemente
                            TextButton.icon(
                              onPressed: () async {
                                final confirmed = await _showDeleteDialog(context);
                                if (confirmed == true) {
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
                              icon: const Icon(Icons.delete_forever, size: 18),
                              label: const Text('Eliminar', style: TextStyle(fontSize: 12)),
                              style: TextButton.styleFrom(
                                foregroundColor: Theme.of(context).colorScheme.error,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<int?> _showRenewDialog(BuildContext context) {
    int? selectedMonths;
    
    return showDialog<int>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Renovar suscripción'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('¿Por cuánto tiempo deseas renovar esta suscripción?'),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Duración',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedMonths,
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('1 mes')),
                    DropdownMenuItem(value: 3, child: Text('3 meses')),
                    DropdownMenuItem(value: 6, child: Text('6 meses')),
                    DropdownMenuItem(value: 12, child: Text('1 año')),
                    DropdownMenuItem(value: 24, child: Text('2 años')),
                    DropdownMenuItem(value: -1, child: Text('Indefinido')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedMonths = value;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: selectedMonths != null
                    ? () => Navigator.pop(context, selectedMonths == -1 ? 999 : selectedMonths)
                    : null,
                child: const Text('Renovar'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<bool?> _showDeleteDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar permanentemente'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar esta suscripción?\n\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
