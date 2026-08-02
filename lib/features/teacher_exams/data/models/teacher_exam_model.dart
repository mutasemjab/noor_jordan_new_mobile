import '../../../teacher_common/domain/entities/teacher_subject.dart';
import '../../../teacher_files/domain/entities/teacher_file_item.dart';
import '../../domain/entities/teacher_exam.dart';

class TeacherExamOptionModel extends TeacherExamOption {
  const TeacherExamOptionModel({super.id, required super.textAr, required super.isCorrect});

  factory TeacherExamOptionModel.fromJson(Map<String, dynamic> json) {
    return TeacherExamOptionModel(
      id: (json['id'] as num?)?.toInt(),
      textAr: json['option_text_ar'] as String? ?? json['option_text'] as String? ?? '',
      isCorrect: json['is_correct'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'option_text_ar': textAr,
        'is_correct': isCorrect,
      };
}

class TeacherExamQuestionModel extends TeacherExamQuestion {
  const TeacherExamQuestionModel({
    super.id,
    required super.questionAr,
    required super.questionType,
    required super.marks,
    super.difficulty,
    super.explanationAr,
    required super.options,
  });

  factory TeacherExamQuestionModel.fromJson(Map<String, dynamic> json) {
    final optionsJson = json['options'] as List<dynamic>? ?? [];
    return TeacherExamQuestionModel(
      id: (json['id'] as num?)?.toInt(),
      questionAr: json['question_ar'] as String? ?? json['question_text'] as String? ?? '',
      questionType: json['question_type'] as String? ?? 'mcq',
      marks: (json['marks'] as num?)?.toInt() ?? 1,
      difficulty: json['difficulty'] as String?,
      explanationAr: json['explanation_ar'] as String?,
      options: optionsJson.whereType<Map<String, dynamic>>().map((e) => TeacherExamOptionModel.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'question_ar': questionAr,
        'question_type': questionType,
        'marks': marks,
        if (difficulty != null) 'difficulty': difficulty,
        if (explanationAr != null && explanationAr!.isNotEmpty) 'explanation_ar': explanationAr,
        'options': options.map((o) => (o as TeacherExamOptionModel).toJson()).toList(),
      };
}

class TeacherExamModel extends TeacherExam {
  const TeacherExamModel({
    required super.id,
    required super.titleAr,
    super.descriptionAr,
    required super.examType,
    super.totalQuestions,
    required super.durationMinutes,
    required super.totalMarks,
    super.passMarks,
    super.difficultyLevel,
    super.isPublished,
    super.showResultImmediately,
    super.subject,
    super.schoolClass,
    super.questions,
  });

  factory TeacherExamModel.fromJson(Map<String, dynamic> json) {
    final subjectJson = json['subject'] as Map<String, dynamic>?;
    final classJson = json['class'] as Map<String, dynamic>?;
    final questionsJson = json['questions'] as List<dynamic>? ?? [];
    return TeacherExamModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      titleAr: json['title_ar'] as String? ?? json['title'] as String? ?? '',
      descriptionAr: json['description_ar'] as String? ?? json['description'] as String?,
      examType: json['exam_type'] as String? ?? 'unit',
      totalQuestions: (json['total_questions'] as num?)?.toInt() ?? questionsJson.length,
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 0,
      totalMarks: (json['total_marks'] as num?)?.toInt() ?? 0,
      passMarks: (json['pass_marks'] as num?)?.toInt(),
      difficultyLevel: json['difficulty_level'] as String?,
      isPublished: json['is_published'] as bool? ?? false,
      showResultImmediately: json['show_result_immediately'] as bool? ?? true,
      subject: subjectJson != null
          ? TeacherSubject(id: (subjectJson['id'] as num?)?.toInt() ?? 0, name: subjectJson['name'] as String? ?? '')
          : null,
      schoolClass: classJson != null
          ? TeacherClassRef(id: (classJson['id'] as num?)?.toInt() ?? 0, name: classJson['name'] as String? ?? '')
          : null,
      questions: questionsJson.whereType<Map<String, dynamic>>().map((e) => TeacherExamQuestionModel.fromJson(e)).toList(),
    );
  }
}
