import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

/// Modelo para información de una release de GitHub
class GithubRelease {
  final String tagName;
  final String name;
  final String body;
  final String htmlUrl;
  final String publishedAt;
  final bool prerelease;
  final List<ReleaseAsset> assets;

  GithubRelease({
    required this.tagName,
    required this.name,
    required this.body,
    required this.htmlUrl,
    required this.publishedAt,
    required this.prerelease,
    required this.assets,
  });

  factory GithubRelease.fromJson(Map<String, dynamic> json) {
    return GithubRelease(
      tagName: json['tag_name'] ?? '',
      name: json['name'] ?? '',
      body: json['body'] ?? '',
      htmlUrl: json['html_url'] ?? '',
      publishedAt: json['published_at'] ?? '',
      prerelease: json['prerelease'] ?? false,
      assets: (json['assets'] as List?)
              ?.map((asset) => ReleaseAsset.fromJson(asset))
              .toList() ??
          [],
    );
  }

  /// Obtiene la versión limpia (sin 'v' al inicio)
  String get version {
    return tagName.startsWith('v') ? tagName.substring(1) : tagName;
  }
}

/// Modelo para un asset (archivo) de una release
class ReleaseAsset {
  final String name;
  final String browserDownloadUrl;
  final int size;

  ReleaseAsset({
    required this.name,
    required this.browserDownloadUrl,
    required this.size,
  });

  factory ReleaseAsset.fromJson(Map<String, dynamic> json) {
    return ReleaseAsset(
      name: json['name'] ?? '',
      browserDownloadUrl: json['browser_download_url'] ?? '',
      size: json['size'] ?? 0,
    );
  }
}

/// Servicio para verificar actualizaciones desde GitHub Releases
class UpdateService {
  static const String _owner = 'NRVH';
  static const String _repo = 'app_streaming_costos';
  static const String _apiUrl =
      'https://api.github.com/repos/$_owner/$_repo/releases/latest';

  /// Obtiene la información del paquete actual
  Future<PackageInfo> getCurrentPackageInfo() async {
    return await PackageInfo.fromPlatform();
  }

  /// Obtiene la versión actual de la app
  Future<String> getCurrentVersion() async {
    final packageInfo = await getCurrentPackageInfo();
    return packageInfo.version;
  }

  /// Obtiene el número de build actual
  Future<String> getCurrentBuildNumber() async {
    final packageInfo = await getCurrentPackageInfo();
    return packageInfo.buildNumber;
  }

  /// Verifica si hay una actualización disponible
  Future<GithubRelease?> checkForUpdate() async {
    try {
      print('🔍 Verificando actualizaciones en: $_apiUrl');
      
      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
        },
      ).timeout(
        const Duration(seconds: 10),
      );

      print('📡 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final release = GithubRelease.fromJson(json);

        print('📦 Release encontrada: ${release.tagName}');
        print('🔖 Version release: ${release.version}');

        // No mostrar pre-releases
        if (release.prerelease) {
          print('⚠️ Es pre-release, ignorando');
          return null;
        }

        // Comparar versiones
        final currentVersion = await getCurrentVersion();
        print('📱 Versión actual: $currentVersion');
        
        final isNewer = _isNewerVersion(release.version, currentVersion);
        print('🔄 ¿Es más nueva? $isNewer');
        
        if (isNewer) {
          print('✅ Actualización disponible: $currentVersion → ${release.version}');
          return release;
        } else {
          print('✅ Ya tienes la última versión');
        }
      } else {
        print('❌ Error HTTP: ${response.statusCode}');
      }

      return null;
    } catch (e) {
      print('❌ Error al verificar actualizaciones: $e');
      return null;
    }
  }

  /// Compara dos versiones en formato semver (1.0.0)
  /// Retorna true si newVersion es más nueva que currentVersion
  bool _isNewerVersion(String newVersion, String currentVersion) {
    final newParts = newVersion.split('.').map(int.tryParse).toList();
    final currentParts = currentVersion.split('.').map(int.tryParse).toList();

    // Asegurar que tenemos 3 partes (major.minor.patch)
    while (newParts.length < 3) {
      newParts.add(0);
    }
    while (currentParts.length < 3) {
      currentParts.add(0);
    }

    // Comparar major version
    if ((newParts[0] ?? 0) > (currentParts[0] ?? 0)) return true;
    if ((newParts[0] ?? 0) < (currentParts[0] ?? 0)) return false;

    // Comparar minor version
    if ((newParts[1] ?? 0) > (currentParts[1] ?? 0)) return true;
    if ((newParts[1] ?? 0) < (currentParts[1] ?? 0)) return false;

    // Comparar patch version
    if ((newParts[2] ?? 0) > (currentParts[2] ?? 0)) return true;

    return false;
  }

  /// Obtiene el APK de Android de la release (si existe)
  String? getAndroidApkUrl(GithubRelease release) {
    try {
      final apkAsset = release.assets.firstWhere(
        (asset) =>
            asset.name.toLowerCase().endsWith('.apk') &&
            !asset.name.toLowerCase().contains('unaligned'),
      );
      return apkAsset.browserDownloadUrl;
    } catch (e) {
      return null;
    }
  }

  /// Obtiene el IPA de iOS de la release (si existe)
  String? getIosIpaUrl(GithubRelease release) {
    try {
      final ipaAsset = release.assets.firstWhere(
        (asset) => asset.name.toLowerCase().endsWith('.ipa'),
      );
      return ipaAsset.browserDownloadUrl;
    } catch (e) {
      return null;
    }
  }

  /// Formatea las notas de la versión para mostrar
  String formatReleaseNotes(String body) {
    if (body.isEmpty) return 'Sin notas de la versión';

    // Limitar a 500 caracteres
    if (body.length > 500) {
      return '${body.substring(0, 500)}...';
    }

    return body;
  }

  /// Formatea la fecha de publicación
  String formatPublishedDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          return 'Hace ${difference.inMinutes} minutos';
        }
        return 'Hace ${difference.inHours} horas';
      } else if (difference.inDays == 1) {
        return 'Ayer';
      } else if (difference.inDays < 7) {
        return 'Hace ${difference.inDays} días';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return 'Hace $weeks ${weeks == 1 ? "semana" : "semanas"}';
      } else {
        final months = (difference.inDays / 30).floor();
        return 'Hace $months ${months == 1 ? "mes" : "meses"}';
      }
    } catch (e) {
      return isoDate;
    }
  }
}
