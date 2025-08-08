import 'package:flutter/material.dart';
import '../utils/dark_theme_colors.dart';

class TrendIndicator extends StatelessWidget {
  final double trend; // pozitif/negatif yüzde
  final TextStyle? textStyle;

  const TrendIndicator({
    super.key,
    required this.trend,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPositive = trend > 0;
    final isNeutral = trend == 0;

    Color color;
    if (isNeutral) {
      color = isDark ? DarkThemeColors.secondaryText : Colors.grey;
    } else if (isPositive) {
      color = isDark ? DarkThemeColors.successColor : Colors.green;
    } else {
      color = isDark ? DarkThemeColors.errorColor : Colors.red;
    }

    final icon = isNeutral
        ? Icons.trending_flat
        : isPositive
            ? Icons.trending_up
            : Icons.trending_down;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: isDark
            ? Border.all(
                color: color.withValues(alpha: 0.3),
                width: 0.5,
              )
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            isNeutral
                ? '0%'
                : '${trend > 0 ? '+' : ''}${trend.toStringAsFixed(1)}%',
            style: (textStyle ?? const TextStyle()).copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
