import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:linux_do/const/app_const.dart';
import 'package:linux_do/controller/base_controller.dart';
import 'package:linux_do/net/http_client.dart';
import 'package:linux_do/net/http_config.dart';
import 'package:linux_do/utils/log.dart';
import 'package:linux_do/utils/storage_manager.dart';

class CloudflareTimingsService extends StatefulWidget {
  final String topicId;
  final VoidCallback onCookiesLoaded;

  const CloudflareTimingsService({
    super.key,
    required this.topicId,
    required this.onCookiesLoaded,
  });

  @override
  CloudflareTimingsServiceState createState() => CloudflareTimingsServiceState();
}

class CloudflareTimingsServiceState extends State<CloudflareTimingsService> {
  final CloudflareController cloudflareController = Get.find<CloudflareController>();

  bool _isCloudflareDetected = false;
  String _resultUrl = '';
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    _resultUrl = '${HttpConfig.baseUrl}t/topic/${widget.topicId}';
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  Future<void> _setupCookies(InAppWebViewController controller) async {
    try {
      await CookieManager.instance().deleteAllCookies();

      final cookieList = await NetClient.getInstance()
          .cookieJar
          .loadForRequest(Uri.parse(HttpConfig.baseUrl));

      for (final cookie in cookieList) {
        await CookieManager.instance().setCookie(
          url: WebUri(HttpConfig.baseUrl),
          name: cookie.name,
          value: cookie.value,
          domain: cookie.domain,
          path: cookie.path ?? '/',
          isHttpOnly: cookie.httpOnly,
          isSecure: cookie.secure,
        );
      }

      controller.addJavaScriptHandler(
        handlerName: 'checkLoginStatus',
        callback: (args) {
          // l.d('登录状态检查结果: $args');
          if (args.isNotEmpty && args[0]['isLoggedIn'] == true) {
            widget.onCookiesLoaded();
          }
          return null;
        },
      );

      final allCookiesJs = cookieList.map((cookie) {
        return "document.cookie='${cookie.name}=${cookie.value}; domain=${cookie.domain ?? HttpConfig.domain}; path=${cookie.path ?? '/'}'";
      }).join(';');

      controller.evaluateJavascript(source: '''
        $allCookiesJs;
        window.addEventListener('load', function() {
          const isLoggedIn = document.querySelector('.current-user') !== null;
          window.flutter_inappwebview.callHandler('checkLoginStatus', {
            isLoggedIn: isLoggedIn,
            cookies: document.cookie,
            elements: {
              userMenu: !!document.querySelector('.current-user'),
              loginButton: !!document.querySelector('.login-button')
            }
          });
        });
      ''');
    } catch (e, stack) {
      l.e('设置 cookies 失败: $e\n$stack');
    }
  }

  Future<void> _simulateUserInteraction() async {
    if (cloudflareController.webViewController == null) return;

    try {
      final hasTurnstile = await cloudflareController.webViewController!
              .evaluateJavascript(source: '''
        !!document.querySelector('div.cf-turnstile')
      ''') ??
          false;

      if (hasTurnstile) {
        // 模拟点击 Turnstile 复选框
        await cloudflareController.webViewController!
            .evaluateJavascript(source: '''
          const turnstile = document.querySelector('div.cf-turnstile iframe');
          if (turnstile) {
            turnstile.contentWindow.postMessage({
              event: 'click',
              type: 'checkbox'
            }, '*');
            console.log('模拟点击 Turnstile 复选框');
          }
        ''');

        await Future.delayed(const Duration(seconds: 3));

        final isVerified = await cloudflareController.webViewController!
                .evaluateJavascript(source: '''
          document.querySelector('input[name="cf-turnstile-response"]')?.value !== undefined
        ''') ??
            false;

        if (isVerified) {
          //l.d('Turnstile 验证通过，重新加载目标页面...');
          _isCloudflareDetected = false;
          await cloudflareController.webViewController!.loadUrl(
            urlRequest: URLRequest(url: WebUri(_resultUrl)),
          );
        } else {
          l.w('Turnstile 验证未通过，稍后重试...');
          _scheduleRetry();
        }
      }
    } catch (e, stack) {
      l.e('模拟用户交互失败: $e\n$stack');
      _scheduleRetry();
    }
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    _retryTimer = Timer(const Duration(seconds: 5), () {
      if (cloudflareController.webViewController != null) {
        l.d('重试加载页面...');
        cloudflareController.webViewController!.loadUrl(
          urlRequest: URLRequest(url: WebUri(_resultUrl)),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final csrfToken = StorageManager.getString(AppConst.identifier.csrfToken);
    return InAppWebView(
      key: UniqueKey(),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        domStorageEnabled: true,
        databaseEnabled: true,
        clearSessionCache: false,
        clearCache: false,
        useShouldInterceptRequest: true,
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
        allowsInlineMediaPlayback: true,
        transparentBackground: true,
        javaScriptCanOpenWindowsAutomatically: true,
        userAgent: NetClient.userAgent,
        supportMultipleWindows: true,
        allowFileAccess: true,
        allowContentAccess: true,
      ),
      initialUrlRequest: URLRequest(
        url: WebUri(_resultUrl),
        headers: {
          'User-Agent': NetClient.userAgent,
          if (csrfToken != null) 'X-CSRF-Token': csrfToken,
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          'Accept-Language': 'zh-CN,zh-Hans;q=0.9',
        },
      ),
      onWebViewCreated: (InAppWebViewController controller) {
        cloudflareController.webViewController = controller;
        _setupCookies(controller);
      },
      onLoadStart: (controller, url) {
        //l.d('开始加载: $url');
        if (url.toString().contains('cloudflare') ||
            url.toString().contains('challenge')) {
          //l.d('检测到 Cloudflare 验证页面');
          _isCloudflareDetected = true;
        }
      },
      onLoadStop: (controller, url) async {
        //l.d('加载完成: $url');
        if (_isCloudflareDetected) {
          await _simulateUserInteraction();
        } else {
          // 检查登录状态
          await cloudflareController.webViewController
              ?.evaluateJavascript(source: '''
            const isLoggedIn = document.querySelector('.current-user') !== null;
            window.flutter_inappwebview.callHandler('checkLoginStatus', {
              isLoggedIn: isLoggedIn,
              cookies: document.cookie,
              elements: {
                userMenu: !!document.querySelector('.current-user'),
                loginButton: !!document.querySelector('.login-button')
              }
            });
          ''');
        }
      },
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        final url = navigationAction.request.url?.toString() ?? '';
        if (url.contains('cloudflare') || url.contains('challenge')) {
          //l.d('拦截到 Cloudflare 验证请求: $url');
          _isCloudflareDetected = true;
        }
        return NavigationActionPolicy.ALLOW;
      },
      onReceivedError: (controller, request, error) {
        l.e('WebView 加载错误: $error');
        _scheduleRetry();
      },
      onConsoleMessage: (controller, consoleMessage) {
        if (consoleMessage.message.contains('阅读时间')) {
          l.e('JS Console: $consoleMessage');
        }
      },
      gestureRecognizers: const {},
    );
  }
}

class CloudflareController extends BaseController {
  CloudflareController();

  InAppWebViewController? webViewController;

  Future<void> updateTopicTiming(Map<String, dynamic> timings) async {
    if (webViewController == null) return;

    final csrfToken = StorageManager.getString(AppConst.identifier.csrfToken);
    
    final Map<String, dynamic> requestData = {
      'topic_id': timings['topic_id'],
      'topic_time': timings['topic_time'],
      'timings': timings['timings']
    };

    final isLoggedInResult = await webViewController?.evaluateJavascript(
      source: 'document.querySelector(".current-user") !== null'
    );
    
    if (isLoggedInResult != true) {
      l.e('用户未登录，无法更新阅读时间');
      return;
    }

    final js = '''
      (function() {
        const xhr = new XMLHttpRequest();
        xhr.open('POST', '${HttpConfig.baseUrl}topics/timings', true);
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.setRequestHeader('X-CSRF-Token', '${csrfToken ?? ''}');
        xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
        xhr.setRequestHeader('Accept', 'application/json');
        xhr.setRequestHeader('Discourse-Present', 'true');
        xhr.setRequestHeader('Discourse-Background', 'true');
        xhr.setRequestHeader('X-SILENCE-LOGGER', 'true');
        
        xhr.onload = function() {
          if (xhr.status === 200) {
            console.log('成功更新阅读时间');
          } else {
            console.error('更新阅读时间失败: 状态码', xhr.status);
          }
        };
        
        xhr.onerror = function() {
          console.error('更新阅读时间失败: 网络错误');
        };
        
        xhr.send(JSON.stringify(${jsonEncode(requestData)}));
      })()
    ''';

    try {
      await webViewController?.evaluateJavascript(source: js);
    } catch (e, stack) {
      l.e('执行脚本失败: $e\n$stack');
    }
  }
}
