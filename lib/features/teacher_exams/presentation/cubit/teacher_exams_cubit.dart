import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/teacher_exams_usecases.dart';
import 'teacher_exams_state.dart';

class TeacherExamsCubit extends Cubit<TeacherExamsState> {
  final GetTeacherExamsUseCase _getExams;
  final CreateExamUseCase _createExam;
  final DeleteExamUseCase _deleteExam;
  final int classId;

  TeacherExamsCubit({
    required this.classId,
    required GetTeacherExamsUseCase getExams,
    required CreateExamUseCase createExam,
    required DeleteExamUseCase deleteExam,
  })  : _getExams = getExams,
        _createExam = createExam,
        _deleteExam = deleteExam,
        super(const TeacherExamsLoading());

  Future<void> load() async {
    emit(const TeacherExamsLoading());
    final result = await _getExams(classId: classId);
    result.fold(
      (f) => emit(TeacherExamsError(f.message)),
      (exams) => emit(TeacherExamsLoaded(exams)),
    );
  }

  Future<ExamActionResult> create({
    required int subjectId,
    required String titleAr,
    String? descriptionAr,
    required String examType,
    required int durationMinutes,
    required int totalMarks,
    int? passMarks,
    String? difficultyLevel,
    required bool isPublished,
    required bool showResultImmediately,
  }) async {
    final result = await _createExam(
      classId: classId,
      subjectId: subjectId,
      titleAr: titleAr,
      descriptionAr: descriptionAr,
      examType: examType,
      durationMinutes: durationMinutes,
      totalMarks: totalMarks,
      passMarks: passMarks,
      difficultyLevel: difficultyLevel,
      isPublished: isPublished,
      showResultImmediately: showResultImmediately,
    );
    return result.fold(
      (f) => ExamActionResult(error: f.message),
      (exam) {
        load();
        return ExamActionResult(exam: exam);
      },
    );
  }

  Future<String?> delete(int id) async {
    final result = await _deleteExam(id);
    return result.fold((f) => f.message, (_) {
      load();
      return null;
    });
  }
}
