# 🧪 Plan de Pruebas - SubTrack v1.0.3

## ✅ Checklist de Testing - Mejoras de Recordatorios

### 📋 **Preparación**
- [ ] Desinstalar versión anterior (si existe)
- [ ] Instalar APK SubTrack-v1.0.3.apk
- [ ] Otorgar permisos de calendario cuando se soliciten
- [ ] Abrir la app

---

## 🧪 **Prueba 1: Crear una suscripción CON recordatorio**

### Pasos:
1. [ ] Tocar el botón **+** para agregar suscripción
2. [ ] Llenar los datos:
   - **Nombre**: Netflix (o cualquier servicio)
   - **Precio**: 139
   - **Categoría**: Streaming de Video
   - **Fecha de facturación**: (selecciona una fecha cercana)
   - **Ciclo**: Mensual
3. [ ] **ACTIVAR** el switch "Habilitar recordatorio"
4. [ ] Configurar "Recordar X días antes": 1 día
5. [ ] Guardar

### Resultados Esperados:
✅ **Debe mostrar un SnackBar verde con:**
```
✅ Suscripción agregada
✅ Recordatorio creado para el [fecha específica]
```

❌ **Si muestra advertencia naranja:**
```
⚠️ Suscripción agregada
⚠️ No se pudo crear el recordatorio en el calendario
```
→ Verificar permisos de calendario en configuración del dispositivo

---

## 🧪 **Prueba 2: Verificar en la pantalla de Recordatorios**

### Pasos:
1. [ ] Ir a **Configuración** (última pestaña)
2. [ ] Tocar **"Gestionar recordatorios"**

### Resultados Esperados:
✅ **Debe mostrar 3 contadores:**
- **Recordatorios Activos**: 1
- **Eventos Sincronizados**: 1
- **En Calendario**: 1

✅ **Debe mostrar UNA tarjeta de evento con:**
- Título con emoji: **"💳 Pago Netflix"** (o tu servicio)
- Badge verde: **"Vinculado"**
- Fecha y hora del recordatorio
- Monto (si está vinculado): **"MXN 139.00"**
- Borde de color (mismo color que tu suscripción)

❌ **Si NO aparece ningún evento:**
1. [ ] Tocar el ícono de filtro 🔍 (se pone amarillo)
2. [ ] Verificar si aparecen otros eventos del calendario
3. [ ] Si aparecen otros eventos pero no el de Netflix:
   - Problema con el filtro (revisar logs)
4. [ ] Si NO aparecen eventos:
   - Problema con permisos o calendario del dispositivo

---

## 🧪 **Prueba 3: Probar el botón "Sincronizar"**

### Pasos:
1. [ ] En la pantalla de Recordatorios
2. [ ] Tocar el ícono **Sincronizar** (⟳) en la barra superior
3. [ ] Esperar unos segundos

### Resultados Esperados:
✅ **Debe mostrar un SnackBar:**
```
Sincronización completa: X creados, 0 errores
```

---

## 🧪 **Prueba 4: Crear suscripción SIN recordatorio**

### Pasos:
1. [ ] Agregar nueva suscripción (Disney+, Spotify, etc.)
2. [ ] **NO activar** el switch de recordatorio
3. [ ] Guardar

### Resultados Esperados:
✅ **Debe mostrar:**
```
✅ Suscripción agregada
```
(Sin mensaje de recordatorio)

✅ **En pantalla de Recordatorios:**
- **Recordatorios Activos**: 1 (sigue siendo el anterior)
- **En Calendario**: 1 (solo el anterior)

---

## 🧪 **Prueba 5: Editar y activar recordatorio existente**

### Pasos:
1. [ ] En la lista de suscripciones
2. [ ] Tocar la suscripción que NO tiene recordatorio (Disney+)
3. [ ] **ACTIVAR** el switch de recordatorio
4. [ ] Guardar

### Resultados Esperados:
✅ **Debe mostrar:**
```
✅ Suscripción actualizada
✅ Recordatorio creado para el [fecha]
```

✅ **En pantalla de Recordatorios:**
- **Recordatorios Activos**: 2
- **Eventos Sincronizados**: 2
- **En Calendario**: 2

---

## 🧪 **Prueba 6: Verificar evento en calendario nativo**

### Pasos:
1. [ ] Salir de SubTrack
2. [ ] Abrir la app **Calendario** nativa de tu dispositivo
3. [ ] Navegar a la fecha del recordatorio

### Resultados Esperados:
✅ **Debe aparecer un evento:**
- **Título**: "💳 Pago Netflix"
- **Fecha/hora**: La configurada
- **Descripción**: Con información de SubTrack

❌ **Si NO aparece:**
- Verificar permisos
- Verificar que el calendario seleccionado sea el correcto

---

## 🧪 **Prueba 7: Eliminar recordatorio desde SubTrack**

### Pasos:
1. [ ] En pantalla de Recordatorios
2. [ ] Tocar el botón **🗑️ eliminar** en una tarjeta
3. [ ] Confirmar en el diálogo

### Resultados Esperados:
✅ **Debe mostrar:**
```
Recordatorio eliminado correctamente
```

✅ **Los contadores deben actualizarse:**
- **Recordatorios Activos**: Sigue igual (porque el switch sigue ON)
- **En Calendario**: Disminuye en 1

❌ **Alerta de sincronización debe aparecer** (porque hay recordatorio activo sin evento)

---

## 🧪 **Prueba 8: Modo "Ver TODOS los eventos"**

### Pasos:
1. [ ] En pantalla de Recordatorios
2. [ ] Tocar el ícono de **filtro** 🔍 en la barra superior
3. [ ] El ícono debe ponerse **amarillo/ámbar**

### Resultados Esperados:
✅ **Debe mostrar:**
- Banner amarillo: "Mostrando TODOS los eventos del calendario (X eventos)"
- TODOS los eventos del rango de fechas (no solo SubTrack)
- Eventos de otros apps, cumpleaños, etc.

✅ **Tocar filtro de nuevo:**
- Vuelve al modo SubTrack
- Solo muestra eventos de SubTrack

---

## 🧪 **Prueba 9: Pantalla vacía (sin recordatorios)**

### Pasos:
1. [ ] Desactivar recordatorios en TODAS las suscripciones
2. [ ] Ir a pantalla de Recordatorios

### Resultados Esperados:
✅ **Debe mostrar:**
- Ícono grande de calendario vacío
- Mensaje: "No hay eventos de SubTrack"
- Sugerencia: "Tienes X recordatorio(s) activo(s)..."
- Botón: **"Sincronizar Ahora"** (naranja)
- Botón: **"Ver todos los eventos"**

---

## 🐛 **Si algo falla**

### Logs en Consola
Si ejecutas con `flutter run --release`, verás logs como:
```
📅 [CREATE] Iniciando creación de recordatorio para: Netflix
📅 [CREATE] Usando calendario ID: xxx
📅 [CREATE] Fecha de recordatorio: 2025-10-24
✅ [CREATE] Evento creado exitosamente! ID: xxx
```

### Verificar Permisos
1. Configuración del dispositivo
2. Aplicaciones
3. SubTrack
4. Permisos
5. Calendario: **Debe estar PERMITIDO**

### Verificar Calendario
1. Algunos dispositivos tienen múltiples calendarios
2. SubTrack usa el calendario "predeterminado"
3. En Android: suele ser "Calendar" o tu cuenta de Google
4. En iOS: suele ser "iCloud" o tu cuenta principal

---

## ✅ **Checklist Final**

Marca si funcionan correctamente:
- [ ] Crear suscripción CON recordatorio → Mensaje de confirmación con fecha
- [ ] Pantalla de Recordatorios muestra 3 contadores precisos
- [ ] Tarjetas de eventos muestran badge "Vinculado"
- [ ] Emojis 💳 visibles en títulos
- [ ] Información completa (monto, fecha, ciclo)
- [ ] Botón Sincronizar funciona
- [ ] Modo "Ver TODO" funciona
- [ ] Eliminar recordatorio funciona
- [ ] Eventos aparecen en calendario nativo
- [ ] Alertas de sincronización aparecen cuando corresponde

---

## 📸 **Screenshots Recomendados**

Si quieres documentar:
1. SnackBar de confirmación al crear
2. Pantalla de Recordatorios con contadores
3. Tarjeta de evento con badge "Vinculado"
4. Alerta de sincronización (si aparece)
5. Modo "Ver TODO" activo
6. Pantalla vacía con sugerencias
7. Evento en calendario nativo del dispositivo

---

**¿Encontraste algún problema?** Anota:
- ¿Qué paso estabas haciendo?
- ¿Qué esperabas que pasara?
- ¿Qué pasó en realidad?
- ¿Hay algún mensaje de error?
