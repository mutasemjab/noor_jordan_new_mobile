import '../../domain/entities/grade.dart';

class GradeEntryModel extends GradeEntry {
  const GradeEntryModel({
    required super.id,
    required super.title,
    required super.score,
    required super.maxScore,
    required super.percentage,
    required super.gradedAt,
  });

  factory GradeEntryModel.fromJson(Map<String, dynamic> json) {
    return GradeEntryModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      maxScore: (json['max_score'] as num?)?.toDouble() ?? 100.0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      gradedAt: json['graded_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'score': score,
      'max_score': maxScore,
      'percentage': percentage,
      'graded_at': gradedAt,
    };
  }
}

class SubjectGradesModel extends SubjectGrades {
  const SubjectGradesModel({
    required super.subjectId,
    required super.subjectName,
    super.subjectIcon,
    super.colorClass,
    required super.grades,
    required super.average,
  });

  factory SubjectGradesModel.fromJson(Map<String, dynamic> json) {
    final subject = json['subject'] as Map<String, dynamic>? ?? {};
    final gradesJson = json['grades'] as List<dynamic>? ?? [];

    return SubjectGradesModel(
      subjectId: subject['id'] as int? ?? 0,
      subjectName: subject['name_ar'] as String? ?? '',
      subjectIcon: subject['icon'] as String?,
      colorClass: subject['color_class'] as String?,
      grades: gradesJson
          .map((g) => GradeEntryModel.fromJson(g as Map<String, dynamic>))
          .toList(),
      average: (json['average'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject': {
        'id': subjectId,
        'name_ar': subjectName,
        'icon': subjectIcon,
        'color_class': colorClass,
      },
      'grades': (grades as List<GradeEntryModel>)
          .map((g) => (g as GradeEntryModel).toJson())
          .toList(),
      'average': average,
    };
  }
}
