import 'package:flutter/material.dart';
import '../../core/constants.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.category,
    this.selected  = false,
    this.onTap,
    this.small     = false,
  });

  final String  category;
  final bool    selected;
  final VoidCallback? onTap;
  final bool    small;

  static const _icons = <String, IconData>{
    'military':     Icons.military_tech,
    'diplomatic':   Icons.handshake,
    'economic':     Icons.trending_up,
    'humanitarian': Icons.volunteer_activism,
    'social':       Icons.people,
    'other':        Icons.circle,
  };

  @override
  Widget build(BuildContext context) {
    final hex   = AppConstants.categoryColors[category] ?? 0xFF757575;
    final color = Color(hex);
    final icon  = _icons[category] ?? Icons.circle;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: small ? 6 : 10,
          vertical:   small ? 2 : 5,
        ),
        decoration: BoxDecoration(
          color:        selected ? color.withValues(alpha: 0.25) : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border:       Border.all(
            color: selected ? color : color.withValues(alpha: 0.3),
            width: selected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: small ? 10 : 13),
            SizedBox(width: small ? 3 : 5),
            Text(
              category,
              style: TextStyle(
                color:      color,
                fontSize:   small ? 10 : 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}