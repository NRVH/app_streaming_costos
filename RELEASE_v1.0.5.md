# 🎨 Release v1.0.5 - Selector de Colores Mejorado

## Fecha de Lanzamiento
14 de octubre de 2025

## 🆕 Nuevas Características

### Selector de Paletas de Colores
- **6 esquemas de colores predefinidos** con nombres atractivos:
  - 🌸 **Sakura Pink** - Rosa elegante inspirado en flores de cerezo
  - 🌊 **Ocean Blue** - Azul profundo como el océano
  - 🌲 **Forest Green** - Verde natural del bosque
  - 🌅 **Sunset Orange** - Naranja cálido del atardecer
  - 💜 **Lavender Dream** - Lavanda relajante
  - 🍃 **Mint Fresh** - Verde menta fresco

### Visualización Mejorada
- **Vista previa de 3 tonos** para cada paleta de colores
- Círculos de color mostrando: primario, secundario y terciario
- Diseño en cuadrícula de 3 columnas para fácil selección
- Indicador visual del esquema actualmente seleccionado

## 🗑️ Características Removidas

### Modo AMOLED
- Eliminado el modo AMOLED completamente de la aplicación
- Simplificación de opciones de personalización
- El modo oscuro estándar ofrece excelente experiencia

### Vista Previa en Configuración
- Removida la tarjeta de vista previa de suscripción
- La configuración de tema es más compacta y enfocada

## 🐛 Correcciones de Errores

### Compatibilidad de Datos
- **Fix crítico**: Adaptador Hive con compatibilidad hacia atrás
- Solución para migración de datos antiguos (modo AMOLED → paletas de colores)
- Valor por defecto (Sakura Pink) para datos sin migrar
- Prevención de crashes por tipos null

### Versión de la Aplicación
- Corregida versión mostrada en Configuración (ahora 1.0.5)
- Sincronización entre `pubspec.yaml` y `app_constants.dart`

## 🔧 Mejoras Técnicas

### Arquitectura
- Nuevo enum `AppColorScheme` con TypeAdapter Hive (typeId: 5)
- Método `getColorSchemeName()` para nombres localizados
- Simplificación del provider de temas (eliminación de `setAmoledMode`)
- Nuevo método `setColorScheme()` para cambio de paletas

### Código
- Refactorización de `theme_settings_screen.dart` (771 líneas)
- Widget `_buildColorOption()` para opciones de color reutilizables
- Limpieza de parámetros obsoletos en `app_theme.dart`
- Actualización de `main.dart` con conversión de enums

## 📦 Información de Build

- **Versión**: 1.0.5
- **Build Number**: 7
- **Flutter SDK**: Compatible con últimas versiones
- **Plataformas**: Android (APK disponible)

## 🚀 Cómo Actualizar

### Desde la Aplicación
1. Abre **SubTrack**
2. Ve a **Configuración → Buscar actualizaciones**
3. Descarga e instala la versión 1.0.5

### Instalación Manual
1. Descarga el APK desde los assets del release
2. Desinstala la versión anterior (opcional, no perderás datos)
3. Instala el nuevo APK

## ⚠️ Notas Importantes

- **Migración automática**: Los usuarios con modo AMOLED verán el esquema Sakura Pink por defecto
- **Sin pérdida de datos**: Todas las suscripciones y configuraciones se mantienen
- **Compatibilidad**: Requiere Android 5.0 (API 21) o superior

## 🎯 Próximas Características

- Exportación de datos
- Más opciones de personalización de colores
- Soporte para tablets y modo horizontal
- Widgets de pantalla principal

## 🙏 Agradecimientos

Gracias a todos los usuarios por su feedback y sugerencias. Esta versión refleja las peticiones de simplificar la experiencia de personalización.

---

**Descargar**: [SubTrack v1.0.5 APK](../../releases/download/v1.0.5/SubTrack-v1.0.5.apk)

**Código fuente**: [GitHub](https://github.com/NRVH/app_streaming_costos)
