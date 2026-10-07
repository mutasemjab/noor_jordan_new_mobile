import 'package:dio/dio.dart';
import '../api/api_logger.dart';
import '../auth/auth_session_manager.dart';
import '../storage/local_storage.dart';
import 'api_endpoints.dart';

class ApiInterceptor extends InterceptorsWrapper {
  final LocalStorage _localStorage;
  final AuthSessionManager _authSessionManager;

  ApiInterceptor(this._localStorage, this._authSessionManager);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _localStorage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Accept'] = 'application/json';
    options.headers['Accept-Language'] = 'ar';
    ApiLogger.logRequest(options);
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    ApiLogger.logResponse(response);
    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    ApiLogger.logError(err);

    String arabicMessage;
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        arabicMessage = 'انتهت مهلة الاتصال، تحقق من الإنترنت';
        break;
      case DioExceptionType.connectionError:
        arabicMessage = 'لا يوجد اتصال بالإنترنت';
        break;
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        final backendMessage = _backendMessage(err.response?.data);
        if (statusCode == 401) {
          final rejectedToken = _bearerToken(err.requestOptions);
          if (rejectedToken != null && !_isLoginRequest(err.requestOptions)) {
            await _authSessionManager.handleUnauthorized(rejectedToken);
          }
          arabicMessage = backendMessage ?? 'انتهت جلسة تسجيل الدخول، يرجى تسجيل الدخول مجدداً';
        } else if (statusCode == 403) {
          arabicMessage = backendMessage ?? 'غير مصرح بالوصول';
        } else if (statusCode == 404) {
          arabicMessage = backendMessage ?? 'البيانات غير موجودة';
        } else if (statusCode == 422) {
          arabicMessage = backendMessage ?? 'يرجى التحقق من البيانات المدخلة';
        } else if (statusCode != null && statusCode >= 500) {
          arabicMessage = backendMessage ?? 'خطأ في الخادم، حاول لاحقاً';
        } else {
          arabicMessage = backendMessage ?? 'حدث خطأ، حاول مرة أخرى';
        }
        break;
      default:
        arabicMessage = 'حدث خطأ غير متوقع';
    }

    final customError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: arabicMessage,
      message: arabicMessage,
    );
    handler.next(customError);
  }

  String? _backendMessage(dynamic responseData) {
    if (responseData is! Map) return null;
    final message = responseData['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message;
    }
    return null;
  }

  String? _bearerToken(RequestOptions options) {
    final authorization = options.headers['Authorization']?.toString();
    const prefix = 'Bearer ';
    if (authorization == null || !authorization.startsWith(prefix)) {
      return null;
    }

    final token = authorization.substring(prefix.length).trim();
    return token.isEmpty ? null : token;
  }

  bool _isLoginRequest(RequestOptions options) {
    return options.path == ApiEndpoints.studentLogin ||
        options.path == ApiEndpoints.teacherLogin;
  }
}
