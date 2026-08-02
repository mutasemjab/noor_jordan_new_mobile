import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/exam_entities.dart';
import '../../domain/usecases/get_exam_detail_usecase.dart';
import '../../domain/usecases/get_exams_usecase.dart';
import '../../domain/usecases/get_my_exams_usecase.dart';
import '../../domain/usecases/start_exam_usecase.dart';
import '../../domain/usecases/submit_exam_usecase.dart';
import 'exams_state.dart';

class ExamsCubit extends Cubit<ExamsState> {
  final GetExamsUseCase _getExams;
  final GetMyExamsUseCase _getMyExams;
  final GetExamDetailUseCase _getExamDetail;
  final StartExamUseCase _startExam;
  final SubmitExamUseCase _submitExam;
  Timer? _countdownTimer;

  ExamsCubit(this._getExams, this._getMyExams, this._getExamDetail, this._startExam, this._submitExam)
      : super(ExamsInitial());

  Future<void> loadExams() async {
    emit(ExamsLoading());
    final examsResult = await _getExams();
    final myExamsResult = await _getMyExams();

    examsResult.fold(
      (f) => emit(ExamsError(f.message)),
      (exams) {
        myExamsResult.fold(
          (f) => emit(ExamsError(f.message)),
          (myExams) {
            final takenIds = myExams.map((m) => m.exam.id).toSet();
            final available = exams.where((e) => !takenIds.contains(e.id)).toList();
            emit(ExamsLoaded(availableExams: available, myExams: myExams));
          },
        );
      },
    );
  }

  Future<void> startExam(int examId, Exam exam) async {
    emit(ExamStarting());
    final result = await _startExam(examId);
    await result.fold(
      (f) async => emit(ExamsError(f.message)),
      (attempt) async {
        // POST /start only returns exam metadata, not the actual questions —
        // fetch the full detail (falls back to the summary-level exam if that fails).
        final detailResult = await _getExamDetail(examId);
        final fullExam = detailResult.fold((_) => exam, (detail) => detail);

        final duration = Duration(minutes: fullExam.durationMinutes > 0 ? fullExam.durationMinutes : exam.durationMinutes);
        emit(ExamTaking(
          exam: fullExam,
          attemptId: attempt.id,
          currentIndex: 0,
          answers: {},
          timeLeft: duration,
        ));
        _startCountdown();
      },
    );
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final current = state;
      if (current is ExamTaking) {
        if (current.timeLeft.inSeconds <= 0) {
          _countdownTimer?.cancel();
          submitExam();
        } else {
          emit(current.copyWith(timeLeft: current.timeLeft - const Duration(seconds: 1)));
        }
      } else {
        _countdownTimer?.cancel();
      }
    });
  }

  void answerQuestion(int questionId, int optionId) {
    final current = state;
    if (current is ExamTaking) {
      final newAnswers = Map<int, int>.from(current.answers)..[questionId] = optionId;
      emit(current.copyWith(answers: newAnswers));
    }
  }

  void nextQuestion() {
    final current = state;
    if (current is ExamTaking && current.currentIndex < current.exam.questions.length - 1) {
      emit(current.copyWith(currentIndex: current.currentIndex + 1));
    }
  }

  void previousQuestion() {
    final current = state;
    if (current is ExamTaking && current.currentIndex > 0) {
      emit(current.copyWith(currentIndex: current.currentIndex - 1));
    }
  }

  void goToQuestion(int index) {
    final current = state;
    if (current is ExamTaking) {
      emit(current.copyWith(currentIndex: index));
    }
  }

  Future<void> submitExam() async {
    final current = state;
    if (current is! ExamTaking) return;
    _countdownTimer?.cancel();
    final attemptId = current.attemptId;
    final answers = current.answers.entries
        .map((e) => AttemptAnswer(questionId: e.key, selectedOptionId: e.value))
        .toList();
    emit(ExamSubmitting());
    final result = await _submitExam(attemptId, answers);
    result.fold(
      (f) => emit(ExamsError(f.message)),
      (attempt) => emit(ExamResult(attempt)),
    );
  }

  @override
  Future<void> close() {
    _countdownTimer?.cancel();
    return super.close();
  }
}
