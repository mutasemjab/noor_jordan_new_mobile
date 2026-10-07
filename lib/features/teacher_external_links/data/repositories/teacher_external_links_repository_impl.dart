import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/teacher_external_link.dart';
import '../../domain/repositories/teacher_external_links_repository.dart';
import '../datasources/teacher_external_links_remote_datasource.dart';

class TeacherExternalLinksRepositoryImpl implements TeacherExternalLinksRepository {
  final TeacherExternalLinksRemoteDataSource _remote;
  final NetworkInfo _network;

  TeacherExternalLinksRepositoryImpl(this._remote, this._network);

  @override
  Future<Either<Failure, List<TeacherExternalLink>>> getLinks({int? classId, int? subjectId}) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await _remote.getLinks(classId: classId, subjectId: subjectId));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> createLink({required int classId, required int subjectId, required String url}) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      await _remote.createLink(classId: classId, subjectId: subjectId, url: url);
      return const Right(null);
    } on NetworkException {
      return const Left(NetworkFailure());
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateLink({required int id, required String url}) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      await _remote.updateLink(id: id, url: url);
      return const Right(null);
    } on NetworkException {
      return const Left(NetworkFailure());
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteLink(int id) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      await _remote.deleteLink(id);
      return const Right(null);
    } on NetworkException {
      return const Left(NetworkFailure());
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
