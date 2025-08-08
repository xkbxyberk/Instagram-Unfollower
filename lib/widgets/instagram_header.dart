import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../language_selector.dart';
import '../utils/instagram_colors.dart';
import '../utils/dark_theme_colors.dart';

class InstagramHeader extends StatelessWidget {
  final Animation<double> headerAnimation;
  final bool isLoggedIn;

  const InstagramHeader({
    super.key,
    required this.headerAnimation,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = isDark
        ? DarkThemeColors.gradientColors
        : InstagramColors.gradientColors;

    return AnimatedBuilder(
      animation: headerAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                gradientColors[0].withValues(
                  alpha: 0.8 + (0.2 * headerAnimation.value),
                ),
                gradientColors[2].withValues(
                  alpha: 0.8 + (0.2 * headerAnimation.value),
                ),
                gradientColors[4].withValues(
                  alpha: 0.8 + (0.2 * headerAnimation.value),
                ),
                gradientColors[6].withValues(
                  alpha: 0.8 + (0.2 * headerAnimation.value),
                ),
              ],
              stops: [
                0.0,
                0.3 + (0.1 * headerAnimation.value),
                0.7 + (0.1 * headerAnimation.value),
                1.0,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: gradientColors[3].withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.9),
                          Colors.white.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 40,
                        height: 40,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          // Logo yüklenemezse fallback icon
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  gradientColors[0],
                                  gradientColors[2],
                                ],
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.white.withValues(alpha: 0.9),
                            ],
                          ).createShader(bounds),
                          child: Text(
                            'app_name'.tr(),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.8),
                              Colors.white.withValues(alpha: 0.6),
                            ],
                          ).createShader(bounds),
                          child: Text(
                            'app_subtitle'.tr(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const LanguageSelector(),
                  const SizedBox(width: 10),
                  if (isLoggedIn)
                    AnimatedOpacity(
                      opacity: isLoggedIn ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? DarkThemeColors.connectedColor
                                  .withValues(alpha: 0.2)
                              : Colors.green.withValues(alpha: 0.2),
                          border: Border.all(
                            color: isDark
                                ? DarkThemeColors.connectedColor
                                : Colors.green.shade300,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? DarkThemeColors.connectedColor
                                    : Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'connected'.tr(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
