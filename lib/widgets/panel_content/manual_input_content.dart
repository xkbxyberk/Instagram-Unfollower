import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../utils/instagram_colors.dart';
import '../../utils/dark_theme_colors.dart';

class ManualInputContent extends StatelessWidget {
  final TextEditingController usernameController;
  final VoidCallback onStartAnalysis;

  const ManualInputContent({
    super.key,
    required this.usernameController,
    required this.onStartAnalysis,
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
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        Colors.orange.shade900.withValues(alpha: 0.3),
                        Colors.orange.shade800.withValues(alpha: 0.4),
                      ]
                    : [
                        Colors.orange.shade50,
                        Colors.orange.shade100,
                      ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.edit_outlined,
              size: 70,
              color: Colors.orange.shade600,
            ),
          ),
          const SizedBox(height: 30),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [gradientColors[6], gradientColors[8]],
            ).createShader(bounds),
            child: Text(
              'username_required'.tr(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'enter_username_manually'.tr(),
            style: TextStyle(
              fontSize: 16,
              color: _getSecondaryTextColor(context, isDark),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Container(
            decoration: BoxDecoration(
              color: _getCardColor(context, isDark),
              borderRadius: BorderRadius.circular(16),
              boxShadow: _getCardShadow(context, isDark),
            ),
            child: TextField(
              controller: usernameController,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: _getPrimaryTextColor(context, isDark),
              ),
              decoration: InputDecoration(
                labelText: 'instagram_username'.tr(),
                labelStyle: TextStyle(color: gradientColors[3]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: gradientColors[3], width: 2),
                ),
                filled: true,
                fillColor:
                    isDark ? DarkThemeColors.surfaceColor : Colors.grey.shade50,
                prefixIcon: Icon(
                  Icons.alternate_email,
                  color: gradientColors[3],
                ),
                hintText: 'username_placeholder'.tr(),
                hintStyle:
                    TextStyle(color: _getSecondaryTextColor(context, isDark)),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
              ),
              keyboardType: TextInputType.text,
              autocorrect: false,
            ),
          ),
          const SizedBox(height: 30),
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
              onPressed: onStartAnalysis,
              icon: const Icon(
                Icons.analytics_outlined,
                size: 24,
                color: Colors.white,
              ),
              label: Text(
                'start_analysis'.tr(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
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

  Color _getPrimaryTextColor(BuildContext context, bool isDark) {
    return isDark ? DarkThemeColors.primaryText : Colors.black87;
  }

  Color _getCardColor(BuildContext context, bool isDark) {
    return isDark ? DarkThemeColors.cardColor : Colors.white;
  }

  List<BoxShadow> _getCardShadow(BuildContext context, bool isDark) {
    return isDark
        ? DarkThemeColors.cardShadow
        : [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ];
  }
}
