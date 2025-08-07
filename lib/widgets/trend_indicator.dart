import 'package:flutter/material.dart';

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
    final isPositive = trend > 0;
    final isNeutral = trend == 0;
    final color = isNeutral
        ? Colors.grey
        : isPositive
            ? Colors.green
            : Colors.red;

    final icon = isNeutral
        ? Icons.trending_flat
        : isPositive
            ? Icons.trending_up
            : Icons.trending_down;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: color,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          isNeutral
              ? '0%'
              : '${trend > 0 ? '+' : ''}${trend.toStringAsFixed(1)}%',
          style: (textStyle ?? const TextStyle()).copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
