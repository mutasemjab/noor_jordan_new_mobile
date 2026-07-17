import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/teacher_attendance.dart';
import '../../domain/usecases/get_attendance_classes_usecase.dart';
import '../../domain/usecases/submit_attendance_usecase.dart';
import '../../data/datasources/teacher_attendance_remote_datasource.dart';
import 'teacher_attendance_state.dart';

class TeacherAttendanceCubit extends Cubit<TeacherAttendanceState> {
  final GetAttendanceClassesUseCase _getClasses;
  final SubmitAttendanceUseCase _submitAttendance;
  final TeacherAttendanceRemoteDataSource _remote;

  TeacherAttendanceCubit(this._getClasses, this._submitAttendance, this._remote)
      : super(TeacherAttendanceInitial());

  Future<void> loadClasses() async {
    emit(TeacherAttendanceLoading());
    final result = await _getClasses();
    result.fold(
      (f) => emit(TeacherAttendanceError(f.message)),
      (classes) => emit(TeacherAttendanceClassesLoaded(classes)),
    );
  }

  Future<void> selectClass(TeacherAttendanceClass cls) async {
    final current = state;
    List<TeacherAttendanceClass> classes = [];
    if (current is TeacherAttendanceClassesLoaded) classes = current.classes;
    if (current is TeacherAttendanceStudentsLoaded) classes = current.classes;

    emit(TeacherAttendanceLoading());
    final result = await _remote.getStudents(cls.classId);
    final today = DateTime.now();
    final date = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    emit(TeacherAttendanceStudentsLoaded(
      classes: classes,
      selectedClass: cls,
      entries: result,
      date: date,
    ));
  }

  void updateStatus(int studentId, AttendanceStatus status) {
    final current = state;
    if (current is! TeacherAttendanceStudentsLoaded) return;
    final updated = current.entries.map((e) {
      return e.studentId == studentId ? e.copyWith(status: status) : e;
    }).toList();
    emit(current.copyWith(entries: updated));
  }

  Future<void> submit() async {
    final current = state;
    if (current is! TeacherAttendanceStudentsLoaded) return;

    emit(TeacherAttendanceSubmitting());
    final entries = current.entries.map((e) {
      return {
        'student_id': e.studentId,
        'status': e.status.name,
      };
    }).toList();

    final result = await _submitAttendance(
      classId: current.selectedClass.classId,
      date: current.date,
      entries: entries,
    );

    result.fold(
      (f) => emit(TeacherAttendanceError(f.message)),
      (_) => emit(TeacherAttendanceSubmitted()),
    );
  }
}
