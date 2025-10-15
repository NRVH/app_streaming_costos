import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Servicio para descargar e instalar APKs
class ApkInstallerService {
  final Dio _dio = Dio();
  
  /// Stream para reportar el progreso de descarga (0.0 a 1.0)
  final ValueNotifier<double> downloadProgress = ValueNotifier(0.0);
  
  /// Estado actual de la descarga
  final ValueNotifier<DownloadState> downloadState = 
      ValueNotifier(DownloadState.idle);
  
  /// Mensaje de estado actual
  final ValueNotifier<String> statusMessage = ValueNotifier('');

  /// Descarga e instala un APK desde una URL
  Future<bool> downloadAndInstallApk(String url, String fileName) async {
    try {
      // Verificar y solicitar permiso para instalar paquetes (Android 8.0+)
      if (Platform.isAndroid) {
        final status = await Permission.requestInstallPackages.status;
        if (!status.isGranted) {
          statusMessage.value = 'Solicitando permiso de instalación...';
          final result = await Permission.requestInstallPackages.request();
          if (!result.isGranted) {
            statusMessage.value = 'Permiso de instalación denegado';
            downloadState.value = DownloadState.error;
            return false;
          }
        }
      }
      
      downloadState.value = DownloadState.downloading;
      statusMessage.value = 'Preparando descarga...';
      downloadProgress.value = 0.0;

      // Obtener directorio de descargas
      final Directory? downloadDir = await getExternalStorageDirectory();
      if (downloadDir == null) {
        throw Exception('No se pudo acceder al directorio de descargas');
      }

      // Crear ruta completa del archivo
      final String filePath = '${downloadDir.path}/$fileName';
      
      // Eliminar archivo anterior si existe
      final File file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }

      statusMessage.value = 'Descargando actualización...';

      // Descargar el archivo con seguimiento de progreso
      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            downloadProgress.value = progress;
            
            // Calcular MB descargados
            final receivedMB = (received / 1024 / 1024).toStringAsFixed(1);
            final totalMB = (total / 1024 / 1024).toStringAsFixed(1);
            final percentage = (progress * 100).toStringAsFixed(0);
            
            statusMessage.value = 
                'Descargando: $receivedMB MB / $totalMB MB ($percentage%)';
          }
        },
      );

      downloadState.value = DownloadState.installing;
      statusMessage.value = 'Abriendo instalador...';
      
      // Abrir el APK para instalación
      final result = await OpenFile.open(filePath);
      
      if (result.type == ResultType.done) {
        downloadState.value = DownloadState.completed;
        statusMessage.value = '¡Instalación iniciada!';
        return true;
      } else {
        throw Exception('Error al abrir el instalador: ${result.message}');
      }
    } catch (e) {
      downloadState.value = DownloadState.error;
      statusMessage.value = 'Error: ${e.toString()}';
      print('❌ Error al descargar/instalar APK: $e');
      return false;
    }
  }

  /// Cancela la descarga actual
  void cancelDownload() {
    _dio.close(force: true);
    downloadState.value = DownloadState.idle;
    statusMessage.value = 'Descarga cancelada';
    downloadProgress.value = 0.0;
  }

  /// Limpia los recursos
  void dispose() {
    downloadProgress.dispose();
    downloadState.dispose();
    statusMessage.dispose();
  }
}

/// Estados de descarga
enum DownloadState {
  idle,
  downloading,
  installing,
  completed,
  error,
}
