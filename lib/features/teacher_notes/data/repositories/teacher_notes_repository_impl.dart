import 'dart:io';

import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../educational_notes/domain/entities/educational_note.dart';
import '../../domain/repositories/teacher_notes_repository.dart';
import '../datasources/teacher_notes_remote_datasource.dart';

class TeacherNotesRepositoryImpl implements TeacherNotesRepository {
  final TeacherNotesRemoteDataSource _remote;
  final NetworkInfo _network;

  TeacherNotesRepositoryImpl(this._remote, this._network);

  @override
  Future<Either<Failure, List<EducationalNote>>> getClassNotes(int classId) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await _remote.getClassNotes(classId));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> createNote({
    required int classId,
    required String title,
    required String description,
    required EducationalNoteType type,
    required DateTime date,
    File? attachment,
  }) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      await _remote.createNote(
        classId: classId,
        title: title,
        description: description,
        type: type,
        date: date,
        attachment: attachment,
      );
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
  Future<Either<Failure, void>> updateNote({
    required int noteId,
    required String title,
    required String description,
    required EducationalNoteType type,
    required DateTime date,
    File? attachment,
  }) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      await _remote.updateNote(
        noteId: noteId,
        title: title,
        description: description,
        type: type,
        date: date,
        attachment: attachment,
      );
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
  Future<Either<Failure, void>> deleteNote(int noteId) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      await _remote.deleteNote(noteId);
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
