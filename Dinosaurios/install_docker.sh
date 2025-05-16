#!/bin/bash

# Verificar si Docker está instalado
if ! command -v docker &> /dev/null
then
    echo "Docker no está instalado. Instalando Docker..."
    # Instalar Docker
    sudo apt update
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

    # Agregar la clave GPG de Docker
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

    # Agregar el repositorio de Docker
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

    # Actualizar la lista de paquetes e instalar Docker
    sudo apt update
    sudo apt install -y docker-ce

    # Verificar instalación de Docker
    if command -v docker &> /dev/null
    then
        echo "Docker instalado correctamente."
    else
        echo "Hubo un error al instalar Docker."
        exit 1
    fi
else
    echo "Docker ya está instalado."
fi

# Verificar si Docker Compose está instalado
if ! command -v docker-compose &> /dev/null
then
    echo "Docker Compose no está instalado. Instalando Docker Compose..."
    # Descargar la última versión de Docker Compose
    sudo curl -L "https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r .tag_name)/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

    # Dar permisos de ejecución
    sudo chmod +x /usr/local/bin/docker-compose

    # Verificar instalación de Docker Compose
    if command -v docker-compose &> /dev/null
    then
        echo "Docker Compose instalado correctamente."
    else
        echo "Hubo un error al instalar Docker Compose."
        exit 1
    fi
else
    echo "Docker Compose ya está instalado."
fi
