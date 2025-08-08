import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

class AnalyticsService {
  static const String _keyTotalAnalyses = 'total_analyses';
  static const String _keyLastAnalysisDate = 'last_analysis_date';
  static const String _keyFirstUseDate = 'first_use_date';
  static const String _keyWeeklyAnalyses = 'weekly_analyses';
  static const String _keyLastWeekReset = 'last_week_reset';
  static const String _keyDailyAnalyses = 'daily_analyses_';
  static const String _keyUsageStreak = 'usage_streak';
  static const String _keyBestDay = 'best_day';

  static AnalyticsService? _instance;
  static AnalyticsService get instance {
    _instance ??= AnalyticsService._();
    return _instance!;
  }

  AnalyticsService._();

  // Toplam analiz sayısını artır
  Future<void> recordAnalysis() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    // İlk kullanım tarihini kaydet
    if (!prefs.containsKey(_keyFirstUseDate)) {
      await prefs.setString(_keyFirstUseDate, now.toIso8601String());
    }

    // Toplam analiz sayısını artır
    final totalAnalyses = await getTotalAnalyses();
    await prefs.setInt(_keyTotalAnalyses, totalAnalyses + 1);

    // Son analiz tarihini kaydet
    await prefs.setString(_keyLastAnalysisDate, now.toIso8601String());

    // Haftalık analiz sayısını artır
    await _updateWeeklyAnalyses();

    // Günlük analiz sayısını artır
    await _updateDailyAnalyses(now);

    // Kullanım streak'ini güncelle
    await _updateUsageStreak(now);
  }

  // Günlük analiz sayısını güncelle
  Future<void> _updateDailyAnalyses(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final dateKey = _getDayKey(date);
    final currentCount = prefs.getInt('$_keyDailyAnalyses$dateKey') ?? 0;
    await prefs.setInt('$_keyDailyAnalyses$dateKey', currentCount + 1);

    // En iyi günü kontrol et
    final bestDayCount = await getBestDayCount();
    if (currentCount + 1 > bestDayCount) {
      await prefs.setString(_keyBestDay, dateKey);
    }
  }

  // Kullanım streak'ini güncelle
  Future<void> _updateUsageStreak(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final lastAnalysis = await getLastAnalysisDate();

    if (lastAnalysis != null) {
      final daysSinceLastAnalysis = date.difference(lastAnalysis).inDays;

      if (daysSinceLastAnalysis <= 1) {
        // Streak devam ediyor
        final currentStreak = await getUsageStreak();
        await prefs.setInt(_keyUsageStreak, currentStreak + 1);
      } else if (daysSinceLastAnalysis > 1) {
        // Streak kırıldı
        await prefs.setInt(_keyUsageStreak, 1);
      }
    } else {
      // İlk analiz
      await prefs.setInt(_keyUsageStreak, 1);
    }
  }

  // Günlük analiz sayısını getir
  Future<int> getDailyAnalyses(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final dateKey = _getDayKey(date);
    return prefs.getInt('$_keyDailyAnalyses$dateKey') ?? 0;
  }

  // Son 7 günün verilerini getir
  Future<List<DailyUsageData>> getLast7DaysData() async {
    final now = DateTime.now();
    final List<DailyUsageData> data = [];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final count = await getDailyAnalyses(date);
      data.add(DailyUsageData(
        date: date,
        analysisCount: count,
        dayName: _getDayName(date.weekday),
      ));
    }

    return data;
  }

  // Kullanım streak'ini getir
  Future<int> getUsageStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUsageStreak) ?? 0;
  }

  // En iyi gün analiz sayısını getir
  Future<int> getBestDayCount() async {
    final prefs = await SharedPreferences.getInstance();
    final bestDayKey = prefs.getString(_keyBestDay);
    if (bestDayKey != null) {
      return prefs.getInt('$_keyDailyAnalyses$bestDayKey') ?? 0;
    }
    return 0;
  }

  // Haftalık trend hesapla (artış/azalış yüzdesi)
  Future<double> getWeeklyTrend() async {
    final data = await getLast7DaysData();
    if (data.length < 7) return 0.0;

    final thisWeekSum = data
        .skip(3)
        .take(4)
        .map((e) => e.analysisCount)
        .fold(0, (a, b) => a + b);
    final lastWeekSum =
        data.take(3).map((e) => e.analysisCount).fold(0, (a, b) => a + b);

    if (lastWeekSum == 0 && thisWeekSum == 0) return 0.0;
    if (lastWeekSum == 0) return 100.0;

    return ((thisWeekSum - lastWeekSum) / lastWeekSum * 100);
  }

  // Toplam analiz sayısını getir
  Future<int> getTotalAnalyses() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyTotalAnalyses) ?? 0;
  }

  // Son analiz tarihini getir
  Future<DateTime?> getLastAnalysisDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = prefs.getString(_keyLastAnalysisDate);
    if (dateStr != null) {
      return DateTime.parse(dateStr);
    }
    return null;
  }

  // İlk kullanım tarihini getir
  Future<DateTime?> getFirstUseDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = prefs.getString(_keyFirstUseDate);
    if (dateStr != null) {
      return DateTime.parse(dateStr);
    }
    return null;
  }

  // Bu haftaki analiz sayısını getir
  Future<int> getWeeklyAnalyses() async {
    await _resetWeeklyCountIfNeeded();
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyWeeklyAnalyses) ?? 0;
  }

  // Haftalık analiz sayısını artır
  Future<void> _updateWeeklyAnalyses() async {
    await _resetWeeklyCountIfNeeded();
    final prefs = await SharedPreferences.getInstance();
    final weeklyCount = prefs.getInt(_keyWeeklyAnalyses) ?? 0;
    await prefs.setInt(_keyWeeklyAnalyses, weeklyCount + 1);
  }

  // Haftanın başında sayacı sıfırla
  Future<void> _resetWeeklyCountIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final lastResetStr = prefs.getString(_keyLastWeekReset);
    final now = DateTime.now();

    DateTime? lastReset;
    if (lastResetStr != null) {
      lastReset = DateTime.parse(lastResetStr);
    }

    // Haftanın başlangıcını hesapla (Pazartesi)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    if (lastReset == null || lastReset.isBefore(startOfWeek)) {
      await prefs.setInt(_keyWeeklyAnalyses, 0);
      await prefs.setString(_keyLastWeekReset, now.toIso8601String());
    }
  }

  // Güvenlik uyarısı gerekli mi kontrol et - ÇEVİRİ ANAHTARLARI İLE
  Future<SecurityAlert?> checkForSecurityAlerts() async {
    final weeklyCount = await getWeeklyAnalyses();
    final lastAnalysis = await getLastAnalysisDate();

    // Bu hafta çok fazla analiz yapıldıysa uyar
    if (weeklyCount >= 10) {
      return SecurityAlert(
        type: SecurityAlertType.overuse,
        messageKey: 'weekly_limit_exceeded',
        messageArgs: [weeklyCount.toString()],
        subtitleKey: 'take_a_break',
        severity: AlertSeverity.high,
      );
    } else if (weeklyCount >= 7) {
      return SecurityAlert(
        type: SecurityAlertType.warning,
        messageKey: 'weekly_limit_approaching',
        messageArgs: [weeklyCount.toString()],
        subtitleKey: 'use_responsibly',
        severity: AlertSeverity.medium,
      );
    }

    // Son analiz zamanı kontrolü
    if (lastAnalysis != null) {
      final hoursSinceLastAnalysis =
          DateTime.now().difference(lastAnalysis).inHours;

      if (hoursSinceLastAnalysis < 1) {
        return SecurityAlert(
          type: SecurityAlertType.recentActivity,
          messageKey: 'last_analysis_time',
          messageArgs: ['just_now'],
          subtitleKey: 'avoid_frequent_analysis',
          severity: AlertSeverity.low,
        );
      } else if (hoursSinceLastAnalysis < 6) {
        return SecurityAlert(
          type: SecurityAlertType.recentActivity,
          messageKey: 'last_analysis_time',
          messageArgs: ['hours_ago:${hoursSinceLastAnalysis.toString()}'],
          subtitleKey: 'normal_usage_range',
          severity: AlertSeverity.low,
        );
      }
    }

    return null; // Güvenli durum
  }

  // Uygulama kullanım süresini getir
  Future<int> getDaysSinceFirstUse() async {
    final firstUse = await getFirstUseDate();
    if (firstUse != null) {
      return DateTime.now().difference(firstUse).inDays;
    }
    return 0;
  }

  // Helper methods
  String _getDayKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Pzt';
      case 2:
        return 'Sal';
      case 3:
        return 'Çar';
      case 4:
        return 'Per';
      case 5:
        return 'Cum';
      case 6:
        return 'Cmt';
      case 7:
        return 'Paz';
      default:
        return '';
    }
  }
}

class SecurityAlert {
  final SecurityAlertType type;
  final String messageKey; // Çeviri anahtarı
  final List<String>? messageArgs; // Çeviri argümanları
  final String? subtitleKey; // Çeviri anahtarı
  final List<String>? subtitleArgs; // Çeviri argümanları
  final AlertSeverity severity;

  SecurityAlert({
    required this.type,
    required this.messageKey,
    this.messageArgs,
    this.subtitleKey,
    this.subtitleArgs,
    required this.severity,
  });

  // Çevrilmiş mesajı getir
  String getMessage() {
    if (messageArgs != null && messageArgs!.isNotEmpty) {
      // Özel args işleme - "hours_ago:3" gibi durumlar için
      final processedArgs = messageArgs!.map((arg) {
        if (arg.contains(':')) {
          final parts = arg.split(':');
          if (parts.length == 2) {
            return parts[0].tr(args: [parts[1]]);
          }
        }
        return arg.tr();
      }).toList();
      return messageKey.tr(args: processedArgs);
    }
    return messageKey.tr();
  }

  // Çevrilmiş alt başlığı getir
  String? getSubtitle() {
    if (subtitleKey == null) return null;
    if (subtitleArgs != null && subtitleArgs!.isNotEmpty) {
      return subtitleKey!.tr(args: subtitleArgs!);
    }
    return subtitleKey!.tr();
  }
}

enum SecurityAlertType {
  overuse,
  warning,
  recentActivity,
  frequency,
}

enum AlertSeverity {
  low,
  medium,
  high,
}

class DailyUsageData {
  final DateTime date;
  final int analysisCount;
  final String dayName;

  DailyUsageData({
    required this.date,
    required this.analysisCount,
    required this.dayName,
  });
}
