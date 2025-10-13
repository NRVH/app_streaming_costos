# Release v1.0.4

## 🎯 Gestión del Ciclo de Vida de Suscripciones

### ✨ Nuevas Características

#### 1. **Duración de Suscripciones**
- Ahora puedes establecer una **duración específica** para cada suscripción
- Opciones disponibles:
  - 1 mes
  - 3 meses
  - 6 meses
  - 1 año
  - 2 años
  - **Indefinido** (por defecto)
- Los recordatorios de calendario se crearán **solo hasta la fecha de fin** de la suscripción
- Para suscripciones indefinidas, se crean recordatorios por un máximo de 5 años (60 meses)

#### 2. **Cancelar Suscripciones**
- Nuevo botón **"Cancelar"** en cada tarjeta de suscripción activa (ícono 🚫)
- Al cancelar, se te preguntará:
  - **Archivar**: La suscripción se guarda como cancelada y puedes renovarla después
  - **Eliminar**: Se elimina permanentemente (sin posibilidad de recuperación)
- Las suscripciones archivadas **no se cuentan** en el costo mensual total

#### 3. **Suscripciones Archivadas**
- Nueva pantalla accesible desde el botón **"Archivo"** (📦) en el AppBar
- Badge con contador de suscripciones archivadas
- Muestra todas las suscripciones canceladas con:
  - Tachado en el nombre
  - Badge "Cancelada" en rojo
  - Opacidad reducida para diferenciarlas

#### 4. **Renovar Suscripciones**
- En la pantalla de archivadas, cada suscripción tiene un botón **"Renovar"**
- Al renovar, seleccionas la nueva duración:
  - 1 mes
  - 3 meses
  - 6 meses
  - 1 año
  - 2 años
  - Indefinido
- La suscripción vuelve al estado **activo** y se recalculan los recordatorios

#### 5. **Estados de Suscripción**
Ahora las suscripciones tienen 3 estados posibles:
- ✅ **Activa**: Suscripción en curso
- ⏸️ **Pausada**: (Preparado para futuro uso)
- ❌ **Cancelada**: Suscripción archivada

### 🔧 Mejoras Técnicas

#### Modelo de Datos
```dart
// Nuevos campos en Subscription:
- status: SubscriptionStatus (activa/pausada/cancelada)
- subscriptionEndDate: DateTime? (fecha de fin, null = indefinido)

// Nuevos métodos:
- cancel() → Cambia estado a cancelado
- renew({newEndDate}) → Reactiva con nueva fecha de fin
- pause() → Pausa la suscripción
- isActive → Verifica si está activa
- isCanceled → Verifica si está cancelada
- isPaused → Verifica si está pausada
- isExpired → Verifica si expiró
```

#### Servicio de Calendario
```dart
// Mejora en createReminder():
- Si tiene subscriptionEndDate: crea recurrencia hasta esa fecha
- Si es indefinida: crea recurrencia por máximo 60 meses (5 años)
- Usa RecurrenceRule.until para limitar eventos
```

#### Provider de Suscripciones
```dart
// Actualizado getTotalMonthlyCost():
- Solo suma suscripciones con estado "activa"
- Las canceladas/pausadas no afectan el total
```

### 🎨 Cambios en la UI

#### HomeScreen
- Ahora muestra **solo suscripciones activas**
- Nuevo botón "Archivo" con badge contador
- El total mensual solo incluye suscripciones activas

#### SubscriptionCard
- Nuevo botón "Cancelar" (ícono block 🚫) en tarjetas activas
- Se muestra junto al botón de eliminar

#### ArchivedSubscriptionsScreen (Nueva)
- Lista de suscripciones canceladas
- Botón "Renovar" para reactivar
- Botón "Eliminar permanentemente" para borrar definitivamente
- Diseño visual diferenciado (tachado, opacidad)

#### Add/Edit Screen
- Nueva sección **"Duración de la suscripción"**
- Dropdown con opciones de duración
- Muestra fecha de fin calculada automáticamente

### 📋 Ejemplo de Uso

#### Escenario: Prueba gratuita de 3 meses
1. Crear suscripción "Netflix Prueba"
2. Seleccionar "3 meses" en duración
3. La app creará recordatorios solo por 3 meses
4. Después de 3 meses, puedes:
   - Cancelar → Archivar o eliminar
   - Si archivas, puedes renovar más tarde por otro periodo

#### Escenario: Cambio temporal de servicio
1. Tienes "HBO Max" activa
2. Decides cancelarla temporalmente
3. Presionas "Cancelar" → "Archivar"
4. Más tarde decides volver:
5. Vas a "Archivadas"
6. Presionas "Renovar" → Seleccionas "1 año"
7. ¡Listo! HBO Max vuelve a estar activa

### 🐛 Correcciones

- Ahora los recordatorios no se crean indefinidamente (máximo 5 años para indefinidas)
- El costo mensual total solo incluye suscripciones activas
- Las suscripciones canceladas no aparecen en la pantalla principal

### 📦 Versión
- **Versión**: 1.0.4+6
- **Build**: 6
- **Fecha**: 2025

---

## 🚀 Próximas Características Planeadas

1. **Mejoras en Pantalla de Calendario**
   - Agrupar eventos por suscripción
   - Expandir/colapsar grupos
   - Botón "Eliminar todos" por suscripción

2. **Filtros y Búsqueda**
   - Buscar suscripciones por nombre
   - Filtrar por categoría
   - Filtrar por rango de precio

3. **Estadísticas Mejoradas**
   - Gráficos de gasto mensual
   - Comparativa año anterior
   - Predicciones de gasto

---

## 📝 Notas Técnicas

### Cambios en Base de Datos (Hive)
```dart
// SubscriptionStatus enum (TypeId: 2)
@HiveType(typeId: 2)
enum SubscriptionStatus {
  @HiveField(0)
  active,
  
  @HiveField(1)
  paused,
  
  @HiveField(2)
  canceled,
}

// Nuevos HiveFields en Subscription:
@HiveField(18)
final SubscriptionStatus status;

@HiveField(19)
final DateTime? subscriptionEndDate;
```

### Migración de Datos
- Las suscripciones existentes se cargarán con `status = active` por defecto
- `subscriptionEndDate` será `null` (indefinido) para suscripciones existentes
- No se requiere migración manual

### Compatibilidad
- ✅ Android 5.0+ (API 21+)
- ✅ iOS 12.0+
- ⚠️ Requiere reinicio completo de la app para aplicar cambios (no hot reload)
