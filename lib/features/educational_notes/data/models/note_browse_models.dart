import '../../domain/entities/educational_note.dart';

class NoteDateSummaryModel extends NoteDateSummary {
  const NoteDateSummaryModel({
    required super.date,
    required super.lessonsCount,
    required super.homeworkCount,
  });

  factory NoteDateSummaryModel.fromJson(Map<String, dynamic> json) {
    return NoteDateSummaryModel(
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      lessonsCount: (json['lessons_count'] as num?)?.toInt() ?? 0,
      homeworkCount: (json['homework_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class NoteSubjectModel extends NoteSubject {
  const NoteSubjectModel({
    required super.id,
    required super.name,
    super.icon,
    super.colorClass,
    required super.lessonsCount,
    required super.homeworkCount,
  });

  factory NoteSubjectModel.fromJson(Map<String, dynamic> json) {
    return NoteSubjectModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      icon: json['icon'] as String?,
      colorClass: json['color_class'] as String?,
      lessonsCount: (json['lessons_count'] as num?)?.toInt() ?? 0,
      homeworkCount: (json['homework_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class NoteContentItemModel extends NoteContentItem {
  const NoteContentItemModel({
    required super.id,
    required super.title,
    required super.description,
    required super.type,
    required super.date,
    super.attachment,
    required super.teacherName,
    super.teacherAvatar,
    required super.className,
    required super.subjectName,
  });

  factory NoteContentItemModel.fromJson(Map<String, dynamic> json) {
    final teacher = json['teacher'] as Map<String, dynamic>? ?? {};
    final subject = json['subject'] as Map<String, dynamic>? ?? {};
    return NoteContentItemModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: (json['type'] as String?) == 'homework' ? EducationalNoteType.homework : EducationalNoteType.lesson,
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      attachment: json['attachment'] as String?,
      teacherName: teacher['name'] as String? ?? '',
      teacherAvatar: teacher['avatar'] as String?,
      className: json['class'] as String? ?? '',
      subjectName: subject['name'] as String? ?? '',
    );
  }
}
