from django.shortcuts import render, redirect
from django.contrib import messages
from .models import ProductoDino, Carrito, ItemCarrito
from django.db import transaction

def index(request):
    productos = ProductoDino.objects.all()
    return render(request, 'Dino/index.html', {'productos': productos})


def _get_or_create_carrito(request):
    """Función helper para manejar el carrito basado en sesión"""
    if not request.session.get('carrito_id'):
        carrito = Carrito.objects.create()
        request.session['carrito_id'] = carrito.id
        return carrito
    try:
        return Carrito.objects.get(id=request.session['carrito_id'])
    except Carrito.DoesNotExist:
        carrito = Carrito.objects.create()
        request.session['carrito_id'] = carrito.id
        return carrito

def agregar_al_carrito(request, producto_id):
    try:
        producto = ProductoDino.objects.get(id=producto_id)
        carrito = _get_or_create_carrito(request)  # Cambio aquí
        
        cantidad = int(request.POST.get('cantidad', 1))

        if cantidad <= 0:
            messages.error(request, "Cantidad inválida")
            return redirect('index')

        if cantidad > producto.stock:
            messages.error(request, "No hay suficiente stock")
            return redirect('index')

        item, created = ItemCarrito.objects.get_or_create(
            carrito=carrito,
            producto=producto,
            defaults={'cantidad': cantidad}
        )

        if not created:
            if item.cantidad + cantidad > producto.stock:
                messages.error(request, "No hay suficiente stock para agregar más")
                return redirect('index')
            item.cantidad += cantidad
            item.save()

        messages.success(request, f"{cantidad} {producto.nombre}(s) añadidos al carrito!")
        return redirect('index')

    except ProductoDino.DoesNotExist:
        messages.error(request, "Producto no encontrado")
        return redirect('index')

def ver_carrito(request):
    carrito = _get_or_create_carrito(request)  # Cambio aquí
    items = carrito.itemcarrito_set.all()
    
    return render(request, 'Dino/carrito.html', {
        'carrito': carrito,
        'items': items
    })

def comprar(request):
    try:
        carrito = _get_or_create_carrito(request)  # Cambio aquí
        
        with transaction.atomic():
            # Verificar stock antes de comprar
            for item in carrito.itemcarrito_set.select_related('producto').all():
                if item.cantidad > item.producto.stock:
                    messages.error(request, f"No hay suficiente stock de {item.producto.nombre}")
                    return redirect('ver_carrito')
            
            # Procesar compra
            for item in carrito.itemcarrito_set.all():
                item.producto.stock -= item.cantidad
                item.producto.save()
            
            carrito.itemcarrito_set.all().delete()
            messages.success(request, "¡Compra realizada con éxito!")
            return redirect('index')
            
    except Exception as e:
        messages.error(request, f"Error al procesar la compra: {str(e)}")
        return redirect('index')

def eliminar_item(request, item_id):
    carrito = _get_or_create_carrito(request)  # Cambio aquí
    ItemCarrito.objects.filter(id=item_id, carrito=carrito).delete()
    return redirect('ver_carrito')
