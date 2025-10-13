import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/subscription_model.dart';
import '../core/constants/app_constants.dart';

class SubscriptionCard extends StatelessWidget {
  final Subscription subscription;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback? onMarkAsPaid;
  final VoidCallback? onCancel; // Nuevo callback para cancelar

  const SubscriptionCard({
    super.key,
    required this.subscription,
    required this.onTap,
    required this.onDelete,
    this.onMarkAsPaid,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: AppConstants.currencySymbol,
      decimalDigits: 2,
    );
    
    final nextBillingDate = subscription.getNextBillingDate();
    final daysUntil = subscription.getDaysUntilNextBilling();
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icono/Color
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Color(subscription.colorValue).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.subscriptions,
                  color: Color(subscription.colorValue),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              
              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subscription.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subscription.category,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Próximo: ${dateFormat.format(nextBillingDate)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(width: 8),
                        if (daysUntil <= 3)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Pronto',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onErrorContainer,
                                  ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Precio y acciones
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currencyFormat.format(subscription.price),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  Text(
                    subscription.billingCycle.shortName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                  ),
                  const SizedBox(height: 8),
                  // Botón para marcar/desmarcar como pagado
                  if (onMarkAsPaid != null)
                    subscription.isPaidThisCycle()
                        ? // Badge "Pagado" clickeable para desmarcar
                        InkWell(
                            onTap: onMarkAsPaid,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.green, width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle, size: 14, color: Colors.green),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Pagado',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.close, size: 12, color: Colors.green.withOpacity(0.7)),
                                ],
                              ),
                            ),
                          )
                        : // Botón "Marcar como Pagado" si NO está pagado
                        FilledButton.tonalIcon(
                            onPressed: onMarkAsPaid,
                            icon: const Icon(Icons.check_circle, size: 18),
                            label: const Text('Pagado', style: TextStyle(fontSize: 12)),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botón Cancelar (solo si está activa)
                      if (subscription.isActive && onCancel != null)
                        IconButton(
                          icon: const Icon(Icons.block, size: 20),
                          onPressed: onCancel,
                          color: Colors.orange,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: 'Cancelar suscripción',
                        ),
                      if (subscription.isActive && onCancel != null)
                        const SizedBox(width: 8),
                      // Botón Eliminar
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: onDelete,
                        color: Theme.of(context).colorScheme.error,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Eliminar',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
