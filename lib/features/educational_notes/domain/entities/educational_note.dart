import 'package:equatable/equatable.dart';

enum EducationalNoteType { lesson, homework }

/// Used by the teacher's مفكرتي create/edit/delete flow (teacher_notes
/// feature) — keep this shape stable, it's shared across features.
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
  final int? subjectId;
  final String? subjectName;

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
    this.subjectId,
    this.subjectName,
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
        subjectId,
        subjectName,
      ];
}

/// Step 1 — one day that has at least one note, with counts by type.
class NoteDateSummary extends Equatable {
  final DateTime date;
  final int lessonsCount;
  final int homeworkCount;

  const NoteDateSummary({
    required this.date,
    required this.lessonsCount,
    required this.homeworkCount,
  });

  @override
  List<Object?> get props => [date, lessonsCount, homeworkCount];
}

/// Step 2 — one subject that has notes on a given date.
class NoteSubject extends Equatable {
  final int id;
  final String name;
  final String? icon;
  final String? colorClass;
  final int lessonsCount;
  final int homeworkCount;

  const NoteSubject({
    required this.id,
    required this.name,
    this.icon,
    this.colorClass,
    required this.lessonsCount,
    required this.homeworkCount,
  });

  @override
  List<Object?> get props => [id, name, icon, colorClass, lessonsCount, homeworkCount];
}

/// Step 3 — one note item for a given date + subject.
class NoteContentItem extends Equatable {
  final int id;
  final String title;
  final String description;
  final EducationalNoteType type;
  final DateTime date;
  final String? attachment;
  final String teacherName;
  final String? teacherAvatar;
  final String className;
  final String subjectName;

  const NoteContentItem({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.date,
    this.attachment,
    required this.teacherName,
    this.teacherAvatar,
    required this.className,
    required this.subjectName,
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
        subjectName,
      ];
}
