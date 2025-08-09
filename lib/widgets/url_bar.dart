import 'package:flutter/material.dart';
import '../utils/dark_theme_colors.dart';

class UrlBar extends StatelessWidget {
  final String currentUrl;
  final VoidCallback onRefresh;
  final bool isLoading;

  const UrlBar({
    super.key,
    required this.currentUrl,
    required this.onRefresh,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color:
            isDark ? DarkThemeColors.secondaryBackground : Colors.grey.shade50,
        border: Border(
          top: BorderSide(
            color: isDark ? DarkThemeColors.borderColor : Colors.grey.shade300,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            // SSL Lock Icon
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _getSecurityColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                _getSecurityIcon(),
                color: _getSecurityColor(),
                size: 14,
              ),
            ),
            const SizedBox(width: 8),

            // URL Container
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? DarkThemeColors.surfaceColor : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark
                        ? DarkThemeColors.borderColor
                        : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.language,
                      color: isDark
                          ? DarkThemeColors.secondaryText
                          : Colors.grey.shade600,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _formatUrl(currentUrl),
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? DarkThemeColors.primaryText
                              : Colors.black87,
                          fontWeight: FontWeight.w500,
                          fontFamily:
                              'monospace', // Monospace font for better URL reading
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Refresh Button
            Container(
              decoration: BoxDecoration(
                color: ThemeColors.instagramGradient(context)[0]
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: IconButton(
                onPressed: isLoading ? null : onRefresh,
                padding: const EdgeInsets.all(6),
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isLoading
                      ? SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              ThemeColors.instagramGradient(context)[0],
                            ),
                          ),
                        )
                      : Icon(
                          Icons.refresh,
                          color: ThemeColors.instagramGradient(context)[0],
                          size: 16,
                        ),
                ),
                tooltip: 'Sayfayı Yenile',
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatUrl(String url) {
    if (url.isEmpty) return 'Sayfa yükleniyor...';

    try {
      // Tam URL'yi göster, sadece protokolü kaldır
      String displayUrl = url;

      if (displayUrl.startsWith('https://')) {
        displayUrl = displayUrl.substring(8);
      } else if (displayUrl.startsWith('http://')) {
        displayUrl = displayUrl.substring(7);
      }

      // Çok uzunsa kısalt
      if (displayUrl.length > 45) {
        // İlk 20 karakter + ... + son 20 karakter
        final start = displayUrl.substring(0, 20);
        final end = displayUrl.substring(displayUrl.length - 20);
        displayUrl = '$start...$end';
      }

      return displayUrl;
    } catch (e) {
      return url;
    }
  }

  Color _getSecurityColor() {
    if (currentUrl.startsWith('https://')) {
      return Colors.green;
    } else if (currentUrl.startsWith('http://')) {
      return Colors.orange;
    }
    return Colors.grey;
  }

  IconData _getSecurityIcon() {
    if (currentUrl.startsWith('https://')) {
      return Icons.lock;
    } else if (currentUrl.startsWith('http://')) {
      return Icons.lock_open;
    }
    return Icons.public;
  }
}
