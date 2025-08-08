import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:convert';
import 'dart:async';
import '../constants/javascript_constants.dart';
import '../services/analytics_service.dart';
import 'animation_controllers_mixin.dart';

mixin WebViewHandlersMixin<T extends StatefulWidget>
    on State<T>, AnimationControllersMixin<T> {
  late final WebViewController controller;
  final TextEditingController usernameController = TextEditingController();

  bool isLoggedIn = false;
  List<Map<String, dynamic>> unfollowers = [];
  List<Map<String, dynamic>> fans = [];
  bool isLoading = false;
  String errorMessage = '';
  String progressMessage = '';
  String currentUsername = '';
  bool showManualInput = false;
  bool hasResults = false;
  bool isPanelOpen = false;
  Set<String> selectedUsers = <String>{};
  Timer? urlMonitorTimer;

  // Panel state preservation
  int currentTabIndex = 0;
  String searchQuery = '';
  String sortOption = 'none';
  double scrollPosition = 0.0;

  // Analytics callback - Ana screen'e dashboard güncellemesi için
  VoidCallback? onAnalysisCompleted;

  void initializeWebView({VoidCallback? onAnalyticsUpdate}) {
    onAnalysisCompleted = onAnalyticsUpdate;
    progressMessage = 'preparing_analysis'.tr();

    controller = WebViewController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setBackgroundColor(const Color(0x00000000));
      await controller.addJavaScriptChannel(
        'UnfollowerChannel',
        onMessageReceived: handleJavaScriptMessage,
      );

      await controller.setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: handlePageFinished,
        ),
      );

      await controller.loadRequest(
        Uri.parse('https://www.instagram.com/accounts/login/'),
      );
    });
  }

  void handleJavaScriptMessage(JavaScriptMessage message) {
    try {
      final decodedMessage = jsonDecode(message.message);
      if (decodedMessage is Map) {
        switch (decodedMessage['status']) {
          case 'logged_out':
            handleLogout();
            break;
          case 'logged_in_confirmed':
            if (!isLoggedIn) {
              handleLogin();
            }
            break;
          case 'progress':
            setState(() {
              String progressKey = decodedMessage['message'];
              if (progressKey.contains('Loading followers')) {
                progressMessage = 'loading_followers'.tr();
              } else if (progressKey.contains('Loading following')) {
                progressMessage = 'loading_following'.tr();
              } else if (progressKey.contains('Comparing lists')) {
                progressMessage = 'comparing_lists'.tr();
              } else if (progressKey.contains('Getting user info')) {
                progressMessage = 'getting_user_info'.tr();
              } else {
                progressMessage = decodedMessage['message'];
              }
            });
            break;
          case 'username_captured':
            setState(() {
              currentUsername = decodedMessage['username'];
            });
            break;
          case 'username':
            setState(() {
              currentUsername = decodedMessage['username'];
            });
            break;
          case 'need_manual_input':
            setState(() {
              showManualInput = true;
              isLoading = false;
            });
            openPanel();
            break;
          default:
            if (decodedMessage.containsKey('error')) {
              setState(() {
                isLoading = false;
                errorMessage = decodedMessage['error'];
                progressMessage = '';
              });
            } else if (decodedMessage.containsKey('notFollowingBack') ||
                decodedMessage.containsKey('fans')) {
              // Yeni analiz sonuçları geldi
              _handleAnalysisResults(Map<String, dynamic>.from(decodedMessage));
            }
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'data_retrieval_error'.tr();
        progressMessage = '';
      });
    }
  }

  // Analiz sonuçlarını işle
  void _handleAnalysisResults(Map<String, dynamic> results) {
    try {
      final notFollowingBackList = results['notFollowingBack'] as List? ?? [];
      final fansList = results['fans'] as List? ?? [];

      final processedUnfollowers = <Map<String, dynamic>>[];
      for (final user in notFollowingBackList) {
        if (user is Map) {
          final userMap = Map<String, dynamic>.from(user);
          processedUnfollowers.add({
            'username': userMap['username']?.toString() ?? '',
            'profilePicUrl': userMap['profilePicUrl']?.toString() ?? '',
          });
        } else if (user is String) {
          // Backwards compatibility
          processedUnfollowers.add({
            'username': user,
            'profilePicUrl': '',
          });
        } else {
          processedUnfollowers.add({
            'username': user.toString(),
            'profilePicUrl': '',
          });
        }
      }

      final processedFans = <Map<String, dynamic>>[];
      for (final user in fansList) {
        if (user is Map) {
          final userMap = Map<String, dynamic>.from(user);
          processedFans.add({
            'username': userMap['username']?.toString() ?? '',
            'profilePicUrl': userMap['profilePicUrl']?.toString() ?? '',
          });
        } else if (user is String) {
          processedFans.add({
            'username': user,
            'profilePicUrl': '',
          });
        } else {
          processedFans.add({
            'username': user.toString(),
            'profilePicUrl': '',
          });
        }
      }

      _recordAnalysisCompletion(processedUnfollowers, processedFans);
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'data_retrieval_error'.tr();
        progressMessage = '';
      });
    }
  }

  // Analiz tamamlandığında analytics'e kaydet
  Future<void> _recordAnalysisCompletion(
    List<Map<String, dynamic>> unfollowersList,
    List<Map<String, dynamic>> fansList,
  ) async {
    try {
      // Analytics servisine analiz tamamlandığını kaydet
      await AnalyticsService.instance.recordAnalysis();

      // Sonuçları güncelle
      setState(() {
        unfollowers = unfollowersList;
        fans = fansList;
        isLoading = false;
        progressMessage = '';
        showManualInput = false;
        hasResults = true;
        selectedUsers.clear();
      });

      // Dashboard güncellemesi için callback'i çağır
      if (onAnalysisCompleted != null) {
        onAnalysisCompleted!();
      }

      // Panel'i aç
      openPanel();

      // Başarı mesajı göster
      if (mounted) {
        final totalCount = unfollowersList.length + fansList.length;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${'analysis_completed'.tr()} - $totalCount ${'people_found'.tr().toLowerCase()}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Analytics kaydetme hatası - sessizce geç
      setState(() {
        unfollowers = unfollowersList;
        fans = fansList;
        isLoading = false;
        progressMessage = '';
        showManualInput = false;
        hasResults = true;
        selectedUsers.clear();
      });
      openPanel();
    }
  }

  void handlePageFinished(String url) {
    controller.runJavaScript(JavaScriptConstants.logoutDetectionCode);

    if (url.contains('accounts/login') ||
        url.contains('accounts/emailsignup')) {
      controller.runJavaScript(JavaScriptConstants.loginCaptureCode);
    } else if (url.contains('https://www.instagram.com/') &&
        !url.contains('accounts/login') &&
        !url.contains('accounts/emailsignup')) {
      controller.runJavaScript(JavaScriptConstants.analysisJavaScriptCode);
    }
  }

  void handleLogin() {
    setState(() {
      isLoggedIn = true;
    });

    controller.runJavaScript(JavaScriptConstants.analysisJavaScriptCode);

    Future.delayed(const Duration(milliseconds: 800), () {
      slideInController.forward();
      bounceController.forward();

      Future.delayed(const Duration(seconds: 10), () {
        if (isLoggedIn && !isPanelOpen && !hasResults) {
          bounceController.reset();
          bounceController.forward();
        }
      });
    });
  }

  void handleLogout() {
    controller.runJavaScript('clearStoredUsername()');

    setState(() {
      isLoggedIn = false;
      unfollowers.clear();
      fans.clear();
      isLoading = false;
      errorMessage = '';
      progressMessage = '';
      currentUsername = '';
      showManualInput = false;
      hasResults = false;
      selectedUsers.clear();
    });

    if (isPanelOpen) {
      closePanel();
    }

    slideInController.reset();
    bounceController.reset();
    usernameController.clear();
  }

  void openPanel() {
    if (!isPanelOpen) {
      setState(() {
        isPanelOpen = true;
      });
      slideController.forward();
    }
  }

  void closePanel() {
    if (isPanelOpen) {
      slideController.reverse().then((_) {
        setState(() {
          isPanelOpen = false;
        });
      });
    }
  }

  void copySelectedUsers() {
    final selectedList = selectedUsers.toList();
    if (selectedList.isNotEmpty) {
      final usernamesText = selectedList.join('\n');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.copy, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'users_copied'.tr(args: [selectedList.length.toString()]),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      Clipboard.setData(ClipboardData(text: usernamesText));
    }
  }

  void selectAllUsers(List<Map<String, dynamic>> currentList) {
    setState(() {
      final currentUsernames =
          currentList.map((user) => user['username'] as String).toSet();
      if (selectedUsers.containsAll(currentUsernames)) {
        selectedUsers.removeAll(currentUsernames);
      } else {
        selectedUsers.addAll(currentUsernames);
      }
    });
  }

  // Analiz başlatma (Analytics entegrasyonu ile)
  Future<void> startAnalysis({String? username}) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
      unfollowers.clear();
      fans.clear();
      progressMessage = 'starting_analysis'.tr();
    });

    // Panel state'ini sıfırla
    _resetPanelState();

    if (username != null) {
      controller.runJavaScript('analyzeAccount("$username")');
    } else {
      controller.runJavaScript('analyzeAccount()');
    }
  }

  void startManualAnalysis() {
    final username = usernameController.text.trim();
    if (username.isNotEmpty) {
      setState(() {
        isLoading = true;
        errorMessage = '';
        unfollowers.clear();
        fans.clear();
        progressMessage = 'starting_analysis'.tr();
        showManualInput = false;
      });

      // Panel state'ini sıfırla
      _resetPanelState();

      controller.runJavaScript('analyzeAccount("$username")');
    }
  }

  void restartAnalysis() {
    setState(() {
      unfollowers.clear();
      fans.clear();
      errorMessage = '';
      showManualInput = false;
      hasResults = false;
      isLoading = true;
      progressMessage = 'starting_analysis'.tr();
      selectedUsers.clear();
    });

    // Panel state'ini sıfırla
    _resetPanelState();

    controller.runJavaScript('analyzeAccount()');
  }

  void clearError() {
    setState(() {
      errorMessage = '';
      currentUsername = '';
    });
  }

  void toggleUserSelection(String user) {
    setState(() {
      if (selectedUsers.contains(user)) {
        selectedUsers.remove(user);
      } else {
        selectedUsers.add(user);
      }
    });
  }

  void openUserProfile(String username) {
    // State'i koru panel kapanmadan önce
    _preservePanelState();
    closePanel();
    controller.loadRequest(
      Uri.parse('https://www.instagram.com/$username/'),
    );
  }

  // Panel state'ini koru
  void _preservePanelState() {
    // State zaten class seviyesinde tutuluyor, bir şey yapmaya gerek yok
  }

  // Panel state'ini güncelle
  void updatePanelState(
      int? tabIndex, String? search, String? sort, double? scroll) {
    if (tabIndex != null) currentTabIndex = tabIndex;
    if (search != null) searchQuery = search;
    if (sort != null) sortOption = sort;
    if (scroll != null) scrollPosition = scroll;
  }

  // Panel state'ini sıfırla (yeni analiz başladığında)
  void _resetPanelState() {
    currentTabIndex = 0;
    searchQuery = '';
    sortOption = 'none';
    scrollPosition = 0.0;
  }

  @override
  void dispose() {
    usernameController.dispose();
    urlMonitorTimer?.cancel();
    super.dispose();
  }
}
