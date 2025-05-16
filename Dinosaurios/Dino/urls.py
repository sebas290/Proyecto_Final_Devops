from django.urls import path
from . import views
from django.contrib.auth import views as auth_views

urlpatterns = [
    path('', views.index, name='index'),
    path('agregar/<int:producto_id>/', views.agregar_al_carrito, name='agregar_al_carrito'),
    path('carrito/', views.ver_carrito, name='ver_carrito'),
    path('comprar/', views.comprar, name='comprar'),
    path('eliminar/<int:item_id>/', views.eliminar_item, name='eliminar_item'),
]
