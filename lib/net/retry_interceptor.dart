import 'dart:async';
import 'package:dio/dio.dart';
import '../utils/log.dart';

class RateLimitExhaustedException extends DioException {
  final int retryAfter;

  RateLimitExhaustedException({
    required RequestOptions requestOptions,
    required this.retryAfter,
  }) : super(requestOptions: requestOptions);
}

// 应该是NEO对服务的API 新增了速率限制 😭处理429
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration initialDelay;
  final Duration maxDelay;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 4,
    this.initialDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 10),
  });

  bool _isValidResponse(Response? response) {
    if (response == null) return false;
    
    if (response.statusCode == 429) {
      return false;
    }
    final contentType = response.headers.value('content-type') ?? '';
    
    if (contentType.toLowerCase().contains('text/html')) {
      return false;
    }
    
    return true;
  }

  @override
  Future<void> onResponse(Response response, ResponseInterceptorHandler handler) async {
    if (!_isValidResponse(response)) {
      
      final retryCount = response.requestOptions.extra['retryCount'] as int? ?? 0;
      
      if (retryCount < maxRetries) {
        final delay = _calculateDelay(retryCount);
        
        await Future.delayed(delay);
        final options = Options(
          method: response.requestOptions.method,
          headers: response.requestOptions.headers,
        );
        
        options.extra = {
          ...response.requestOptions.extra,
          'retryCount': retryCount + 1,
        };
        
        try {
          final newResponse = await dio.request(
            response.requestOptions.path,
            data: response.requestOptions.data,
            queryParameters: response.requestOptions.queryParameters,
            options: options,
          );
          
          // 验证响应是否有效
          if (_isValidResponse(newResponse)) {
            return handler.next(newResponse);
          } else {
            // 递归调用自身，继续重试
            return onResponse(newResponse, handler);
          }
        } catch (e) {
          // 转为错误处理
          if (e is DioException) {
            return handler.reject(e);
          }
          return handler.reject(
            DioException(
              requestOptions: response.requestOptions,
              error: e,
            ),
          );
        }
      } else {
        l.e('达到最大重试次数');
        final retryAfter = int.tryParse(
          response.headers.value('Retry-After') ?? '60'
        ) ?? 60;
        
        final rateLimitErr = RateLimitExhaustedException(
          requestOptions: response.requestOptions,
          retryAfter: retryAfter,
        );
        return handler.reject(rateLimitErr);
      }
    }
    
    // 如果响应有效，直接传递给下一个拦截器
    return handler.next(response);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    // 保留 onError 处理，以防有错误无法通过 onResponse 捕获
    
    // 检查是否是429或收到了HTML响应
    if (err.response?.statusCode == 429 || !_isValidResponse(err.response)) {
      final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;
      
      if (retryCount < maxRetries) {
        final delay = _calculateDelay(retryCount);
        
        await Future.delayed(delay);
        final options = Options(
          method: err.requestOptions.method,
          headers: err.requestOptions.headers,
        );
        
        options.extra = {
          ...err.requestOptions.extra,
          'retryCount': retryCount + 1,
        };
        
        try {
          final response = await dio.request(
            err.requestOptions.path,
            data: err.requestOptions.data,
            queryParameters: err.requestOptions.queryParameters,
            options: options,
          );
          
          // 验证响应是否有效
          if (_isValidResponse(response)) {
            return handler.resolve(response);
          } else {
            // 如果响应无效，继续重试
            return onError(
              DioException(
                requestOptions: err.requestOptions,
                response: response,
                type: DioExceptionType.badResponse,
              ),
              handler,
            );
          }
        } catch (e) {
          if (e is DioException) {
            return onError(e, handler);
          }
          return handler.next(err);
        }
      } else {
        final retryAfter = int.tryParse(
          err.response?.headers.value('Retry-After') ?? '60'
        ) ?? 60;
        
        final rateLimitErr = RateLimitExhaustedException(
          requestOptions: err.requestOptions,
          retryAfter: retryAfter,
        );
        return handler.next(rateLimitErr);
      }
    }
    return handler.next(err);
  }

  Duration _calculateDelay(int retryCount) {
    final delay = initialDelay * (1 << retryCount);
    return delay > maxDelay ? maxDelay : delay;
  }
} 