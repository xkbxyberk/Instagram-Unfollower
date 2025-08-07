import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'home_screen.dart';
import 'security_screen.dart';
import 'settings_screen.dart';
import '../webview_screen.dart';

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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF833ab4),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: 'home_tab'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.analytics_outlined),
            activeIcon: const Icon(Icons.analytics),
            label: 'analysis_tab'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.security_outlined),
            activeIcon: const Icon(Icons.security),
            label: 'security_tab'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_outlined),
            activeIcon: const Icon(Icons.settings),
            label: 'settings_tab'.tr(),
          ),
        ],
      ),
    );
  }
}
