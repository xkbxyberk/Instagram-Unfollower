import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../language_selector.dart';
import '../utils/instagram_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
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
                _buildHeader(),

                const SizedBox(height: 30),

                // App Settings Section
                _buildSection(
                  title: 'app_settings'.tr(),
                  children: [
                    _buildLanguageSetting(),
                    const SizedBox(height: 10),
                    _buildThemeSetting(),
                  ],
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
                    ),
                    const SizedBox(height: 10),
                    _buildAboutItem(
                      icon: Icons.person_outline,
                      title: 'developer'.tr(),
                      value: 'berk_akbay'.tr(),
                    ),
                    const SizedBox(height: 15),
                    _buildMadeWithLove(),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
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
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 15),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLanguageSetting() {
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
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        const LanguageSelector(),
      ],
    );
  }

  Widget _buildThemeSetting() {
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
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        SegmentedButton<bool>(
          segments: [
            ButtonSegment<bool>(
              value: false,
              label: Text(
                'theme_light'.tr(),
                style: const TextStyle(fontSize: 12),
              ),
              icon: const Icon(Icons.light_mode, size: 16),
            ),
            ButtonSegment<bool>(
              value: true,
              label: Text(
                'theme_dark'.tr(),
                style: const TextStyle(fontSize: 12),
              ),
              icon: const Icon(Icons.dark_mode, size: 16),
            ),
          ],
          selected: {_isDarkMode},
          onSelectionChanged: (selection) {
            setState(() {
              _isDarkMode = selection.first;
            });
            // TODO: Dark mode implementasyonu sonra eklenecek
          },
          style: SegmentedButton.styleFrom(
            selectedBackgroundColor: InstagramColors.gradientColors[0],
            selectedForegroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildAboutItem({
    required IconData icon,
    required String title,
    required String value,
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
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMadeWithLove() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
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
              color: Colors.grey.shade700,
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
