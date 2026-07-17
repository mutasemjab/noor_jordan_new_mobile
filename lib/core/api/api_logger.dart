import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiLogger {
  static void logRequest(RequestOptions options) {
    if (!kDebugMode) return;
    debugPrint('┌─────────────────────────────────────');
    debugPrint('│ 🚀 REQUEST: ${options.method} ${options.uri}');
    if (options.headers.isNotEmpty) {
      debugPrint('│ Headers: ${options.headers}');
    }
    if (options.data != null) {
      debugPrint('│ Body: ${options.data}');
    }
    if (options.queryParameters.isNotEmpty) {
      debugPrint('│ Query: ${options.queryParameters}');
    }
    debugPrint('└─────────────────────────────────────');
  }

  static void logResponse(Response response) {
    if (!kDebugMode) return;
    final emoji = (response.statusCode ?? 0) < 300 ? '✅' : '⚠️';
    debugPrint('┌─────────────────────────────────────');
    debugPrint('│ $emoji RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
    debugPrint('│ Body: ${response.data}');
    debugPrint('└─────────────────────────────────────');
  }

  static void logError(DioException error) {
    if (!kDebugMode) return;
    debugPrint('┌─────────────────────────────────────');
    debugPrint('│ ❌ ERROR: ${error.type} — ${error.requestOptions.uri}');
    debugPrint('│ Status: ${error.response?.statusCode}');
    debugPrint('│ Message: ${error.message}');
    debugPrint('│ Response: ${error.response?.data}');
    debugPrint('└─────────────────────────────────────');
  }
}
