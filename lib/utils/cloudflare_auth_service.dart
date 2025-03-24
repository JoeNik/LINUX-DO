import 'dart:async';
import 'dart:io' as dart_io;
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:linux_do/const/app_const.dart';
import 'package:linux_do/net/http_client.dart';
import 'package:linux_do/net/http_config.dart';
import 'package:linux_do/utils/device_util.dart';
import 'package:linux_do/utils/log.dart';
import 'package:linux_do/utils/storage_manager.dart';
import 'package:path_provider/path_provider.dart';

class CloudflareAuthService {
  HeadlessInAppWebView? _webView;
  String _userAgent = '';
  late final CookieJar _cookieJar;
  final Completer<bool> _authCompleter = Completer<bool>();
  
  Future<bool> authenticate() async {
    if (_authCompleter.isCompleted) return _authCompleter.future;
    
    await _initCookieJar();
    await _initUserAgent();
    await _startHeadlessWebView();
    
    return _authCompleter.future;
  }
  
  Future<void> _initUserAgent() async {
    _userAgent = await DeviceUtil.getUserAgent();
  }
  
  Future<void> _initCookieJar() async {
    final directory = await getApplicationDocumentsDirectory();
    final cookiePath = '${directory.path}/.cookies/';
    _cookieJar = PersistCookieJar(ignoreExpires: true, storage: FileStorage(cookiePath));
  }
  
  Future<void> _startHeadlessWebView() async {
    _webView = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(HttpConfig.baseUrl)),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        userAgent: _userAgent,
        cacheEnabled: true,
        thirdPartyCookiesEnabled: true,
      ),
      onLoadStop: (controller, url) async {
        await _checkAndSaveCookies(controller);
        
        await controller.evaluateJavascript(source: '''
          function autoClickTurnstile() {
            const buttons = document.querySelectorAll('button, input[type="submit"]');
            for (const button of buttons) {
              if (button.textContent.includes('Verify') || button.value?.includes('Verify')) {
                button.click();
              }
            }
          }
          setInterval(autoClickTurnstile, 1000);
        ''');

        await _dispose();
      }
    );
    
    await _webView!.run();
  }
  
  Future<void> _checkAndSaveCookies(InAppWebViewController controller) async {
    final uri = Uri.parse(HttpConfig.baseUrl);
    final webUri = WebUri(uri.toString());
    
    // 获取所有 Cookie
    final cookieManager = CookieManager.instance();
    List<Cookie> cookies = await cookieManager.getCookies(url: webUri);
    
    bool needsCfVerification = false;
    
    // 检查是否需要 Cloudflare 验证
    for (var cookie in cookies) {
      if (cookie.name == 'cf_clearance') {
        needsCfVerification = true;
        break;
      }
    }
    
    // 保存必要的 cookies
    for (var cookie in cookies) {
      final name = cookie.name;
      final value = cookie.value;
      
      if (name == NetClient.tokenKey) {
        await _saveCookie(uri, name, value);
      } else if (name == NetClient.forumSession) {
        await _saveCookie(uri, name, value);
      } else if (name == NetClient.cfClearance && needsCfVerification) {
        await _saveCookie(uri, name, value);
        l.d('更新 cf_clearance: $value');
        await StorageManager.setData(AppConst.identifier.cfClearance, value);
      }
    }

    
      await _fetchCsrfToken(controller);
  }
  
Future<void> _saveCookie(Uri uri, String name, String value) async {
  final cookie = dart_io.Cookie(name, value)
    ..domain = HttpConfig.domain
    ..path = '/'
    ..httpOnly = true
    ..secure = true;
  await _cookieJar.saveFromResponse(uri, [cookie]);
  await NetClient.getInstance().cookieJar.saveFromResponse(uri, [cookie]);
  l.d('同步 Cookie 到 NetClient: $name=$value');
}
  
  Future<void> _fetchCsrfToken(InAppWebViewController controller) async {
    // 尝试从 meta 标签获取
    var result = await controller.evaluateJavascript(source: '''
      (function() {
        const meta = document.querySelector('meta[name="csrf-token"]');
        return meta ? meta.getAttribute('content') : null;
      })();
    ''');
    
    // 如果失败，尝试通过 API 获取
    if (result == null || result.toString() == '{}' || result.toString().isEmpty) {
      result = await controller.evaluateJavascript(source: '''
        fetch('${HttpConfig.baseUrl}session/csrf', {
          credentials: 'include',
          headers: {
            'Accept': 'application/json',
            'X-Requested-With': 'XMLHttpRequest',
            'User-Agent': '$_userAgent'
          }
        })
        .then(response => response.text())
        .then(text => {
          try {
            const data = JSON.parse(text);
            return data.csrf;
          } catch (e) {
            return null;
          }
        });
      ''');
    }
    
    if (result != null && result.toString() != '{}' && result.toString().isNotEmpty) {
      await StorageManager.setData(AppConst.identifier.csrfToken, result.toString());
     
    }

     if (!_authCompleter.isCompleted) {
        _authCompleter.complete(true);
      }
      
  }
  
  Future<void> _dispose() async {
    await _webView?.dispose();
    _webView = null;
  }
}