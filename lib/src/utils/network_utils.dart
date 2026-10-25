import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class NetworkUtils {
  NetworkUtils._();

  /// Interceptors every data source's Dio gets. Request/response logging is
  /// debug-only so response data never reaches release-build logs.
  static List<Interceptor> getNetworkInterceptor() => [
    if (kDebugMode) LogInterceptor(requestBody: true, responseBody: true),
  ];
}
