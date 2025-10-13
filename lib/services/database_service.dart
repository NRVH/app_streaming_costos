import 'package:hive_flutter/hive_flutter.dart';
import '../models/subscription_model.dart';

/// Servicio para gestionar la base de datos Hive
class DatabaseService {
  static const String _subscriptionsBox = 'subscriptions';
  static const String _settingsBox = 'settings';

  /// Inicializa Hive y registra los adaptadores
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Registrar adaptadores
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(SubscriptionAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(BillingCycleAdapter());
    }

    // Abrir las cajas
    await Hive.openBox<Subscription>(_subscriptionsBox);
    await Hive.openBox(_settingsBox);
  }

  /// Obtiene la caja de suscripciones
  static Box<Subscription> getSubscriptionsBox() {
    return Hive.box<Subscription>(_subscriptionsBox);
  }

  /// Obtiene la caja de configuraciones
  static Box getSettingsBox() {
    return Hive.box(_settingsBox);
  }

  /// Cierra todas las cajas
  static Future<void> close() async {
    await Hive.close();
  }
}
