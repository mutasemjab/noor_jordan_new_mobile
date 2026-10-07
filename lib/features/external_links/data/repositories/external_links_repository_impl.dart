import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/external_link.dart';
import '../../domain/repositories/external_links_repository.dart';
import '../datasources/external_links_remote_datasource.dart';

class ExternalLinksRepositoryImpl implements ExternalLinksRepository {
  final ExternalLinksRemoteDataSource _remote;
  final NetworkInfo _network;

  ExternalLinksRepositoryImpl(this._remote, this._network);

  @override
  Future<Either<Failure, List<ExternalLink>>> getExternalLinks() async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await _remote.getExternalLinks());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
