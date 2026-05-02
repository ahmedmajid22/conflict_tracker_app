import 'package:flutter/material.dart';
import '../../data/models/sentiment_model.dart';

class SentimentBadge extends StatelessWidget {
  const SentimentBadge({super.key, required this.sentiment, this.compact = false});

  final SentimentModel? sentiment;
  final bool            compact;

  @override
  Widget build(BuildContext context) {
    if (sentiment == null) return const SizedBox.shrink();

    final Color color;
    final IconData icon;

    switch (sentiment!.label) {
      case 'negative':
        color = const Color(0xFFE53935);
        icon  = Icons.trending_down;
        break;
      case 'positive':
        color = const Color(0xFF43A047);
        icon  = Icons.trending_up;
        break;
      default:
        color = const Color(0xFF757575);
        icon  = Icons.trending_flat;
    }

    if (compact) {
      return Icon(icon, color: color, size: 16);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color:        color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: color.withValues(alpha: 0.4), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            sentiment!.label,
            style: TextStyle(
              color:      color,
              fontSize:   11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}