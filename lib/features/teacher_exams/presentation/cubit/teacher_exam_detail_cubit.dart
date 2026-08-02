import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/teacher_exam.dart';
import '../../domain/usecases/teacher_exams_usecases.dart';
import 'teacher_exam_detail_state.dart';

class TeacherExamDetailCubit extends Cubit<TeacherExamDetailState> {
  final GetTeacherExamDetailUseCase _getExamDetail;
  final UpdateExamUseCase _updateExam;
  final DeleteExamUseCase _deleteExam;
  final CreateExamQuestionUseCase _createQuestion;
  final UpdateExamQuestionUseCase _updateQuestion;
  final DeleteExamQuestionUseCase _deleteQuestion;
  final int examId;

  TeacherExamDetailCubit({
    required this.examId,
    required GetTeacherExamDetailUseCase getExamDetail,
    required UpdateExamUseCase updateExam,
    required DeleteExamUseCase deleteExam,
    required CreateExamQuestionUseCase createQuestion,
    required UpdateExamQuestionUseCase updateQuestion,
    required DeleteExamQuestionUseCase deleteQuestion,
  })  : _getExamDetail = getExamDetail,
        _updateExam = updateExam,
        _deleteExam = deleteExam,
        _createQuestion = createQuestion,
        _updateQuestion = updateQuestion,
        _deleteQuestion = deleteQuestion,
        super(const TeacherExamDetailLoading());

  Future<void> load() async {
    emit(const TeacherExamDetailLoading());
    final result = await _getExamDetail(examId);
    result.fold(
      (f) => emit(TeacherExamDetailError(f.message)),
      (exam) => emit(TeacherExamDetailLoaded(exam)),
    );
  }

  Future<String?> updateMeta({
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
    final result = await _updateExam(
      id: examId,
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
    return result.fold((f) => f.message, (_) {
      load();
      return null;
    });
  }

  Future<String?> deleteExam() async {
    final result = await _deleteExam(examId);
    return result.fold((f) => f.message, (_) => null);
  }

  Future<String?> addQuestion(TeacherExamQuestion question) async {
    final result = await _createQuestion(examId: examId, question: question);
    return result.fold((f) => f.message, (_) {
      load();
      return null;
    });
  }

  Future<String?> updateQuestion(int questionId, TeacherExamQuestion question) async {
    final result = await _updateQuestion(examId: examId, questionId: questionId, question: question);
    return result.fold((f) => f.message, (_) {
      load();
      return null;
    });
  }

  Future<String?> deleteQuestion(int questionId) async {
    final result = await _deleteQuestion(examId: examId, questionId: questionId);
    return result.fold((f) => f.message, (_) {
      load();
      return null;
    });
  }
}
