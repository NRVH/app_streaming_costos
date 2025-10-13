# 📱 SubTrack

<div align="center">

**Una aplicación móvil moderna y elegante para gestionar tus suscripciones mensuales**

[![Flutter](https://img.shields.io/badge/Flutter-3.35.6-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9.2-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android-blue.svg)](https://github.com/NRVH/app_streaming_costos)

[Características](#-características) • [Capturas](#-capturas-de-pantalla) • [Instalación](#-instalación) • [Tecnologías](#-tecnologías) • [Contribuir](#-contribuir)

</div>

---

## 📖 Descripción

**SubTrack** es una aplicación móvil profesional diseñada para ayudarte a gestionar y realizar un seguimiento de todas tus suscripciones mensuales (Netflix, Spotify, HBO, Apple Music, y más). Con una interfaz limpia siguiendo Material Design 3, SubTrack te permite controlar tus gastos recurrentes de manera simple y efectiva.

### 🎯 ¿Por qué SubTrack?

- 💰 **Control total** de tus gastos mensuales
- 📊 **Visualiza** fácilmente cuánto gastas en suscripciones
- 🔔 **Recordatorios** integrados con el calendario nativo
- 🎨 **Personalizable** con 6 paletas de colores y modo oscuro
- 📱 **Diseño moderno** siguiendo Material Design 3
- 🔒 **Privacidad** - Todo se guarda localmente en tu dispositivo

---

## ✨ Características

### 🎨 Interfaz y Diseño

- ✅ **Material Design 3** - Interfaz moderna y fluida
- ✅ **Modo Oscuro/Claro** - Cambia según tu preferencia
- ✅ **6 Paletas de Colores Armónicas**:
  - 🌸 **Sakura Pink** - Rosa suave y elegante
  - 🌊 **Ocean Blue** - Azul océano profesional
  - 🌲 **Forest Green** - Verde natural y calmante
  - 🌅 **Sunset Orange** - Naranja vibrante y energético
  - 💜 **Lavender Dream** - Púrpura sofisticado
  - 🌿 **Mint Fresh** - Menta refrescante y moderno
- ✅ **Cada paleta incluye 3 colores** que se complementan perfectamente

### 📊 Gestión de Suscripciones

- ✅ **CRUD Completo** - Crea, lee, actualiza y elimina suscripciones
- ✅ **Servicios Populares** - Chips rápidos para Netflix, Spotify, Disney+, HBO Max, Prime Video, YouTube Premium, Apple Music
- ✅ **Categorización** - Organiza por tipo (Streaming Video, Música, Cloud, Gaming, etc.)
- ✅ **Ciclos de Facturación** - Mensual, trimestral, semestral o anual
- ✅ **Múltiples Monedas** - Soporte para diferentes divisas
- ✅ **Colores Personalizados** - Asigna un color a cada suscripción

### 📈 Análisis y Resumen

- ✅ **Total Mensual** - Visualiza el gasto total de forma prominente
- ✅ **Próximos Pagos** - Lista de suscripciones que vencen pronto
- ✅ **Desglose por Categoría** - Gráficos y porcentajes por tipo
- ✅ **Proyecciones** - Calcula gastos mensuales y anuales

### 🔔 Recordatorios

- ✅ **Integración con Calendario Nativo** - Los recordatorios se crean en tu app de Calendario (iOS/Android)
- ✅ **Notificaciones Automáticas** - Te avisa 1 día antes del cobro
- ✅ **Sincronización** - Los cambios en suscripciones actualizan los recordatorios

### 💾 Almacenamiento

- ✅ **Base de Datos Local** - Usa Hive para almacenamiento rápido y eficiente
- ✅ **Sin Internet Requerido** - Funciona 100% offline
- ✅ **Persistencia de Configuración** - Tus preferencias se guardan automáticamente

---

## 📸 Capturas de Pantalla

> *Próximamente: Screenshots de la app en acción*

---

## 🚀 Instalación

### Prerrequisitos

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.35.6 o superior)
- [Dart SDK](https://dart.dev/get-dart) (3.9.2 o superior)
- Xcode (para iOS) o Android Studio (para Android)

### Pasos de Instalación

1. **Clona el repositorio**

```bash
git clone git@github.com:NRVH/app_streaming_costos.git
cd app_streaming_costos
```

2. **Instala las dependencias**

```bash
flutter pub get
```

3. **Genera los archivos de código (Hive adapters)**

```bash
dart run build_runner build --delete-conflicting-outputs
```

4. **Ejecuta la aplicación**

Para iOS:
```bash
flutter run -d ios
```

Para Android:
```bash
flutter run -d android
```

Para desarrollo en macOS:
```bash
flutter run -d macos
```

---

## 🛠 Tecnologías

### Framework y Lenguaje

- **Flutter 3.35.6** - UI framework multiplataforma
- **Dart 3.9.2** - Lenguaje de programación

### Arquitectura y Estado

- **Clean Architecture** - Separación de capas (core, models, providers, services, screens, widgets)
- **Riverpod 2.6.1** - Gestión de estado reactivo
- **StateNotifier** - Patrón para manejar estado mutable

### Almacenamiento

- **Hive 2.2.3** - Base de datos NoSQL local y rápida
- **Hive Flutter 1.1.0** - Integración de Hive con Flutter

### Integraciones Nativas

- **device_calendar 4.3.3** - Acceso al calendario nativo iOS/Android
- **timezone 0.9.4** - Manejo de zonas horarias para recordatorios

### UI y Utilidades

- **Material Design 3** - Sistema de diseño moderno de Google
- **intl 0.19.0** - Internacionalización y formato de fechas/monedas
- **uuid 4.3.3** - Generación de IDs únicos

### Generación de Código

- **build_runner 2.4.13** - Ejecutor de generadores de código
- **hive_generator 2.0.1** - Genera adaptadores para Hive

---

## 📁 Estructura del Proyecto

```
lib/
├── core/
│   ├── constants/       # Constantes de la aplicación
│   └── theme/          # Sistema de temas y paletas de colores
├── models/             # Modelos de datos (Subscription)
├── providers/          # Proveedores de estado (Riverpod)
├── services/           # Servicios (Database, Calendar)
├── screens/            # Pantallas principales
│   ├── home_screen.dart
│   ├── add_edit_subscription_screen.dart
│   ├── summary_screen.dart
│   └── settings_screen.dart
└── widgets/            # Widgets reutilizables
```

---

## 🎨 Paletas de Colores

SubTrack incluye 6 paletas de colores profesionales, cada una con 3 tonos que se complementan armónicamente:

| Paleta | Primary | Secondary | Tertiary |
|--------|---------|-----------|----------|
| 🌸 **Sakura Pink** | `#FFB3D9` | `#FF6B9D` | `#FFF0F5` |
| 🌊 **Ocean Blue** | `#006494` | `#0582CA` | `#00A6FB` |
| 🌲 **Forest Green** | `#2D6A4F` | `#40916C` | `#52B788` |
| 🌅 **Sunset Orange** | `#FF6D00` | `#FF9E00` | `#FFBC42` |
| 💜 **Lavender Dream** | `#7209B7` | `#9D4EDD` | `#C77DFF` |
| 🌿 **Mint Fresh** | `#06FFA5` | `#00D9A3` | `#4DFFC3` |

---

## 🔧 Configuración

### Permisos

**iOS** - Agrega a `ios/Runner/Info.plist`:
```xml
<key>NSCalendarsUsageDescription</key>
<string>SubTrack necesita acceso al calendario para crear recordatorios de tus suscripciones</string>
```

**Android** - Ya configurado en `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.READ_CALENDAR"/>
<uses-permission android:name="android.permission.WRITE_CALENDAR"/>
```

---

## 🤝 Contribuir

Las contribuciones son bienvenidas. Para cambios importantes:

1. Haz un Fork del proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add: nueva característica increíble'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

---

## 📝 Roadmap

- [ ] Exportar/Importar datos (JSON/CSV)
- [ ] Gráficos de tendencias de gastos
- [ ] Compartir resumen mensual
- [ ] Widget para pantalla de inicio
- [ ] Soporte multi-idioma (Español/Inglés)
- [ ] Backup en la nube (opcional)
- [ ] Estadísticas avanzadas

---

## 👨‍💻 Autor

**NRVH**

- GitHub: [@NRVH](https://github.com/NRVH)
- Proyecto: [SubTrack](https://github.com/NRVH/app_streaming_costos)

---

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

---

## 🙏 Agradecimientos

- [Flutter Team](https://flutter.dev) por el increíble framework
- [Material Design](https://m3.material.io/) por las guías de diseño
- [Riverpod](https://riverpod.dev/) por la gestión de estado
- [Hive](https://docs.hivedb.dev/) por la base de datos local

---

<div align="center">

**⭐ Si te gusta este proyecto, dale una estrella en GitHub ⭐**

**Hecho con ❤️ y Flutter**

</div>
