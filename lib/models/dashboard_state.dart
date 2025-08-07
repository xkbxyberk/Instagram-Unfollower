import '../services/analytics_service.dart';

class DashboardState {
  final int totalAnalyses;
  final int weeklyAnalyses;
  final DateTime? lastAnalysisDate;
  final int daysSinceFirstUse;
  final SecurityAlert? currentAlert;
  final bool isLoading;
  final List<DailyUsageData> last7DaysData;
  final double weeklyTrend;
  final int usageStreak;
  final int bestDayCount;

  DashboardState({
    this.totalAnalyses = 0,
    this.weeklyAnalyses = 0,
    this.lastAnalysisDate,
    this.daysSinceFirstUse = 0,
    this.currentAlert,
    this.isLoading = false,
    this.last7DaysData = const [],
    this.weeklyTrend = 0.0,
    this.usageStreak = 0,
    this.bestDayCount = 0,
  });

  DashboardState copyWith({
    int? totalAnalyses,
    int? weeklyAnalyses,
    DateTime? lastAnalysisDate,
    int? daysSinceFirstUse,
    SecurityAlert? currentAlert,
    bool? isLoading,
    List<DailyUsageData>? last7DaysData,
    double? weeklyTrend,
    int? usageStreak,
    int? bestDayCount,
  }) {
    return DashboardState(
      totalAnalyses: totalAnalyses ?? this.totalAnalyses,
      weeklyAnalyses: weeklyAnalyses ?? this.weeklyAnalyses,
      lastAnalysisDate: lastAnalysisDate ?? this.lastAnalysisDate,
      daysSinceFirstUse: daysSinceFirstUse ?? this.daysSinceFirstUse,
      currentAlert: currentAlert ?? this.currentAlert,
      isLoading: isLoading ?? this.isLoading,
      last7DaysData: last7DaysData ?? this.last7DaysData,
      weeklyTrend: weeklyTrend ?? this.weeklyTrend,
      usageStreak: usageStreak ?? this.usageStreak,
      bestDayCount: bestDayCount ?? this.bestDayCount,
    );
  }

  static Future<DashboardState> load() async {
    final analytics = AnalyticsService.instance;

    final totalAnalyses = await analytics.getTotalAnalyses();
    final weeklyAnalyses = await analytics.getWeeklyAnalyses();
    final lastAnalysisDate = await analytics.getLastAnalysisDate();
    final daysSinceFirstUse = await analytics.getDaysSinceFirstUse();
    final currentAlert = await analytics.checkForSecurityAlerts();
    final last7DaysData = await analytics.getLast7DaysData();
    final weeklyTrend = await analytics.getWeeklyTrend();
    final usageStreak = await analytics.getUsageStreak();
    final bestDayCount = await analytics.getBestDayCount();

    return DashboardState(
      totalAnalyses: totalAnalyses,
      weeklyAnalyses: weeklyAnalyses,
      lastAnalysisDate: lastAnalysisDate,
      daysSinceFirstUse: daysSinceFirstUse,
      currentAlert: currentAlert,
      last7DaysData: last7DaysData,
      weeklyTrend: weeklyTrend,
      usageStreak: usageStreak,
      bestDayCount: bestDayCount,
    );
  }
}
