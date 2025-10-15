# Release Notes v1.0.6 🎉

## 📅 Mejoras en el Sistema de Calendario

### ✨ Nuevas Características

#### 🎯 Selector Manual de Calendario
- Implementado **CalendarSelectorDialog** para selección manual de calendarios
- Mejora significativa en la detección de calendarios en dispositivos Samsung
- Interfaz intuitiva que muestra:
  - Nombre del calendario
  - Cuenta asociada
  - Color identificador
  - Indicador de calendario por defecto

#### 🛡️ Sistema de Control de Notificaciones
- Nuevo **SnackBarController** para prevenir mensajes duplicados
- Sistema de cooldown de 3 segundos entre mensajes similares
- **Solución al problema de bucle infinito** de notificaciones toast verdes

### 🔧 Mejoras Técnicas

#### Validación y Manejo de Errores
- Validación robusta antes de sincronizar recordatorios
- Contador detallado de suscripciones procesadas
- Mensajes de error más descriptivos y accionables
- Manejo apropiado de casos sin calendario seleccionado

#### Sincronización de Recordatorios
- Verificación de permisos mejorada
- Validación de calendario antes de crear recordatorios
- Estadísticas en tiempo real (recordatorios creados/actualizados)
- Prevención de sincronizaciones innecesarias

### 🐛 Correcciones de Errores

- ✅ Corregido bucle infinito de mensajes toast
- ✅ Mejorada detección de calendarios en Samsung
- ✅ Eliminados mensajes duplicados durante sincronización
- ✅ Mejor manejo cuando no hay calendario disponible

### 📱 Experiencia de Usuario

- Mensajes más claros y concisos
- Feedback inmediato de acciones realizadas
- Prompts accionables cuando falta configuración
- Interfaz más intuitiva para gestión de calendarios

---

## 🔄 Sistema de Actualización

El sistema de actualización automática sigue funcionando perfectamente:
- ✅ Detección automática de nuevas versiones
- ✅ Descarga directa desde GitHub
- ✅ Verificación de integridad del APK
- ✅ Notificaciones de actualizaciones disponibles

---

## 📦 Instalación

### Nueva Instalación
1. Descarga `SubTrack-v1.0.6.apk`
2. Habilita "Instalar desde fuentes desconocidas"
3. Instala el APK

### Actualización desde versión anterior
La app detectará automáticamente la actualización disponible y te permitirá descargarla directamente.

---

## 🔐 Permisos Requeridos

- 📅 **Calendario**: Para crear y gestionar recordatorios de suscripciones
- 🔔 **Notificaciones**: Para alertas de próximos pagos
- 📥 **Almacenamiento**: Para descarga de actualizaciones

---

## 🙏 Agradecimientos

Gracias a todos los usuarios que reportaron los problemas con la detección de calendario en dispositivos Samsung y el bucle de notificaciones. Sus reportes fueron fundamentales para mejorar la experiencia de todos.

---

## 📝 Notas Técnicas

- **Tamaño del APK**: 53.1 MB
- **Versión mínima de Android**: API 21 (Android 5.0)
- **Versión objetivo**: API 34 (Android 14)
- **Build**: 1.0.6+8
