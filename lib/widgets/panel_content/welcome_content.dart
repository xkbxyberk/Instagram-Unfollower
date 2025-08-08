import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../utils/instagram_colors.dart';
import '../../utils/dark_theme_colors.dart';

class WelcomeContent extends StatelessWidget {
  final Animation<double> pulseAnimation;
  final VoidCallback onAnalyzePressed;

  const WelcomeContent({
    super.key,
    required this.pulseAnimation,
    required this.onAnalyzePressed,
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
          ScaleTransition(
            scale: pulseAnimation,
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          Colors.green.shade900.withValues(alpha: 0.3),
                          Colors.green.shade800.withValues(alpha: 0.4),
                        ]
                      : [
                          Colors.green.shade50,
                          Colors.green.shade100,
                        ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.verified_user_outlined,
                size: 70,
                color: Colors.green.shade600,
              ),
            ),
          ),
          const SizedBox(height: 30),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [gradientColors[2], gradientColors[4]],
            ).createShader(bounds),
            child: Text(
              'connected_successfully'.tr(),
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'ready_to_analyze'.tr(),
            style: TextStyle(
              fontSize: 16,
              color: _getSecondaryTextColor(context, isDark),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  gradientColors[0],
                  gradientColors[2],
                  gradientColors[4],
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: gradientColors[3].withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: onAnalyzePressed,
              icon: const Icon(
                Icons.analytics_outlined,
                size: 28,
                color: Colors.white,
              ),
              label: Text(
                'analyze_my_account'.tr(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for theme colors
  Color _getSecondaryTextColor(BuildContext context, bool isDark) {
    return isDark ? DarkThemeColors.secondaryText : Colors.grey.shade600;
  }
}
