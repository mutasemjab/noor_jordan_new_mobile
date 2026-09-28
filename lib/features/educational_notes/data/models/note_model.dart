import '../../domain/entities/educational_note.dart';

class NoteModel extends EducationalNote {
  const NoteModel({
    required super.id,
    required super.title,
    required super.description,
    required super.type,
    required super.date,
    super.attachment,
    super.images,
    required super.teacherName,
    super.teacherAvatar,
    required super.className,
    super.subjectId,
    super.subjectName,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    final teacher = json['teacher'] as Map<String, dynamic>? ?? {};
    final subject = json['subject'] as Map<String, dynamic>?;
    final images = (json['images'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map((i) => NoteImage(id: (i['id'] as num?)?.toInt() ?? 0, url: i['url'] as String? ?? ''))
            .toList() ??
        const [];
    return NoteModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: (json['type'] as String?) == 'homework'
          ? EducationalNoteType.homework
          : EducationalNoteType.lesson,
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      attachment: json['attachment'] as String?,
      images: images,
      teacherName: teacher['name'] as String? ?? '',
      teacherAvatar: teacher['avatar'] as String?,
      className: json['class'] as String? ?? '',
      subjectId: (subject?['id'] as num?)?.toInt(),
      subjectName: subject?['name'] as String?,
    );
  }
}
