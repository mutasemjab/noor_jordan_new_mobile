import '../../domain/entities/exam_entities.dart';

class ExamOptionModel extends ExamOption {
  const ExamOptionModel({required super.id, required super.text});

  factory ExamOptionModel.fromJson(Map<String, dynamic> json) {
    return ExamOptionModel(
      id: json['id'] as int,
      text: json['text'] as String? ?? json['option_text'] as String? ?? '',
    );
  }
}

class ExamQuestionModel extends ExamQuestion {
  const ExamQuestionModel({
    required super.id,
    required super.questionText,
    required super.options,
  });

  factory ExamQuestionModel.fromJson(Map<String, dynamic> json) {
    final optionsJson =
        (json['options'] as List<dynamic>? ?? json['answers'] as List<dynamic>? ?? []);
    return ExamQuestionModel(
      id: json['id'] as int,
      questionText: json['question_text'] as String? ?? json['text'] as String? ?? '',
      options: optionsJson
          .map((e) => ExamOptionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

ExamSubjectRef? _parseSubject(dynamic raw) {
  if (raw is Map<String, dynamic>) {
    return ExamSubjectRef(id: (raw['id'] as num?)?.toInt(), name: raw['name'] as String? ?? '');
  }
  if (raw is String && raw.isNotEmpty) {
    return ExamSubjectRef(name: raw);
  }
  return null;
}

class ExamModel extends Exam {
  const ExamModel({
    required super.id,
    required super.title,
    super.description,
    super.examType,
    super.totalQuestions,
    super.durationMinutes,
    super.totalMarks,
    super.passMarks,
    super.difficultyLevel,
    super.showResultImmediately,
    super.subject,
    super.questions,
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    final questionsJson = json['questions'] as List<dynamic>? ?? [];
    return ExamModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? json['title_ar'] as String? ?? '',
      description: json['description'] as String?,
      examType: json['exam_type'] as String? ?? 'unit',
      totalQuestions: (json['total_questions'] as num?)?.toInt() ?? questionsJson.length,
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 0,
      totalMarks: (json['total_marks'] as num?)?.toInt() ?? 0,
      passMarks: (json['pass_marks'] as num?)?.toInt(),
      difficultyLevel: json['difficulty_level'] as String?,
      showResultImmediately: json['show_result_immediately'] as bool? ?? false,
      subject: _parseSubject(json['subject']),
      questions: questionsJson
          .map((e) => ExamQuestionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AttemptAnswerModel extends AttemptAnswer {
  const AttemptAnswerModel({
    required super.questionId,
    required super.selectedOptionId,
    super.isCorrect,
  });

  factory AttemptAnswerModel.fromJson(Map<String, dynamic> json) {
    return AttemptAnswerModel(
      questionId: json['question_id'] as int,
      selectedOptionId:
          json['selected_option_id'] as int? ?? json['option_id'] as int? ?? 0,
      isCorrect: json['is_correct'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'option_id': selectedOptionId,
    };
  }
}

class ExamAttemptModel extends ExamAttempt {
  const ExamAttemptModel({
    required super.id,
    required super.examId,
    super.score,
    super.percentage,
    super.isPassed,
    required super.isSubmitted,
    super.answers,
  });

  factory ExamAttemptModel.fromJson(Map<String, dynamic> json) {
    final answersJson = json['answers'] as List<dynamic>? ?? [];
    final examJson = json['exam'] as Map<String, dynamic>?;
    return ExamAttemptModel(
      // POST /start returns "attempt_id", not "id" — accept either.
      id: (json['id'] as num?)?.toInt() ?? (json['attempt_id'] as num?)?.toInt() ?? 0,
      examId: (json['exam_id'] as num?)?.toInt() ?? (examJson?['id'] as num?)?.toInt() ?? 0,
      score: (json['score'] as num?)?.toDouble(),
      percentage: (json['percentage'] as num?)?.toDouble(),
      isPassed: json['is_passed'] as bool?,
      isSubmitted: json['is_submitted'] as bool? ?? json['submitted'] as bool? ?? false,
      answers: answersJson
          .map((e) => AttemptAnswerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class MyExamModel extends MyExam {
  const MyExamModel({
    required super.attemptId,
    required super.exam,
    required super.score,
    required super.totalMarks,
    required super.percentage,
    required super.isPassed,
    super.timeTakenMinutes,
    super.submittedAt,
  });

  factory MyExamModel.fromJson(Map<String, dynamic> json) {
    final examJson = json['exam'] as Map<String, dynamic>? ?? {};
    return MyExamModel(
      attemptId: (json['attempt_id'] as num?)?.toInt() ?? 0,
      exam: ExamModel.fromJson(examJson),
      score: (json['score'] as num? ?? 0).toDouble(),
      totalMarks: (json['total_marks'] as num? ?? 0).toDouble(),
      percentage: (json['percentage'] as num? ?? 0).toDouble(),
      isPassed: json['is_passed'] as bool? ?? false,
      timeTakenMinutes: (json['time_taken_minutes'] as num?)?.toInt(),
      submittedAt: json['submitted_at'] != null
          ? DateTime.tryParse(json['submitted_at'] as String)
          : null,
    );
  }
}
