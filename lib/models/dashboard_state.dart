import '../services/analytics_service.dart';

class DashboardState {
  final String? selectedAccount; // null = all accounts
  final List<String> availableAccounts;
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
    this.selectedAccount,
    this.availableAccounts = const [],
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
    String? selectedAccount,
    List<String>? availableAccounts,
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
      selectedAccount: selectedAccount ?? this.selectedAccount,
      availableAccounts: availableAccounts ?? this.availableAccounts,
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

  // Load data for specific account or combined data
  static Future<DashboardState> load([String? account]) async {
    final analytics = AnalyticsService.instance;

    // Get available accounts
    final availableAccounts = await analytics.getAnalyzedAccounts();

    // Determine selected account
    String? selectedAccount = account;

    // If account is explicitly null, show combined data
    // If account is not specified and we have accounts, try to get current or last used
    if (account == null && availableAccounts.isNotEmpty) {
      selectedAccount = await analytics.getCurrentAccount();
      selectedAccount ??= await analytics.getLastUsedAccount();
    }

    // Load data based on selected account
    int totalAnalyses;
    int weeklyAnalyses;
    DateTime? lastAnalysisDate;
    SecurityAlert? currentAlert;
    List<DailyUsageData> last7DaysData;
    double weeklyTrend;
    int usageStreak;
    int bestDayCount;

    if (selectedAccount != null &&
        availableAccounts.contains(selectedAccount)) {
      // Account-specific data
      totalAnalyses = await analytics.getTotalAnalyses(selectedAccount);
      weeklyAnalyses = await analytics.getWeeklyAnalyses(selectedAccount);
      lastAnalysisDate = await analytics.getLastAnalysisDate(selectedAccount);
      currentAlert = await analytics.checkForSecurityAlerts(selectedAccount);
      last7DaysData = await analytics.getLast7DaysData(selectedAccount);
      weeklyTrend = await analytics.getWeeklyTrend(selectedAccount);
      usageStreak = await analytics.getUsageStreak(selectedAccount);
      bestDayCount = await analytics.getBestDayCount(selectedAccount);
    } else {
      // Combined data for all accounts or no accounts available
      selectedAccount = null; // Force to null for combined view
      totalAnalyses = await analytics.getCombinedTotalAnalyses();
      weeklyAnalyses = await analytics.getCombinedWeeklyAnalyses();
      lastAnalysisDate = await analytics.getCombinedLastAnalysisDate();
      currentAlert = await analytics.getCombinedSecurityAlerts();
      last7DaysData = await analytics.getCombinedLast7DaysData();
      weeklyTrend = await analytics.getCombinedWeeklyTrend();
      usageStreak = await analytics.getCombinedUsageStreak();
      bestDayCount = await analytics.getCombinedBestDayCount();
    }

    // Global data
    final daysSinceFirstUse = await analytics.getDaysSinceFirstUse();

    return DashboardState(
      selectedAccount: selectedAccount,
      availableAccounts: availableAccounts,
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

  // Check if showing combined data
  bool get isShowingCombinedData => selectedAccount == null;

  // Get display name for current selection
  String getDisplayName() {
    if (selectedAccount != null) {
      return '@$selectedAccount';
    } else {
      return 'all_accounts'; // This will be translated
    }
  }
}
