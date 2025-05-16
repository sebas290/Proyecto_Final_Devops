import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'Dinosaurios.settings')
django.setup()

from Dino.models import Producto

def agregar_producto(nombre, cantidad, precio):
    p = Producto(nombre=nombre, cantidad=cantidad, precio=precio)
    p.save()
    print(f"Producto {nombre} agregado con éxito.")

if __name__ == "__main__":
    agregar_producto("Dino T-Rex", 10, 299.99)
