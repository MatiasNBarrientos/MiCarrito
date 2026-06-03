import 'package:flutter/material.dart';

class CatalogoPresets {
  // Lista estática para poder accederla desde cualquier parte de la app
  static List<Map<String, dynamic>> lista = [
    {'nombre': 'Leche', 'icono': Icons.local_drink, 'categoria': 'Lácteos'},
    {
      'nombre': 'Pan',
      'icono': Icons.breakfast_dining,
      'categoria': 'Panadería',
    },
    {'nombre': 'Huevos', 'icono': Icons.egg, 'categoria': 'Frescos'},
    {'nombre': 'Galletitas', 'icono': Icons.cookie, 'categoria': 'Almacén'},
    {
      'nombre': 'Ñoquis/Pasta',
      'icono': Icons.dinner_dining,
      'categoria': 'Almacén',
    },
    {'nombre': 'Carne', 'icono': Icons.set_meal, 'categoria': 'Carnicería'},
    {'nombre': 'Comida Gato', 'icono': Icons.pets, 'categoria': 'Mascotas'},
    {'nombre': 'Comida Perro', 'icono': Icons.pets, 'categoria': 'Mascotas'},
    {
      'nombre': 'Limpieza',
      'icono': Icons.cleaning_services,
      'categoria': 'Limpieza',
    },
  ];

  // Función para inyectar nuevos presets creados por el usuario
  static void agregarPreset(String nombre, String categoria) {
    lista.add({
      'nombre': nombre,
      // Le asignamos un ícono genérico de "bolsa de compras" a los creados por el usuario
      'icono': Icons.shopping_bag,
      'categoria': categoria,
    });
  }
}
