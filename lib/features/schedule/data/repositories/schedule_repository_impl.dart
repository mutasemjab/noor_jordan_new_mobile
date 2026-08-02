import 'package:dartz/dartz.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/storage/local_storage.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../datasources/schedule_remote_datasource.dart';
import '../models/schedule_models.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;
  final LocalStorage _localStorage;

  ScheduleRepositoryImpl(
    ScheduleRemoteDataSource remoteDataSource,
    NetworkInfo networkInfo,
    LocalStorage localStorage,
  )   : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo,
        _localStorage = localStorage;

  @override
  Future<Either<Failure, ClassSchedule>> getSchedule() async {
    final isConnected = await _networkInfo.isConnected;

    if (isConnected) {
      try {
        final result = await _remoteDataSource.getSchedule();
        await _localStorage.cacheData(
          AppConstants.cachedScheduleKey,
          result.toJson(),
        );
        return Right(result);
      } on NetworkException {
        return const Left(NetworkFailure());
      } on UnauthorizedException {
        return const Left(UnauthorizedFailure());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (_) {
        return const Left(UnknownFailure());
      }
    } else {
      final cachedRaw =
          _localStorage.getCachedData(AppConstants.cachedScheduleKey);
      if (cachedRaw != null && cachedRaw is Map<String, dynamic>) {
        try {
          return Right(ClassScheduleModel.fromJson(cachedRaw));
        } catch (_) {
          return const Left(CacheFailure('تعذّر قراءة الجدول المحفوظ'));
        }
      }
      return const Left(NetworkFailure());
    }
  }
}
