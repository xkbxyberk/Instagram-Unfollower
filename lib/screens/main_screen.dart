import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'home_screen.dart';
import 'security_screen.dart';
import 'settings_screen.dart';
import '../webview_screen.dart';
import '../utils/dark_theme_colors.dart';
import '../utils/instagram_colors.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // Ana Sayfa başlangıçta açık
  final GlobalKey<HomeScreenState> _homeScreenKey =
      GlobalKey<HomeScreenState>(); // final eklendi

  // Dashboard'ı yenilemek için callback
  void _onAnalysisCompleted() {
    // Ana sayfadaki dashboard'ı yenile
    _homeScreenKey.currentState?.refreshDashboard(); // public method çağrısı
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = isDark
        ? DarkThemeColors.gradientColors
        : InstagramColors.gradientColors;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(
            key: _homeScreenKey,
            onStartAnalysis: () {
              // Analiz sekmesine geç
              setState(() {
                _currentIndex = 1;
              });
            },
          ),
          WebViewScreen(
            onAnalysisCompleted: _onAnalysisCompleted,
          ),
          const SecurityScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: gradientColors[3],
          unselectedItemColor:
              isDark ? DarkThemeColors.secondaryText : Colors.grey,
          backgroundColor:
              isDark ? DarkThemeColors.secondaryBackground : Colors.white,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: _currentIndex == 0
                    ? BoxDecoration(
                        color: gradientColors[3].withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      )
                    : null,
                child: Icon(
                  _currentIndex == 0 ? Icons.home : Icons.home_outlined,
                ),
              ),
              label: 'home_tab'.tr(),
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: _currentIndex == 1
                    ? BoxDecoration(
                        color: gradientColors[3].withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      )
                    : null,
                child: Icon(
                  _currentIndex == 1
                      ? Icons.analytics
                      : Icons.analytics_outlined,
                ),
              ),
              label: 'analysis_tab'.tr(),
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: _currentIndex == 2
                    ? BoxDecoration(
                        color: gradientColors[3].withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      )
                    : null,
                child: Icon(
                  _currentIndex == 2 ? Icons.security : Icons.security_outlined,
                ),
              ),
              label: 'security_tab'.tr(),
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: _currentIndex == 3
                    ? BoxDecoration(
                        color: gradientColors[3].withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      )
                    : null,
                child: Icon(
                  _currentIndex == 3 ? Icons.settings : Icons.settings_outlined,
                ),
              ),
              label: 'settings_tab'.tr(),
            ),
          ],
        ),
      ),
    );
  }
}
