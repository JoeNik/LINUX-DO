import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:linux_do/utils/device_util.dart';
import 'package:path_provider/path_provider.dart';
import 'api_response.dart';
import 'http_config.dart';
import '../controller/global_controller.dart';
import '../const/app_const.dart';
import '../utils/storage_manager.dart';
import '../utils/log.dart';

class HttpClient {
  static HttpClient? _instance;
  late final Dio _dio;
  late final CookieJar _cookieJar;
  late final BaseOptions _options;
  static const String cfClearance = 'cf_clearance';
  static const String forumSession = '_forum_session';
  static const String tokenKey = '_t';

  /// 获取dio实例
  Dio get dio => _dio;

  /// 获取options
  BaseOptions get options => _options;

  /// 静态方法获取dio实例
  static Dio get getDio {
    if (_instance == null) {
      throw Exception('HttpClient not initialized');
    }
    return _instance!._dio;
  }

  /// 静态方法获取options
  static BaseOptions get getOptions {
    if (_instance == null) {
      throw Exception('HttpClient not initialized');
    }
    return _instance!._options;
  }

  /// 私有构造函数
  HttpClient._();

  Future<void> init() async {
    await _initOptions();
    await _initCookieManager();
    
    _initInterceptors();
  }

  /// 初始化options
  Future<void>  _initOptions() async{
    final userAgent = await DeviceUtil.getUserAgent();
    _options = BaseOptions(
      baseUrl: HttpConfig.baseUrl,
      connectTimeout: const Duration(milliseconds: HttpConfig.connectTimeout),
      receiveTimeout: const Duration(milliseconds: HttpConfig.receiveTimeout),
      sendTimeout: const Duration(milliseconds: HttpConfig.sendTimeout),
      
      headers: {
        'Accept': 'application/json, text/plain, */*',
        'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
        'Content-Type': 'application/json; charset=utf-8',
        'X-Requested-With': 'XMLHttpRequest',
        'User-Agent': userAgent,
      },
      responseType: ResponseType.json,
      validateStatus: (status) {
        return status != null && status >= 200 && status < 500;
      },
      followRedirects: true,
      receiveDataWhenStatusError: true,
    );

    // 设置代理服务器
    final proxyServer = StorageManager.getProxyServer();
    if (proxyServer != null && proxyServer.isNotEmpty) {
      l.d('使用代理服务器: $proxyServer');
      _options.baseUrl = proxyServer;
    }

    _dio = Dio(_options);
  }

  /// 更新代理服务器设置
  void updateProxy(String? proxyServer) {
    if (proxyServer != null && proxyServer.isNotEmpty) {
      l.d('更新代理服务器: $proxyServer');
      _options.baseUrl = proxyServer;
    } else {
      l.d('清除代理服务器设置');
      _options.baseUrl = HttpConfig.baseUrl;
    }
    _dio.options = _options;
  }

  /// 初始化Cookie管理器
  Future<void> _initCookieManager() async {
    if (kIsWeb) {
      _cookieJar = CookieJar();
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final cookiePath = '${directory.path}/.cookies/';
      _cookieJar = PersistCookieJar(
          ignoreExpires: true, storage: FileStorage(cookiePath));
    }
    // 确保在添加 CookieManager 之前清除其他可能存在的 CookieManager
    _dio.interceptors
        .removeWhere((interceptor) => interceptor is CookieManager);
    _dio.interceptors.add(CookieManager(_cookieJar));
  }

  /// 单例模式
  static HttpClient getInstance() {
    _instance ??= HttpClient._();
    return _instance!;
  }

  /// 清除所有Cookie
  Future<void> clearCookies() async {
    await _cookieJar.deleteAll();
  }

  /// 初始化拦截器
  void _initInterceptors() {
    // 清除所有现有的拦截器
    _dio.interceptors.clear();

    // 添加 Cookie 管理拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 从 cookie jar 获取 cookies
        final uri = Uri.parse(options.uri.toString());
        final cookies = await _cookieJar.loadForRequest(uri);

        // 如果有 cookies，添加到请求头
        if (cookies.isNotEmpty) {
          options.headers['Cookie'] = cookies
              .map((cookie) => '${cookie.name}=${cookie.value}')
              .join('; ');
        }
        // 如果是 POST 请求，添加 Referer
        if (options.method == 'POST') {
          options.headers['Referer'] = '${HttpConfig.baseUrl}${options.path}';
        }

        return handler.next(options);
      },
      onResponse: (response, handler) async {
        await _handleCookies(response);
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        // if (e.response != null) {
        //   await _handleCookies(e.response!);
        // }
        return handler.next(e);
      },
    ));

    // 添加错误处理拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // 从本地存储获取CSRF Token
        final csrfToken =
            StorageManager.getString(AppConst.identifier.csrfToken);
        if (csrfToken != null && csrfToken.isNotEmpty) {
          l.d('添加 csrfToken : $csrfToken');
          options.headers['X-CSRF-Token'] = csrfToken;
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        try {
          // 检查并保存CSRF Token
          final csrfToken = response.headers.value('X-CSRF-Token');
          if (csrfToken != null) {
            StorageManager.setData(AppConst.identifier.csrfToken, csrfToken);
            l.d('保存 csrfToken : $csrfToken');
          }
        } catch (e) {
          l.e('处理响应头错误: $e');
        }
        return handler.next(response);
      },
      onError: (error, handler) {
        _handleError(error);
        return handler.next(error);
      },
    ));

    // 添加日志拦截器
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final sb = StringBuffer();
          sb.writeln('┌─────────────────────────── Request ───────────────────────────');
          sb.writeln('│ ${options.method} ${options.uri}');
          sb.writeln('│ Headers:');
          options.headers.forEach((key, value) {
            sb.writeln('│   $key: $value');
          });
          if (options.data != null) {
            sb.writeln('│ Body: ${options.data}');
          }
          if (options.queryParameters.isNotEmpty) {
            sb.writeln('│ Query: ${options.queryParameters}');
          }
          sb.writeln('└─────────────────────────────────────────────────────────────────────');
          l.d(sb.toString());
          return handler.next(options);
        },
        onResponse: (response, handler) {
          final sb = StringBuffer();
          sb.writeln('┌─────────────────────────── Response ───────────────────────────');
          sb.writeln('│ Status: ${response.statusCode}');
          sb.writeln('│ Headers:');
          response.headers.forEach((name, values) {
            sb.writeln('│   $name: ${values.join(", ")}');
          });
          sb.writeln('│ Body: ${response.data}');
          sb.writeln('└─────────────────────────────────────────────────────────────────────');
          l.d(sb.toString());

          // 获取并存储用户名
          String linuxDoUser =
              StorageManager.getString(AppConst.identifier.username) ?? '';

          if (linuxDoUser.isNotEmpty) {
            return handler.next(response);
          }

          final username = response.headers.value('x-discourse-username');
          if (username != null && username.isNotEmpty) {
            StorageManager.setData(AppConst.identifier.username, username);
          }
          return handler.next(response);
        },
        onError: (error, handler) {
          final sb = StringBuffer();
          sb.writeln('┌─────────────────────────── Request Error ───────────────────────────');
          sb.writeln('│ 请求类型: ${error.requestOptions.method} URL: ${error.requestOptions.uri}');
          sb.writeln('│ Headers:');
          error.requestOptions.headers.forEach((key, value) {
            sb.writeln('│   $key: $value');
          });
          if (error.requestOptions.data != null) {
            sb.writeln('│ 请求 Data: ${error.requestOptions.data}');
          }
          sb.writeln('│ 响应 Code: ${error.response?.statusCode}');
          if (error.response?.headers != null) {
            sb.writeln('│ 响应 Headers:');
            error.response!.headers.forEach((name, values) {
              sb.writeln('│   $name: ${values.join(", ")}');
            });
          }
          if (error.response?.data != null) {
            sb.writeln('│ 响应 Data: ${error.response?.data}');
          }
          if (error.message != null) {
            sb.writeln('│ Error: ${error.message}');
          }
          sb.writeln('└─────────────────────────────────────────────────────────────────────');
          l.e(sb.toString());
          return handler.next(error);
        },
      ),
    );
  }

  Future<void> _handleCookies(Response response) async {
    final cookies = response.headers['set-cookie'];
    if (cookies != null) {
      final uri = Uri.parse(HttpConfig.baseUrl);
      for (var cookieString in cookies) {
        if (cookieString.contains(cfClearance)) {
          // 解析 CF cookie
          final cfCookie = _parseCfCookie(cookieString);
          if (cfCookie != null) {
            l.d('保存 CF cookie: ${cfCookie.value}');
            await _cookieJar.saveFromResponse(uri, [cfCookie]);
          }
        } else if (cookieString.contains(tokenKey)) {
          // 解析登录 token
          final tokenCookie = _parseTokenCookie(cookieString);
          if (tokenCookie != null) {
            l.d('保存 token cookie: ${tokenCookie.value}');
            await _cookieJar.saveFromResponse(uri, [tokenCookie]);
            // 更新登录状态
            Get.find<GlobalController>().setIsLogin(true);
          }
        } else if (cookieString.contains(forumSession)) {
          // 解析 forum session
          final sessionCookie = _parseSessionCookie(cookieString);
          if (sessionCookie != null) {
            l.d('保存 session cookie: ${sessionCookie.value}');
            await _cookieJar.saveFromResponse(uri, [sessionCookie]);
          }
        }
      }
    }
  }

  Cookie? _parseCfCookie(String cookieString) {
    try {
      // 解析 cookie 字符串
      final parts = cookieString.split(';');
      final mainPart = parts[0].trim();
      if (mainPart.startsWith(cfClearance)) {
        final value = mainPart.split('=')[1];
        return Cookie(cfClearance, value)
          ..domain = HttpConfig.domain
          ..path = '/'
          ..httpOnly = true
          ..secure = true;
      }
    } catch (e) {
      l.e('解析 CF cookie 失败: $e');
    }
    return null;
  }

  Cookie? _parseTokenCookie(String cookieString) {
    try {
      final parts = cookieString.split(';');
      final mainPart = parts[0].trim();
      if (mainPart.startsWith(tokenKey)) {
        final value = mainPart.split('=')[1];
        return Cookie(tokenKey, value)
          ..domain = HttpConfig.domain
          ..path = '/'
          ..httpOnly = true
          ..secure = true;
      }
    } catch (e) {
      l.e('解析 token cookie 失败: $e');
    }
    return null;
  }

  Cookie? _parseSessionCookie(String cookieString) {
    try {
      final parts = cookieString.split(';');
      final mainPart = parts[0].trim();
      if (mainPart.startsWith(forumSession)) {
        final value = mainPart.split('=')[1];
        return Cookie(forumSession, value)
          ..domain = HttpConfig.domain
          ..path = '/'
          ..httpOnly = true
          ..secure = true;
      }
    } catch (e) {
      l.e('解析 session cookie 失败: $e');
    }
    return null;
  }

  /// 处理错误
  void _handleError(DioException error) {
    String message;
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = HttpConfig.timeoutMessage;
        break;
      case DioExceptionType.badResponse:
        switch (error.response?.statusCode) {
          case HttpConfig.unauthorizedCode:
            message = HttpConfig.unauthorizedMessage;
            // 清除登录状态
            // StorageManager.remove(AppConst.identifier.csrfToken);
            // clearCookies(); // 清除Cookie
            // Get.find<GlobalController>().setIsLogin(false);
            // Get.offAllNamed('/login');
            break;
          case HttpConfig.forbiddenCode:
            message = HttpConfig.forbiddenMessage;
            break;
          case HttpConfig.notFoundCode:
            message = HttpConfig.notFoundMessage;
            break;
          default:
            message = error.response?.data?['error'] ?? HttpConfig.errorMessage;
        }
        break;
      default:
        message = HttpConfig.networkErrorMessage;
    }
    Get.snackbar('错误', message);
  }

  /// GET请求
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      // 如果响应数据是 Map，直接使用它
      if (response.data is Map<String, dynamic>) {
        return ApiResponse<T>.fromJson(response.data, fromJson);
      }

      // 如果响应数据不是 Map，创建一个包含原始数据的 Map
      return ApiResponse<T>.fromJson({
        'code': response.statusCode,
        'message': 'success',
        'data': response.data,
      }, fromJson);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// POST请求
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return ApiResponse<T>.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// PUT请求
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return ApiResponse<T>.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// DELETE请求
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return ApiResponse<T>.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// 检查网站是否使用了 Cloudflare 保护
  Future<bool> _checkCloudflareEnabled() async {
    try {
      final response = await _dio.head(
        HttpConfig.baseUrl,
        options: Options(
          followRedirects: false,
          validateStatus: (status) => true,
        ),
      );
      
      // 检查响应头中是否包含 Cloudflare 相关信息
      final headers = response.headers;
      final server = headers.value('server');
      final cfRay = headers.value('cf-ray');
      
      // 如果响应头中包含 Cloudflare 相关信息，说明网站使用了 Cloudflare
      return (server?.toLowerCase().contains('cloudflare') ?? false) || 
             (cfRay != null);
    } catch (e) {
      l.e('检查 Cloudflare 状态失败: $e');
      // 如果检查失败，保守起见返回 true
      return true;
    }
  }

  /// 检查是否存在关键的 cookies
  Future<bool> hasValidCookies() async {
    try {
      final uri = Uri.parse(HttpConfig.baseUrl);
      final cookies = await _cookieJar.loadForRequest(uri);
      
      bool hasCfClearance = false;
      bool hasForumSession = false;
      bool hasToken = false;
      final csrfToken =
            StorageManager.getString(AppConst.identifier.csrfToken) ;

        l.d('没有 CSRF Token  $csrfToken');

      // 检查所有必要的 cookies
      for (var cookie in cookies) {
        if (cookie.name == cfClearance) hasCfClearance = true;
        if (cookie.name == forumSession) hasForumSession = true;
        if (cookie.name == tokenKey) hasToken = true;
      }

      // 检查网站是否使用了 Cloudflare
      final needsCfVerification = await _checkCloudflareEnabled();
      
      l.d('Cookie 状态: CF=$hasCfClearance, Session=$hasForumSession, Token=$hasToken, NeedCF=$needsCfVerification');
      
      // 根据是否需要 CF 验证来判断 cookies 是否有效
      return  hasForumSession && hasToken && (!needsCfVerification || (needsCfVerification && hasCfClearance));
    } catch (e) {
      l.e('检查 cookies 失败: $e');
      return false;
    }
  }

  /// 获取指定的 cookie 值
  Future<String?> getCookieValue(String name) async {
    try {
      final uri = Uri.parse(HttpConfig.baseUrl);
      final cookies = await _cookieJar.loadForRequest(uri);
      final cookie = cookies.firstWhereOrNull((c) => c.name == name);
      return cookie?.value;
    } catch (e) {
      l.e('获取 cookie 失败: $e');
      return null;
    }
  }
}
