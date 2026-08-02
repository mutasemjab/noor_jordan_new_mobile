import '../../domain/entities/educational_note.dart';

class NoteModel extends EducationalNote {
  const NoteModel({
    required super.id,
    required super.title,
    required super.description,
    required super.type,
    required super.date,
    super.attachment,
    required super.teacherName,
    super.teacherAvatar,
    required super.className,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    final teacher = json['teacher'] as Map<String, dynamic>? ?? {};
    return NoteModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: (json['type'] as String?) == 'homework'
          ? EducationalNoteType.homework
          : EducationalNoteType.lesson,
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      attachment: json['attachment'] as String?,
      teacherName: teacher['name'] as String? ?? '',
      teacherAvatar: teacher['avatar'] as String?,
      className: json['class'] as String? ?? '',
    );
  }
}
