import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:instagram_unfollower_app/language_selector.dart';
import 'dart:convert';
import 'dart:async';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen>
    with TickerProviderStateMixin {
  late final WebViewController _controller;
  final TextEditingController _usernameController = TextEditingController();
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _bounceController;
  late AnimationController _slideInController;
  late AnimationController _glowController;
  late AnimationController _headerAnimationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<Offset> _slideInAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _headerAnimation;

  bool _isLoggedIn = false;
  List<String> _unfollowers = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _progressMessage = '';
  String _currentUsername = '';
  bool _showManualInput = false;
  bool _hasResults = false;
  bool _isPanelOpen = false;
  Set<String> _selectedUsers = <String>{};

  static const List<Color> instagramColors = [
    Color(0xFF405de6),
    Color(0xFF5851db),
    Color(0xFF833ab4),
    Color(0xFFc13584),
    Color(0xFFe1306c),
    Color(0xFFfd1d1d),
    Color(0xFFf56040),
    Color(0xFFf77737),
    Color(0xFFfcaf45),
    Color(0xFFffdc80),
  ];

  final String loginCaptureCode = r'''
    const captureUsername = () => {
      const universalSelectors = [
        'input[name="username"][maxlength="75"][type="text"]',
        'input[name="username"][autocapitalize="off"]',
        'input[name="username"][maxlength="75"]',
        'input[name="username"]',
        'input[maxlength="75"][type="text"][autocapitalize="off"]',
        'input[type="text"][maxlength="75"]',
      ];
      
      let usernameInput = null;
      let foundSelector = '';
      
      for (const selector of universalSelectors) {
        try {
          const inputs = document.querySelectorAll(selector);
          if (inputs.length > 0) {
            usernameInput = inputs[0];
            foundSelector = selector;
            break;
          }
        } catch (e) {
          continue;
        }
      }
      
      if (usernameInput) {
        const isInstagramInput = 
          usernameInput.name === 'username' && 
          usernameInput.maxLength === 75 && 
          usernameInput.type === 'text';
      } else {
        const allTextInputs = document.querySelectorAll('input[type="text"]');
        usernameInput = Array.from(allTextInputs).find(input => 
          input.name === 'username' || 
          input.maxLength === 75 ||
          (input.getAttribute('aria-label') && 
           (input.getAttribute('aria-label').toLowerCase().includes('username') ||
            input.getAttribute('aria-label').toLowerCase().includes('kullanıcı')))
        );
      }
      
      if (usernameInput) {
        let capturedUsername = '';
        let lastCapturedValue = '';
        
        const handleInput = (eventType, value) => {
          if (value && value.length > 0 && value !== lastCapturedValue) {
            capturedUsername = value;
            lastCapturedValue = value;
            
            localStorage.setItem('captured_instagram_username', capturedUsername);
            
            try {
              if (typeof UnfollowerChannel !== 'undefined') {
                UnfollowerChannel.postMessage(JSON.stringify({
                  status: 'username_captured',
                  username: capturedUsername,
                  capturedBy: eventType
                }));
              }
            } catch (e) {
              // Handle error silently
            }
          }
        };
        
        const createEventHandler = (eventType) => {
          return (e) => {
            const value = e.target.value.trim();
            handleInput(eventType, value);
          };
        };
        
        const criticalEvents = [
          'input',
          'change',
          'blur',
          'keyup',
          'paste',
        ];
        
        criticalEvents.forEach(eventType => {
          usernameInput.addEventListener(eventType, createEventHandler(eventType), true);
        });
        
        const form = usernameInput.closest('form');
        if (form) {
          form.addEventListener('submit', (e) => {
            const finalUsername = usernameInput.value.trim();
            
            if (finalUsername) {
              handleInput('form-submit', finalUsername);
              
              setTimeout(() => {
                localStorage.setItem('captured_instagram_username', finalUsername);
              }, 100);
            }
          }, true);
        }
        
        if (usernameInput.value && usernameInput.value.trim()) {
          handleInput('initial-value', usernameInput.value.trim());
        }
        
        let checkCount = 0;
        const maxChecks = 60;
        
        const intervalId = setInterval(() => {
          checkCount++;
          const currentValue = usernameInput.value ? usernameInput.value.trim() : '';
          
          if (currentValue && currentValue !== lastCapturedValue) {
            handleInput('periodic-check', currentValue);
          }
          
          if (checkCount >= maxChecks) {
            clearInterval(intervalId);
          }
        }, 500);
      }
    };
    
    const waitForUsernameInput = () => {
      captureUsername();
      
      const retryTimeouts = [
        { delay: 200, reason: 'Instant loading' },
        { delay: 600, reason: 'Fast loading' },
        { delay: 1200, reason: 'Normal loading' },
        { delay: 2500, reason: 'Slow loading' },
        { delay: 4000, reason: 'Last chance' }
      ];
      
      retryTimeouts.forEach(({ delay, reason }) => {
        setTimeout(() => {
          captureUsername();
        }, delay);
      });
    };
    
    let lastUrl = window.location.href;
    const checkUrlChange = () => {
      const currentUrl = window.location.href;
      if (currentUrl !== lastUrl) {
        lastUrl = currentUrl;
        
        if (currentUrl.includes('login') || currentUrl.includes('accounts')) {
          setTimeout(() => {
            captureUsername();
          }, 300);
        }
      }
    };
    
    setInterval(checkUrlChange, 1000);
    
    const observer = new MutationObserver((mutations) => {
      let shouldRecheck = false;
      
      mutations.forEach((mutation) => {
        if (mutation.addedNodes.length > 0) {
          mutation.addedNodes.forEach(node => {
            if (node.nodeType === 1) {
              if (node.tagName === 'INPUT' ||
                  node.tagName === 'FORM' ||
                  (node.querySelector && 
                   node.querySelector('input[name="username"]'))) {
                shouldRecheck = true;
              }
            }
          });
        }
        
        if (mutation.type === 'attributes' && 
            mutation.target.tagName === 'INPUT' &&
            ['name', 'maxlength', 'aria-label'].includes(mutation.attributeName)) {
          shouldRecheck = true;
        }
      });
      
      if (shouldRecheck) {
        setTimeout(captureUsername, 150);
      }
    });
    
    if (document.body) {
      observer.observe(document.body, {
        childList: true,
        subtree: true,
        attributes: true,
        attributeFilter: ['name', 'maxlength', 'aria-label', 'class']
      });
    }
    
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', () => {
        setTimeout(captureUsername, 100);
      });
    }
    
    window.addEventListener('load', () => {
      setTimeout(captureUsername, 250);
    });
    
    waitForUsernameInput();
  ''';

  final String analysisJavaScriptCode = r'''
    const fetchOptions = {
      credentials: "include",
      headers: { "X-IG-App-ID": "936619743392459" },
      method: "GET",
    };

    const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
    const random = (min, max) => Math.ceil(Math.random() * (max - min)) + min;

    const concatFriendshipsApiResponse = async (list, user_id, count, next_max_id = "") => {
      let url = `https://www.instagram.com/api/v1/friendships/${user_id}/${list}/?count=${count}`;
      if (next_max_id) { url += `&max_id=${next_max_id}`; }
      
      const data = await fetch(url, fetchOptions).then((r) => r.json());
      
      if (!data || !data.users) {
        throw new Error('API Response Error: ' + JSON.stringify(data));
      }
      
      const progressMessage = list === 'followers' ? 'Loading followers...' : 'Loading following...';
      UnfollowerChannel.postMessage(JSON.stringify({
          status: 'progress',
          message: progressMessage + ` ${data.users.length}`
      }));

      if (data.next_max_id) {
        const timeToSleep = random(100, 500);
        await sleep(timeToSleep);
        return data.users.concat(await concatFriendshipsApiResponse(list, user_id, count, data.next_max_id));
      }
      return data.users;
    };

    const getFollowers = (user_id, count = 50) => concatFriendshipsApiResponse("followers", user_id, count);
    const getFollowing = (user_id, count = 50) => concatFriendshipsApiResponse("following", user_id, count);

    const getUserId = async (username) => {
      const lower = username.toLowerCase();
      const url = `https://www.instagram.com/api/v1/web/search/topsearch/?context=blended&query=${lower}&include_reel=false`;
      const data = await fetch(url, fetchOptions).then((r) => r.json());
      const result = data.users?.find((result) => result.user.username.toLowerCase() === lower);
      return result?.user?.pk || null;
    };

    const getUserFriendshipStats = async (username) => {
      UnfollowerChannel.postMessage(JSON.stringify({status: 'progress', message: 'Getting user info...'}));
      
      const user_id = await getUserId(username);
      if (!user_id) {
        throw new Error(`User '${username}' not found.`);
      }
      
      UnfollowerChannel.postMessage(JSON.stringify({status: 'progress', message: 'Loading followers...'}));
      const followers = await getFollowers(user_id);
      
      UnfollowerChannel.postMessage(JSON.stringify({status: 'progress', message: 'Loading following...'}));
      const following = await getFollowing(user_id);
      
      UnfollowerChannel.postMessage(JSON.stringify({status: 'progress', message: 'Comparing lists...'}));
      
      const followersUsernames = followers.map((follower) => follower.username.toLowerCase());
      const followingUsernames = following.map((followed) => followed.username.toLowerCase());
      const followerSet = new Set(followersUsernames);
      const PeopleNotFollowingMeBack = followingUsernames.filter((following) => !followerSet.has(following));
      
      return { PeopleNotFollowingMeBack };
    };

    async function analyzeAccount(username = null) {
      try {
        let targetUsername = username;
        
        if (!targetUsername) {
          targetUsername = localStorage.getItem('captured_instagram_username');
        }
        
        if (!targetUsername) {
          UnfollowerChannel.postMessage(JSON.stringify({
            status: 'need_manual_input'
          }));
          return;
        }
        
        UnfollowerChannel.postMessage(JSON.stringify({
          status: 'username',
          username: targetUsername
        }));
        
        const result = await getUserFriendshipStats(targetUsername);
        UnfollowerChannel.postMessage(JSON.stringify(result.PeopleNotFollowingMeBack));
        
      } catch (e) {
        UnfollowerChannel.postMessage('{"error":"' + e.message + '"}');
      }
    }

    function clearStoredUsername() {
      localStorage.removeItem('captured_instagram_username');
    }
  ''';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController();
    _progressMessage = 'preparing_analysis'.tr();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideInController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _slideInAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(
      CurvedAnimation(parent: _slideInController, curve: Curves.elasticOut),
    );

    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.easeOut,
      ),
    );

    _pulseController.repeat(reverse: true);
    _glowController.repeat(reverse: true);
    _headerAnimationController.repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await _controller.setBackgroundColor(const Color(0x00000000));
      await _controller.addJavaScriptChannel(
        'UnfollowerChannel',
        onMessageReceived: (JavaScriptMessage message) {
          try {
            final decodedMessage = jsonDecode(message.message);
            if (decodedMessage is Map) {
              switch (decodedMessage['status']) {
                case 'progress':
                  setState(() {
                    String progressKey = decodedMessage['message'];
                    if (progressKey.contains('Loading followers')) {
                      _progressMessage = 'loading_followers'.tr();
                    } else if (progressKey.contains('Loading following')) {
                      _progressMessage = 'loading_following'.tr();
                    } else if (progressKey.contains('Comparing lists')) {
                      _progressMessage = 'comparing_lists'.tr();
                    } else if (progressKey.contains('Getting user info')) {
                      _progressMessage = 'getting_user_info'.tr();
                    } else {
                      _progressMessage = decodedMessage['message'];
                    }
                  });
                  break;
                case 'username_captured':
                  setState(() {
                    _currentUsername = decodedMessage['username'];
                  });
                  break;
                case 'username':
                  setState(() {
                    _currentUsername = decodedMessage['username'];
                  });
                  break;
                case 'need_manual_input':
                  setState(() {
                    _showManualInput = true;
                    _isLoading = false;
                  });
                  _openPanel();
                  break;
                default:
                  if (decodedMessage.containsKey('error')) {
                    setState(() {
                      _isLoading = false;
                      _errorMessage = decodedMessage['error'];
                      _progressMessage = '';
                    });
                  }
              }
            } else if (decodedMessage is List) {
              setState(() {
                _unfollowers = decodedMessage.cast<String>();
                _isLoading = false;
                _progressMessage = '';
                _showManualInput = false;
                _hasResults = true;
                _selectedUsers.clear();
              });
              _openPanel();
            }
          } catch (e) {
            setState(() {
              _isLoading = false;
              _errorMessage = 'data_retrieval_error'.tr();
              _progressMessage = '';
            });
          }
        },
      );

      await _controller.setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (url.contains('accounts/login') ||
                url.contains('accounts/emailsignup')) {
              _controller.runJavaScript(loginCaptureCode);
            } else if (url.contains('https://www.instagram.com/') &&
                !url.contains('accounts/login') &&
                !url.contains('accounts/emailsignup')) {
              if (!_isLoggedIn) {
                setState(() {
                  _isLoggedIn = true;
                });
                _controller.runJavaScript(analysisJavaScriptCode);

                Future.delayed(const Duration(milliseconds: 800), () {
                  _slideInController.forward();
                  _bounceController.forward();

                  Future.delayed(const Duration(seconds: 10), () {
                    if (_isLoggedIn && !_isPanelOpen && !_hasResults) {
                      _bounceController.reset();
                      _bounceController.forward();
                    }
                  });
                });
              }
            }
          },
        ),
      );
      await _controller.loadRequest(
        Uri.parse('https://www.instagram.com/accounts/login/'),
      );
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _bounceController.dispose();
    _slideInController.dispose();
    _glowController.dispose();
    _headerAnimationController.dispose();
    super.dispose();
  }

  void _openPanel() {
    if (!_isPanelOpen) {
      setState(() {
        _isPanelOpen = true;
      });
      _slideController.forward();
    }
  }

  void _closePanel() {
    if (_isPanelOpen) {
      _slideController.reverse().then((_) {
        setState(() {
          _isPanelOpen = false;
        });
      });
    }
  }

  void _copySelectedUsers() {
    final selectedList = _selectedUsers.toList();
    if (selectedList.isNotEmpty) {
      final usernamesText = selectedList.join('\n');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.copy, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'users_copied'.tr(args: [selectedList.length.toString()]),
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: Duration(seconds: 2),
        ),
      );

      Clipboard.setData(ClipboardData(text: usernamesText));
    }
  }

  void _selectAllUsers() {
    setState(() {
      if (_selectedUsers.length == _unfollowers.length) {
        _selectedUsers.clear();
      } else {
        _selectedUsers = _unfollowers.toSet();
      }
    });
  }

  Widget _buildInstagramHeader() {
    return AnimatedBuilder(
      animation: _headerAnimation,
      builder: (context, child) {
        return Container(
          height: 100 + MediaQuery.of(context).padding.top,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                instagramColors[0].withValues(
                  alpha: 0.8 + (0.2 * _headerAnimation.value),
                ),
                instagramColors[2].withValues(
                  alpha: 0.8 + (0.2 * _headerAnimation.value),
                ),
                instagramColors[4].withValues(
                  alpha: 0.8 + (0.2 * _headerAnimation.value),
                ),
                instagramColors[6].withValues(
                  alpha: 0.8 + (0.2 * _headerAnimation.value),
                ),
              ],
              stops: [
                0.0,
                0.3 + (0.1 * _headerAnimation.value),
                0.7 + (0.1 * _headerAnimation.value),
                1.0,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: instagramColors[3].withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.9),
                          Colors.white.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt_outlined,
                      size: 26,
                      color: instagramColors[3],
                    ),
                  ),
                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.white.withValues(alpha: 0.9),
                            ],
                          ).createShader(bounds),
                          child: Text(
                            'app_name'.tr(),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.8),
                              Colors.white.withValues(alpha: 0.6),
                            ],
                          ).createShader(bounds),
                          child: Text(
                            'app_subtitle'.tr(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Dil seçici
                  LanguageSelector(),
                  const SizedBox(width: 10),

                  if (_isLoggedIn)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.2),
                        border: Border.all(
                          color: Colors.green.shade300,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'connected'.tr(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSlidePanel() {
    return SlideTransition(
      position: _slideAnimation,
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
              color: instagramColors[3].withValues(alpha: 0.1),
              blurRadius: 40,
              offset: const Offset(-15, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildPanelHeader(),
            Expanded(child: _buildPanelContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildPanelHeader() {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(25, topPadding + 15, 25, 25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [instagramColors[0], instagramColors[2], instagramColors[4]],
        ),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  _hasResults
                      ? Icons.list_alt_rounded
                      : Icons.analytics_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'instagram_analysis'.tr(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      _hasResults
                          ? 'analysis_completed'.tr()
                          : 'analysis_center'.tr(),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: _closePanel,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          if (_currentUsername.isNotEmpty) ...[
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.account_circle_outlined,
                    color: Colors.white.withValues(alpha: 0.9),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '@$_currentUsername',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPanelContent() {
    if (_isLoading) {
      return _buildLoadingContent();
    } else if (_errorMessage.isNotEmpty) {
      return _buildErrorContent();
    } else if (_hasResults) {
      return _buildResultsContent();
    } else if (_showManualInput) {
      return _buildManualInputContent();
    } else {
      return _buildWelcomeContent();
    }
  }

  Widget _buildWelcomeContent() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade50, Colors.green.shade100],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.verified_user_outlined,
                size: 70,
                color: Colors.green.shade600,
              ),
            ),
          ),
          const SizedBox(height: 30),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [instagramColors[2], instagramColors[4]],
            ).createShader(bounds),
            child: Text(
              'connected_successfully'.tr(),
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'ready_to_analyze'.tr(),
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  instagramColors[0],
                  instagramColors[2],
                  instagramColors[4],
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: instagramColors[3].withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = '';
                  _unfollowers.clear();
                  _progressMessage = 'starting_analysis'.tr();
                });
                _controller.runJavaScript('analyzeAccount()');
              },
              icon: const Icon(
                Icons.analytics_outlined,
                size: 28,
                color: Colors.white,
              ),
              label: Text(
                'analyze_my_account'.tr(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingContent() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      instagramColors[0].withValues(alpha: 0.1),
                      instagramColors[4].withValues(alpha: 0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  strokeWidth: 6,
                  valueColor: AlwaysStoppedAnimation(
                    LinearGradient(
                      colors: [instagramColors[0], instagramColors[4]],
                    ).colors.first,
                  ),
                ),
              ),
              Icon(
                Icons.analytics_outlined,
                size: 35,
                color: instagramColors[3],
              ),
            ],
          ),
          const SizedBox(height: 30),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [instagramColors[2], instagramColors[4]],
            ).createShader(bounds),
            child: Text(
              'analysis_in_progress'.tr(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            _progressMessage,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Container(
            width: double.infinity,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [instagramColors[0], instagramColors[4]],
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsContent() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.fromLTRB(20, 15, 20, 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.red.shade50,
                Colors.red.shade100.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.red.shade200, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade100, Colors.red.shade200],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_remove_outlined,
                  color: Colors.red.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'people_found'.tr(args: [_unfollowers.length.toString()]),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'not_following_back'.tr(),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_unfollowers.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [instagramColors[0], instagramColors[2]],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _selectAllUsers,
                    child: Row(
                      children: [
                        Icon(
                          _selectedUsers.length == _unfollowers.length
                              ? Icons.check_box
                              : _selectedUsers.isEmpty
                                  ? Icons.check_box_outline_blank
                                  : Icons.indeterminate_check_box,
                          color: Colors.white,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _selectedUsers.isEmpty
                              ? 'select_all'.tr()
                              : _selectedUsers.length == _unfollowers.length
                                  ? 'clear_all'.tr()
                                  : 'selected_count'.tr(
                                      args: [_selectedUsers.length.toString()]),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_selectedUsers.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: _copySelectedUsers,
                      icon: const Icon(
                        Icons.copy,
                        color: Colors.white,
                        size: 18,
                      ),
                      tooltip: 'copy_selected'.tr(),
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _unfollowers.length,
            itemBuilder: (context, index) {
              final user = _unfollowers[index];
              final isSelected = _selectedUsers.contains(user);

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? instagramColors[0].withValues(alpha: 0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? instagramColors[0] : Colors.transparent,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  leading: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedUsers.remove(user);
                        } else {
                          _selectedUsers.add(user);
                        }
                      });
                    },
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isSelected
                              ? [instagramColors[0], instagramColors[2]]
                              : [Colors.red.shade100, Colors.red.shade200],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isSelected ? Icons.check : Icons.person_outline,
                        color: isSelected ? Colors.white : Colors.red.shade700,
                        size: 22,
                      ),
                    ),
                  ),
                  title: Text(
                    '@$user',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: isSelected ? instagramColors[3] : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    'not_following'.tr(),
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  trailing: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [instagramColors[0], instagramColors[2]],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.open_in_new_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      onPressed: () {
                        _closePanel();
                        _controller.loadRequest(
                          Uri.parse('https://www.instagram.com/$user/'),
                        );
                      },
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedUsers.remove(user);
                      } else {
                        _selectedUsers.add(user);
                      }
                    });
                  },
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey.shade600, Colors.grey.shade700],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                setState(() {
                  _unfollowers.clear();
                  _errorMessage = '';
                  _showManualInput = false;
                  _hasResults = false;
                  _isLoading = true;
                  _progressMessage = 'starting_analysis'.tr();
                  _selectedUsers.clear();
                });
                _controller.runJavaScript('analyzeAccount()');
              },
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: Text(
                'restart_analysis'.tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildManualInputContent() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade50, Colors.orange.shade100],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.edit_outlined,
              size: 70,
              color: Colors.orange.shade600,
            ),
          ),
          const SizedBox(height: 30),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [instagramColors[6], instagramColors[8]],
            ).createShader(bounds),
            child: Text(
              'username_required'.tr(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'enter_username_manually'.tr(),
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: TextField(
              controller: _usernameController,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                labelText: 'instagram_username'.tr(),
                labelStyle: TextStyle(color: instagramColors[3]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: instagramColors[3], width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                prefixIcon: Icon(
                  Icons.alternate_email,
                  color: instagramColors[3],
                ),
                hintText: 'username_placeholder'.tr(),
                hintStyle: TextStyle(color: Colors.grey.shade400),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
              ),
              keyboardType: TextInputType.text,
              autocorrect: false,
            ),
          ),
          const SizedBox(height: 30),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  instagramColors[0],
                  instagramColors[2],
                  instagramColors[4],
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: instagramColors[3].withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                final username = _usernameController.text.trim();
                if (username.isNotEmpty) {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = '';
                    _unfollowers.clear();
                    _progressMessage = 'starting_analysis'.tr();
                    _showManualInput = false;
                  });
                  _controller.runJavaScript('analyzeAccount("$username")');
                }
              },
              icon: const Icon(
                Icons.analytics_outlined,
                size: 24,
                color: Colors.white,
              ),
              label: Text(
                'start_analysis'.tr(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorContent() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade50, Colors.red.shade100],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 70,
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(height: 30),
          Text(
            'error_occurred'.tr(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            _errorMessage,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade500, Colors.blue.shade700],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                setState(() {
                  _errorMessage = '';
                  _currentUsername = '';
                });
              },
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: Text(
                'try_again'.tr(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEdgeIndicator() {
    if (!_isLoggedIn || _isPanelOpen) return const SizedBox();

    return Positioned(
      right: 0,
      top: MediaQuery.of(context).size.height * 0.4,
      child: SlideTransition(
        position: _slideInAnimation,
        child: ScaleTransition(
          scale: _bounceAnimation,
          child: AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return GestureDetector(
                onTap: _openPanel,
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity! < 0) {
                    _openPanel();
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      bottomLeft: Radius.circular(25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 15,
                        offset: const Offset(-5, 0),
                      ),
                      BoxShadow(
                        color: (_hasResults ? Colors.green : instagramColors[3])
                            .withValues(alpha: 0.4 * _glowAnimation.value),
                        blurRadius: 25 + (15 * _glowAnimation.value),
                        offset: const Offset(-10, 0),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: 55,
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: _hasResults
                              ? [
                                  Colors.green.shade400.withValues(
                                    alpha: 0.85 + (0.15 * _glowAnimation.value),
                                  ),
                                  Colors.green.shade600.withValues(
                                    alpha: 0.85 + (0.15 * _glowAnimation.value),
                                  ),
                                  Colors.green.shade700.withValues(
                                    alpha: 0.85 + (0.15 * _glowAnimation.value),
                                  ),
                                ]
                              : [
                                  instagramColors[0].withValues(
                                    alpha: 0.85 + (0.15 * _glowAnimation.value),
                                  ),
                                  instagramColors[2].withValues(
                                    alpha: 0.85 + (0.15 * _glowAnimation.value),
                                  ),
                                  instagramColors[4].withValues(
                                    alpha: 0.85 + (0.15 * _glowAnimation.value),
                                  ),
                                ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(25),
                          bottomLeft: Radius.circular(25),
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ScaleTransition(
                            scale: _pulseAnimation,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(
                                  alpha: 0.25 + (0.15 * _glowAnimation.value),
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                _hasResults
                                    ? Icons.checklist_rounded
                                    : Icons.analytics_outlined,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (_hasResults)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(
                                  alpha: 0.9 + (0.1 * _glowAnimation.value),
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '${_unfollowers.length}',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(3, (index) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 1.5,
                                  ),
                                  width: 3,
                                  height: 8 + (index == 1 ? 4 : 0),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(
                                      alpha:
                                          (0.4 + (0.3 * _glowAnimation.value)) *
                                              (index == 1 ? 1.2 : 0.8),
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              _buildInstagramHeader(),
              Expanded(child: WebViewWidget(controller: _controller)),
            ],
          ),
          _buildEdgeIndicator(),
          if (_isPanelOpen)
            GestureDetector(
              onTap: _closePanel,
              child: Container(color: Colors.black.withValues(alpha: 0.4)),
            ),
          if (_isPanelOpen)
            Positioned(right: 0, top: 0, bottom: 0, child: _buildSlidePanel()),
        ],
      ),
    );
  }
}
