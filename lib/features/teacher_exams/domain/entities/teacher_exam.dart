import 'package:equatable/equatable.dart';
import '../../../teacher_common/domain/entities/teacher_subject.dart';
import '../../../teacher_files/domain/entities/teacher_file_item.dart';

/// mock | unit | final | practice | previous_years | placement
extension ExamTypeX on String {
  String get examTypeLabel {
    switch (this) {
      case 'unit':
        return 'امتحان وحدة';
      case 'final':
        return 'امتحان نهائي';
      case 'mock':
        return 'امتحان تجريبي';
      case 'practice':
        return 'تدريب';
      case 'previous_years':
        return 'سنوات سابقة';
      case 'placement':
        return 'تحديد مستوى';
      default:
        return this;
    }
  }
}

const List<String> kExamTypes = ['unit', 'final', 'mock', 'practice', 'previous_years', 'placement'];

/// easy | medium | hard | mixed
extension DifficultyX on String {
  String get difficultyLabel {
    switch (this) {
      case 'easy':
        return 'سهل';
      case 'medium':
        return 'متوسط';
      case 'hard':
        return 'صعب';
      case 'mixed':
        return 'متنوع';
      default:
        return this;
    }
  }
}

const List<String> kDifficultyLevels = ['easy', 'medium', 'hard', 'mixed'];
const List<String> kQuestionDifficultyLevels = ['easy', 'medium', 'hard'];

/// mcq | true_false — the only two types the backend currently accepts.
extension QuestionTypeX on String {
  String get questionTypeLabel => this == 'true_false' ? 'صح وخطأ' : 'اختيار من متعدد';
}

class TeacherExamOption extends Equatable {
  final int? id;
  final String textAr;
  final bool isCorrect;

  const TeacherExamOption({this.id, required this.textAr, required this.isCorrect});

  TeacherExamOption copyWith({String? textAr, bool? isCorrect}) => TeacherExamOption(
        id: id,
        textAr: textAr ?? this.textAr,
        isCorrect: isCorrect ?? this.isCorrect,
      );

  @override
  List<Object?> get props => [id, textAr, isCorrect];
}

class TeacherExamQuestion extends Equatable {
  final int? id;
  final String questionAr;
  final String questionType; // mcq | true_false
  final int marks;
  final String? difficulty;
  final String? explanationAr;
  final List<TeacherExamOption> options;

  const TeacherExamQuestion({
    this.id,
    required this.questionAr,
    required this.questionType,
    required this.marks,
    this.difficulty,
    this.explanationAr,
    required this.options,
  });

  @override
  List<Object?> get props => [id, questionAr, questionType, marks, difficulty, explanationAr, options];
}

class TeacherExam extends Equatable {
  final int id;
  final String titleAr;
  final String? descriptionAr;
  final String examType;
  final int totalQuestions;
  final int durationMinutes;
  final int totalMarks;
  final int? passMarks;
  final String? difficultyLevel;
  final bool isPublished;
  final bool showResultImmediately;
  final TeacherSubject? subject;
  final TeacherClassRef? schoolClass;
  final List<TeacherExamQuestion> questions;

  const TeacherExam({
    required this.id,
    required this.titleAr,
    this.descriptionAr,
    required this.examType,
    this.totalQuestions = 0,
    required this.durationMinutes,
    required this.totalMarks,
    this.passMarks,
    this.difficultyLevel,
    this.isPublished = false,
    this.showResultImmediately = true,
    this.subject,
    this.schoolClass,
    this.questions = const [],
  });

  @override
  List<Object?> get props => [
        id,
        titleAr,
        descriptionAr,
        examType,
        totalQuestions,
        durationMinutes,
        totalMarks,
        passMarks,
        difficultyLevel,
        isPublished,
        showResultImmediately,
        subject,
        schoolClass,
        questions,
      ];
}
