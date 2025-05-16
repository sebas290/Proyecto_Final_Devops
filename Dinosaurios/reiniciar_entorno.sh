#!/bin/bash

echo "🔄 Eliminando migraciones anteriores..."

# Elimina archivos de migraciones en la app Dino
find Dino/migrations/ -type f -name "00*.py" -delete
find Dino/migrations/ -type f -name "*.pyc" -delete

echo "✅ Migraciones anteriores eliminadas."

echo "📦 Verificando instalación de Pillow..."
pip show Pillow > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "📥 Pillow no está instalado. Instalando..."
    pip install Pillow
else
    echo "✅ Pillow ya está instalado."
fi

echo "⚙️ Creando nuevas migraciones..."
python manage.py makemigrations

echo "📄 Estado de migraciones:"
python manage.py showmigrations

echo "✅ Script terminado."
