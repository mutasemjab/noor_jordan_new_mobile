import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_remote_datasource.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  NotificationsRepositoryImpl(this._remoteDataSource, this._networkInfo);

  @override
  Future<Either<Failure, NotificationsData>> getNotifications() async {
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) return const Left(NetworkFailure());
    try {
      final result = await _remoteDataSource.getNotifications();
      return Right(result);
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> markRead(int id) async {
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) return const Left(NetworkFailure());
    try {
      await _remoteDataSource.markRead(id);
      return const Right(null);
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> markAllRead() async {
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) return const Left(NetworkFailure());
    try {
      await _remoteDataSource.markAllRead();
      return const Right(null);
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
