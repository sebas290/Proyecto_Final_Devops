#!/bin/bash

# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar Python, pip y entorno virtual
sudo apt install python3 python3-pip python3-venv -y

# Crear entorno virtual
python3 -m venv env

# Activar entorno virtual
source env/bin/activate

# Instalar Django
pip install django

# Crear proyecto
django-admin startproject Dinosaurios

# Cambiar a la carpeta del proyecto
cd Dinosaurios

# Iniciar servidor
python3 manage.py runserver 0.0.0.0:8000

