import 'package:dio/dio.dart';
import '../api/api_logger.dart';
import '../storage/local_storage.dart';
import '../constants/app_constants.dart';

class ApiInterceptor extends InterceptorsWrapper {
  final LocalStorage _localStorage;

  ApiInterceptor(this._localStorage);

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
  void onError(DioException err, ErrorInterceptorHandler handler) {
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
        if (statusCode == 401) {
          arabicMessage = 'انتهت جلسة تسجيل الدخول، يرجى تسجيل الدخول مجدداً';
        } else if (statusCode == 403) {
          arabicMessage = 'غير مصرح بالوصول';
        } else if (statusCode == 404) {
          arabicMessage = 'البيانات غير موجودة';
        } else if (statusCode == 422) {
          arabicMessage = 'يرجى التحقق من البيانات المدخلة';
        } else if (statusCode != null && statusCode >= 500) {
          arabicMessage = 'خطأ في الخادم، حاول لاحقاً';
        } else {
          arabicMessage = 'حدث خطأ، حاول مرة أخرى';
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
}
