# Release Notes v1.0.8 📱

## 📅 Mejora en Detección de Calendarios

### ❗ Problema Identificado
Usuarios con Samsung Calendar, Outlook u otras apps de calendario reportaban que la app no detectaba ningún calendario disponible, aunque tuvieran la app instalada.

### ✨ ¿Qué cambió?

#### 🎯 Nuevo Diálogo de Ayuda Interactivo
Cuando no se detectan calendarios, ahora aparece un diálogo completo con:

- ✅ **Explicación clara** del por qué no se detectan calendarios
- ✅ **Pasos detallados** para sincronizar cualquier app de calendario
- ✅ **Guía paso a paso** con iconos visuales
- ✅ **Botón "Reintentar"** después de seguir los pasos

#### 📱 Apps de Calendario Compatibles

SubTrack funciona con **cualquier calendario sincronizado con el sistema Android**:
- ✅ Google Calendar
- ✅ Samsung Calendar (con cuenta Samsung/Google)
- ✅ Outlook Calendar
- ✅ Cualquier calendario que sincronice con Android

#### 🔧 Cómo Funciona

**El plugin `device_calendar` solo puede acceder a calendarios registrados en el CalendarProvider de Android** (la API estándar del sistema). Apps de calendario que funcionan de forma independiente sin sincronización no serán detectadas.

**Solución**: Sincronizar el calendario con una cuenta (Google, Samsung, Microsoft, etc.)

---

## 📋 Pasos para Sincronizar (Ahora en la App)

El nuevo diálogo muestra estos pasos directamente en la app:

1. **Abre tu app de Calendario** 📅
2. **Ve a Configuración (⚙️) o Menú (☰)**
3. **Busca "Cuentas" o "Sincronización"**
4. **Agrega una cuenta:**
   - Google
   - Samsung
   - Microsoft/Outlook
5. **Activa sincronización de calendario** ✓
6. **Vuelve a SubTrack y presiona "Reintentar"**

---

## 🎨 Mejoras de UX

### Antes (v1.0.7):
```
❌ No se encontraron calendarios
   Asegúrate de tener la app de Calendario instalada
   [Recargar calendarios]
```

### Ahora (v1.0.8):
```
⚠️ No se encontraron calendarios
   SubTrack necesita un calendario sincronizado con el sistema Android

   [¿Cómo configurar?]  [Reintentar]
```

Al presionar **"¿Cómo configurar?"** se abre un diálogo completo con:
- 📘 Explicación detallada
- 🎯 6 pasos ilustrados
- 💡 Información sobre apps compatibles
- ✅ Lista de calendarios soportados
- 🔄 Botón para reintentar directamente

---

## 🔍 Por Qué Mi Samsung Calendar No Se Detecta

### Escenario Común:
```
Usuario: "Tengo Samsung Calendar instalado"
SubTrack: "No encuentro calendarios"
```

### Explicación:
Samsung Calendar (y otras apps similares) pueden funcionar en dos modos:

1. **Modo Independiente** ❌
   - Sin cuenta/sincronización
   - Base de datos privada
   - **NO detectable por SubTrack**

2. **Modo Sincronizado** ✅
   - Con cuenta Google/Samsung
   - Usa CalendarProvider de Android
   - **Detectable por SubTrack**

### Solución:
Agregar una cuenta en Samsung Calendar para activar la sincronización.

---

## 📦 Características Heredadas

### v1.0.7:
- ✅ Actualización directa desde la app
- ✅ Descarga automática de APK
- ✅ Barra de progreso visual

### v1.0.6:
- ✅ Selector manual de calendario
- ✅ Anti-bucle de notificaciones
- ✅ Mejoras en Samsung

---

## 🔐 Permisos

Los mismos que v1.0.7:
- 📅 **Calendario**: Lectura/escritura
- 🔔 **Notificaciones**: Alertas
- 🌐 **Internet**: Actualizaciones
- 📦 **Instalar Paquetes**: Actualizar APK
- 💾 **Almacenamiento**: Descargar actualizaciones

---

## 📥 Instalación

### Actualizar desde v1.0.7:
1. Abrir SubTrack
2. Ir a Configuración → Buscar actualizaciones
3. Presionar **"Actualizar Ahora"**
4. Esperar descarga (53.6 MB)
5. Instalar

### Nueva Instalación:
1. Descargar `SubTrack-v1.0.8.apk`
2. Habilitar "Instalar desde fuentes desconocidas"
3. Instalar

---

## 💡 Consejos

### Si no ves calendarios después de sincronizar:

1. **Espera unos segundos** - La sincronización puede tardar
2. **Abre tu app de calendario** - Fuerza la sincronización inicial
3. **Verifica permisos** - Asegúrate de que SubTrack tenga permiso de calendario
4. **Reinicia SubTrack** - Cierra completamente y vuelve a abrir
5. **Presiona "Reintentar"** en la pantalla de calendario

### Apps de Calendario Recomendadas:

- **Google Calendar** (Recomendado) ✅
  - Pre-instalado en la mayoría de Android
  - Excelente sincronización

- **Samsung Calendar** ✅
  - Requiere cuenta Samsung o Google
  - Diseño nativo de Samsung

- **Outlook Calendar** ✅
  - Ideal si usas Microsoft 365
  - Sincroniza con Exchange

---

## 📝 Notas Técnicas

- **Tamaño del APK**: 53.6 MB
- **Versión mínima de Android**: API 21 (Android 5.0)
- **Versión objetivo**: API 34 (Android 14)
- **Build**: 1.0.8+10
- **Plugin**: `device_calendar` 4.3.3

---

## 🙏 Agradecimientos

Gracias por reportar el problema con Samsung Calendar. Esta actualización aclara cómo funciona la detección de calendarios y proporciona una guía paso a paso para configurar cualquier app de calendario correctamente. 📱✨

---

## 🆚 Comparación Rápida

| Característica | v1.0.7 | v1.0.8 |
|---------------|--------|--------|
| Detectar calendarios | ✅ | ✅ |
| Mensaje de ayuda | ❌ | ✅ |
| Guía paso a paso | ❌ | ✅ |
| Explicación técnica | ❌ | ✅ |
| Botones mejorados | ❌ | ✅ |
| Diálogo interactivo | ❌ | ✅ |

---

**¿Tienes preguntas?** El nuevo diálogo de ayuda en la app explica todo detalladamente. 🎯
