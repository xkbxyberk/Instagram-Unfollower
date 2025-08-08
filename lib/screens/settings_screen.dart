import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../language_selector.dart';
import '../utils/instagram_colors.dart';
import '../utils/dark_theme_colors.dart';
import '../services/theme_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
                _buildHeader(isDark),

                const SizedBox(height: 30),

                // App Settings Section
                _buildSection(
                  title: 'app_settings'.tr(),
                  children: [
                    _buildLanguageSetting(isDark),
                    const SizedBox(height: 10),
                    _buildThemeSetting(isDark),
                  ],
                  isDark: isDark,
                ),

                const SizedBox(height: 20),

                // About Section
                _buildSection(
                  title: 'about'.tr(),
                  children: [
                    _buildAboutItem(
                      icon: Icons.info_outline,
                      title: 'version'.tr(),
                      value: '1.0.0',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 10),
                    _buildAboutItem(
                      icon: Icons.person_outline,
                      title: 'developer'.tr(),
                      value: 'berk_akbay'.tr(),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 15),
                    _buildMadeWithLove(isDark),
                  ],
                  isDark: isDark,
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      DarkThemeColors.gradientColors[0],
                      DarkThemeColors.gradientColors[2],
                    ]
                  : [
                      InstagramColors.gradientColors[0],
                      InstagramColors.gradientColors[2],
                    ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.settings_outlined,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            'settings_title'.tr(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: ThemeColors.primaryText(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeColors.card(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: ThemeColors.cardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ThemeColors.primaryText(context),
            ),
          ),
          const SizedBox(height: 15),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLanguageSetting(bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.language,
            color: Colors.blue,
            size: 20,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            'language_setting'.tr(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: ThemeColors.primaryText(context),
            ),
          ),
        ),
        const LanguageSelector(),
      ],
    );
  }

  Widget _buildThemeSetting(bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.purple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.palette_outlined,
            color: Colors.purple,
            size: 20,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            'theme_setting'.tr(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: ThemeColors.primaryText(context),
            ),
          ),
        ),
        _buildThemeSelector(isDark),
      ],
    );
  }

  Widget _buildThemeSelector(bool isDark) {
    return AnimatedBuilder(
      animation: ThemeService.instance,
      builder: (context, child) {
        final currentTheme = ThemeService.instance.themeMode;

        return PopupMenuButton<ThemeMode>(
          onSelected: (ThemeMode mode) {
            ThemeService.instance.setThemeMode(mode);
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: ThemeColors.card(context),
          itemBuilder: (BuildContext context) => [
            _buildThemeMenuItem(
              ThemeMode.system,
              Icons.brightness_auto,
              'theme_system'.tr(),
              currentTheme == ThemeMode.system,
            ),
            _buildThemeMenuItem(
              ThemeMode.light,
              Icons.light_mode,
              'theme_light'.tr(),
              currentTheme == ThemeMode.light,
            ),
            _buildThemeMenuItem(
              ThemeMode.dark,
              Icons.dark_mode,
              'theme_dark'.tr(),
              currentTheme == ThemeMode.dark,
            ),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color:
                  isDark ? DarkThemeColors.surfaceColor : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isDark ? DarkThemeColors.borderColor : Colors.grey.shade300,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getThemeIcon(currentTheme),
                  size: 16,
                  color: ThemeColors.secondaryText(context),
                ),
                const SizedBox(width: 8),
                Text(
                  _getThemeDisplayName(currentTheme),
                  style: TextStyle(
                    fontSize: 14,
                    color: ThemeColors.primaryText(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: ThemeColors.secondaryText(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  PopupMenuItem<ThemeMode> _buildThemeMenuItem(
    ThemeMode mode,
    IconData icon,
    String label,
    bool isSelected,
  ) {
    return PopupMenuItem<ThemeMode>(
      value: mode,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? ThemeColors.instagramGradient(context)[0]
                  : ThemeColors.secondaryText(context),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? ThemeColors.instagramGradient(context)[0]
                      : ThemeColors.primaryText(context),
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check,
                color: ThemeColors.instagramGradient(context)[0],
                size: 18,
              ),
          ],
        ),
      ),
    );
  }

  IconData _getThemeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  String _getThemeDisplayName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'theme_light'.tr();
      case ThemeMode.dark:
        return 'theme_dark'.tr();
      case ThemeMode.system:
        return 'theme_system'.tr();
    }
  }

  Widget _buildAboutItem({
    required IconData icon,
    required String title,
    required String value,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.green,
            size: 20,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: ThemeColors.primaryText(context),
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: ThemeColors.secondaryText(context),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMadeWithLove(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  Colors.pink.withValues(alpha: 0.2),
                  Colors.purple.withValues(alpha: 0.2),
                ]
              : [
                  Colors.pink.withValues(alpha: 0.1),
                  Colors.purple.withValues(alpha: 0.1),
                ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.pink.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'made_with_love'.tr(),
            style: TextStyle(
              fontSize: 14,
              color: ThemeColors.secondaryText(context),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'berk_akbay'.tr(),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.pink,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
