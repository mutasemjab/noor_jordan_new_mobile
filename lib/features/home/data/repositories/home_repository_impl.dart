import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/home_data.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_datasource.dart';
import '../models/home_models.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;
  final LocalStorage _localStorage;

  HomeRepositoryImpl(
    HomeRemoteDataSource remoteDataSource,
    NetworkInfo networkInfo,
    LocalStorage localStorage,
  )   : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo,
        _localStorage = localStorage;

  @override
  Future<Either<Failure, StudentHomeData>> getStudentHome() async {
    final isConnected = await _networkInfo.isConnected;

    if (isConnected) {
      try {
        final result = await _remoteDataSource.getStudentHome();
        await _localStorage.cacheData(
          AppConstants.cachedHomeKey,
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
          _localStorage.getCachedData(AppConstants.cachedHomeKey);
      if (cachedRaw != null && cachedRaw is Map<String, dynamic>) {
        try {
          final cached = StudentHomeDataModel.fromCacheJson(cachedRaw);
          return Right(cached);
        } catch (_) {
          return const Left(CacheFailure('تعذّر قراءة البيانات المحفوظة'));
        }
      }
      return const Left(NetworkFailure());
    }
  }
}
