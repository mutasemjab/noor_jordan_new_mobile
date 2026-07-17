import 'package:equatable/equatable.dart';

class ExamOption extends Equatable {
  final int id;
  final String text;

  const ExamOption({required this.id, required this.text});

  @override
  List<Object?> get props => [id, text];
}

class ExamQuestion extends Equatable {
  final int id;
  final String questionText;
  final List<ExamOption> options;

  const ExamQuestion({
    required this.id,
    required this.questionText,
    required this.options,
  });

  @override
  List<Object?> get props => [id, questionText, options];
}

class Exam extends Equatable {
  final int id;
  final String title;
  final int durationMinutes;
  final int questionsCount;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<ExamQuestion> questions;

  const Exam({
    required this.id,
    required this.title,
    required this.durationMinutes,
    required this.questionsCount,
    required this.status,
    this.startDate,
    this.endDate,
    this.questions = const [],
  });

  @override
  List<Object?> get props => [
        id,
        title,
        durationMinutes,
        questionsCount,
        status,
        startDate,
        endDate,
        questions,
      ];
}

class AttemptAnswer extends Equatable {
  final int questionId;
  final int selectedOptionId;
  final bool? isCorrect;

  const AttemptAnswer({
    required this.questionId,
    required this.selectedOptionId,
    this.isCorrect,
  });

  @override
  List<Object?> get props => [questionId, selectedOptionId, isCorrect];
}

class ExamAttempt extends Equatable {
  final int id;
  final int examId;
  final double? score;
  final double? percentage;
  final bool? isPassed;
  final bool isSubmitted;
  final List<AttemptAnswer> answers;

  const ExamAttempt({
    required this.id,
    required this.examId,
    this.score,
    this.percentage,
    this.isPassed,
    required this.isSubmitted,
    this.answers = const [],
  });

  @override
  List<Object?> get props => [
        id,
        examId,
        score,
        percentage,
        isPassed,
        isSubmitted,
        answers,
      ];
}

class MyExam extends Equatable {
  final int? attemptId;
  final Exam exam;
  final double? score;
  final double? percentage;
  final bool? isPassed;
  final DateTime? submittedAt;

  const MyExam({
    this.attemptId,
    required this.exam,
    this.score,
    this.percentage,
    this.isPassed,
    this.submittedAt,
  });

  @override
  List<Object?> get props => [
        attemptId,
        exam,
        score,
        percentage,
        isPassed,
        submittedAt,
      ];
}
