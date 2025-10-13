# 🧪 Guía de Prueba del Sistema de Actualizaciones

## 📱 Problema Detectado

Tu app instalada muestra **versión 1.0.0**, pero hemos creado releases hasta la **1.0.2**.

El sistema de actualizaciones solo funciona si:
1. Tienes una versión anterior instalada (ej: 1.0.0)
2. Existe una versión más nueva en GitHub (ej: 1.0.2)
3. La release está marcada como "latest" en GitHub

---

## ✅ Solución: Probar el Sistema Completo

### Paso 1: Instalar Versión Base (1.0.0)

Para probar correctamente el sistema de actualizaciones, necesitas:

1. **Usar el APK v1.0.0** (el primero que creaste)
2. **Instalarlo en tu dispositivo**
3. **Verificar que muestra "Versión 1.0.0"** en Ajustes

### Paso 2: Instalar Nueva Versión (1.0.2+3)

Una vez que compiles el nuevo APK con la versión **1.0.2+3**:

1. **Abre la app v1.0.0**
2. **Espera 2-3 segundos** (el sistema verifica al inicio)
3. **Deberías ver**:
   - 🟡 Badge amarillo en el ícono de actualización
   - Número "1" en el badge

### Paso 3: Ver Detalles de Actualización

1. **Toca el badge amarillo**
2. **Se abrirá un diálogo** mostrando:
   - Versión actual: 1.0.0
   - Nueva versión: 1.0.2
   - Notas de la versión
   - ℹ️ **Mensaje de seguridad**: "Tus datos están seguros"

### Paso 4: Prueba Manual

Si el automático no funciona:

1. Ve a **Ajustes → Buscar actualizaciones**
2. Toca la opción
3. Debería mostrar:
   - Si hay actualización: Diálogo con detalles
   - Si no hay: "Ya tienes la versión más reciente" (snackbar verde)

---

## 🐛 Debug: Ver Logs

Para entender qué está pasando, ejecuta:

```bash
# Conecta tu dispositivo y ejecuta:
adb logcat | grep "🔍\|📡\|📦\|📱\|🔄\|✅\|❌"
```

Verás mensajes como:
```
🔍 Verificando actualizaciones en: https://api.github.com/repos/...
📡 Status Code: 200
📦 Release encontrada: v1.0.2
🔖 Version release: 1.0.2
📱 Versión actual: 1.0.0
🔄 ¿Es más nueva? true
✅ Actualización disponible: 1.0.0 → 1.0.2
```

---

## 📊 Comparación de Versiones

| APK | Versión | Build | Fecha | Para Probar |
|-----|---------|-------|-------|-------------|
| SubTrack-v1.0.0.apk | 1.0.0 | 1 | Primera | Instalar primero |
| SubTrack-v1.0.1.apk | 1.0.1 | 2 | Con icono | No usar |
| SubTrack-v1.0.2.apk | 1.0.2 | 3 | Con logs | Actualizar a esta |

---

## 💾 Sobre la Persistencia de Datos

### ✅ Los Datos SÍ se Mantienen

Cuando actualizas la app (instalando un APK sobre la versión existente):

**Se MANTIENEN**:
- ✅ Todas las suscripciones guardadas
- ✅ Recordatorios del calendario
- ✅ Configuración de tema y colores
- ✅ Preferencias de la app
- ✅ Cualquier dato en Hive (base de datos local)

**Se PIERDEN solo si**:
- ❌ Desinstalas la app completamente
- ❌ Limpias los datos de la app desde Ajustes de Android
- ❌ Cambias el nombre del paquete (com.example.app)

### 🔒 Garantía Técnica

**Por qué es seguro**:
1. **Hive almacena** en: `/data/data/com.example.app/`
2. **Android preserva** esta carpeta al actualizar
3. **Solo se borra** al desinstalar o limpiar datos

### ℹ️ Mensaje Agregado al Diálogo

Ahora el diálogo de actualización muestra:

```
ℹ️ Tus datos están seguros. Al actualizar, todas tus 
   suscripciones y configuraciones se mantendrán intactas.
```

---

## 🎯 Checklist de Prueba

### Antes de Instalar v1.0.2

- [ ] Tengo v1.0.0 instalada (verificar en Ajustes)
- [ ] He agregado al menos 1 suscripción
- [ ] He configurado un recordatorio
- [ ] He seleccionado un tema de color

### Al Abrir v1.0.0

- [ ] El badge amarillo aparece (esperar 2-3 seg)
- [ ] Al tocar el badge, se abre el diálogo
- [ ] El diálogo muestra: 1.0.0 → 1.0.2
- [ ] Aparece el mensaje de datos seguros

### Después de Actualizar a v1.0.2

- [ ] Todas mis suscripciones siguen ahí
- [ ] Los recordatorios se mantienen
- [ ] Mi tema de color está igual
- [ ] La versión en Ajustes muestra: 1.0.2

---

## 🚨 Solución a Problemas Comunes

### "No aparece el badge"

**Causas posibles**:
1. La app instalada ya es la última versión
2. No hay conexión a internet
3. GitHub API no responde
4. La release no está marcada como "latest"

**Solución**:
```bash
# Ver logs para identificar el problema
adb logcat -c  # Limpiar logs
# Abrir la app
adb logcat | grep "🔍\|❌"
```

### "Dice que ya tengo la última versión"

**Causa**: Tu app instalada tiene la misma versión o más nueva que la release.

**Solución**: Instala SubTrack-v1.0.0.apk primero.

### "No se actualiza al instalar el APK"

**Causa**: Android considera que son apps diferentes.

**Solución**: Verifica que ambos APK tengan el mismo:
- Package name: `com.example.app_streaming_gastos`
- Firma digital (keystore)

---

## 📝 Notas Finales

1. **Primera vez**: Instala v1.0.0 para probar el sistema
2. **Producción**: Los usuarios siempre instalarán la última versión disponible
3. **Futuro**: Cada nueva release activará el badge automáticamente
4. **Seguridad**: Los datos SIEMPRE están seguros al actualizar

---

¿Todo claro? ¡Prueba y cuéntame qué ves en los logs! 🚀
