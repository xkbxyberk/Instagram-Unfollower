import 'package:flutter/material.dart';
import '../services/analytics_service.dart';
import '../utils/dark_theme_colors.dart';

class MiniChart extends StatefulWidget {
  final List<DailyUsageData> data;
  final Color color;
  final double height;

  const MiniChart({
    super.key,
    required this.data,
    required this.color,
    this.height = 80,
  });

  @override
  State<MiniChart> createState() => _MiniChartState();
}

class _MiniChartState extends State<MiniChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.data.isEmpty) {
      return SizedBox(height: widget.height);
    }

    final maxValue = widget.data
        .map((e) => e.analysisCount)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    if (maxValue == 0) {
      return SizedBox(height: widget.height);
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          height: widget.height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: widget.data.map((dayData) {
              final normalizedValue = dayData.analysisCount / maxValue;
              final barHeight =
                  normalizedValue * widget.height * _animation.value;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Bar
                      Container(
                        height: barHeight,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              widget.color.withValues(alpha: 0.8),
                              widget.color.withValues(alpha: 0.4),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: isDark
                              ? [
                                  BoxShadow(
                                    color: widget.color.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Day label - now using the localized day name from DailyUsageData
                      Text(
                        dayData
                            .dayName, // This now comes from analytics service with proper localization
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark
                              ? DarkThemeColors.secondaryText
                              : Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
