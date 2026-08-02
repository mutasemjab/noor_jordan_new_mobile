import 'package:equatable/equatable.dart';
import '../../../teacher_common/domain/entities/teacher_subject.dart';

enum TeacherFileKind { questionBank, previousYearExam, worksheet }

extension TeacherFileKindX on TeacherFileKind {
  String get label {
    switch (this) {
      case TeacherFileKind.questionBank:
        return 'بنك الأسئلة';
      case TeacherFileKind.previousYearExam:
        return 'امتحانات سابقة';
      case TeacherFileKind.worksheet:
        return 'أوراق عمل';
    }
  }

  /// Whether this kind carries a "year" field at all.
  bool get supportsYear => this != TeacherFileKind.questionBank;

  /// Whether "year" is required on creation.
  bool get yearRequired => this == TeacherFileKind.previousYearExam;
}

class TeacherClassRef extends Equatable {
  final int id;
  final String name;
  const TeacherClassRef({required this.id, required this.name});
  @override
  List<Object?> get props => [id, name];
}

class TeacherFileItem extends Equatable {
  final int id;
  final String title;
  final int? year;
  final int? pages;
  final double? fileSize;
  final String pdfUrl;
  final TeacherSubject? subject;
  final TeacherClassRef? schoolClass;

  const TeacherFileItem({
    required this.id,
    required this.title,
    this.year,
    this.pages,
    this.fileSize,
    required this.pdfUrl,
    this.subject,
    this.schoolClass,
  });

  @override
  List<Object?> get props => [id, title, year, pages, fileSize, pdfUrl, subject, schoolClass];
}
