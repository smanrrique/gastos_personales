import 'package:flutter/material.dart';

/// Catálogo cerrado de íconos para categorías.
/// Usar claves estables permite que el tree-shaking elimine íconos no usados
/// y mantiene la compatibilidad cuando Material rota codepoints.
class CategoryIconLibrary {
  CategoryIconLibrary._();

  static const Map<String, IconData> _icons = {
    'food': Icons.restaurant,
    'transport': Icons.directions_car,
    'home': Icons.home_outlined,
    'health': Icons.medical_services_outlined,
    'entertainment': Icons.sports_esports,
    'shopping': Icons.shopping_bag_outlined,
    'education': Icons.school_outlined,
    'pets': Icons.pets,
    'subscriptions': Icons.subscriptions,
    'travel': Icons.flight_takeoff,
    'gym': Icons.fitness_center,
    'other': Icons.more_horiz,
    'salary': Icons.work_outline,
    'freelance': Icons.laptop_mac,
    'investment': Icons.trending_up,
    'gift': Icons.card_giftcard,
  };

  static IconData get(String key) => _icons[key] ?? Icons.category_outlined;
  static List<MapEntry<String, IconData>> get all => _icons.entries.toList();
}
