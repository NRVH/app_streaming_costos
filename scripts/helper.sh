#!/bin/bash

# Script de ayuda para el proyecto App Streaming Gastos

echo "🎯 App de Gastos de Streaming - Comandos Útiles"
echo ""

# Función para mostrar el menú
show_menu() {
    echo "Selecciona una opción:"
    echo "1) Instalar dependencias"
    echo "2) Generar código de Hive"
    echo "3) Limpiar y reinstalar"
    echo "4) Ejecutar app"
    echo "5) Ejecutar en dispositivo específico"
    echo "6) Ver dispositivos disponibles"
    echo "7) Abrir simulador iOS / Ver emuladores"
    echo "8) Analizar código"
    echo "9) Compilar APK (Android)"
    echo "0) Salir"
    echo ""
}

# Función para esperar enter
wait_for_enter() {
    echo ""
    read -p "Presiona Enter para continuar..."
    clear
}

# Loop principal
while true; do
    show_menu
    read -p "Opción: " option
    
    case $option in
        1)
            echo "📦 Instalando dependencias..."
            flutter pub get
            wait_for_enter
            ;;
        2)
            echo "⚙️ Generando código de Hive..."
            flutter pub run build_runner build --delete-conflicting-outputs
            wait_for_enter
            ;;
        3)
            echo "🧹 Limpiando proyecto..."
            flutter clean
            echo "📦 Instalando dependencias..."
            flutter pub get
            echo "⚙️ Generando código de Hive..."
            flutter pub run build_runner build --delete-conflicting-outputs
            wait_for_enter
            ;;
        4)
            echo "🚀 Ejecutando app..."
            flutter run
            wait_for_enter
            ;;
        5)
            echo "📱 Dispositivos disponibles:"
            flutter devices
            echo ""
            read -p "Ingresa el ID del dispositivo: " device_id
            echo "🚀 Ejecutando en $device_id..."
            flutter run -d $device_id
            wait_for_enter
            ;;
        6)
            echo "📱 Dispositivos disponibles:"
            flutter devices
            wait_for_enter
            ;;
        7)
            echo "� Emuladores disponibles:"
            flutter emulators
            echo ""
            read -p "¿Quieres iniciar el simulador de iOS? (s/n): " response
            if [[ "$response" == "s" || "$response" == "S" ]]; then
                echo "� Abriendo simulador de iOS..."
                open -a Simulator
                echo "✅ Simulador abierto. Espera a que cargue y luego ejecuta 'flutter run'"
            fi
            wait_for_enter
            ;;
        8)
            echo "🔍 Analizando código..."
            flutter analyze
            wait_for_enter
            ;;
        9)
            echo "📦 Compilando APK..."
            flutter build apk --release
            echo ""
            echo "✅ APK generado en: build/app/outputs/flutter-apk/app-release.apk"
            wait_for_enter
            ;;
        0)
            echo "👋 ¡Hasta luego!"
            exit 0
            ;;
        *)
            echo "❌ Opción inválida"
            wait_for_enter
            ;;
    esac
done
