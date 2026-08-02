import 'package:equatable/equatable.dart';

enum EducationalNoteType { lesson, homework }

class EducationalNote extends Equatable {
  final int id;
  final String title;
  final String description;
  final EducationalNoteType type;
  final DateTime date;
  final String? attachment;
  final String teacherName;
  final String? teacherAvatar;
  final String className;

  const EducationalNote({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.date,
    this.attachment,
    required this.teacherName,
    this.teacherAvatar,
    required this.className,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        date,
        attachment,
        teacherName,
        teacherAvatar,
        className,
      ];
}
