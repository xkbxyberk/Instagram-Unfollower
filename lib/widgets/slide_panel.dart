import 'package:flutter/material.dart';
import 'panel_header.dart';
import 'panel_content/welcome_content.dart';
import 'panel_content/loading_content.dart';
import 'panel_content/error_content.dart';
import 'panel_content/manual_input_content.dart';
import 'panel_content/results_content.dart';

class SlidePanel extends StatelessWidget {
  final Animation<Offset> slideAnimation;
  final bool isLoading;
  final bool hasResults;
  final bool showManualInput;
  final String errorMessage;
  final String progressMessage;
  final String currentUsername;
  final List<Map<String, dynamic>> unfollowers;
  final List<Map<String, dynamic>> fans;
  final Set<String> selectedUsers;
  final TextEditingController usernameController;
  final Animation<double> pulseAnimation;
  final VoidCallback onClose;
  final VoidCallback onAnalyzePressed;
  final Function(List<Map<String, dynamic>>) onSelectAll;
  final VoidCallback onCopySelected;
  final VoidCallback onRestartAnalysis;
  final VoidCallback onStartManualAnalysis;
  final VoidCallback onClearError;
  final Function(String) onToggleUserSelection;
  final Function(String) onOpenUserProfile;

  // Panel state preservation
  final int initialTabIndex;
  final String initialSearchQuery;
  final String initialSortOption;
  final double initialScrollPosition;
  final Function(int?, String?, String?, double?) onUpdatePanelState;

  const SlidePanel({
    super.key,
    required this.slideAnimation,
    required this.isLoading,
    required this.hasResults,
    required this.showManualInput,
    required this.errorMessage,
    required this.progressMessage,
    required this.currentUsername,
    required this.unfollowers,
    required this.fans,
    required this.selectedUsers,
    required this.usernameController,
    required this.pulseAnimation,
    required this.onClose,
    required this.onAnalyzePressed,
    required this.onSelectAll,
    required this.onCopySelected,
    required this.onRestartAnalysis,
    required this.onStartManualAnalysis,
    required this.onClearError,
    required this.onToggleUserSelection,
    required this.onOpenUserProfile,
    // Panel state preservation
    this.initialTabIndex = 0,
    this.initialSearchQuery = '',
    this.initialSortOption = 'none',
    this.initialScrollPosition = 0.0,
    required this.onUpdatePanelState,
  });

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: slideAnimation,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.88,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey.shade50],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            bottomLeft: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(-10, 0),
            ),
            BoxShadow(
              color: Colors.purple.withValues(alpha: 0.1),
              blurRadius: 40,
              offset: const Offset(-15, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            PanelHeader(
              hasResults: hasResults,
              currentUsername: currentUsername,
              onClose: onClose,
            ),
            Expanded(child: _buildPanelContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildPanelContent() {
    if (isLoading) {
      return LoadingContent(progressMessage: progressMessage);
    } else if (errorMessage.isNotEmpty) {
      return ErrorContent(
        errorMessage: errorMessage,
        onTryAgain: onClearError,
      );
    } else if (hasResults) {
      return ResultsContent(
        unfollowers: unfollowers,
        fans: fans,
        selectedUsers: selectedUsers,
        onSelectAll: onSelectAll,
        onCopySelected: onCopySelected,
        onRestartAnalysis: onRestartAnalysis,
        onToggleUserSelection: onToggleUserSelection,
        onOpenUserProfile: onOpenUserProfile,
        // Panel state preservation
        initialTabIndex: initialTabIndex,
        initialSearchQuery: initialSearchQuery,
        initialSortOption: initialSortOption,
        initialScrollPosition: initialScrollPosition,
        onUpdatePanelState: onUpdatePanelState,
      );
    } else if (showManualInput) {
      return ManualInputContent(
        usernameController: usernameController,
        onStartAnalysis: onStartManualAnalysis,
      );
    } else {
      return WelcomeContent(
        pulseAnimation: pulseAnimation,
        onAnalyzePressed: onAnalyzePressed,
      );
    }
  }
}
