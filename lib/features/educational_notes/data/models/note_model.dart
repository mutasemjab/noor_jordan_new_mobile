import '../../domain/entities/educational_note.dart';

class NoteModel extends EducationalNote {
  const NoteModel({required super.id, required super.title, required super.body, required super.createdAt});

  factory NoteModel.fromJson(Map<String, dynamic> json) => NoteModel(
        id: json['id'] as int,
        title: (json['title'] ?? '') as String,
        body: (json['body'] ?? '') as String,
        createdAt: (json['created_at'] ?? '') as String,
      );
}
