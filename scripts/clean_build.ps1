# Script para limpiar completamente el build de Flutter
# Ejecutar como: .\scripts\clean_build.ps1

Write-Host "Limpiando proyecto Flutter..." -ForegroundColor Cyan

# Detener todos los procesos de Gradle
Write-Host "Deteniendo procesos Gradle..." -ForegroundColor Yellow
Get-Process | Where-Object {$_.ProcessName -like "*gradle*" -or $_.ProcessName -like "*java*"} | Stop-Process -Force -ErrorAction SilentlyContinue

Start-Sleep -Seconds 2

# Limpiar Flutter
Write-Host "Ejecutando flutter clean..." -ForegroundColor Yellow
flutter clean

Start-Sleep -Seconds 1

# Eliminar carpetas manualmente
Write-Host "Eliminando carpetas de build..." -ForegroundColor Yellow
$foldersToDelete = @(
    "build",
    ".dart_tool",
    "android\.gradle",
    "android\build",
    "android\app\build"
)

foreach ($folder in $foldersToDelete) {
    $fullPath = Join-Path $PSScriptRoot "..\$folder"
    if (Test-Path $fullPath) {
        Write-Host "  Eliminando: $folder" -ForegroundColor Gray
        Remove-Item -Path $fullPath -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "Limpieza completada!" -ForegroundColor Green
Write-Host ""
Write-Host "Ahora ejecuta:" -ForegroundColor Cyan
Write-Host "  flutter pub get" -ForegroundColor White
Write-Host "  flutter run -d emulator-5554" -ForegroundColor White
