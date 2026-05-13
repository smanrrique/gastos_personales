import 'package:flutter/material.dart';

class CategoryColorLibrary {
  CategoryColorLibrary._();

  static const Map<String, Color> _colors = {
    'red': Color(0xFFEF4444),
    'orange': Color(0xFFF59E0B),
    'amber': Color(0xFFFBBF24),
    'green': Color(0xFF22C55E),
    'emerald': Color(0xFF10B981),
    'teal': Color(0xFF14B8A6),
    'cyan': Color(0xFF06B6D4),
    'blue': Color(0xFF3B82F6),
    'indigo': Color(0xFF6366F1),
    'purple': Color(0xFF8B5CF6),
    'pink': Color(0xFFEC4899),
    'grey': Color(0xFF64748B),
  };

  static Color get(String key) => _colors[key] ?? const Color(0xFF6366F1);
  static List<MapEntry<String, Color>> get all => _colors.entries.toList();
}
