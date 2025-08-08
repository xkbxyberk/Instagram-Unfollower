import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_screen.dart';
import 'services/theme_service.dart';
import 'utils/instagram_colors.dart';
import 'utils/dark_theme_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: [
        Locale('en', 'US'), // İngilizce
        Locale('tr', 'TR'), // Türkçe
        Locale('es', 'ES'), // İspanyolca
        Locale('zh', 'CN'), // Çince (Basitleştirilmiş)
        Locale('de', 'DE'), // Almanca
        Locale('ja', 'JP'), // Japonca
        Locale('fr', 'FR'), // Fransızca
        Locale('pt', 'BR'), // Portekizce
        Locale('ko', 'KR'), // Korece
        Locale('hi', 'IN'), // Hintçe
        Locale('ru', 'RU'), // Rusça
        Locale('ar', 'SA'), // Arapça
        Locale('it', 'IT'), // İtalyanca
        Locale('id', 'ID'), // Endonezce
        Locale('nl', 'NL'), // Hollandaca
      ],
      path: 'assets/translations',
      fallbackLocale: Locale('en', 'US'),
      startLocale: null, // Sistem dilini otomatik algılar
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeService.instance,
      builder: (context, child) {
        return MaterialApp(
          title: 'app_title'.tr(),
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          theme: _lightTheme,
          darkTheme: _darkTheme,
          themeMode: ThemeService.instance.themeMode,
          home: const StartupScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }

  // Açık tema
  ThemeData get _lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: const Color(0xFF833ab4),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF833ab4),
        brightness: Brightness.light,
      ),

      // Scaffold arka planı
      scaffoldBackgroundColor: Colors.white,

      // AppBar teması
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Card teması
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 8,
        shadowColor: Colors.grey.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Elevated Button teması
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Input Decoration teması
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: InstagramColors.gradientColors[3],
            width: 2,
          ),
        ),
      ),

      // Bottom Navigation Bar teması
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF833ab4),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Text teması
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: Colors.black87,
        ),
        bodyMedium: TextStyle(
          color: Colors.black54,
        ),
      ),

      // Visual density
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  // Koyu tema
  ThemeData get _darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: DarkThemeColors.accentColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: DarkThemeColors.accentColor,
        brightness: Brightness.dark,
      ),

      // Scaffold arka planı
      scaffoldBackgroundColor: DarkThemeColors.primaryBackground,

      // AppBar teması
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: DarkThemeColors.primaryText),
        titleTextStyle: TextStyle(
          color: DarkThemeColors.primaryText,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Card teması
      cardTheme: CardThemeData(
        color: DarkThemeColors.cardColor,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Elevated Button teması
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Input Decoration teması
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DarkThemeColors.surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: DarkThemeColors.gradientColors[3],
            width: 2,
          ),
        ),
      ),

      // Bottom Navigation Bar teması
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: DarkThemeColors.secondaryBackground,
        selectedItemColor: DarkThemeColors.accentColor,
        unselectedItemColor: DarkThemeColors.secondaryText,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Text teması
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: DarkThemeColors.primaryText,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: DarkThemeColors.primaryText,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: DarkThemeColors.primaryText,
        ),
        bodyMedium: TextStyle(
          color: DarkThemeColors.secondaryText,
        ),
      ),

      // Visual density
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}

class StartupScreen extends StatelessWidget {
  const StartupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkFirstLaunch(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Yükleme ekranı
          return Scaffold(
            backgroundColor: ThemeColors.background(context),
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  ThemeColors.instagramGradient(context)[0],
                ),
              ),
            ),
          );
        }

        final isFirstLaunch = snapshot.data ?? true;

        if (isFirstLaunch) {
          return const OnboardingScreen();
        } else {
          return const MainScreen();
        }
      },
    );
  }

  Future<bool> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool('onboarding_completed') ?? false;
    return !completed; // İlk açılış = onboarding tamamlanmamış
  }
}
