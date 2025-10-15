# 🔧 SubTrack v1.0.8 - Herramientas de Diagnóstico

## 🆕 Nuevas Funcionalidades

### 📊 Sistema de Diagnóstico de Calendarios
- **Nuevo botón de Diagnóstico Técnico**: Cuando no se detectan calendarios, ahora puedes acceder a información técnica detallada
- **Información de diagnóstico completa**:
  - Estado de permisos (READ_CALENDAR, WRITE_CALENDAR)
  - Resultado de la API `retrieveCalendars()`
  - Número de calendarios encontrados (raw y filtrados)
  - Detalles de cada calendario (ID, nombre, cuenta, tipo, isReadOnly, isDefault)
- **Copiar al portapapeles**: Facilita compartir información técnica para soporte

### 📝 Logging Mejorado
- Logs detallados en consola para diagnóstico de problemas de calendario
- Trazabilidad completa del flujo de permisos y detección de calendarios

### 📚 Documentación
- Nuevo archivo `EXPLICACION_CALENDARIOS.md` explicando cómo funciona la detección de calendarios en Android

## ✨ Mejoras de UX

### 🔕 Interfaz Más Limpia
- **Eliminados todos los toast/snackbar de éxito**: La app ya no muestra notificaciones para acciones completadas correctamente
- **Solo se muestran warnings y errores**: Notificaciones únicamente cuando algo requiere atención del usuario
- Ejemplos de lo eliminado:
  - ✅ "Sincronización completa"
  - ✅ "Calendario cambiado correctamente"
  - ✅ "Recordatorios eliminados"
  - ✅ "Instalación iniciada"
  - ✅ "Todo al día"
- Se conservan:
  - ⚠️ Warnings (errores parciales)
  - ❌ Errores críticos

## 🐛 Correcciones

- **Fix**: Corregido acceso a propiedad `errorMessages` inexistente en tipo `Result<T>` del plugin device_calendar
- **Fix**: Eliminadas referencias a APIs deprecadas del plugin

## 🎯 Objetivo de esta Versión

Esta versión está diseñada específicamente para **diagnosticar problemas de detección de calendarios**. Si tu dispositivo no detecta calendarios:

1. Ve a la pantalla de Calendario
2. Presiona **"Diagnóstico Técnico"**
3. Revisa la información mostrada
4. Si necesitas ayuda, copia el diagnóstico y compártelo

## 📦 Instalación

Descarga el APK `SubTrack-v1.0.8.apk` e instálalo en tu dispositivo Android.

## ⚙️ Requisitos

- Android 7.0 (API 24) o superior
- Permisos de calendario
- Calendario sincronizado con una cuenta (Google, Samsung, etc.)

---

**Versión anterior**: [v1.0.7](https://github.com/NRVH/app_streaming_costos/releases/tag/v1.0.7)
