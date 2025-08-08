import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../utils/instagram_colors.dart';
import '../utils/dark_theme_colors.dart';

class PanelHeader extends StatelessWidget {
  final bool hasResults;
  final String currentUsername;
  final VoidCallback onClose;

  const PanelHeader({
    super.key,
    required this.hasResults,
    required this.currentUsername,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = isDark
        ? DarkThemeColors.gradientColors
        : InstagramColors.gradientColors;

    return Container(
      padding: EdgeInsets.fromLTRB(20, topPadding + 12, 20, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [gradientColors[0], gradientColors[2], gradientColors[4]],
        ),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Sol taraf - Sadece görsel ikon (overlay yok)
              Icon(
                hasResults ? Icons.list_alt_rounded : Icons.analytics_outlined,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'instagram_analysis'.tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasResults
                          ? 'analysis_completed'.tr()
                          : 'analysis_center'.tr(),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              // Sağ taraf - Aktif buton (overlay ile)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  onPressed: onClose,
                  padding: const EdgeInsets.all(8),
                  constraints:
                      const BoxConstraints(minWidth: 36, minHeight: 36),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          if (currentUsername.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.account_circle_outlined,
                    color: Colors.white.withValues(alpha: 0.9),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      '@${currentUsername.length > 15 ? '${currentUsername.substring(0, 15)}...' : currentUsername}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
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
