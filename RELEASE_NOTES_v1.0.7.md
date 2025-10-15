# Release Notes v1.0.7 🚀

## 📲 Sistema de Actualización Mejorado

### ✨ Nueva Característica Principal

#### 🎯 Actualización Directa desde la App
- **¡YA NO NECESITAS IR A GITHUB!** 🎉
- Botón **"Actualizar Ahora"** en el diálogo de actualización
- Descarga automática del APK directamente desde la app
- Barra de progreso en tiempo real con porcentaje y MB descargados
- Instalador de Android se abre automáticamente al finalizar

### 🔧 Flujo de Actualización Mejorado

#### Antes (v1.0.6):
1. App detectaba actualización
2. Mostraba botón "Ver en GitHub" ❌
3. Tenías que:
   - Abrir navegador
   - Ir a GitHub
   - Buscar el release
   - Descargar manualmente el APK
   - Instalar desde archivos

#### Ahora (v1.0.7):
1. App detecta actualización ✅
2. Muestra botón **"Actualizar Ahora"** 🎯
3. Un solo clic:
   - ✅ Descarga automática (con progreso visual)
   - ✅ Instalador se abre automáticamente
   - ✅ Tus datos se conservan intactos

### 📱 Experiencia de Usuario

#### Durante la Descarga:
- 📊 Barra de progreso visual
- 📈 Porcentaje de descarga (0% a 100%)
- 💾 MB descargados / MB totales
- 🔄 Estado actual: "Preparando...", "Descargando...", "Abriendo instalador..."
- ❌ Opción de cancelar descarga

#### Seguridad y Privacidad:
- ✅ Tus suscripciones se mantienen intactas
- ✅ Configuraciones preservadas
- ✅ Calendarios sincronizados
- ✅ Descarga desde GitHub oficial
- ✅ Sin servidores intermediarios

### 🛠️ Aspectos Técnicos

#### Nuevas Dependencias:
- **Dio**: Descarga de archivos con progreso
- **Path Provider**: Gestión de rutas de almacenamiento
- **Open File**: Apertura automática del instalador
- **Permission Handler**: Gestión de permisos de instalación

#### Nuevos Permisos Android:
- `REQUEST_INSTALL_PACKAGES`: Necesario para abrir el instalador
- Almacenamiento (solo para descargar el APK)

#### Nuevo Servicio:
- `ApkInstallerService`: Gestiona todo el proceso de descarga e instalación

---

## 🔄 Características Heredadas de v1.0.6

### 📅 Sistema de Calendario Mejorado
- Selector manual de calendario (CalendarSelectorDialog)
- Mejora en detección en dispositivos Samsung
- Sistema de control de notificaciones (SnackBarController)
- **Solución al bucle infinito de toast** ✅

---

## 📦 Instalación

### Si vienes de v1.0.6:
1. La app detectará automáticamente esta actualización
2. Presiona **"Actualizar Ahora"**
3. Espera la descarga (53.6 MB)
4. El instalador se abrirá automáticamente
5. Presiona "Instalar"
6. ¡Listo! 🎉

### Nueva Instalación:
1. Descarga `SubTrack-v1.0.7.apk`
2. Habilita "Instalar desde fuentes desconocidas"
3. Instala el APK

---

## 🔐 Permisos

### Nuevos Permisos en v1.0.7:
- 📦 **Instalar Paquetes**: Para abrir el instalador automáticamente
- 💾 **Almacenamiento**: Para guardar el APK descargado temporalmente

### Permisos Existentes:
- 📅 **Calendario**: Para recordatorios de suscripciones
- 🔔 **Notificaciones**: Para alertas de próximos pagos
- 🌐 **Internet**: Para verificar y descargar actualizaciones

---

## 🎯 Comparación de Versiones

| Característica | v1.0.6 | v1.0.7 |
|---------------|--------|--------|
| Detectar actualización | ✅ | ✅ |
| Descarga directa | ❌ | ✅ |
| Progreso visual | ❌ | ✅ |
| Abrir instalador | ❌ | ✅ |
| Selector de calendario | ✅ | ✅ |
| Anti-bucle toast | ✅ | ✅ |

---

## 💡 Preguntas Frecuentes

**P: ¿Perderé mis datos al actualizar?**
R: No, todas tus suscripciones y configuraciones se mantienen intactas.

**P: ¿Por qué necesita permisos de instalación?**
R: Para poder abrir automáticamente el instalador de Android después de descargar el APK.

**P: ¿Puedo cancelar la descarga?**
R: Sí, hay un botón "Cancelar" mientras se descarga.

**P: ¿Cuánto pesa la actualización?**
R: Aproximadamente 53.6 MB.

**P: ¿Es seguro descargar desde la app?**
R: Sí, la app descarga directamente desde los releases oficiales de GitHub.

---

## 🙏 Agradecimientos

Gracias por tu feedback sobre el sistema de actualizaciones. Esta nueva versión hace el proceso mucho más simple y directo. ¡Ya no necesitas salir de la app para actualizar! 🎉

---

## 📝 Notas Técnicas

- **Tamaño del APK**: 53.6 MB
- **Versión mínima de Android**: API 21 (Android 5.0)
- **Versión objetivo**: API 34 (Android 14)
- **Build**: 1.0.7+9
- **Arquitectura**: ARM64-v8a, ARMv7, x86_64
