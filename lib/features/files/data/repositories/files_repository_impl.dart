import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/file_item.dart';
import '../../domain/repositories/files_repository.dart';
import '../datasources/files_remote_datasource.dart';

class FilesRepositoryImpl implements FilesRepository {
  final FilesRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  FilesRepositoryImpl(this._remoteDataSource, this._networkInfo);

  Future<Either<Failure, List<FileItem>>> _fetch(
      Future<List<FileItem>> Function() fn) async {
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) return const Left(NetworkFailure());
    try {
      final result = await fn();
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
  Future<Either<Failure, List<FileItem>>> getPreviousExams() =>
      _fetch(_remoteDataSource.getPreviousExams);

  @override
  Future<Either<Failure, List<FileItem>>> getQuestionBanks() =>
      _fetch(_remoteDataSource.getQuestionBanks);

  @override
  Future<Either<Failure, List<FileItem>>> getWorksheets() =>
      _fetch(_remoteDataSource.getWorksheets);
}
