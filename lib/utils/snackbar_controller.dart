import 'package:flutter/material.dart';

/// Controlador para gestionar SnackBars y evitar duplicados/bucles
class SnackBarController {
  static final Map<String, DateTime> _lastShownMessages = {};
  static const Duration _cooldownDuration = Duration(seconds: 3);
  
  /// Muestra un SnackBar solo si no se ha mostrado recientemente el mismo mensaje
  static void showSnackBar(
    BuildContext context, {
    required String message,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
    bool force = false,
  }) {
    if (!context.mounted) return;

    // Si no es forzado, verificar si ya se mostró recientemente
    if (!force) {
      final lastShown = _lastShownMessages[message];
      if (lastShown != null) {
        final timeSinceLastShown = DateTime.now().difference(lastShown);
        if (timeSinceLastShown < _cooldownDuration) {
          print('⚠️ SnackBar bloqueado (mostrado hace ${timeSinceLastShown.inSeconds}s): $message');
          return;
        }
      }
    }

    // Registrar que se mostró este mensaje
    _lastShownMessages[message] = DateTime.now();

    // Limpiar mensajes antiguos del caché
    _cleanOldMessages();

    // Mostrar el SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Muestra un SnackBar de éxito
  static void showSuccess(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    showSnackBar(
      context,
      message: message,
      backgroundColor: Colors.green,
      duration: duration,
    );
  }

  /// Muestra un SnackBar de error
  static void showError(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    showSnackBar(
      context,
      message: message,
      backgroundColor: Colors.red,
      duration: duration,
      action: action,
    );
  }

  /// Muestra un SnackBar de advertencia
  static void showWarning(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    showSnackBar(
      context,
      message: message,
      backgroundColor: Colors.orange,
      duration: duration,
      action: action,
    );
  }

  /// Muestra un SnackBar de información
  static void showInfo(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    showSnackBar(
      context,
      message: message,
      backgroundColor: Colors.blue,
      duration: duration,
    );
  }

  /// Limpia mensajes antiguos del caché (mantener solo últimos 5 minutos)
  static void _cleanOldMessages() {
    final now = DateTime.now();
    _lastShownMessages.removeWhere((message, lastShown) {
      return now.difference(lastShown) > const Duration(minutes: 5);
    });
  }

  /// Limpia todo el historial de mensajes
  static void clearHistory() {
    _lastShownMessages.clear();
  }

  /// Fuerza ocultar cualquier SnackBar visible
  static void hide(BuildContext context) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
  }
}
