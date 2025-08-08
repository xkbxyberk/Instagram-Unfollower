import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../utils/dark_theme_colors.dart';

class ErrorContent extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onTryAgain;

  const ErrorContent({
    super.key,
    required this.errorMessage,
    required this.onTryAgain,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                        Colors.red.shade900.withValues(alpha: 0.3),
                        Colors.red.shade800.withValues(alpha: 0.4),
                      ]
                    : [
                        Colors.red.shade50,
                        Colors.red.shade100,
                      ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 70,
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(height: 30),
          Text(
            'error_occurred'.tr(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            errorMessage,
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
                colors: [Colors.blue.shade500, Colors.blue.shade700],
              ),
              borderRadius: BorderRadius.circular(16),
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
              onPressed: onTryAgain,
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: Text(
                'try_again'.tr(),
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

  // Helper method for theme colors
  Color _getSecondaryTextColor(BuildContext context, bool isDark) {
    return isDark ? DarkThemeColors.secondaryText : Colors.grey.shade600;
  }
}
