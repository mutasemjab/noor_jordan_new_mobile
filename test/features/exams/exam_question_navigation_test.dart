import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor/core/error/failures.dart';
import 'package:noor/features/exams/domain/entities/exam_entities.dart';
import 'package:noor/features/exams/domain/repositories/exams_repository.dart';
import 'package:noor/features/exams/domain/usecases/get_exam_detail_usecase.dart';
import 'package:noor/features/exams/domain/usecases/get_exams_usecase.dart';
import 'package:noor/features/exams/domain/usecases/get_my_exams_usecase.dart';
import 'package:noor/features/exams/domain/usecases/start_exam_usecase.dart';
import 'package:noor/features/exams/domain/usecases/submit_exam_usecase.dart';
import 'package:noor/features/exams/presentation/cubit/exams_cubit.dart';
import 'package:noor/features/exams/presentation/cubit/exams_state.dart';

class _FakeExamsRepository implements ExamsRepository {
  final Exam exam;

  _FakeExamsRepository(this.exam);

  @override
  Future<Either<Failure, Exam>> getExamDetail(int examId) async => Right(exam);

  @override
  Future<Either<Failure, List<Exam>>> getExams() async => Right([exam]);

  @override
  Future<Either<Failure, List<MyExam>>> getMyExams() async => const Right([]);

  @override
  Future<Either<Failure, ExamAttempt>> startExam(int examId) async =>
      Right(ExamAttempt(id: 99, examId: examId, isSubmitted: false));

  @override
  Future<Either<Failure, ExamAttempt>> submitAttempt(
    int attemptId,
    List<AttemptAnswer> answers,
  ) async =>
      Right(
        ExamAttempt(
          id: attemptId,
          examId: exam.id,
          isSubmitted: true,
          answers: answers,
        ),
      );

  @override
  Future<Either<Failure, ExamAttempt>> getAttemptResult(int attemptId) async =>
      Right(
        ExamAttempt(
          id: attemptId,
          examId: exam.id,
          isSubmitted: true,
        ),
      );
}

void main() {
  const exam = Exam(
    id: 1,
    title: 'اختبار',
    durationMinutes: 10,
    questions: [
      ExamQuestion(
        id: 1,
        questionText: 'السؤال الأول',
        options: [ExamOption(id: 11, text: 'إجابة')],
      ),
      ExamQuestion(
        id: 2,
        questionText: 'السؤال الثاني',
        options: [ExamOption(id: 21, text: 'إجابة')],
      ),
      ExamQuestion(
        id: 3,
        questionText: 'السؤال الثالث',
        options: [ExamOption(id: 31, text: 'إجابة')],
      ),
    ],
  );

  late ExamsCubit cubit;

  setUp(() async {
    final repository = _FakeExamsRepository(exam);
    cubit = ExamsCubit(
      GetExamsUseCase(repository),
      GetMyExamsUseCase(repository),
      GetExamDetailUseCase(repository),
      StartExamUseCase(repository),
      SubmitExamUseCase(repository),
    );
    await cubit.startExam(exam.id, exam);
  });

  tearDown(() => cubit.close());

  test('does not advance while the current question is unanswered', () {
    cubit.nextQuestion();

    final state = cubit.state as ExamTaking;
    expect(state.currentIndex, 0);
    expect(cubit.canGoToQuestion(1), isFalse);
  });

  test('does not skip over an unanswered question from the indicators', () {
    cubit.answerQuestion(1, 11);
    cubit.goToQuestion(2);

    expect((cubit.state as ExamTaking).currentIndex, 0);

    cubit.nextQuestion();
    cubit.answerQuestion(2, 21);
    cubit.goToQuestion(2);

    expect((cubit.state as ExamTaking).currentIndex, 2);
  });

  test('allows returning to an earlier question', () {
    cubit.answerQuestion(1, 11);
    cubit.nextQuestion();
    cubit.previousQuestion();

    expect((cubit.state as ExamTaking).currentIndex, 0);
  });
}
