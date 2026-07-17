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

class ExamModel extends Exam {
  const ExamModel({
    required super.id,
    required super.title,
    required super.durationMinutes,
    required super.questionsCount,
    required super.status,
    super.startDate,
    super.endDate,
    super.questions,
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    final questionsJson = json['questions'] as List<dynamic>? ?? [];
    return ExamModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      durationMinutes: json['duration_minutes'] as int? ?? json['duration'] as int? ?? 60,
      questionsCount: json['questions_count'] as int? ??
          json['total_questions'] as int? ??
          questionsJson.length,
      status: json['status'] as String? ?? 'upcoming',
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'] as String)
          : null,
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'] as String)
          : null,
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
      'selected_option_id': selectedOptionId,
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
    return ExamAttemptModel(
      id: json['id'] as int,
      examId: json['exam_id'] as int? ?? 0,
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
    super.attemptId,
    required super.exam,
    super.score,
    super.percentage,
    super.isPassed,
    super.submittedAt,
  });

  factory MyExamModel.fromJson(Map<String, dynamic> json) {
    final examJson = json['exam'] as Map<String, dynamic>? ?? json;
    return MyExamModel(
      attemptId: json['attempt_id'] as int?,
      exam: ExamModel.fromJson(examJson),
      score: (json['score'] as num?)?.toDouble(),
      percentage: (json['percentage'] as num?)?.toDouble(),
      isPassed: json['is_passed'] as bool?,
      submittedAt: json['submitted_at'] != null
          ? DateTime.tryParse(json['submitted_at'] as String)
          : null,
    );
  }
}
