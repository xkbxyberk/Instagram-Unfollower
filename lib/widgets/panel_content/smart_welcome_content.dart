import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../utils/instagram_colors.dart';
import '../../utils/dark_theme_colors.dart';

class SmartWelcomeContent extends StatelessWidget {
  final Animation<double> pulseAnimation;
  final VoidCallback onAnalyzePressed;
  final VoidCallback onManualInputPressed;
  final VoidCallback onRetriggerDetection;
  final String currentUsername;
  final bool isUserDetected;

  const SmartWelcomeContent({
    super.key,
    required this.pulseAnimation,
    required this.onAnalyzePressed,
    required this.onManualInputPressed,
    required this.onRetriggerDetection,
    required this.currentUsername,
    required this.isUserDetected,
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
          ScaleTransition(
            scale: pulseAnimation,
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isUserDetected
                      ? [
                          Colors.green.shade800
                              .withValues(alpha: isDark ? 0.4 : 0.1),
                          Colors.green.shade600
                              .withValues(alpha: isDark ? 0.5 : 0.2),
                        ]
                      : [
                          Colors.blue.shade800
                              .withValues(alpha: isDark ? 0.4 : 0.1),
                          Colors.blue.shade600
                              .withValues(alpha: isDark ? 0.5 : 0.2),
                        ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: isUserDetected
                        ? Colors.green.withValues(alpha: 0.3)
                        : Colors.blue.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                isUserDetected
                    ? Icons.verified_user_outlined
                    : Icons.person_search_outlined,
                size: 70,
                color: isUserDetected
                    ? Colors.green.shade600
                    : Colors.blue.shade600,
              ),
            ),
          ),
          const SizedBox(height: 30),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: isUserDetected
                  ? [Colors.green.shade600, Colors.green.shade800]
                  : [gradientColors[2], gradientColors[4]],
            ).createShader(bounds),
            child: Text(
              isUserDetected
                  ? 'connected_successfully'.tr()
                  : 'Kullanıcı Tespiti',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 18),
          if (isUserDetected && currentUsername.isNotEmpty) ...[
            // Tespit edilen kullanıcı bilgisi
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.shade50.withValues(alpha: isDark ? 0.1 : 1.0),
                    Colors.green.shade100.withValues(alpha: isDark ? 0.2 : 1.0),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.green.shade300
                      .withValues(alpha: isDark ? 0.5 : 1.0),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_circle,
                    color: Colors.green.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '@$currentUsername',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.check_circle,
                    color: Colors.green.shade600,
                    size: 16,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'ready_to_analyze'.tr(),
              style: TextStyle(
                fontSize: 16,
                color: _getSecondaryTextColor(context, isDark),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ] else ...[
            // Kullanıcı tespit edilmedi
            Text(
              'Hesabınız otomatik tespit edilemedi. Manuel olarak giriş yapabilir veya farklı bir sayfa deneyebilirsiniz.',
              style: TextStyle(
                fontSize: 16,
                color: _getSecondaryTextColor(context, isDark),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 40),
          if (isUserDetected) ...[
            // Analiz Et butonu
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.shade500,
                    Colors.green.shade600,
                    Colors.green.shade700,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.shade400.withValues(alpha: 0.4),
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
                onPressed: onAnalyzePressed,
                icon: const Icon(
                  Icons.analytics_outlined,
                  size: 28,
                  color: Colors.white,
                ),
                label: Text(
                  'analyze_my_account'.tr(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            // Alternatif: Manuel giriş
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getSecondaryTextColor(context, isDark)
                      .withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: onManualInputPressed,
                icon: Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: _getSecondaryTextColor(context, isDark),
                ),
                label: Text(
                  'Farklı hesap analiz et',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _getSecondaryTextColor(context, isDark),
                  ),
                ),
              ),
            ),
          ] else ...[
            // Manuel giriş butonu (birincil)
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
                onPressed: onManualInputPressed,
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 24,
                  color: Colors.white,
                ),
                label: Text(
                  'Kullanıcı adı gir',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            // Yeniden tespit et butonu
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: onRetriggerDetection,
                icon: const Icon(
                  Icons.refresh_outlined,
                  size: 20,
                  color: Colors.blue,
                ),
                label: const Text(
                  'Hesabı yeniden tespit et',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getSecondaryTextColor(BuildContext context, bool isDark) {
    return isDark ? DarkThemeColors.secondaryText : Colors.grey.shade600;
  }
}
