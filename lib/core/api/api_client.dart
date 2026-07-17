import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import 'api_endpoints.dart';
import 'api_interceptor.dart';
import '../storage/local_storage.dart';

class ApiClient {
  static Dio? _instance;

  static Dio getInstance(LocalStorage localStorage) {
    _instance ??= _createDio(localStorage);
    return _instance!;
  }

  static Dio _createDio(LocalStorage localStorage) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        responseType: ResponseType.json,
      ),
    );
    dio.interceptors.add(ApiInterceptor(localStorage));
    return dio;
  }
}
