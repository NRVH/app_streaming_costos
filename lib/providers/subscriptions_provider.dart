import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/subscription_model.dart';
import '../services/database_service.dart';

/// Provider para las suscripciones
final subscriptionsProvider = StateNotifierProvider<SubscriptionsNotifier, List<Subscription>>((ref) {
  return SubscriptionsNotifier();
});

/// Notifier para gestionar las suscripciones
class SubscriptionsNotifier extends StateNotifier<List<Subscription>> {
  SubscriptionsNotifier() : super([]) {
    _loadSubscriptions();
  }

  final Box<Subscription> _box = DatabaseService.getSubscriptionsBox();

  /// Carga las suscripciones desde la base de datos
  void _loadSubscriptions() {
    state = _box.values.toList();
  }

  /// Agrega una nueva suscripción
  Future<void> addSubscription(Subscription subscription) async {
    await _box.put(subscription.id, subscription);
    _loadSubscriptions();
  }

  /// Actualiza una suscripción existente
  Future<void> updateSubscription(Subscription subscription) async {
    await _box.put(subscription.id, subscription);
    _loadSubscriptions();
  }

  /// Elimina una suscripción
  Future<void> deleteSubscription(String id) async {
    await _box.delete(id);
    _loadSubscriptions();
  }

  /// Obtiene una suscripción por ID
  Subscription? getSubscriptionById(String id) {
    return _box.get(id);
  }

  /// Obtiene el total mensual de todas las suscripciones
  double getTotalMonthlyCost() {
    return state.fold(0.0, (sum, sub) => sum + sub.getMonthlyCost());
  }

  /// Obtiene las suscripciones ordenadas por próximo cobro
  List<Subscription> getSubscriptionsByNextBilling() {
    final subs = List<Subscription>.from(state);
    subs.sort((a, b) => a.getNextBillingDate().compareTo(b.getNextBillingDate()));
    return subs;
  }

  /// Obtiene las suscripciones agrupadas por categoría
  Map<String, List<Subscription>> getSubscriptionsByCategory() {
    final Map<String, List<Subscription>> grouped = {};
    
    for (final sub in state) {
      if (!grouped.containsKey(sub.category)) {
        grouped[sub.category] = [];
      }
      grouped[sub.category]!.add(sub);
    }
    
    return grouped;
  }

  /// Obtiene el gasto total por categoría
  Map<String, double> getTotalByCategory() {
    final Map<String, double> totals = {};
    
    for (final sub in state) {
      totals[sub.category] = (totals[sub.category] ?? 0.0) + sub.getMonthlyCost();
    }
    
    return totals;
  }

  /// Obtiene las suscripciones que vencen pronto (próximos 7 días)
  List<Subscription> getUpcomingSubscriptions() {
    final now = DateTime.now();
    return state.where((sub) {
      final daysUntil = sub.getDaysUntilNextBilling();
      return daysUntil >= 0 && daysUntil <= 7;
    }).toList()
      ..sort((a, b) => a.getNextBillingDate().compareTo(b.getNextBillingDate()));
  }
}
