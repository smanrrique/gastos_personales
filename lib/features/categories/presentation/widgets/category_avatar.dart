import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import 'category_color_library.dart';
import 'category_icon_library.dart';

class CategoryAvatar extends StatelessWidget {
  const CategoryAvatar({
    super.key,
    required this.iconKey,
    required this.colorKey,
    this.size = 44,
  });

  final String iconKey;
  final String colorKey;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = CategoryColorLibrary.get(colorKey);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Icon(
        CategoryIconLibrary.get(iconKey),
        color: color,
        size: size * 0.5,
      ),
    );
  }
}
