import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  static const List<Map<String, String>> languages = [
    {'code': 'en_US', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'tr_TR', 'name': 'Türkçe', 'flag': '🇹🇷'},
    {'code': 'es_ES', 'name': 'Español', 'flag': '🇪🇸'},
    {'code': 'zh_CN', 'name': '中文 (简体)', 'flag': '🇨🇳'},
    {'code': 'de_DE', 'name': 'Deutsch', 'flag': '🇩🇪'},
    {'code': 'ja_JP', 'name': '日本語', 'flag': '🇯🇵'},
    {'code': 'fr_FR', 'name': 'Français', 'flag': '🇫🇷'},
    {'code': 'pt_BR', 'name': 'Português', 'flag': '🇵🇹'},
    {'code': 'ko_KR', 'name': '한국어', 'flag': '🇰🇷'},
    {'code': 'hi_IN', 'name': 'हिन्दी', 'flag': '🇮🇳'},
    {'code': 'ru_RU', 'name': 'Русский', 'flag': '🇷🇺'},
    {'code': 'ar_SA', 'name': 'العربية', 'flag': '🇸🇦'},
    {'code': 'it_IT', 'name': 'Italiano', 'flag': '🇮🇹'},
    {'code': 'id_ID', 'name': 'Bahasa Indonesia', 'flag': '🇮🇩'},
    {'code': 'nl_NL', 'name': 'Nederlands', 'flag': '🇳🇱'},
  ];

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Locale>(
      padding: EdgeInsets.zero,
      splashRadius: 20, // Dokunma efektini küçülttük
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getCurrentFlag(context.locale),
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(width: 2),
          Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 14),
        ],
      ),
      onSelected: (Locale locale) {
        context.setLocale(locale);
      },
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      offset: const Offset(0, 35),
      itemBuilder: (BuildContext context) {
        return languages.map((lang) {
          final parts = lang['code']!.split('_');
          final locale = Locale(parts[0], parts[1]);
          final isSelected = context.locale == locale;

          return PopupMenuItem<Locale>(
            value: locale,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text(lang['flag']!, style: TextStyle(fontSize: 18)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      lang['name']!,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.blue : Colors.black87,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check, color: Colors.blue, size: 18),
                ],
              ),
            ),
          );
        }).toList();
      },
    );
  }

  String _getCurrentFlag(Locale locale) {
    final current = languages.firstWhere(
      (lang) => lang['code'] == '${locale.languageCode}_${locale.countryCode}',
      orElse: () => {'flag': '🌐'},
    );
    return current['flag']!;
  }
}
