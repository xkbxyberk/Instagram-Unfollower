import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../utils/instagram_colors.dart';
import '../utils/dark_theme_colors.dart';
import '../models/dashboard_state.dart';
import '../services/analytics_service.dart';
import '../widgets/mini_chart.dart';
import '../widgets/progress_ring.dart';
import '../widgets/trend_indicator.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onStartAnalysis;

  const HomeScreen({
    super.key,
    this.onStartAnalysis,
  });

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  DashboardState _dashboardState = DashboardState(isLoading: true);

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final state = await DashboardState.load();
    if (mounted) {
      setState(() {
        _dashboardState = state;
      });
    }
  }

  Future<void> refreshDashboard() async {
    setState(() {
      _dashboardState = _dashboardState.copyWith(isLoading: true);
    });
    await _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    DarkThemeColors.gradientColors[0].withValues(alpha: 0.1),
                    DarkThemeColors.gradientColors[4].withValues(alpha: 0.1),
                    DarkThemeColors.primaryBackground,
                  ]
                : [
                    InstagramColors.gradientColors[0].withValues(alpha: 0.05),
                    InstagramColors.gradientColors[4].withValues(alpha: 0.05),
                    Colors.white,
                  ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: refreshDashboard,
            color: ThemeColors.instagramGradient(context)[0],
            backgroundColor: ThemeColors.card(context),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Welcome Header
                  _buildWelcomeHeader(isDark),

                  const SizedBox(height: 30),

                  // Main Stats Row
                  if (_dashboardState.isLoading)
                    _buildLoadingState(isDark)
                  else ...[
                    _buildMainStatsRow(isDark),
                    const SizedBox(height: 20),
                    _buildActivitySection(isDark),
                    const SizedBox(height: 20),
                    _buildProgressSection(isDark),
                  ],

                  // Alert Section
                  if (_dashboardState.currentAlert != null) ...[
                    const SizedBox(height: 20),
                    _buildAlertCard(_dashboardState.currentAlert!, isDark),
                  ],

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: isDark
                ? [
                    DarkThemeColors.gradientColors[0],
                    DarkThemeColors.gradientColors[4],
                  ]
                : [
                    InstagramColors.gradientColors[0],
                    InstagramColors.gradientColors[4],
                  ],
          ).createShader(bounds),
          child: Text(
            'welcome_back'.tr(),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'dashboard_subtitle'.tr(),
          style: TextStyle(
            fontSize: 16,
            color: ThemeColors.secondaryText(context),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildMainStatsRow(bool isDark) {
    return Row(
      children: [
        Expanded(child: _buildSecurityStatusCard(isDark)),
        const SizedBox(width: 15),
        Expanded(child: _buildTotalAnalysesCard(isDark)),
      ],
    );
  }

  Widget _buildActivitySection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeColors.card(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: ThemeColors.cardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.bar_chart_outlined,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'weekly_activity'.tr(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ThemeColors.primaryText(context),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '${_dashboardState.weeklyAnalyses} ${'this_week'.tr()}',
                          style: TextStyle(
                            fontSize: 14,
                            color: ThemeColors.secondaryText(context),
                          ),
                        ),
                        const SizedBox(width: 10),
                        TrendIndicator(
                          trend: _dashboardState.weeklyTrend,
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            child: MiniChart(
              data: _dashboardState.last7DaysData,
              color: Colors.blue,
              height: 80,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(bool isDark) {
    return Row(
      children: [
        Expanded(child: _buildUsageProgressCard(isDark)),
        const SizedBox(width: 15),
        Expanded(child: _buildStreakCard(isDark)),
      ],
    );
  }

  Widget _buildUsageProgressCard(bool isDark) {
    final progress = (_dashboardState.weeklyAnalyses / 10).clamp(0.0, 1.0);
    Color progressColor = Colors.green;
    String progressText = 'progress_safe'.tr();

    if (progress >= 0.8) {
      progressColor = Colors.red;
      progressText = 'progress_danger'.tr();
    } else if (progress >= 0.5) {
      progressColor = Colors.orange;
      progressText = 'progress_caution'.tr();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeColors.card(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: ThemeColors.cardShadow(context),
        border: Border.all(
          color: progressColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            'usage_progress'.tr(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ThemeColors.secondaryText(context),
            ),
          ),
          const SizedBox(height: 15),
          ProgressRing(
            progress: progress,
            color: progressColor,
            size: 80,
            strokeWidth: 8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_dashboardState.weeklyAnalyses}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ThemeColors.primaryText(context),
                  ),
                ),
                Text(
                  '/10',
                  style: TextStyle(
                    fontSize: 12,
                    color: ThemeColors.secondaryText(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            progressText,
            style: TextStyle(
              fontSize: 12,
              color: progressColor,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeColors.card(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: ThemeColors.cardShadow(context),
        border: Border.all(
          color: Colors.purple.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_fire_department_outlined,
              color: Colors.purple,
              size: 24,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'usage_streak'.tr(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ThemeColors.secondaryText(context),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'streak_days'.tr(args: [_dashboardState.usageStreak.toString()]),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ThemeColors.primaryText(context),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            _formatLastAnalysisDate(_dashboardState.lastAnalysisDate),
            style: TextStyle(
              fontSize: 12,
              color: ThemeColors.secondaryText(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityStatusCard(bool isDark) {
    final alert = _dashboardState.currentAlert;
    Color statusColor = Colors.green;
    String statusText = 'security_status_safe'.tr();
    String? statusSubtitle;
    IconData statusIcon = Icons.security_outlined;

    if (alert != null) {
      switch (alert.severity) {
        case AlertSeverity.high:
          statusColor = Colors.red;
          statusText = alert.getMessage();
          statusSubtitle = alert.getSubtitle();
          statusIcon = Icons.warning_rounded;
          break;
        case AlertSeverity.medium:
          statusColor = Colors.orange;
          statusText = alert.getMessage();
          statusSubtitle = alert.getSubtitle();
          statusIcon = Icons.info_outlined;
          break;
        case AlertSeverity.low:
          statusColor = Colors.blue;
          statusText = alert.getMessage();
          statusSubtitle = alert.getSubtitle();
          statusIcon = Icons.access_time_rounded;
          break;
      }
    } else {
      final weeklyCount = _dashboardState.weeklyAnalyses;
      statusSubtitle =
          'usage_this_week'.tr(args: [weeklyCount.toString(), '10']);
    }

    return _buildStatusCard(
      title: 'security_status'.tr(),
      value: statusText,
      icon: statusIcon,
      color: statusColor,
      context: context,
      subtitle: statusSubtitle,
      isDark: isDark,
    );
  }

  Widget _buildTotalAnalysesCard(bool isDark) {
    final gradientColors = isDark
        ? DarkThemeColors.gradientColors
        : InstagramColors.gradientColors;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gradientColors[0],
            gradientColors[2],
            gradientColors[4],
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors[3].withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.analytics_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'total_analyses'.tr(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _dashboardState.totalAnalyses.toString(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '${_dashboardState.weeklyAnalyses} ${'this_week'.tr()}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onStartAnalysis,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_arrow_rounded),
                  const SizedBox(width: 8),
                  Text(
                    'start_analysis_quick'.tr(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatLastAnalysisDate(DateTime? date) {
    if (date == null) return 'never'.tr();

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'just_now'.tr();
    } else if (difference.inHours < 1) {
      return 'minutes_ago'.tr(args: [difference.inMinutes.toString()]);
    } else if (difference.inHours < 24) {
      return 'hours_ago'.tr(args: [difference.inHours.toString()]);
    } else if (difference.inDays == 1) {
      return 'yesterday'.tr();
    } else if (difference.inDays < 7) {
      return 'days_ago'.tr(args: [difference.inDays.toString()]);
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  Widget _buildStatusCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required BuildContext context,
    String? subtitle,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeColors.card(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: ThemeColors.cardShadow(context),
        border: Border.all(
          color: color.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ThemeColors.secondaryText(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
              height: 1.2,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: ThemeColors.secondaryText(context),
                height: 1.3,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAlertCard(SecurityAlert alert, bool isDark) {
    Color alertColor = Colors.orange;
    IconData alertIcon = Icons.info_outline;

    switch (alert.severity) {
      case AlertSeverity.high:
        alertColor = Colors.red;
        alertIcon = Icons.error_outline;
        break;
      case AlertSeverity.medium:
        alertColor = Colors.orange;
        alertIcon = Icons.warning_outlined;
        break;
      case AlertSeverity.low:
        alertColor = Colors.blue;
        alertIcon = Icons.info_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: alertColor.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: alertColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                alertIcon,
                color: alertColor,
                size: 24,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  alert.getMessage(),
                  style: TextStyle(
                    fontSize: 14,
                    color: ThemeColors.primaryText(context),
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          if (alert.getSubtitle() != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 39),
              child: Text(
                alert.getSubtitle()!,
                style: TextStyle(
                  fontSize: 12,
                  color: ThemeColors.secondaryText(context),
                  height: 1.3,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildLoadingCard(isDark)),
            const SizedBox(width: 15),
            Expanded(child: _buildLoadingCard(isDark)),
          ],
        ),
        const SizedBox(height: 20),
        _buildLoadingCard(isDark, height: 140),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _buildLoadingCard(isDark)),
            const SizedBox(width: 15),
            Expanded(child: _buildLoadingCard(isDark)),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingCard(bool isDark, {double height = 120}) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeColors.card(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: ThemeColors.cardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: ThemeColors.divider(context),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 15),
          Container(
            height: 14,
            width: 80,
            decoration: BoxDecoration(
              color: ThemeColors.divider(context),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 5),
          Container(
            height: 16,
            width: 60,
            decoration: BoxDecoration(
              color: ThemeColors.border(context),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
