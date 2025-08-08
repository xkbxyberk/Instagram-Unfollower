import 'package:flutter/material.dart';
import 'instagram_colors.dart';

class DarkThemeColors {
  // Ana arka plan renkleri
  static const Color primaryBackground = Color(0xFF121212);
  static const Color secondaryBackground = Color(0xFF1E1E1E);
  static const Color surfaceColor = Color(0xFF2D2D2D);
  static const Color cardColor = Color(0xFF252525);

  // Metin renkleri
  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFFB3B3B3);
  static const Color disabledText = Color(0xFF666666);

  // Accent renkleri
  static const Color accentColor = Color(0xFF405DE6);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);

  // Border ve divider renkleri
  static const Color dividerColor = Color(0xFF383838);
  static const Color borderColor = Color(0xFF404040);

  // Instagram gradient renkleri - koyu tema uyumlu
  static const List<Color> gradientColors = [
    Color(0xFF5A67D8), // Daha koyu mavi
    Color(0xFF6B73FF), // Daha koyu mor-mavi
    Color(0xFF9F7AEA), // Daha koyu mor
    Color(0xFFED64A6), // Daha koyu pembe
    Color(0xFFFC8181), // Daha koyu coral
    Color(0xFFF56565), // Daha koyu kırmızı
    Color(0xFFED8936), // Daha koyu turuncu
    Color(0xFFECC94B), // Daha koyu sarı
    Color(0xFF68D391), // Daha koyu yeşil
    Color(0xFF4FD1C7), // Daha koyu teal
  ];

  // Koyu temada kullanılacak gradient kombinasyonları
  static LinearGradient get primaryGradient => LinearGradient(
        colors: [gradientColors[0], gradientColors[2]],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get secondaryGradient => LinearGradient(
        colors: [gradientColors[2], gradientColors[4]],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get headerGradient => LinearGradient(
        colors: [gradientColors[0], gradientColors[2], gradientColors[4]],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // Card shadow renkleri
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ];

  // Düşük opasiteli arka plan renkleri
  static Color get overlayBackground => Colors.black.withValues(alpha: 0.7);
  static Color get modalBackground => const Color(0xFF1A1A1A);

  // Durum renkleri
  static const Color connectedColor = Color(0xFF4CAF50);
  static const Color disconnectedColor = Color(0xFF757575);
  static const Color loadingColor = Color(0xFF2196F3);
}

// Tema uyumlu renk yardımcı sınıfı
class ThemeColors {
  static Color background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? DarkThemeColors.primaryBackground
        : Colors.white;
  }

  static Color surface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? DarkThemeColors.surfaceColor
        : Colors.grey.shade50;
  }

  static Color card(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? DarkThemeColors.cardColor
        : Colors.white;
  }

  static Color primaryText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? DarkThemeColors.primaryText
        : Colors.black87;
  }

  static Color secondaryText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? DarkThemeColors.secondaryText
        : Colors.grey.shade600;
  }

  static Color border(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? DarkThemeColors.borderColor
        : Colors.grey.shade300;
  }

  static Color divider(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? DarkThemeColors.dividerColor
        : Colors.grey.shade200;
  }

  static List<Color> instagramGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? DarkThemeColors.gradientColors
        : InstagramColors.gradientColors;
  }

  static List<BoxShadow> cardShadow(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? DarkThemeColors.cardShadow
        : [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ];
  }
}
