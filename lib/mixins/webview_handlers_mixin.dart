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

  // URL Bar için yeni state'ler
  String currentUrl = '';
  bool isWebViewLoading = false;

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
          onPageStarted: (String url) {
            setState(() {
              currentUrl = url;
              isWebViewLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              currentUrl = url;
              isWebViewLoading = false;
            });
            handlePageFinished(url);
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              isWebViewLoading = false;
            });
          },
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
        // Map<String, dynamic> tipine güvenli cast
        final messageMap = Map<String, dynamic>.from(decodedMessage);

        switch (messageMap['status']) {
          case 'logged_out':
            handleLogout();
            break;

          case 'logged_in_confirmed':
            if (!isLoggedIn) {
              handleLogin();
            }
            break;

          case 'active_user_detected':
            // YENİ: Aktif kullanıcı otomatik tespit edildi
            handleActiveUserDetected(messageMap);
            break;

          case 'username_confirmed':
            // YENİ: Username onaylandı, direkt analize geç
            setState(() {
              currentUsername = messageMap['username'] ?? '';
              showManualInput = false; // Manuel girişi kapat
            });
            break;

          case 'username_captured':
            // Geliştirilmiş: Yakalama metodunu da kontrol et
            final method = messageMap['method'] ?? 'unknown';
            final username = messageMap['username'] ?? '';

            setState(() {
              currentUsername = username;
              if (method == 'auto_detection') {
                // Otomatik tespit edildiyse, manuel girişi kapat
                showManualInput = false;
              }
            });

            // Analytics'e kaydet (eğer login durumundaysa)
            if (isLoggedIn && method == 'auto_detection') {
              _recordUserDetection(username, method);
            }
            break;

          case 'need_manual_input':
            // Manuel giriş gerekli
            final reason = messageMap['reason'] ?? 'unknown';
            setState(() {
              showManualInput = true;
              isLoading = false;
              errorMessage = '';
            });

            // Kullanıcıya bilgi ver
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.info, color: Colors.white),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          reason == 'no_username_detected'
                              ? 'Hesap bilgisi tespit edilemedi, lütfen manuel olarak girin'
                              : 'Kullanıcı adı gerekli',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.orange.shade600,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  duration: const Duration(seconds: 4),
                ),
              );
            }

            // Panel'i aç
            openPanel();
            break;

          case 'progress':
            setState(() {
              String progressKey = messageMap['message'] ?? '';
              if (progressKey.contains('Loading followers')) {
                progressMessage = 'loading_followers'.tr();
              } else if (progressKey.contains('Loading following')) {
                progressMessage = 'loading_following'.tr();
              } else if (progressKey.contains('Comparing lists')) {
                progressMessage = 'comparing_lists'.tr();
              } else if (progressKey.contains('Getting user info')) {
                progressMessage = 'getting_user_info'.tr();
              } else {
                progressMessage = progressKey;
              }
            });
            break;

          default:
            if (messageMap.containsKey('error')) {
              setState(() {
                isLoading = false;
                errorMessage = messageMap['error'] ?? 'Unknown error';
                progressMessage = '';
              });
            } else if (messageMap.containsKey('notFollowingBack') ||
                messageMap.containsKey('fans')) {
              _handleAnalysisResults(messageMap);
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

  // YENİ: Aktif kullanıcı tespit edildiğinde çağrılır
  void handleActiveUserDetected(Map<String, dynamic> data) {
    final username = data['username'] as String? ?? '';
    final method = data['method'] ?? 'auto_detection';

    setState(() {
      currentUsername = username;
      showManualInput =
          false; // Otomatik tespit edildiği için manuel girişi kapat
    });

    // Başarı mesajı göster
    if (mounted && isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Hesap tespit edildi: @$username',
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
    }

    // Analytics'e kaydet
    _recordUserDetection(username, method);
  }

  // YENİ: Kullanıcı tespitini analytics'e kaydet
  Future<void> _recordUserDetection(String username, String method) async {
    try {
      // Bu sadece tespit, henüz analiz yapılmadı
      // İsteğe bağlı olarak tespit edilen kullanıcıları kaydedebilirsiniz

      // Debug için konsola yazdır (print yerine debugPrint kullan)
      debugPrint('User detected: $username via $method');
    } catch (e) {
      // Sessizce geç
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
      // Analytics servisine analiz tamamlandığını kaydet (hesap bilgisiyle)
      if (currentUsername.isNotEmpty) {
        await AnalyticsService.instance.recordAnalysis(currentUsername);
      }

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
      controller.runJavaScript(JavaScriptConstants.enhancedLoginCaptureCode);
    } else if (url.contains('https://www.instagram.com/') &&
        !url.contains('accounts/login') &&
        !url.contains('accounts/emailsignup')) {
      // Instagram ana sayfalarında aktif kullanıcı tespitini çalıştır
      controller.runJavaScript(JavaScriptConstants.activeUserDetectionCode);
      controller.runJavaScript(JavaScriptConstants.analysisJavaScriptCode);

      // 2 saniye sonra kullanıcı tespitini tetikle
      Future.delayed(const Duration(seconds: 2), () {
        controller.runJavaScript(
            'if (window.triggerUserDetection) window.triggerUserDetection();');
      });
    }
  }

  void handleLogin() {
    setState(() {
      isLoggedIn = true;
    });

    // Gelişmiş JavaScript kodlarını çalıştır
    controller.runJavaScript(JavaScriptConstants.activeUserDetectionCode);
    controller.runJavaScript(JavaScriptConstants.enhancedLoginCaptureCode);
    controller.runJavaScript(JavaScriptConstants.analysisJavaScriptCode);

    Future.delayed(const Duration(milliseconds: 800), () {
      slideInController.forward();
      bounceController.forward();

      // Aktif kullanıcı tespitini tetikle
      controller.runJavaScript(
          'if (window.triggerUserDetection) window.triggerUserDetection();');

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

  // WebView sayfayı yenileme fonksiyonu
  void refreshWebView() {
    if (!isWebViewLoading) {
      setState(() {
        isWebViewLoading = true;
      });
      controller.reload();
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

    // Gelişmiş analiz fonksiyonunu çağır
    if (username != null) {
      controller.runJavaScript(
          'if (window.analyzeAccount) window.analyzeAccount("$username")');
    } else {
      controller
          .runJavaScript('if (window.analyzeAccount) window.analyzeAccount()');
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

      controller.runJavaScript(
          'if (window.analyzeAccount) window.analyzeAccount("$username")');
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

    controller
        .runJavaScript('if (window.analyzeAccount) window.analyzeAccount()');
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

  // YENİ: Manuel input gösterme fonksiyonu (fonksiyon adı değiştirildi)
  void switchToManualInput() {
    setState(() {
      showManualInput = true;
      currentUsername = ''; // Reset current username
    });
  }

  // YENİ: Kullanıcı tespitini yeniden tetikleme
  void retriggerUserDetection() {
    controller.runJavaScript(
        'if (window.triggerUserDetection) window.triggerUserDetection();');
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
