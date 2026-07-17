import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/teacher_grades.dart';
import '../../domain/usecases/get_grade_classes_usecase.dart';
import '../../domain/usecases/submit_grades_usecase.dart';
import '../../data/datasources/teacher_grades_remote_datasource.dart';
import 'teacher_grades_state.dart';

class TeacherGradesCubit extends Cubit<TeacherGradesState> {
  final GetGradeClassesUseCase _getClasses;
  final SubmitGradesUseCase _submitGrades;
  final TeacherGradesRemoteDataSource _remote;

  TeacherGradesCubit(this._getClasses, this._submitGrades, this._remote)
      : super(TeacherGradesInitial());

  Future<void> loadClasses() async {
    emit(TeacherGradesLoading());
    final result = await _getClasses();
    result.fold(
      (f) => emit(TeacherGradesError(f.message)),
      (classes) => emit(TeacherGradesClassesLoaded(classes)),
    );
  }

  Future<void> selectClass(GradeClass cls) async {
    final current = state;
    List<GradeClass> classes = [];
    if (current is TeacherGradesClassesLoaded) classes = current.classes;
    if (current is TeacherGradesExamTypesLoaded) classes = current.classes;
    if (current is TeacherGradesStudentsLoaded) classes = current.classes;

    emit(TeacherGradesLoading());
    try {
      final examTypes = await _remote.getExamTypes(cls.classId);
      emit(TeacherGradesExamTypesLoaded(classes: classes, selectedClass: cls, examTypes: examTypes));
    } catch (e) {
      emit(TeacherGradesError(e.toString()));
    }
  }

  Future<void> selectExamType(GradeExamType examType) async {
    final current = state;
    if (current is! TeacherGradesExamTypesLoaded) return;

    emit(TeacherGradesLoading());
    try {
      final entries = await _remote.getStudentGrades(current.selectedClass.classId, examType.id);
      emit(TeacherGradesStudentsLoaded(
        classes: current.classes,
        selectedClass: current.selectedClass,
        examTypes: current.examTypes,
        selectedExamType: examType,
        entries: entries,
      ));
    } catch (e) {
      emit(TeacherGradesError(e.toString()));
    }
  }

  void updateScore(int studentId, double? score) {
    final current = state;
    if (current is! TeacherGradesStudentsLoaded) return;
    final updated = current.entries.map((e) {
      return e.studentId == studentId ? e.copyWith(score: score) : e;
    }).toList();
    emit(current.copyWith(entries: updated));
  }

  Future<void> submit() async {
    final current = state;
    if (current is! TeacherGradesStudentsLoaded) return;

    emit(TeacherGradesSubmitting());
    final grades = current.entries
        .where((e) => e.score != null)
        .map((e) => {'student_id': e.studentId, 'score': e.score})
        .toList();

    final result = await _submitGrades(
      classId: current.selectedClass.classId,
      examTypeId: current.selectedExamType.id,
      grades: grades,
    );

    result.fold(
      (f) => emit(TeacherGradesError(f.message)),
      (_) => emit(TeacherGradesSubmitted()),
    );
  }

  void backToExamTypes() {
    final current = state;
    if (current is TeacherGradesStudentsLoaded) {
      emit(TeacherGradesExamTypesLoaded(
        classes: current.classes,
        selectedClass: current.selectedClass,
        examTypes: current.examTypes,
      ));
    }
  }

  void backToClasses() {
    final current = state;
    List<GradeClass> classes = [];
    if (current is TeacherGradesExamTypesLoaded) classes = current.classes;
    if (current is TeacherGradesStudentsLoaded) classes = current.classes;
    emit(TeacherGradesClassesLoaded(classes));
  }
}
