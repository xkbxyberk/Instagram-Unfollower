import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../utils/instagram_colors.dart';
import '../../utils/dark_theme_colors.dart';

class LoadingContent extends StatelessWidget {
  final String progressMessage;

  const LoadingContent({
    super.key,
    required this.progressMessage,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = isDark
        ? DarkThemeColors.gradientColors
        : InstagramColors.gradientColors;

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      gradientColors[0].withValues(alpha: 0.1),
                      gradientColors[4].withValues(alpha: 0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  strokeWidth: 6,
                  valueColor: AlwaysStoppedAnimation(
                    gradientColors[0],
                  ),
                ),
              ),
              Icon(
                Icons.analytics_outlined,
                size: 35,
                color: gradientColors[3],
              ),
            ],
          ),
          const SizedBox(height: 30),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [gradientColors[2], gradientColors[4]],
            ).createShader(bounds),
            child: Text(
              'analysis_in_progress'.tr(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            progressMessage,
            style: TextStyle(
              fontSize: 16,
              color: _getSecondaryTextColor(context, isDark),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Container(
            width: double.infinity,
            height: 6,
            decoration: BoxDecoration(
              color: _getDividerColor(context, isDark),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [gradientColors[0], gradientColors[4]],
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for theme colors
  Color _getSecondaryTextColor(BuildContext context, bool isDark) {
    return isDark ? DarkThemeColors.secondaryText : Colors.grey.shade600;
  }

  Color _getDividerColor(BuildContext context, bool isDark) {
    return isDark ? DarkThemeColors.dividerColor : Colors.grey.shade200;
  }
}
