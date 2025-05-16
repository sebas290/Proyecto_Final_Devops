#!/bin/bash

# Datos de conexión
HOST="aurora-instance.ccrfirlaj9it.us-east-1.rds.amazonaws.com"
PORT="3306"
USER="Equipo5"
PASS="Devops28290"

# Verifica si mysql está instalado
if ! command -v mysql &> /dev/null; then
    echo "MySQL no está instalado. Instalando..."
    sudo apt update
    sudo apt install -y mysql-client
else
    echo "MySQL ya está instalado."
fi

# Conexión directa a MySQL
echo "Conectando a MySQL..."
mysql -h "$HOST" -P "$PORT" -u "$USER" -p"$PASS"
