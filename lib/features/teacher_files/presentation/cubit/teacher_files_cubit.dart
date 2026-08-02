import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/teacher_file_item.dart';
import '../../domain/usecases/teacher_files_usecases.dart';
import 'teacher_files_state.dart';

/// Bundles the (kind, classId, subjectId) triple GetIt needs to construct a
/// scoped [TeacherFilesCubit] — registerFactoryParam only takes two params.
class TeacherFilesScope {
  final TeacherFileKind kind;
  final int classId;
  final int subjectId;

  const TeacherFilesScope({required this.kind, required this.classId, required this.subjectId});
}

class TeacherFilesCubit extends Cubit<TeacherFilesState> {
  final GetTeacherFilesUseCase _getFiles;
  final CreateTeacherFileUseCase _createFile;
  final UpdateTeacherFileUseCase _updateFile;
  final DeleteTeacherFileUseCase _deleteFile;

  final TeacherFileKind kind;
  final int classId;
  final int subjectId;

  TeacherFilesCubit({
    required this.kind,
    required this.classId,
    required this.subjectId,
    required GetTeacherFilesUseCase getFiles,
    required CreateTeacherFileUseCase createFile,
    required UpdateTeacherFileUseCase updateFile,
    required DeleteTeacherFileUseCase deleteFile,
  })  : _getFiles = getFiles,
        _createFile = createFile,
        _updateFile = updateFile,
        _deleteFile = deleteFile,
        super(const TeacherFilesLoading());

  Future<void> load() async {
    emit(const TeacherFilesLoading());
    final result = await _getFiles(kind: kind, classId: classId, subjectId: subjectId);
    result.fold(
      (f) => emit(TeacherFilesError(f.message)),
      (files) => emit(TeacherFilesLoaded(files)),
    );
  }

  Future<String?> create({required String title, int? year, required File file}) async {
    final result = await _createFile(kind: kind, classId: classId, subjectId: subjectId, title: title, year: year, file: file);
    return result.fold((f) => f.message, (_) {
      load();
      return null;
    });
  }

  Future<String?> update({required int id, required String title, int? year, File? file}) async {
    final result = await _updateFile(kind: kind, id: id, title: title, year: year, file: file);
    return result.fold((f) => f.message, (_) {
      load();
      return null;
    });
  }

  Future<String?> delete(int id) async {
    final result = await _deleteFile(kind: kind, id: id);
    return result.fold((f) => f.message, (_) {
      load();
      return null;
    });
  }
}
