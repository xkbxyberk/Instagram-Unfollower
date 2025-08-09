import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

class AnalyticsService {
  static const String _keyAccountsList = 'accounts_list';
  static const String _keyCurrentAccount = 'current_account';
  static const String _keyFirstUseDate = 'first_use_date';

  // Account specific keys (with account prefix)
  static const String _keyTotalAnalyses = 'total_analyses';
  static const String _keyLastAnalysisDate = 'last_analysis_date';
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

  // Get account-specific key
  String _getAccountKey(String account, String key) {
    return '${account}_$key';
  }

  // Get all analyzed accounts
  Future<List<String>> getAnalyzedAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final accounts = prefs.getStringList(_keyAccountsList) ?? [];
    return accounts;
  }

  // Add account to the list if not exists
  Future<void> _addAccountToList(String account) async {
    final prefs = await SharedPreferences.getInstance();
    final accounts = await getAnalyzedAccounts();
    if (!accounts.contains(account)) {
      accounts.add(account);
      await prefs.setStringList(_keyAccountsList, accounts);
    }
  }

  // Get current selected account
  Future<String?> getCurrentAccount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCurrentAccount);
  }

  // Set current selected account
  Future<void> setCurrentAccount(String account) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCurrentAccount, account);
  }

  // Clear current account (for "All Accounts" view)
  Future<void> clearCurrentAccount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCurrentAccount);
  }

  // Get last used account (most recent analysis)
  Future<String?> getLastUsedAccount() async {
    final accounts = await getAnalyzedAccounts();
    if (accounts.isEmpty) return null;

    String? lastAccount;
    DateTime? lastDate;

    for (final account in accounts) {
      final accountLastDate = await getLastAnalysisDate(account);
      if (accountLastDate != null &&
          (lastDate == null || accountLastDate.isAfter(lastDate))) {
        lastDate = accountLastDate;
        lastAccount = account;
      }
    }

    return lastAccount;
  }

  // Record analysis for specific account
  Future<void> recordAnalysis(String account) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    // Add account to list
    await _addAccountToList(account);

    // Set as current account
    await setCurrentAccount(account);

    // İlk kullanım tarihini kaydet (global)
    if (!prefs.containsKey(_keyFirstUseDate)) {
      await prefs.setString(_keyFirstUseDate, now.toIso8601String());
    }

    // Account specific data
    final totalKey = _getAccountKey(account, _keyTotalAnalyses);
    final lastDateKey = _getAccountKey(account, _keyLastAnalysisDate);

    // Toplam analiz sayısını artır
    final totalAnalyses = await getTotalAnalyses(account);
    await prefs.setInt(totalKey, totalAnalyses + 1);

    // Son analiz tarihini kaydet
    await prefs.setString(lastDateKey, now.toIso8601String());

    // Haftalık analiz sayısını artır
    await _updateWeeklyAnalyses(account);

    // Günlük analiz sayısını artır
    await _updateDailyAnalyses(account, now);

    // Kullanım streak'ini güncelle
    await _updateUsageStreak(account, now);
  }

  // Günlük analiz sayısını güncelle
  Future<void> _updateDailyAnalyses(String account, DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final dateKey = _getDayKey(date);
    final dailyKey = _getAccountKey(account, '$_keyDailyAnalyses$dateKey');
    final currentCount = prefs.getInt(dailyKey) ?? 0;
    await prefs.setInt(dailyKey, currentCount + 1);

    // En iyi günü kontrol et
    final bestDayCount = await getBestDayCount(account);
    if (currentCount + 1 > bestDayCount) {
      final bestDayKey = _getAccountKey(account, _keyBestDay);
      await prefs.setString(bestDayKey, dateKey);
    }
  }

  // Kullanım streak'ini güncelle
  Future<void> _updateUsageStreak(String account, DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final lastAnalysis = await getLastAnalysisDate(account);
    final streakKey = _getAccountKey(account, _keyUsageStreak);

    if (lastAnalysis != null) {
      final daysSinceLastAnalysis = date.difference(lastAnalysis).inDays;

      if (daysSinceLastAnalysis <= 1) {
        // Streak devam ediyor
        final currentStreak = await getUsageStreak(account);
        await prefs.setInt(streakKey, currentStreak + 1);
      } else if (daysSinceLastAnalysis > 1) {
        // Streak kırıldı
        await prefs.setInt(streakKey, 1);
      }
    } else {
      // İlk analiz
      await prefs.setInt(streakKey, 1);
    }
  }

  // Günlük analiz sayısını getir
  Future<int> getDailyAnalyses(String account, DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final dateKey = _getDayKey(date);
    final dailyKey = _getAccountKey(account, '$_keyDailyAnalyses$dateKey');
    return prefs.getInt(dailyKey) ?? 0;
  }

  // Son 7 günün verilerini getir
  Future<List<DailyUsageData>> getLast7DaysData(String account) async {
    final now = DateTime.now();
    final List<DailyUsageData> data = [];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final count = await getDailyAnalyses(account, date);
      data.add(DailyUsageData(
        date: date,
        analysisCount: count,
        dayName: _getDayName(date.weekday),
      ));
    }

    return data;
  }

  // Combined data for all accounts
  Future<List<DailyUsageData>> getCombinedLast7DaysData() async {
    final now = DateTime.now();
    final accounts = await getAnalyzedAccounts();
    final List<DailyUsageData> data = [];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      int totalCount = 0;

      for (final account in accounts) {
        totalCount += await getDailyAnalyses(account, date);
      }

      data.add(DailyUsageData(
        date: date,
        analysisCount: totalCount,
        dayName: _getDayName(date.weekday),
      ));
    }

    return data;
  }

  // Kullanım streak'ini getir
  Future<int> getUsageStreak(String account) async {
    final prefs = await SharedPreferences.getInstance();
    final streakKey = _getAccountKey(account, _keyUsageStreak);
    return prefs.getInt(streakKey) ?? 0;
  }

  // En iyi gün analiz sayısını getir
  Future<int> getBestDayCount(String account) async {
    final prefs = await SharedPreferences.getInstance();
    final bestDayKey = _getAccountKey(account, _keyBestDay);
    final bestDayString = prefs.getString(bestDayKey);
    if (bestDayString != null) {
      final dailyKey =
          _getAccountKey(account, '$_keyDailyAnalyses$bestDayString');
      return prefs.getInt(dailyKey) ?? 0;
    }
    return 0;
  }

  // Combined best day count
  Future<int> getCombinedBestDayCount() async {
    final accounts = await getAnalyzedAccounts();
    int maxCount = 0;

    for (final account in accounts) {
      final count = await getBestDayCount(account);
      if (count > maxCount) {
        maxCount = count;
      }
    }

    return maxCount;
  }

  // Haftalık trend hesapla
  Future<double> getWeeklyTrend(String account) async {
    final data = await getLast7DaysData(account);
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

  // Combined weekly trend
  Future<double> getCombinedWeeklyTrend() async {
    final data = await getCombinedLast7DaysData();
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
  Future<int> getTotalAnalyses(String account) async {
    final prefs = await SharedPreferences.getInstance();
    final totalKey = _getAccountKey(account, _keyTotalAnalyses);
    return prefs.getInt(totalKey) ?? 0;
  }

  // Combined total analyses
  Future<int> getCombinedTotalAnalyses() async {
    final accounts = await getAnalyzedAccounts();
    int total = 0;

    for (final account in accounts) {
      total += await getTotalAnalyses(account);
    }

    return total;
  }

  // Son analiz tarihini getir
  Future<DateTime?> getLastAnalysisDate(String account) async {
    final prefs = await SharedPreferences.getInstance();
    final lastDateKey = _getAccountKey(account, _keyLastAnalysisDate);
    final dateStr = prefs.getString(lastDateKey);
    if (dateStr != null) {
      return DateTime.parse(dateStr);
    }
    return null;
  }

  // Combined last analysis date
  Future<DateTime?> getCombinedLastAnalysisDate() async {
    final accounts = await getAnalyzedAccounts();
    DateTime? lastDate;

    for (final account in accounts) {
      final accountLastDate = await getLastAnalysisDate(account);
      if (accountLastDate != null &&
          (lastDate == null || accountLastDate.isAfter(lastDate))) {
        lastDate = accountLastDate;
      }
    }

    return lastDate;
  }

  // İlk kullanım tarihini getir (global)
  Future<DateTime?> getFirstUseDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = prefs.getString(_keyFirstUseDate);
    if (dateStr != null) {
      return DateTime.parse(dateStr);
    }
    return null;
  }

  // Bu haftaki analiz sayısını getir
  Future<int> getWeeklyAnalyses(String account) async {
    await _resetWeeklyCountIfNeeded(account);
    final prefs = await SharedPreferences.getInstance();
    final weeklyKey = _getAccountKey(account, _keyWeeklyAnalyses);
    return prefs.getInt(weeklyKey) ?? 0;
  }

  // Combined weekly analyses
  Future<int> getCombinedWeeklyAnalyses() async {
    final accounts = await getAnalyzedAccounts();
    int total = 0;

    for (final account in accounts) {
      total += await getWeeklyAnalyses(account);
    }

    return total;
  }

  // Haftalık analiz sayısını artır
  Future<void> _updateWeeklyAnalyses(String account) async {
    await _resetWeeklyCountIfNeeded(account);
    final prefs = await SharedPreferences.getInstance();
    final weeklyKey = _getAccountKey(account, _keyWeeklyAnalyses);
    final weeklyCount = prefs.getInt(weeklyKey) ?? 0;
    await prefs.setInt(weeklyKey, weeklyCount + 1);
  }

  // Haftanın başında sayacı sıfırla
  Future<void> _resetWeeklyCountIfNeeded(String account) async {
    final prefs = await SharedPreferences.getInstance();
    final resetKey = _getAccountKey(account, _keyLastWeekReset);
    final lastResetStr = prefs.getString(resetKey);
    final now = DateTime.now();

    DateTime? lastReset;
    if (lastResetStr != null) {
      lastReset = DateTime.parse(lastResetStr);
    }

    // Haftanın başlangıcını hesapla (Pazartesi)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    if (lastReset == null || lastReset.isBefore(startOfWeek)) {
      final weeklyKey = _getAccountKey(account, _keyWeeklyAnalyses);
      await prefs.setInt(weeklyKey, 0);
      await prefs.setString(resetKey, now.toIso8601String());
    }
  }

  // Güvenlik uyarısı gerekli mi kontrol et
  Future<SecurityAlert?> checkForSecurityAlerts(String account) async {
    final weeklyCount = await getWeeklyAnalyses(account);
    final lastAnalysis = await getLastAnalysisDate(account);

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

  // Combined security alerts - en yüksek severity'li uyarıyı döndür
  Future<SecurityAlert?> getCombinedSecurityAlerts() async {
    final accounts = await getAnalyzedAccounts();
    SecurityAlert? highestAlert;

    for (final account in accounts) {
      final alert = await checkForSecurityAlerts(account);
      if (alert != null) {
        if (highestAlert == null ||
            alert.severity.index > highestAlert.severity.index) {
          highestAlert = alert;
        }
      }
    }

    return highestAlert;
  }

  // Uygulama kullanım süresini getir (global)
  Future<int> getDaysSinceFirstUse() async {
    final firstUse = await getFirstUseDate();
    if (firstUse != null) {
      return DateTime.now().difference(firstUse).inDays;
    }
    return 0;
  }

  // Combined usage streak - en yüksek streak
  Future<int> getCombinedUsageStreak() async {
    final accounts = await getAnalyzedAccounts();
    int maxStreak = 0;

    for (final account in accounts) {
      final streak = await getUsageStreak(account);
      if (streak > maxStreak) {
        maxStreak = streak;
      }
    }

    return maxStreak;
  }

  // Helper methods
  String _getDayKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'day_monday'.tr();
      case 2:
        return 'day_tuesday'.tr();
      case 3:
        return 'day_wednesday'.tr();
      case 4:
        return 'day_thursday'.tr();
      case 5:
        return 'day_friday'.tr();
      case 6:
        return 'day_saturday'.tr();
      case 7:
        return 'day_sunday'.tr();
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
