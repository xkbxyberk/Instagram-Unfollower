import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../utils/instagram_colors.dart';
import '../utils/dark_theme_colors.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    DarkThemeColors.gradientColors[0].withValues(alpha: 0.1),
                    DarkThemeColors.primaryBackground,
                  ]
                : [
                    InstagramColors.gradientColors[0].withValues(alpha: 0.05),
                    Colors.white,
                  ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Header
                _buildHeader(context, isDark),

                const SizedBox(height: 30),

                // How It Works Section
                _buildSection(
                  context: context,
                  icon: Icons.info_outline,
                  title: 'how_it_works'.tr(),
                  description: 'how_it_works_desc'.tr(),
                  color: Colors.blue,
                  isDark: isDark,
                ),

                const SizedBox(height: 20),

                // Safety Tips Section
                _buildTipsSection(context, isDark),

                const SizedBox(height: 20),

                // Privacy Section
                _buildPrivacySection(context, isDark),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final gradientColors = isDark
        ? DarkThemeColors.gradientColors
        : InstagramColors.gradientColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    gradientColors[0],
                    gradientColors[2],
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.security_outlined,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'security_guide_title'.tr(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _getPrimaryTextColor(context, isDark),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'security_guide_subtitle'.tr(),
                    style: TextStyle(
                      fontSize: 14,
                      color: _getSecondaryTextColor(context, isDark),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getCardColor(context, isDark),
        borderRadius: BorderRadius.circular(16),
        boxShadow: _getCardShadow(context, isDark),
        border: Border.all(
          color: color.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getPrimaryTextColor(context, isDark),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: _getSecondaryTextColor(context, isDark),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getCardColor(context, isDark),
        borderRadius: BorderRadius.circular(16),
        boxShadow: _getCardShadow(context, isDark),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.lightbulb_outline,
                    color: Colors.orange, size: 24),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  'safety_tips'.tr(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getPrimaryTextColor(context, isDark),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            'safety_tips_desc'.tr(),
            style: TextStyle(
              fontSize: 14,
              color: _getSecondaryTextColor(context, isDark),
            ),
          ),
          const SizedBox(height: 15),
          ..._buildTipsList(context, isDark),
        ],
      ),
    );
  }

  List<Widget> _buildTipsList(BuildContext context, bool isDark) {
    final tips = [
      'tip_1'.tr(),
      'tip_2'.tr(),
      'tip_3'.tr(),
      'tip_4'.tr(),
    ];

    return tips
        .map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6, right: 12),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      tip,
                      style: TextStyle(
                        fontSize: 14,
                        color: _getSecondaryTextColor(context, isDark),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }

  Widget _buildPrivacySection(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getCardColor(context, isDark),
        borderRadius: BorderRadius.circular(16),
        boxShadow: _getCardShadow(context, isDark),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.privacy_tip_outlined,
                    color: Colors.green, size: 24),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  'data_privacy'.tr(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getPrimaryTextColor(context, isDark),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            'data_privacy_desc'.tr(),
            style: TextStyle(
              fontSize: 14,
              color: _getSecondaryTextColor(context, isDark),
            ),
          ),
          const SizedBox(height: 15),
          ..._buildPrivacyList(context, isDark),
        ],
      ),
    );
  }

  List<Widget> _buildPrivacyList(BuildContext context, bool isDark) {
    final privacyPoints = [
      'privacy_1'.tr(),
      'privacy_2'.tr(),
      'privacy_3'.tr(),
      'privacy_4'.tr(),
    ];

    return privacyPoints
        .map((point) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      point,
                      style: TextStyle(
                        fontSize: 14,
                        color: _getSecondaryTextColor(context, isDark),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }

  // Helper methods for theme colors
  Color _getPrimaryTextColor(BuildContext context, bool isDark) {
    return isDark ? DarkThemeColors.primaryText : Colors.black87;
  }

  Color _getSecondaryTextColor(BuildContext context, bool isDark) {
    return isDark ? DarkThemeColors.secondaryText : Colors.grey.shade600;
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
