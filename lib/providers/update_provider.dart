import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/update_service.dart';

/// Estado de la actualización
class UpdateState {
  final bool isChecking;
  final GithubRelease? availableUpdate;
  final String? error;
  final DateTime? lastChecked;

  const UpdateState({
    this.isChecking = false,
    this.availableUpdate,
    this.error,
    this.lastChecked,
  });

  UpdateState copyWith({
    bool? isChecking,
    GithubRelease? availableUpdate,
    String? error,
    DateTime? lastChecked,
    bool clearUpdate = false,
    bool clearError = false,
  }) {
    return UpdateState(
      isChecking: isChecking ?? this.isChecking,
      availableUpdate: clearUpdate ? null : (availableUpdate ?? this.availableUpdate),
      error: clearError ? null : (error ?? this.error),
      lastChecked: lastChecked ?? this.lastChecked,
    );
  }

  bool get hasUpdate => availableUpdate != null;
  bool get hasError => error != null;
}

/// Notifier para gestionar el estado de actualizaciones
class UpdateNotifier extends StateNotifier<UpdateState> {
  final UpdateService _updateService;

  UpdateNotifier(this._updateService) : super(const UpdateState()) {
    // Verificar actualizaciones al iniciar
    checkForUpdates();
  }

  /// Verifica si hay actualizaciones disponibles
  Future<void> checkForUpdates() async {
    if (state.isChecking) return;

    state = state.copyWith(
      isChecking: true,
      clearError: true,
    );

    try {
      final release = await _updateService.checkForUpdate();
      
      state = state.copyWith(
        isChecking: false,
        availableUpdate: release,
        lastChecked: DateTime.now(),
        clearUpdate: release == null,
      );
    } catch (e) {
      state = state.copyWith(
        isChecking: false,
        error: 'Error al verificar actualizaciones',
        lastChecked: DateTime.now(),
      );
    }
  }

  /// Descarta la actualización actual (no mostrar más el badge hasta la próxima verificación)
  void dismissUpdate() {
    state = state.copyWith(clearUpdate: true);
  }

  /// Limpia el error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Provider del servicio de actualización
final updateServiceProvider = Provider<UpdateService>((ref) {
  return UpdateService();
});

/// Provider del estado de actualización
final updateProvider = StateNotifierProvider<UpdateNotifier, UpdateState>((ref) {
  final updateService = ref.watch(updateServiceProvider);
  return UpdateNotifier(updateService);
});
