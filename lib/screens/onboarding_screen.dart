import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/instagram_colors.dart';
import '../utils/dark_theme_colors.dart';
import '../screens/main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _riskAccepted = false;

  @override
  void initState() {
    super.initState();
    // Theme.of(context) çağrısını initState'den kaldırdık
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = isDark
        ? DarkThemeColors.gradientColors
        : InstagramColors.gradientColors;

    // Pages'i build metodunda oluşturuyoruz
    final pages = [
      OnboardingPage(
        icon: Icons.waving_hand_outlined,
        title: 'onboarding_welcome',
        description: 'onboarding_welcome_desc',
        gradient: [
          gradientColors[0],
          gradientColors[2],
        ],
      ),
      OnboardingPage(
        icon: Icons.auto_awesome_outlined,
        title: 'onboarding_features',
        description: 'onboarding_features_desc',
        gradient: [
          gradientColors[2],
          gradientColors[4],
        ],
      ),
      OnboardingPage(
        icon: Icons.security_outlined,
        title: 'onboarding_privacy',
        description: 'onboarding_privacy_desc',
        gradient: [
          gradientColors[4],
          gradientColors[6],
        ],
      ),
      OnboardingPage(
        icon: Icons.info_outline,
        title: 'onboarding_security',
        description: 'onboarding_security_desc',
        gradient: [
          gradientColors[6],
          gradientColors[8],
        ],
        isRiskPage: true,
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: pages[_currentPage].gradient,
              ),
            ),
          ),

          // Dark theme overlay for better contrast
          if (isDark)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.1),
                  ],
                ),
              ),
            ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Skip button - sadece son sayfa değilse göster
                if (_currentPage < pages.length - 1)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          child: TextButton(
                            onPressed: () => _skipToRiskPage(pages),
                            child: Text(
                              'onboarding_skip'.tr(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Page view
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                        if (index < pages.length - 1) {
                          _riskAccepted = false;
                        }
                        // Sayfalar değiştiğinde gradientleri güncelle
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          // Artık _initializePages'e gerek yok
                        });
                      });
                    },
                    itemCount: pages.length,
                    itemBuilder: (context, index) {
                      return _buildPage(pages[index]);
                    },
                  ),
                ),

                // Bottom controls
                Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: [
                      // Page indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          pages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 30 : 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: _currentPage == index
                                  ? [
                                      BoxShadow(
                                        color:
                                            Colors.white.withValues(alpha: 0.5),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Navigation buttons
                      Row(
                        children: [
                          if (_currentPage > 0)
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: OutlinedButton(
                                  onPressed: () => _previousPage(),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(
                                        color: Colors.white, width: 2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                  ),
                                  child: Text(
                                    'previous'.tr(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (_currentPage > 0) const SizedBox(width: 15),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 15,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _currentPage == pages.length - 1 &&
                                        !_riskAccepted
                                    ? null
                                    : () => _nextPage(pages),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor:
                                      pages[_currentPage].gradient.first,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  elevation: 0,
                                ),
                                child: Text(
                                  _currentPage == pages.length - 1
                                      ? 'onboarding_continue'.tr()
                                      : 'next'.tr(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _skipToRiskPage(List<OnboardingPage> pages) {
    _pageController.animateToPage(
      pages.length - 1, // Son sayfaya (risk kabul sayfası) git
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _nextPage(List<OnboardingPage> pages) {
    if (_currentPage < pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (_riskAccepted) {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              page.icon,
              size: 80,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 40),

          // Title
          Text(
            page.title.tr(),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Description
          Text(
            page.description.tr(),
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.5,
              shadows: const [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),

          // Risk information (only for the last page)
          if (page.isRiskPage) ...[
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'onboarding_risk_title'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'onboarding_risk_1'.tr(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'onboarding_risk_2'.tr(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'onboarding_risk_3'.tr(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'onboarding_risk_4'.tr(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _riskAccepted = !_riskAccepted;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: _riskAccepted
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                              boxShadow: _riskAccepted
                                  ? [
                                      BoxShadow(
                                        color:
                                            Colors.white.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: _riskAccepted
                                ? Icon(
                                    Icons.check,
                                    size: 18,
                                    color: page.gradient.first,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'onboarding_checkbox'.tr(),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradient;
  final bool isRiskPage;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
    this.isRiskPage = false,
  });
}
