import 'dart:io';

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/teacher_file_item.dart';

abstract class TeacherFilesRepository {
  Future<Either<Failure, List<TeacherFileItem>>> getFiles({
    required TeacherFileKind kind,
    int? classId,
    int? subjectId,
  });

  Future<Either<Failure, void>> createFile({
    required TeacherFileKind kind,
    required int classId,
    required int subjectId,
    required String title,
    int? year,
    required File file,
  });

  Future<Either<Failure, void>> updateFile({
    required TeacherFileKind kind,
    required int id,
    required String title,
    int? year,
    File? file,
  });

  Future<Either<Failure, void>> deleteFile({
    required TeacherFileKind kind,
    required int id,
  });
}
