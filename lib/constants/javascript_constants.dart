class JavaScriptConstants {
  static const String logoutDetectionCode = r'''
    let lastLoginStatus = null;
    let consecutiveLogoutChecks = 0;
    
    const checkLoginStatus = () => {
      try {
        const currentUrl = window.location.href;
        
        // Logout URL'lerini kontrol et
        const isLogoutUrl = currentUrl.includes('/accounts/logout') || 
                           currentUrl.includes('/logout') ||
                           currentUrl.includes('sessionid') ||
                           currentUrl.includes('/accounts/login/?next=') ||
                           currentUrl.includes('?next=');
        
        // Login sayfalarını kontrol et
        const isLoginPage = currentUrl.includes('/accounts/login') || 
                           currentUrl.includes('/accounts/emailsignup') ||
                           currentUrl.includes('/accounts/signin');
        
        // Login form varlığını kontrol et
        const hasLoginForm = document.querySelector('input[name="username"]') !== null;
        
        // Ana sayfa kontrolü
        const isMainPage = currentUrl === 'https://www.instagram.com/' || 
                          currentUrl.includes('instagram.com/?') ||
                          currentUrl.match(/^https:\/\/www\.instagram\.com\/?$/);
        
        // Instagram logout landing page kontrolü (?flo=true sayfası)
        const isLogoutLandingPage = (currentUrl.includes('?flo=true') || 
                                   currentUrl.includes('flo=true')) &&
                                  (document.querySelector('button[type="button"]') !== null ||
                                   document.textContent.includes('Open Instagram') ||
                                   document.textContent.includes('Log in or sign up') ||
                                   document.textContent.includes('Share everyday moments') ||
                                   document.textContent.includes('from Meta') ||
                                   document.querySelector('a[href*="sign_up"]') !== null ||
                                   (document.querySelector('button') && 
                                    document.querySelector('button').textContent.includes('Open Instagram')));
        
        // Logout URL'sinde ise hemen logout olarak işaretle
        if (isLogoutUrl) {
          UnfollowerChannel.postMessage(JSON.stringify({
            status: 'logged_out',
            reason: 'logout_url_detected'
          }));
          lastLoginStatus = 'logged_out';
          return;
        }
        
        // Logout landing page'inde ise logout olarak işaretle
        if (isLogoutLandingPage) {
          if (lastLoginStatus !== 'logged_out') {
            UnfollowerChannel.postMessage(JSON.stringify({
              status: 'logged_out',
              reason: 'logout_landing_page_detected'
            }));
            lastLoginStatus = 'logged_out';
          }
          return;
        }
        
        // Ana sayfada login form varsa logout
        if (isMainPage && hasLoginForm) {
          if (lastLoginStatus !== 'logged_out') {
            UnfollowerChannel.postMessage(JSON.stringify({
              status: 'logged_out',
              reason: 'login_form_on_main_page'
            }));
            lastLoginStatus = 'logged_out';
          }
          return;
        }
        
        // Login sayfasında ise logout
        if (isLoginPage) {
          if (lastLoginStatus !== 'logged_out') {
            UnfollowerChannel.postMessage(JSON.stringify({
              status: 'logged_out',
              reason: 'redirected_to_login'
            }));
            lastLoginStatus = 'logged_out';
          }
          return;
        }
        
        // Instagram sayfasında ve login form yok ise giriş durumunu kontrol et
        if (currentUrl.includes('instagram.com') && !isLoginPage && !hasLoginForm) {
          // Navigation elementlerini kontrol et
          const hasNavigation = document.querySelector('nav') !== null ||
                                document.querySelector('[role="navigation"]') !== null ||
                                document.querySelector('header') !== null;
          
          // Profile linkini kontrol et (giriş yapmış kullanıcılarda olur)
          const hasProfileLink = document.querySelector('[href*="/accounts/edit/"]') !== null ||
                                 document.querySelector('[href*="/accounts/"]') !== null ||
                                 document.querySelector('[aria-label*="Profile"]') !== null;
          
          // Stories veya feed elementlerini kontrol et
          const hasFeedElements = document.querySelector('[role="button"][aria-label*="Story"]') !== null ||
                                 document.querySelector('article') !== null ||
                                 document.querySelector('[data-testid="story-viewer"]') !== null;
          
          // Username display elementini kontrol et
          const hasUserDisplay = document.querySelector('[data-testid="user-avatar"]') !== null ||
                                 document.querySelector('img[alt*="profile picture"]') !== null;
          
          // Eğer bu elementlerden herhangi biri varsa ve navigation varsa giriş yapmış
          if (hasNavigation && (hasProfileLink || hasFeedElements || hasUserDisplay)) {
            if (lastLoginStatus !== 'logged_in') {
              UnfollowerChannel.postMessage(JSON.stringify({
                status: 'logged_in_confirmed',
                url: currentUrl
              }));
              lastLoginStatus = 'logged_in';
              consecutiveLogoutChecks = 0;
            }
            return;
          }
          
          // Eğer navigation var ama diğer elementler yoksa şüpheli durum
          if (hasNavigation && !hasProfileLink && !hasFeedElements && !hasUserDisplay) {
            consecutiveLogoutChecks++;
            
            // 3 kez üst üste bu durumda ise muhtemelen çıkış yapılmış
            if (consecutiveLogoutChecks >= 3 && lastLoginStatus === 'logged_in') {
              UnfollowerChannel.postMessage(JSON.stringify({
                status: 'logged_out',
                reason: 'session_elements_missing'
              }));
              lastLoginStatus = 'logged_out';
              consecutiveLogoutChecks = 0;
              return;
            }
          }
          
          // Hiç navigation elementi yoksa ve Instagram sayfasındaysa logout
          if (!hasNavigation && !hasLoginForm) {
            consecutiveLogoutChecks++;
            if (consecutiveLogoutChecks >= 2 && lastLoginStatus === 'logged_in') {
              UnfollowerChannel.postMessage(JSON.stringify({
                status: 'logged_out',
                reason: 'navigation_missing'
              }));
              lastLoginStatus = 'logged_out';
              consecutiveLogoutChecks = 0;
            }
          }
        }
        
        // Tamamen farklı bir domain'e yönlendirilmişse
        if (!currentUrl.includes('instagram.com') && lastLoginStatus === 'logged_in') {
          UnfollowerChannel.postMessage(JSON.stringify({
            status: 'logged_out',
            reason: 'redirected_away_from_instagram'
          }));
          lastLoginStatus = 'logged_out';
        }
        
      } catch (e) {
        console.log('Login status check error:', e);
      }
    };
    
    // Daha sık kontrol et (özellikle logout anında)
    setInterval(checkLoginStatus, 1000);
    
    // URL değişikliklerini izle
    let lastUrl = window.location.href;
    const monitorUrlChanges = () => {
      const currentUrl = window.location.href;
      if (currentUrl !== lastUrl) {
        lastUrl = currentUrl;
        consecutiveLogoutChecks = 0; // URL değişince counter'ı sıfırla
        setTimeout(checkLoginStatus, 200); // Hızlı kontrol
        setTimeout(checkLoginStatus, 500); // Yedek kontrol
      }
    };
    
    setInterval(monitorUrlChanges, 500);
    
    // Sayfa yüklendiğinde hemen kontrol et
    checkLoginStatus();
    
    // MutationObserver ile DOM değişikliklerini izle
    const observer = new MutationObserver((mutations) => {
      let shouldCheck = false;
      
      mutations.forEach((mutation) => {
        if (mutation.type === 'childList') {
          mutation.addedNodes.forEach(node => {
            if (node.nodeType === 1) { // Element node
              // Navigation veya form elementleri eklendiyse kontrol et
              if (node.tagName === 'NAV' || 
                  node.tagName === 'HEADER' ||
                  node.tagName === 'FORM' ||
                  node.tagName === 'BUTTON' ||
                  (node.querySelector && node.querySelector('input[name="username"]')) ||
                  (node.textContent && (node.textContent.includes('Open Instagram') ||
                                       node.textContent.includes('Log in or sign up') ||
                                       node.textContent.includes('Share everyday moments')))) {
                shouldCheck = true;
              }
            }
          });
          
          mutation.removedNodes.forEach(node => {
            if (node.nodeType === 1) { // Element node
              // Navigation elementleri kaldırıldıysa kontrol et
              if (node.tagName === 'NAV' || 
                  node.tagName === 'HEADER' ||
                  (node.querySelector && (node.querySelector('nav') || node.querySelector('header')))) {
                shouldCheck = true;
              }
            }
          });
        }
      });
      
      if (shouldCheck) {
        setTimeout(checkLoginStatus, 100);
      }
    });
    
    if (document.body) {
      observer.observe(document.body, {
        childList: true,
        subtree: true
      });
    } else {
      // Body henüz yoksa bekle
      document.addEventListener('DOMContentLoaded', () => {
        observer.observe(document.body, {
          childList: true,
          subtree: true
        });
      });
    }
  ''';

  static const String activeUserDetectionCode = r'''
    let currentActiveUser = null;
    let lastCapturedUser = null;
    let userDetectionInterval = null;
    
    // Aktif kullanıcıyı yakalama fonksiyonu
    const detectActiveUser = () => {
      try {
        let detectedUsername = null;
        
        // Yöntem 1: Navigation bar'daki profil linkinden
        const profileLinks = document.querySelectorAll('a[href*="/"]');
        for (const link of profileLinks) {
          const href = link.getAttribute('href');
          if (href && href.match(/^\/[a-zA-Z0-9._]{1,30}\/?$/)) {
            const username = href.replace(/\//g, '');
            // Bu kendi profilinin linki mi kontrol et
            const parentElement = link.closest('[role="navigation"], nav, header');
            if (parentElement && link.querySelector('img[alt*="profile picture"]')) {
              detectedUsername = username;
              break;
            }
          }
        }
        
        // Yöntem 2: Settings/Profile sayfalarından
        if (!detectedUsername) {
          const currentUrl = window.location.href;
          if (currentUrl.includes('/accounts/edit/') || currentUrl.includes('/accounts/')) {
            const usernameInputs = document.querySelectorAll('input[value]');
            for (const input of usernameInputs) {
              const value = input.value;
              if (value && value.match(/^[a-zA-Z0-9._]{1,30}$/)) {
                detectedUsername = value;
                break;
              }
            }
          }
        }
        
        // Yöntem 3: URL'den direkt çekme (kendi profil sayfasında)
        if (!detectedUsername) {
          const currentUrl = window.location.href;
          const profileMatch = currentUrl.match(/instagram\.com\/([a-zA-Z0-9._]{1,30})\/?$/);
          if (profileMatch) {
            const username = profileMatch[1];
            // Bu sayfada "Edit profile" butonu varsa, bu kullanıcının kendi profili
            const editButton = document.querySelector('a[href="/accounts/edit/"], button:contains("Edit profile")');
            if (editButton) {
              detectedUsername = username;
            }
          }
        }
        
        // Yöntem 4: Instagram'ın internal data'sından
        if (!detectedUsername) {
          try {
            // window._sharedData veya benzeri global objeler
            if (window._sharedData && window._sharedData.config && window._sharedData.config.viewer) {
              detectedUsername = window._sharedData.config.viewer.username;
            }
          } catch (e) {
            // Sessizce geç
          }
        }
        
        // Yöntem 5: DOM'daki data attributelerinden
        if (!detectedUsername) {
          const userElements = document.querySelectorAll('[data-username], [data-testid*="user"]');
          for (const element of userElements) {
            const username = element.getAttribute('data-username') || element.textContent;
            if (username && username.match(/^[a-zA-Z0-9._]{1,30}$/)) {
              detectedUsername = username;
              break;
            }
          }
        }
        
        // Kullanıcı değişimi kontrolü
        if (detectedUsername && detectedUsername !== lastCapturedUser) {
          lastCapturedUser = detectedUsername;
          currentActiveUser = detectedUsername;
          
          // Local storage'a kaydet
          try {
            localStorage.setItem('captured_instagram_username', detectedUsername);
          } catch (e) {
            // Storage hatası - sessizce geç
          }
          
          // Flutter'a bildir
          try {
            if (typeof UnfollowerChannel !== 'undefined') {
              UnfollowerChannel.postMessage(JSON.stringify({
                status: 'active_user_detected',
                username: detectedUsername,
                timestamp: Date.now(),
                method: 'auto_detection'
              }));
            }
          } catch (e) {
            console.log('Channel error:', e);
          }
          
          console.log('Active user detected:', detectedUsername);
        }
        
        return detectedUsername;
        
      } catch (error) {
        console.log('User detection error:', error);
        return null;
      }
    };
    
    // Sürekli kullanıcı kontrolü
    const startUserDetection = () => {
      // İlk kontrol
      detectActiveUser();
      
      // Periyodik kontrol (her 3 saniyede bir)
      if (userDetectionInterval) {
        clearInterval(userDetectionInterval);
      }
      
      userDetectionInterval = setInterval(() => {
        const currentUrl = window.location.href;
        if (currentUrl.includes('instagram.com') && !currentUrl.includes('login')) {
          detectActiveUser();
        }
      }, 3000);
    };
    
    // URL değişikliklerini izle
    let lastDetectionUrl = window.location.href;
    const monitorUrlForUserDetection = () => {
      const currentUrl = window.location.href;
      if (currentUrl !== lastDetectionUrl) {
        lastDetectionUrl = currentUrl;
        
        // URL değiştiğinde 1 saniye sonra kontrol et
        setTimeout(() => {
          detectActiveUser();
        }, 1000);
      }
    };
    
    setInterval(monitorUrlForUserDetection, 1000);
    
    // DOM değişikliklerini izle
    const observeForUserChanges = () => {
      const observer = new MutationObserver((mutations) => {
        let shouldCheck = false;
        
        mutations.forEach((mutation) => {
          if (mutation.type === 'childList') {
            mutation.addedNodes.forEach(node => {
              if (node.nodeType === 1) {
                // Navigation, profile veya user-related elementler eklendiyse
                if (node.tagName === 'NAV' || 
                    node.tagName === 'HEADER' ||
                    node.querySelector && (
                      node.querySelector('img[alt*="profile picture"]') ||
                      node.querySelector('a[href*="/accounts/"]') ||
                      node.querySelector('[data-username]')
                    )) {
                  shouldCheck = true;
                }
              }
            });
          }
        });
        
        if (shouldCheck) {
          setTimeout(detectActiveUser, 500);
        }
      });
      
      if (document.body) {
        observer.observe(document.body, {
          childList: true,
          subtree: true
        });
      }
    };
    
    // Başlat
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', () => {
        startUserDetection();
        observeForUserChanges();
      });
    } else {
      startUserDetection();
      observeForUserChanges();
    }
    
    // Manuel tetikleme fonksiyonu
    window.triggerUserDetection = () => {
      return detectActiveUser();
    };
    
    // Mevcut kullanıcıyı al fonksiyonu
    window.getCurrentActiveUser = () => {
      return currentActiveUser;
    };
  ''';

  static const String enhancedLoginCaptureCode = r'''
    const captureUsernameEnhanced = () => {
      // Önce aktif kullanıcıyı kontrol et
      const activeUser = window.getCurrentActiveUser && window.getCurrentActiveUser();
      if (activeUser) {
        handleUsernameCapture('active_user_check', activeUser);
        return;
      }
      
      // Sonra login formunu kontrol et
      const universalSelectors = [
        'input[name="username"][maxlength="75"][type="text"]',
        'input[name="username"][autocapitalize="off"]',
        'input[name="username"][maxlength="75"]',
        'input[name="username"]',
        'input[maxlength="75"][type="text"][autocapitalize="off"]',
        'input[type="text"][maxlength="75"]',
      ];
      
      let usernameInput = null;
      for (const selector of universalSelectors) {
        try {
          const inputs = document.querySelectorAll(selector);
          if (inputs.length > 0) {
            usernameInput = inputs[0];
            break;
          }
        } catch (e) {
          continue;
        }
      }
      
      if (usernameInput && usernameInput.value) {
        handleUsernameCapture('login_form', usernameInput.value.trim());
      }
    };
    
    const handleUsernameCapture = (method, username) => {
      if (username && username.length > 0) {
        try {
          localStorage.setItem('captured_instagram_username', username);
          
          if (typeof UnfollowerChannel !== 'undefined') {
            UnfollowerChannel.postMessage(JSON.stringify({
              status: 'username_captured',
              username: username,
              method: method,
              timestamp: Date.now()
            }));
          }
        } catch (e) {
          console.log('Username capture error:', e);
        }
      }
    };
    
    // Gelişmiş yakalama başlat
    captureUsernameEnhanced();
    
    // Periyodik kontrol
    setInterval(captureUsernameEnhanced, 2000);
  ''';

  static const String analysisJavaScriptCode = r'''
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
      
      // Create maps for easier lookup with both username and profile picture
      const followersMap = new Map();
      const followingMap = new Map();
      
      followers.forEach((user) => {
        followersMap.set(user.username.toLowerCase(), {
          username: user.username,
          profilePicUrl: user.profile_pic_url || ''
        });
      });
      
      following.forEach((user) => {
        followingMap.set(user.username.toLowerCase(), {
          username: user.username,
          profilePicUrl: user.profile_pic_url || ''
        });
      });
      
      // People I follow but don't follow me back
      const notFollowingBack = [];
      followingMap.forEach((userData, username) => {
        if (!followersMap.has(username)) {
          notFollowingBack.push(userData);
        }
      });
      
      // People who follow me but I don't follow back (fans)
      const fans = [];
      followersMap.forEach((userData, username) => {
        if (!followingMap.has(username)) {
          fans.push(userData);
        }
      });
      
      return { notFollowingBack, fans };
    };

    async function analyzeAccountEnhanced(username = null) {
      try {
        let targetUsername = username;
        
        // 1. Parametre olarak gelen username'i kullan
        if (!targetUsername) {
          // 2. Aktif kullanıcıyı kontrol et
          targetUsername = window.getCurrentActiveUser && window.getCurrentActiveUser();
        }
        
        if (!targetUsername) {
          // 3. Local storage'dan al
          targetUsername = localStorage.getItem('captured_instagram_username');
        }
        
        if (!targetUsername) {
          // 4. Son çare: manuel giriş iste
          UnfollowerChannel.postMessage(JSON.stringify({
            status: 'need_manual_input',
            reason: 'no_username_detected'
          }));
          return;
        }
        
        // Username tespit edildi, analizi başlat
        UnfollowerChannel.postMessage(JSON.stringify({
          status: 'username_confirmed',
          username: targetUsername,
          source: 'auto_detection'
        }));
        
        const result = await getUserFriendshipStats(targetUsername);
        UnfollowerChannel.postMessage(JSON.stringify(result));
        
      } catch (e) {
        UnfollowerChannel.postMessage('{"error":"' + e.message + '"}');
      }
    }

    // Global fonksiyon override
    window.analyzeAccount = analyzeAccountEnhanced;

    function clearStoredUsername() {
      localStorage.removeItem('captured_instagram_username');
    }
  ''';
}
