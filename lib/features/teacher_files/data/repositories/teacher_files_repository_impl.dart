import 'dart:io';

import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/teacher_file_item.dart';
import '../../domain/repositories/teacher_files_repository.dart';
import '../datasources/teacher_files_remote_datasource.dart';

class TeacherFilesRepositoryImpl implements TeacherFilesRepository {
  final TeacherFilesRemoteDataSource _remote;
  final NetworkInfo _network;

  TeacherFilesRepositoryImpl(this._remote, this._network);

  @override
  Future<Either<Failure, List<TeacherFileItem>>> getFiles({
    required TeacherFileKind kind,
    int? classId,
    int? subjectId,
  }) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await _remote.getFiles(kind: kind, classId: classId, subjectId: subjectId));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> createFile({
    required TeacherFileKind kind,
    required int classId,
    required int subjectId,
    required String title,
    int? year,
    required File file,
  }) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      await _remote.createFile(kind: kind, classId: classId, subjectId: subjectId, title: title, year: year, file: file);
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
  Future<Either<Failure, void>> updateFile({
    required TeacherFileKind kind,
    required int id,
    required String title,
    int? year,
    File? file,
  }) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      await _remote.updateFile(kind: kind, id: id, title: title, year: year, file: file);
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
  Future<Either<Failure, void>> deleteFile({required TeacherFileKind kind, required int id}) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      await _remote.deleteFile(kind: kind, id: id);
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
