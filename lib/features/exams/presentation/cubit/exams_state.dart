import 'dart:async';
import 'package:equatable/equatable.dart';
import '../../domain/entities/exam_entities.dart';

abstract class ExamsState extends Equatable {
  const ExamsState();
  @override
  List<Object?> get props => [];
}

class ExamsInitial extends ExamsState {}
class ExamsLoading extends ExamsState {}

class ExamsLoaded extends ExamsState {
  final List<MyExam> myExams;
  const ExamsLoaded(this.myExams);
  @override
  List<Object?> get props => [myExams];
}

class ExamsError extends ExamsState {
  final String message;
  const ExamsError(this.message);
  @override
  List<Object?> get props => [message];
}

class ExamStarting extends ExamsState {}

class ExamTaking extends ExamsState {
  final Exam exam;
  final int attemptId;
  final int currentIndex;
  final Map<int, int> answers; // questionId → optionId
  final Duration timeLeft;

  const ExamTaking({
    required this.exam,
    required this.attemptId,
    required this.currentIndex,
    required this.answers,
    required this.timeLeft,
  });

  ExamTaking copyWith({int? currentIndex, Map<int, int>? answers, Duration? timeLeft}) {
    return ExamTaking(
      exam: exam,
      attemptId: attemptId,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      timeLeft: timeLeft ?? this.timeLeft,
    );
  }

  @override
  List<Object?> get props => [exam, attemptId, currentIndex, answers, timeLeft];
}

class ExamSubmitting extends ExamsState {}

class ExamResult extends ExamsState {
  final ExamAttempt attempt;
  const ExamResult(this.attempt);
  @override
  List<Object?> get props => [attempt];
}
