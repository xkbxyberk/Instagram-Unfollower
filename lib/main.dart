import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:instagram_unfollower_app/webview_screen.dart';

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
    return MaterialApp(
      title: 'app_title'.tr(),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF833ab4)),
        useMaterial3: true,
        primaryColor: const Color(0xFF833ab4),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const WebViewScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
