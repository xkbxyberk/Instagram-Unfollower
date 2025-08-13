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
  }

  // Teknik detay popup'ı göster
  void _showTechnicalDetailsPopup(
      String titleKey, String contentKey, int pageIndex) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = isDark
        ? DarkThemeColors.gradientColors
        : InstagramColors.gradientColors;

    // Sayfa indeksine göre popup renklerini ayarla
    List<Color> popupColors;
    switch (pageIndex) {
      case 2: // Gizlilik sayfası
        popupColors = [
          gradientColors[4].withValues(alpha: 0.9),
          gradientColors[6].withValues(alpha: 0.9),
        ];
        break;
      case 3: // Güvenlik sayfası
        popupColors = [
          gradientColors[6].withValues(alpha: 0.9),
          gradientColors[8].withValues(alpha: 0.9),
        ];
        break;
      default:
        popupColors = [
          gradientColors[0].withValues(alpha: 0.9),
          gradientColors[2].withValues(alpha: 0.9),
        ];
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: popupColors,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          titleKey.tr(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Flexible(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        contentKey.tr(),
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: isDark
                              ? DarkThemeColors.primaryText
                                  .withValues(alpha: 0.8)
                              : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),

                // Close button
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'close'.tr(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = isDark
        ? DarkThemeColors.gradientColors
        : InstagramColors.gradientColors;

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLandscape = screenWidth > screenHeight;

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
        showLearnMore: true,
        onLearnMore: () => _showTechnicalDetailsPopup(
          'privacy_technical_title',
          'privacy_technical_content',
          2, // Gizlilik sayfası indeksi
        ),
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
        showLearnMore: true,
        onLearnMore: () => _showTechnicalDetailsPopup(
          'security_technical_title',
          'security_technical_content',
          3, // Güvenlik sayfası indeksi
        ),
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

          // Content with SingleChildScrollView
          SafeArea(
            child: Column(
              children: [
                // Skip button - sadece son sayfa değilse göster
                if (_currentPage < pages.length - 1)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
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

                // Page view with flexible height
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                        if (index < pages.length - 1) {
                          _riskAccepted = false;
                        }
                      });
                    },
                    itemCount: pages.length,
                    itemBuilder: (context, index) {
                      return SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: isLandscape ? 40 : 30,
                          vertical: isLandscape ? 10 : 20,
                        ),
                        child: _buildPage(pages[index], isLandscape),
                      );
                    },
                  ),
                ),

                // Bottom controls with fixed height
                Container(
                  padding: EdgeInsets.all(isLandscape ? 20 : 30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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

                      SizedBox(height: isLandscape ? 20 : 30),

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
                                    padding: EdgeInsets.symmetric(
                                        vertical: isLandscape ? 12 : 16),
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
                                  padding: EdgeInsets.symmetric(
                                      vertical: isLandscape ? 12 : 16),
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
      pages.length - 1,
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

  Widget _buildPage(OnboardingPage page, bool isLandscape) {
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive boyutlar
    final iconSize = isLandscape ? 60.0 : 80.0;
    final titleSize = isLandscape ? 24.0 : 28.0;
    final descSize = isLandscape ? 14.0 : 16.0;
    final spacing = isLandscape ? 20.0 : 30.0;
    final smallSpacing = isLandscape ? 10.0 : 20.0;

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: screenHeight * 0.5, // Minimum yükseklik
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            padding: EdgeInsets.all(isLandscape ? 20 : 30),
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
              size: iconSize,
              color: Colors.white,
            ),
          ),

          SizedBox(height: spacing),

          // Title
          Text(
            page.title.tr(),
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
              shadows: const [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: smallSpacing),

          // Description
          Text(
            page.description.tr(),
            style: TextStyle(
              fontSize: descSize,
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

          // Learn More button (gizlilik ve güvenlik sayfalarında)
          if (page.showLearnMore) ...[
            SizedBox(height: smallSpacing),
            TextButton.icon(
              onPressed: page.onLearnMore,
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ),
              icon: const Icon(Icons.info_outline, size: 18),
              label: Text(
                'learn_more'.tr(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],

          // Risk information (only for the last page)
          if (page.isRiskPage) ...[
            SizedBox(height: spacing),
            _buildRiskSection(isLandscape),
            SizedBox(height: smallSpacing),
            _buildCheckboxSection(isLandscape, page),
          ],
        ],
      ),
    );
  }

  Widget _buildRiskSection(bool isLandscape) {
    return Container(
      padding: EdgeInsets.all(isLandscape ? 16 : 20),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'onboarding_risk_title'.tr(),
            style: TextStyle(
              fontSize: isLandscape ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isLandscape ? 10 : 15),

          // Risk items with smaller spacing
          _buildRiskItem('onboarding_risk_1'.tr(), isLandscape),
          SizedBox(height: isLandscape ? 6 : 8),
          _buildRiskItem('onboarding_risk_2'.tr(), isLandscape),
          SizedBox(height: isLandscape ? 6 : 8),
          _buildRiskItem('onboarding_risk_3'.tr(), isLandscape),
          SizedBox(height: isLandscape ? 6 : 8),
          _buildRiskItem('onboarding_risk_4'.tr(), isLandscape),
        ],
      ),
    );
  }

  Widget _buildCheckboxSection(bool isLandscape, OnboardingPage page) {
    return Container(
      padding: EdgeInsets.all(isLandscape ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _riskAccepted = !_riskAccepted;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _riskAccepted ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: _riskAccepted
                      ? [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.3),
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
                  style: TextStyle(
                    fontSize: isLandscape ? 14 : 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRiskItem(String text, bool isLandscape) {
    return Text(
      text,
      style: TextStyle(
        fontSize: isLandscape ? 12 : 14,
        color: Colors.white.withValues(alpha: 0.9),
        height: 1.4,
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
  final bool showLearnMore;
  final VoidCallback? onLearnMore;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
    this.isRiskPage = false,
    this.showLearnMore = false,
    this.onLearnMore,
  });
}
