import os
import django

# Configura el entorno Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'Dinosaurios.settings')
django.setup()

from Dino.models import ProductoDino

def eliminar_producto():
    nombre = input("Nombre del producto a eliminar: ")

    try:
        producto = ProductoDino.objects.get(nombre=nombre)
        producto.delete()
        print(f"Producto '{nombre}' eliminado correctamente.")
    except ProductoDino.DoesNotExist:
        print(f"Producto '{nombre}' no encontrado.")

if __name__ == '__main__':
    eliminar_producto()
