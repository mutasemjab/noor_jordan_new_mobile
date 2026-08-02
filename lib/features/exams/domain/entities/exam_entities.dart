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

class ExamSubjectRef extends Equatable {
  final int? id;
  final String name;

  const ExamSubjectRef({this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

class Exam extends Equatable {
  final int id;
  final String title;
  final String? description;
  final String examType; // mock | unit | final | practice | previous_years | placement
  final int totalQuestions;
  final int durationMinutes;
  final int totalMarks;
  final int? passMarks;
  final String? difficultyLevel;
  final bool showResultImmediately;
  final ExamSubjectRef? subject;
  final List<ExamQuestion> questions;

  const Exam({
    required this.id,
    required this.title,
    this.description,
    this.examType = 'unit',
    this.totalQuestions = 0,
    this.durationMinutes = 0,
    this.totalMarks = 0,
    this.passMarks,
    this.difficultyLevel,
    this.showResultImmediately = false,
    this.subject,
    this.questions = const [],
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        examType,
        totalQuestions,
        durationMinutes,
        totalMarks,
        passMarks,
        difficultyLevel,
        showResultImmediately,
        subject,
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

/// A submitted exam attempt, as returned by GET /my-exams.
class MyExam extends Equatable {
  final int attemptId;
  final Exam exam;
  final double score;
  final double totalMarks;
  final double percentage;
  final bool isPassed;
  final int? timeTakenMinutes;
  final DateTime? submittedAt;

  const MyExam({
    required this.attemptId,
    required this.exam,
    required this.score,
    required this.totalMarks,
    required this.percentage,
    required this.isPassed,
    this.timeTakenMinutes,
    this.submittedAt,
  });

  @override
  List<Object?> get props => [
        attemptId,
        exam,
        score,
        totalMarks,
        percentage,
        isPassed,
        timeTakenMinutes,
        submittedAt,
      ];
}
