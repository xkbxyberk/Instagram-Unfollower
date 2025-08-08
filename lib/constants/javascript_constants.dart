class JavaScriptConstants {
  static const String logoutDetectionCode = r'''
    const checkLoginStatus = () => {
      try {
        const currentUrl = window.location.href;
        const isLoginPage = currentUrl.includes('/accounts/login') || 
                           currentUrl.includes('/accounts/emailsignup') ||
                           currentUrl.includes('/accounts/signin');
        
        const hasLoginForm = document.querySelector('input[name="username"]') !== null;
        
        const isMainPage = currentUrl === 'https://www.instagram.com/' || 
                          currentUrl.includes('instagram.com/?') ||
                          currentUrl.match(/^https:\/\/www\.instagram\.com\/?$/);
        
        if (isMainPage && hasLoginForm) {
          UnfollowerChannel.postMessage(JSON.stringify({
            status: 'logged_out',
            reason: 'login_form_on_main_page'
          }));
          return;
        }
        
        if (isLoginPage) {
          UnfollowerChannel.postMessage(JSON.stringify({
            status: 'logged_out',
            reason: 'redirected_to_login'
          }));
          return;
        }
        
        if (currentUrl.includes('instagram.com') && !isLoginPage && !hasLoginForm) {
          const hasNavigation = document.querySelector('nav') !== null ||
                                document.querySelector('[role="navigation"]') !== null ||
                                document.querySelector('header') !== null;
          
          if (hasNavigation) {
            UnfollowerChannel.postMessage(JSON.stringify({
              status: 'logged_in_confirmed',
              url: currentUrl
            }));
          }
        }
        
      } catch (e) {
        console.log('Login status check error:', e);
      }
    };
    
    setInterval(checkLoginStatus, 2000);
    
    let lastUrl = window.location.href;
    const monitorUrlChanges = () => {
      const currentUrl = window.location.href;
      if (currentUrl !== lastUrl) {
        lastUrl = currentUrl;
        setTimeout(checkLoginStatus, 500);
      }
    };
    
    setInterval(monitorUrlChanges, 1000);
    
    checkLoginStatus();
  ''';

  static const String loginCaptureCode = r'''
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
        UnfollowerChannel.postMessage(JSON.stringify(result));
        
      } catch (e) {
        UnfollowerChannel.postMessage('{"error":"' + e.message + '"}');
      }
    }

    function clearStoredUsername() {
      localStorage.removeItem('captured_instagram_username');
    }
  ''';
}
