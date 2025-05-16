#!/bin/bash

echo "Deteniendo contenedores existentes (si hay)..."
docker-compose down -v --remove-orphans

echo "Limpiando imágenes antiguas relacionadas..."
docker image prune -af

echo "Reconstruyendo la imagen con docker-compose..."
docker-compose up --build -d

echo "Contenedores activos:"
docker ps

