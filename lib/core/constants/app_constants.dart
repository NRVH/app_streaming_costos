/// Constantes de la aplicación
class AppConstants {
  AppConstants._();

  /// Nombre de la aplicación
  static const String appName = 'SubTrack';

  /// Versión de la aplicación
  static const String appVersion = '1.0.7';

  /// Nombre de la base de datos Hive
  static const String hiveBoxSubscriptions = 'subscriptions';
  static const String hiveBoxSettings = 'settings';

  /// Configuración de moneda
  static const String defaultCurrency = 'MXN';
  static const String currencySymbol = '\$';

  /// Días de anticipación para recordatorios
  static const int reminderDaysBefore = 1;

  /// Categorías de suscripciones predefinidas
  static const List<String> categories = [
    'Streaming de Video',
    'Streaming de Música',
    'Cloud Storage',
    'Productividad',
    'Gaming',
    'Fitness',
    'Educación',
    'Noticias',
    'Otros',
  ];

  /// Servicios populares predefinidos
  static const Map<String, String> popularServices = {
    'Netflix': 'Streaming de Video',
    'Disney+': 'Streaming de Video',
    'HBO Max': 'Streaming de Video',
    'Prime Video': 'Streaming de Video',
    'Apple TV+': 'Streaming de Video',
    'Spotify': 'Streaming de Música',
    'Apple Music': 'Streaming de Música',
    'YouTube Music': 'Streaming de Música',
    'YouTube Premium': 'Streaming de Video',
    'Crunchyroll': 'Streaming de Video',
    'iCloud': 'Cloud Storage',
    'Google One': 'Cloud Storage',
    'Dropbox': 'Cloud Storage',
    'OneDrive': 'Cloud Storage',
    'Xbox Game Pass': 'Gaming',
    'PlayStation Plus': 'Gaming',
    'Nintendo Switch Online': 'Gaming',
  };

  /// Colores predefinidos para las suscripciones
  static const Map<String, int> serviceColors = {
    'Netflix': 0xFFE50914,
    'Disney+': 0xFF113CCF,
    'HBO Max': 0xFF7D1B90,
    'Prime Video': 0xFF00A8E1,
    'Apple TV+': 0xFF000000,
    'Spotify': 0xFF1DB954,
    'Apple Music': 0xFFFA243C,
    'YouTube Music': 0xFFFF0000,
    'YouTube Premium': 0xFFFF0000,
    'Crunchyroll': 0xFFF47521,
    'iCloud': 0xFF3693F3,
    'Google One': 0xFF4285F4,
    'Dropbox': 0xFF0061FF,
    'OneDrive': 0xFF0078D4,
    'Xbox Game Pass': 0xFF107C10,
    'PlayStation Plus': 0xFF003087,
    'Nintendo Switch Online': 0xFFE60012,
  };
}
