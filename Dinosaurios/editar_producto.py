import os
import django

# Configura el entorno Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'Dinosaurios.settings')
django.setup()

from Dino.models import ProductoDino

def editar_producto():
    nombre = input("Nombre del producto a editar: ")

    try:
        producto = ProductoDino.objects.get(nombre=nombre)
    except ProductoDino.DoesNotExist:
        print(f"Producto '{nombre}' no encontrado.")
        return

    print("Deja en blanco si no deseas cambiar un campo.")

    nuevo_nombre = input(f"Nuevo nombre [{producto.nombre}]: ") or producto.nombre
    nuevo_precio = input(f"Nuevo precio [{producto.precio}]: ") or producto.precio
    nueva_imagen = input(f"Nuevo nombre de imagen [{producto.imagen}]: ") or producto.imagen
    nuevo_stock = input(f"Nuevo stock [{producto.stock}]: ") or producto.stock

    try:
        producto.nombre = nuevo_nombre
        producto.precio = float(nuevo_precio)
        producto.imagen = f'dinos/{nueva_imagen}' if nueva_imagen != producto.imagen else producto.imagen
        producto.stock = int(nuevo_stock)
        producto.save()
        print(f"Producto '{producto.nombre}' actualizado correctamente.")
    except ValueError:
        print("Error: Precio o stock inválidos.")

if __name__ == '__main__':
    editar_producto()
