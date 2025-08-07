import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'mixins/animation_controllers_mixin.dart';
import 'mixins/webview_handlers_mixin.dart';
import 'widgets/instagram_header.dart';
import 'widgets/slide_panel.dart';
import 'widgets/edge_indicator.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

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
    initializeWebView();
  }

  @override
  void dispose() {
    disposeAnimations();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              InstagramHeader(
                headerAnimation: headerAnimation,
                isLoggedIn: isLoggedIn,
              ),
              Expanded(child: WebViewWidget(controller: controller)),
            ],
          ),
          EdgeIndicator(
            isLoggedIn: isLoggedIn,
            isPanelOpen: isPanelOpen,
            hasResults: hasResults,
            unfollowersCount: unfollowers.length,
            slideInAnimation: slideInAnimation,
            bounceAnimation: bounceAnimation,
            glowAnimation: glowAnimation,
            pulseAnimation: pulseAnimation,
            onTap: openPanel,
          ),
          if (isPanelOpen)
            GestureDetector(
              onTap: closePanel,
              child: Container(color: Colors.black.withValues(alpha: 0.4)),
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
              ),
            ),
        ],
      ),
    );
  }
}
