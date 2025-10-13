import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/subscriptions_provider.dart';
import '../core/constants/app_constants.dart';
import '../widgets/empty_state_widget.dart';

class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptions = ref.watch(subscriptionsProvider);
    final subscriptionsNotifier = ref.read(subscriptionsProvider.notifier);
    
    if (subscriptions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Resumen'),
        ),
        body: const EmptyStateWidget(
          icon: Icons.assessment_outlined,
          title: 'Sin datos',
          message: 'Agrega suscripciones para ver tu resumen',
        ),
      );
    }

    final totalMonthlyCost = subscriptionsNotifier.getTotalMonthlyCost();
    final upcomingSubscriptions = subscriptionsNotifier.getUpcomingSubscriptions();
    final categoryTotals = subscriptionsNotifier.getTotalByCategory();
    
    final currencyFormat = NumberFormat.currency(
      symbol: AppConstants.currencySymbol,
      decimalDigits: 2,
    );
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Resumen general
          _buildSummaryCard(
            context,
            title: 'Este Mes',
            amount: currencyFormat.format(totalMonthlyCost),
            subtitle: '${subscriptions.length} ${subscriptions.length == 1 ? 'suscripción activa' : 'suscripciones activas'}',
            icon: Icons.calendar_month,
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primaryContainer,
                Theme.of(context).colorScheme.secondaryContainer,
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Proyección anual
          _buildSummaryCard(
            context,
            title: 'Proyección Anual',
            amount: currencyFormat.format(totalMonthlyCost * 12),
            subtitle: 'Si mantienes tus suscripciones actuales',
            icon: Icons.trending_up,
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.tertiaryContainer,
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Próximos pagos
          if (upcomingSubscriptions.isNotEmpty) ...[
            Text(
              'Próximos Pagos (7 días)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...upcomingSubscriptions.map((sub) {
              final daysUntil = sub.getDaysUntilNextBilling();
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Color(sub.colorValue).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.subscriptions,
                      color: Color(sub.colorValue),
                    ),
                  ),
                  title: Text(sub.name),
                  subtitle: Text(
                    '${dateFormat.format(sub.getNextBillingDate())} • $daysUntil ${daysUntil == 1 ? 'día' : 'días'}',
                  ),
                  trailing: Text(
                    currencyFormat.format(sub.price),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
          ],

          // Gasto por categoría
          Text(
            'Gasto por Categoría',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: categoryTotals.entries.map((entry) {
                  final percentage = (entry.value / totalMonthlyCost * 100);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                entry.key,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                            Text(
                              currencyFormat.format(entry.value),
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Stack(
                          children: [
                            Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceVariant,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: percentage / 100,
                              child: Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${percentage.toStringAsFixed(1)}% del total',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Estadísticas adicionales
          Text(
            'Estadísticas',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  label: 'Promedio',
                  value: currencyFormat.format(
                    subscriptions.isEmpty ? 0 : totalMonthlyCost / subscriptions.length,
                  ),
                  icon: Icons.trending_flat,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  label: 'Más cara',
                  value: currencyFormat.format(
                    subscriptions.isEmpty
                        ? 0
                        : subscriptions
                            .map((s) => s.getMonthlyCost())
                            .reduce((a, b) => a > b ? a : b),
                  ),
                  icon: Icons.arrow_upward,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required String amount,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
