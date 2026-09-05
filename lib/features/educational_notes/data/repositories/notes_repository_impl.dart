import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/educational_note.dart';
import '../../domain/repositories/notes_repository.dart';
import '../datasources/notes_remote_datasource.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NotesRemoteDataSource _remote;
  final NetworkInfo _network;

  NotesRepositoryImpl(this._remote, this._network);

  @override
  Future<Either<Failure, List<NoteDateSummary>>> getDates() async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await _remote.getDates());
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
  Future<Either<Failure, List<NoteSubject>>> getSubjects(String date) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await _remote.getSubjects(date));
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
  Future<Either<Failure, List<NoteContentItem>>> getContent({
    required String date,
    required int subjectId,
  }) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await _remote.getContent(date: date, subjectId: subjectId));
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
