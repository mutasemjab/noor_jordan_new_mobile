import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/storage/local_storage.dart';
import '../../domain/entities/teacher_home_data.dart';
import '../../domain/repositories/teacher_home_repository.dart';
import '../datasources/teacher_home_remote_datasource.dart';
import '../models/teacher_home_models.dart';

const _cacheKey = 'teacher_cached_home';

class TeacherHomeRepositoryImpl implements TeacherHomeRepository {
  final TeacherHomeRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;
  final LocalStorage _localStorage;

  TeacherHomeRepositoryImpl(
    this._remoteDataSource,
    this._networkInfo,
    this._localStorage,
  );

  @override
  Future<Either<Failure, TeacherHomeData>> getHome() async {
    final isConnected = await _networkInfo.isConnected;
    if (isConnected) {
      try {
        final result = await _remoteDataSource.getHome();
        await _localStorage.cacheData(_cacheKey, result.toJson());
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
      final cachedRaw = _localStorage.getCachedData(_cacheKey);
      if (cachedRaw != null && cachedRaw is Map<String, dynamic>) {
        try {
          final cached = TeacherHomeDataModel.fromCacheJson(cachedRaw);
          return Right(cached);
        } catch (_) {
          return const Left(CacheFailure('تعذّر قراءة البيانات المحفوظة'));
        }
      }
      return const Left(NetworkFailure());
    }
  }
}
