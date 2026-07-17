import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/storage/local_storage.dart';
import '../../domain/entities/attendance.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_remote_datasource.dart';
import '../models/attendance_models.dart';

const _kCacheKey = 'cached_attendance';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource _remoteDataSource;
  final LocalStorage _localStorage;

  AttendanceRepositoryImpl(
    this._remoteDataSource,
    this._localStorage,
  );

  @override
  Future<Either<Failure, AttendanceData>> getAttendance() async {
    try {
      final data = await _remoteDataSource.getAttendance();
      await _localStorage.cacheData(
        _kCacheKey,
        (data as AttendanceDataModel).toJson(),
      );
      return Right(data);
    } on NetworkException {
      return _getCachedAttendance();
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return _getCachedAttendance();
    }
  }

  Either<Failure, AttendanceData> _getCachedAttendance() {
    final cached = _localStorage.getCachedData(_kCacheKey);
    if (cached != null) {
      try {
        final data =
            AttendanceDataModel.fromJson(cached as Map<String, dynamic>);
        return Right(data);
      } catch (_) {
        return const Left(NetworkFailure());
      }
    }
    return const Left(NetworkFailure());
  }
}
