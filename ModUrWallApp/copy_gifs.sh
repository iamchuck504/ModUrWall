#!/bin/bash

# Script para copiar los GIFs necesarios desde tu carpeta Animations/
# Uso: ./copy_gifs.sh /ruta/a/tu/carpeta/Animations

if [ -z "$1" ]; then
    echo "❌ Error: Debes proporcionar la ruta a tu carpeta Animations/"
    echo "Uso: ./copy_gifs.sh /ruta/a/Animations"
    exit 1
fi

SOURCE_DIR="$1"
DEST_DIR="assets/animations"

# Verificar que el directorio origen existe
if [ ! -d "$SOURCE_DIR" ]; then
    echo "❌ Error: El directorio $SOURCE_DIR no existe"
    exit 1
fi

# Crear directorio destino si no existe
mkdir -p "$DEST_DIR"

echo "🎬 Copiando GIFs necesarios..."
echo ""

# Lista de GIFs necesarios
GIFS=(
    "NeuralNetwork.gif"
    "Blockchain.gif"
    "QuantumComputing.gif"
    "Cybersecurity.gif"
    "DigitalMatrix.gif"
    "DataVisualization.gif"
    "digitalSamurai.gif"
    "CloudComputing.gif"
    "Infrastructure.gif"
)

COPIED=0
MISSING=0

# Copiar cada GIF
for gif in "${GIFS[@]}"; do
    if [ -f "$SOURCE_DIR/$gif" ]; then
        cp "$SOURCE_DIR/$gif" "$DEST_DIR/"
        echo "✅ Copiado: $gif"
        ((COPIED++))
    else
        echo "⚠️  No encontrado: $gif"
        ((MISSING++))
    fi
done

echo ""
echo "📊 Resumen:"
echo "   ✅ Copiados: $COPIED"
echo "   ⚠️  Faltantes: $MISSING"
echo ""

if [ $COPIED -gt 0 ]; then
    echo "🎉 ¡Listo! Ahora ejecuta:"
    echo "   flutter pub get"
    echo "   flutter run -d ios"
else
    echo "❌ No se copió ningún archivo. Verifica la ruta."
fi
