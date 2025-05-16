import os
import django

# Configura el entorno Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'Dinosaurios.settings')
django.setup()

from Dino.models import ProductoDino

def agregar_producto():
    nombre = input("Nombre del producto: ")
    precio = input("Precio del producto: ")
    imagen = input("Nombre del archivo de imagen (con extensión): ")
    stock = input("Cantidad en stock: ")

    try:
        precio = float(precio)
        stock = int(stock)
    except ValueError:
        print("Precio o stock inválido. Intenta de nuevo.")
        return

    # Crear y guardar el producto
    producto = ProductoDino(
        nombre=nombre,
        precio=precio,
        imagen=f'dinos/{imagen}',  # Se asume que la imagen estará en media/dinos/
        stock=stock
    )
    producto.save()
    print(f"Producto '{nombre}' agregado correctamente.")

if __name__ == '__main__':
    agregar_producto()
