# 🚀 Comandos para crear el Release v1.0.2

## 1️⃣ Commitear los cambios de versión

```powershell
git add .
git commit -m "chore: bump version to 1.0.2 - Sistema de actualizaciones funcional"
git push origin main
```

## 2️⃣ Crear el tag v1.0.2

```powershell
git tag -a v1.0.2 -m "Release v1.0.2 - Sistema de actualizaciones funcional"
git push origin v1.0.2
```

## 3️⃣ En GitHub: Crear el Release

1. Ve a: https://github.com/NRVH/app_streaming_costos/releases/new
2. **Tag**: Selecciona `v1.0.2`
3. **Release title**: `SubTrack v1.0.2 - Sistema de Actualizaciones Funcional`
4. **Description**: Copia el contenido de `RELEASE_v1.0.2.md`
5. **Assets**: Sube el APK que estará en:
   ```
   build\app\outputs\flutter-apk\app-release.apk
   ```
6. ⚠️ **IMPORTANTE**: 
   - ❌ **NO** marcar "Set as a pre-release"
   - ✅ **SÍ** marcar "Set as the latest release"
7. Click en **"Publish release"**

## 4️⃣ Verificar

- URL del release: https://github.com/NRVH/app_streaming_costos/releases/tag/v1.0.2
- Verifica que aparezca como "Latest"
- Verifica que el APK esté adjunto

---

## 📱 Para probar (DESPUÉS del release):

1. Instala el APK de v1.0.2 en tu móvil
2. Más adelante, cuando hagas mejoras y crees v1.0.3:
   - La app detectará automáticamente la actualización
   - Aparecerá el badge en Configuración
   - Podrás ver los detalles y descargar

---

## ⚠️ RECORDATORIO CRÍTICO

Para que el sistema funcione en el futuro:
- ✅ Siempre usar tags con formato `v1.x.x` (con la "v")
- ✅ Siempre marcar como "Latest release"
- ✅ Nunca marcar como "Pre-release"
- ✅ Siempre subir el APK al release
