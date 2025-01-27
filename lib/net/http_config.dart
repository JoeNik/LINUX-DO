class HttpConfig {
  /// 默认配置
  static const String baseUrl = 'https://linux.do/';
  static const int connectTimeout = 20000;
  static const int receiveTimeout = 25000;
  static const int sendTimeout = 25000;

  /// 成功码
  static const int successCode = 200;

  /// 错误码
  static const int errorCode = 500;
  static const int unauthorizedCode = 401;
  static const int forbiddenCode = 403;
  static const int notFoundCode = 404;

  /// 服务器错误信息
  static const String successMessage = "请求成功";
  static const String errorMessage = "请求失败";
  static const String unauthorizedMessage = "登录已过期，请重新登录";
  static const String forbiddenMessage = "无权限访问";
  static const String notFoundMessage = "请求地址不存在";
  static const String networkErrorMessage = "网络连接错误";
  static const String timeoutMessage = "请求超时";
}
