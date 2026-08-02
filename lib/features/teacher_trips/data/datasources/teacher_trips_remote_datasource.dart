import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/trip_model.dart';

abstract class TeacherTripsRemoteDataSource {
  Future<({GeoPointModel school, List<TripModel> trips})> getMyTrips();
  Future<TripModel> startTrip(int tripId);
  Future<LocationUpdateResultModel> sendLocation({required int tripId, required double lat, required double lng});
  Future<void> markStudentArrived({required int tripId, required int studentId});
  Future<void> completeTrip(int tripId);
}

class TeacherTripsRemoteDataSourceImpl implements TeacherTripsRemoteDataSource {
  final Dio _dio;
  TeacherTripsRemoteDataSourceImpl(this._dio);

  @override
  Future<({GeoPointModel school, List<TripModel> trips})> getMyTrips() async {
    try {
      final response = await _dio.get(ApiEndpoints.teacherMyTrips);
      final data = response.data;
      final json = data is Map<String, dynamic> ? data['data'] as Map<String, dynamic>? ?? {} : <String, dynamic>{};
      final schoolJson = json['school'] as Map<String, dynamic>? ?? {};
      final tripsJson = json['trips'] as List<dynamic>? ?? [];
      return (
        school: GeoPointModel.fromJson(schoolJson),
        trips: tripsJson.whereType<Map<String, dynamic>>().map((e) => TripModel.fromJson(e)).toList(),
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<TripModel> startTrip(int tripId) async {
    try {
      final response = await _dio.post(ApiEndpoints.teacherStartTrip(tripId));
      final data = response.data;
      final json = data is Map<String, dynamic> ? data['data'] as Map<String, dynamic>? ?? {} : <String, dynamic>{};
      return TripModel.fromJson(json);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<LocationUpdateResultModel> sendLocation({required int tripId, required double lat, required double lng}) async {
    try {
      final response = await _dio.post(ApiEndpoints.teacherTripLocation(tripId), data: {'lat': lat, 'lng': lng});
      final data = response.data;
      final json = data is Map<String, dynamic> ? data['data'] as Map<String, dynamic>? ?? {} : <String, dynamic>{};
      return LocationUpdateResultModel.fromJson(json);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> markStudentArrived({required int tripId, required int studentId}) async {
    try {
      await _dio.post(ApiEndpoints.teacherTripStudentArrived(tripId, studentId));
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> completeTrip(int tripId) async {
    try {
      await _dio.post(ApiEndpoints.teacherCompleteTrip(tripId));
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Exception _mapError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const NetworkException();
    }
    final statusCode = e.response?.statusCode;
    if (statusCode == 401) return const UnauthorizedException();
    return ServerException(
      e.response?.data?['message'] as String? ?? 'حدث خطأ في السيرفر',
      statusCode: statusCode,
    );
  }
}
