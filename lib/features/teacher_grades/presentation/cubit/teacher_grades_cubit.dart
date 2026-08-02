import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../classes/domain/entities/school_class.dart';
import '../../../classes/domain/usecases/get_class_students_usecase.dart';
import '../../../teacher_common/domain/entities/teacher_subject.dart';
import '../../domain/entities/teacher_grades.dart';
import '../../domain/usecases/teacher_grades_usecases.dart';
import 'teacher_grades_state.dart';

class TeacherGradesCubit extends Cubit<TeacherGradesState> {
  final GetTeacherGradesUseCase _getGrades;
  final SubmitGradesUseCase _submitGrades;
  final GetClassStudentsUseCase _getClassStudents;
  final int classId;

  TeacherGradesCubit({
    required this.classId,
    required GetTeacherGradesUseCase getGrades,
    required SubmitGradesUseCase submitGrades,
    required GetClassStudentsUseCase getClassStudents,
  })  : _getGrades = getGrades,
        _submitGrades = submitGrades,
        _getClassStudents = getClassStudents,
        super(const TeacherGradesInitial());

  Future<void> selectSubject(TeacherSubject subject) async {
    emit(const TeacherGradesLoading());
    final rosterResult = await _getClassStudents(classId);
    final rosterFailure = rosterResult.fold((f) => f, (_) => null);
    if (rosterFailure != null) {
      emit(TeacherGradesError(rosterFailure.message));
      return;
    }
    final roster = rosterResult.fold((_) => const <ClassStudent>[], (r) => r);

    final gradesResult = await _getGrades(classId: classId, subjectId: subject.id);
    gradesResult.fold(
      (f) => emit(TeacherGradesError(f.message)),
      (records) => emit(TeacherGradesLoaded(subject: subject, roster: roster, records: records)),
    );
  }

  Future<void> refresh() async {
    final current = state;
    if (current is TeacherGradesLoaded) await selectSubject(current.subject);
  }

  Future<String?> submit({
    required String title,
    required double maxScore,
    required DateTime gradedAt,
    required List<GradeEntryInput> grades,
  }) async {
    final current = state;
    if (current is! TeacherGradesLoaded) return 'الرجاء اختيار المادة أولاً';
    final result = await _submitGrades(
      classId: classId,
      subjectId: current.subject.id,
      title: title,
      maxScore: maxScore,
      gradedAt: gradedAt,
      grades: grades,
    );
    return result.fold((f) => f.message, (_) {
      selectSubject(current.subject);
      return null;
    });
  }
}
