import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'mixins/animation_controllers_mixin.dart';
import 'mixins/webview_handlers_mixin.dart';
import 'widgets/instagram_header.dart';
import 'widgets/slide_panel.dart';
import 'widgets/edge_indicator.dart';
import 'utils/dark_theme_colors.dart';

class WebViewScreen extends StatefulWidget {
  final VoidCallback? onAnalysisCompleted;

  const WebViewScreen({
    super.key,
    this.onAnalysisCompleted,
  });

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen>
    with
        TickerProviderStateMixin,
        AnimationControllersMixin,
        WebViewHandlersMixin {
  @override
  void initState() {
    super.initState();
    initializeAnimations();
    initializeWebView(onAnalyticsUpdate: widget.onAnalysisCompleted);
  }

  @override
  void dispose() {
    disposeAnimations();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? DarkThemeColors.primaryBackground : Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              InstagramHeader(
                headerAnimation: headerAnimation,
                isLoggedIn: isLoggedIn,
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? DarkThemeColors.secondaryBackground
                        : Colors.white,
                    boxShadow: isDark
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, -2),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, -2),
                            ),
                          ],
                  ),
                  child: WebViewWidget(controller: controller),
                ),
              ),
            ],
          ),
          EdgeIndicator(
            isLoggedIn: isLoggedIn,
            isPanelOpen: isPanelOpen,
            hasResults: hasResults,
            unfollowersCount: unfollowers.length + fans.length,
            slideInAnimation: slideInAnimation,
            bounceAnimation: bounceAnimation,
            glowAnimation: glowAnimation,
            pulseAnimation: pulseAnimation,
            onTap: openPanel,
          ),
          if (isPanelOpen)
            GestureDetector(
              onTap: closePanel,
              child: Container(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.6)
                    : Colors.black.withValues(alpha: 0.4),
              ),
            ),
          if (isPanelOpen)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: SlidePanel(
                slideAnimation: slideAnimation,
                isLoading: isLoading,
                hasResults: hasResults,
                showManualInput: showManualInput,
                errorMessage: errorMessage,
                progressMessage: progressMessage,
                currentUsername: currentUsername,
                unfollowers: unfollowers,
                fans: fans,
                selectedUsers: selectedUsers,
                usernameController: usernameController,
                pulseAnimation: pulseAnimation,
                onClose: closePanel,
                onAnalyzePressed: () => startAnalysis(),
                onSelectAll: selectAllUsers,
                onCopySelected: copySelectedUsers,
                onRestartAnalysis: restartAnalysis,
                onStartManualAnalysis: startManualAnalysis,
                onClearError: clearError,
                onToggleUserSelection: toggleUserSelection,
                onOpenUserProfile: openUserProfile,
                // Panel state preservation
                initialTabIndex: currentTabIndex,
                initialSearchQuery: searchQuery,
                initialSortOption: sortOption,
                initialScrollPosition: scrollPosition,
                onUpdatePanelState: updatePanelState,
              ),
            ),
        ],
      ),
    );
  }
}
