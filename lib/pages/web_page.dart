import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io' as dart_io;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:linux_do/const/app_spacing.dart';
import '../../net/http_config.dart';
import '../controller/global_controller.dart';
import '../widgets/dis_loading.dart';
import '../../const/app_const.dart';
import '../../const/app_sizes.dart';
import '../../utils/log.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import '../net/http_client.dart';
import '../widgets/state_view.dart';
import '../utils/storage_manager.dart';

/// 很无奈,解决不了CF验证的问题,
/// 跳转系统浏览器由于无法共享cookie,目前唯一能想到方法
/// 使用webview加载,然后检查cookie,如果cookie存在,则认为登录成功
class WebPage extends StatefulWidget {
  const WebPage({super.key});

  /// 清理所有 WebView 缓存
  static Future<void> clearCache() async {
    try {
      // 清理 Cookies
      await CookieManager.instance().deleteAllCookies();

      // 清理缓存和存储
      await InAppWebViewController.clearAllCache();

      l.d('WebView 缓存已清理');
    } catch (e) {
      l.e('清理 WebView 缓存失败: $e');
    }
  }

  @override
  State<WebPage> createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  InAppWebViewController? _controller;
  bool isLoading = true;
  String? _error;
  late final CookieJar _cookieJar;
  String _userAgent = '';

  @override
  void initState() {
    super.initState();
    _initCookieJar();
    _initUserAgent();
  }

  @override
  void dispose() {
    _controller = null;
    super.dispose();
  }

  Future<void> _initUserAgent() async {
    setState(() {});
    _userAgent = await getUserAgent();
  }

  Future<void> _initCookieJar() async {
    final directory = await getApplicationDocumentsDirectory();
    final cookiePath = '${directory.path}/.cookies/';
    _cookieJar =
        PersistCookieJar(ignoreExpires: true, storage: FileStorage(cookiePath));
    setState(() {});
  }

  Future<void> _checkAndSaveCookies() async {
    try {
      final uri = Uri.parse(HttpConfig.baseUrl);
      final webUri = WebUri(uri.toString());

      // 获取所有 Cookie
      final cookieManager = CookieManager.instance();
      List<Cookie> inAppCookies = await cookieManager.getCookies(url: webUri);

      bool hasTokenCookie = false;
      bool hasSessionCookie = false;
      bool hasCfCookie = false;
      bool needsCfVerification = false; // 添加标志位判断是否需要 CF 验证

      // 检查是否需要 Cloudflare 验证
      // 网站使用了 Cloudflare 的 DDoS 保护才需要获取这个
      for (var cookie in inAppCookies) {
        if (cookie.name == 'cf_clearance') {
          needsCfVerification = true;
          break;
        }
      }

      for (var cookie in inAppCookies) {
        final name = cookie.name;
        final value = cookie.value;

        // 根据 Cookie 名称保存特定的 Cookie
        if (name == HttpClient.tokenKey) {
          hasTokenCookie = true;
          await _cookieJar.saveFromResponse(uri, [
            dart_io.Cookie(name, value)
              ..domain = HttpConfig.domain
              ..path = '/'
              ..httpOnly = true
              ..secure = true
          ]);
        } else if (name == HttpClient.forumSession) {
          hasSessionCookie = true;
          await _cookieJar.saveFromResponse(uri, [
            dart_io.Cookie(name, value)
              ..domain = HttpConfig.domain
              ..path = '/'
              ..httpOnly = true
              ..secure = true
          ]);
        } else if (name == HttpClient.cfClearance && needsCfVerification) {
          hasCfCookie = true;
          await _cookieJar.saveFromResponse(uri, [
            dart_io.Cookie(name, value)
              ..domain = HttpConfig.domain
              ..path = '/'
              ..httpOnly = true
              ..secure = true
          ]);
        }
      }

      // 根据是否需要 CF 验证来判断登录条件
      bool isLoginSuccess = hasTokenCookie &&
          hasSessionCookie &&
          (!needsCfVerification || (needsCfVerification && hasCfCookie));

      if (isLoginSuccess) {
        // 获取 CSRF Token
        final result = await _controller?.evaluateJavascript(source: '''
          (function() {
            const meta = document.querySelector('meta[name="csrf-token"]');
            return meta ? meta.getAttribute('content') : null;
          })();
        ''');

        if (result != null) {
          await StorageManager.setData(
              AppConst.identifier.csrfToken, result.toString());
          l.d('已保存 CSRF Token: $result');
        }

        // l.d('登录成功');
        // await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Future.delayed(const Duration(milliseconds: 200), () {
            Get.find<GlobalController>().fetchUserInfo();
            Get.back(result: true);
          });
        }
      } else {
        // 如果没有获取到所需的 cookies，尝试请求相关接口
        await _controller?.evaluateJavascript(source: '''
          fetch('${HttpConfig.baseUrl}session/csrf', {
            credentials: 'include',
            headers: { 'X-Requested-With': 'XMLHttpRequest' }
          }).then(() => {
            return fetch('${HttpConfig.baseUrl}top.json', {
              credentials: 'include'
            });
          }).catch(error => {
            console.error('请求失败:', error);
          });
        ''');
      }
    } catch (e) {
      l.e('检查 cookies 失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppConst.login.webTitle,
          style: TextStyle(fontSize: AppSizes.fontMedium),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(HttpConfig.baseUrl)),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              useOnDownloadStart: true,
              userAgent: _userAgent,
            ),
            onWebViewCreated: (controller) {
              _controller = controller;
            },
            onLoadStart: (controller, url) {
              setState(() {
                isLoading = true;
                _error = null;
              });
            },
            onLoadStop: (controller, url) async {
              setState(() => isLoading = false);
              await _checkAndSaveCookies();

              // 注入辅助脚本
              await controller.evaluateJavascript(source: '''
                // 自动点击验证按钮
                function autoClickTurnstile() {
                  const buttons = document.querySelectorAll('button, input[type="submit"]');
                  for (const button of buttons) {
                    if (button.textContent.includes('Verify') || 
                        button.value?.includes('Verify')) {
                      button.click();
                    }
                  }
                }
                setInterval(autoClickTurnstile, 1000);
              ''');
            },
            // ignore: deprecated_member_use
            onLoadError: (controller, url, code, message) {
              setState(() {
                _error = message;
                isLoading = false;
              });
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              final uri = navigationAction.request.url!;

              if (['about', 'data', 'javascript'].contains(uri.scheme)) {
                return NavigationActionPolicy.ALLOW;
              }

              final allowedDomains = [
                HttpConfig.domain,
                'challenges.cloudflare.com',
                'js.stripe.com',
                'cloudflareinsights.com',
                'stripe.network',
                'stripe.com',
                'turnstile.com',
                'cloudflare.com',
                'hcaptcha.com',
                'gstatic.com',
                'google.com',
                'recaptcha.net',
              ];

              bool isAllowed =
                  allowedDomains.any((domain) => uri.host.endsWith(domain));

              if (isAllowed) {
                return NavigationActionPolicy.ALLOW;
              }

              return NavigationActionPolicy.CANCEL;
            },
          ),
          if (isLoading) const Center(child: DisSquareLoading()),
          if (_error != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '加载失败',
                    style: TextStyle(
                      fontSize: AppSizes.fontMedium,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  8.vGap,
                  TextButton(
                    onPressed: () {
                      setState(() => _error = null);
                      _controller?.reload();
                    },
                    child: const StateViewError(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<String> getUserAgent() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String userAgent = '';

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      userAgent =
          'Mozilla/5.0 (Linux; Android ${androidInfo.version.release}; ${androidInfo.model} Build/${androidInfo.version.sdkInt}) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36';
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      userAgent =
          'Mozilla/5.0 (iPhone; CPU iPhone OS ${iosInfo.systemVersion.replaceAll('_', ' ')} like Mac OS X) AppleWebKit/537.36 (KHTML, like Gecko) Version/14.0 Mobile/15E148 Safari/537.36';
    } else if (Platform.isMacOS) {
      MacOsDeviceInfo macInfo = await deviceInfo.macOsInfo;
      userAgent =
          'Mozilla/5.0 (Macintosh; Intel Mac OS X ${macInfo.osRelease}) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
    }

    return userAgent;
  }
}
