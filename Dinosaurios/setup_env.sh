#!/bin/bash

# Actualizar repositorios
sudo apt update

# Instalar Python3, mysqlclient y paquete venv (en caso de que no estén)
sudo apt install -y python3 python3-venv python3-pip git

sudo apt-get install -y pkg-config libmysqlclient-dev
# Crear entorno virtual si no existe
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi

# Activar entorno virtual
source venv/bin/activate

# Instalar requerimientos
pip install --upgrade pip
pip install -r requirements.txt

echo "Entorno preparado y dependencias instaladas."
echo "Para activar el entorno virtual usa: source venv/bin/activate"
