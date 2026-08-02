import 'package:equatable/equatable.dart';

/// A subject a teacher is assigned to teach within a specific class.
class TeacherSubject extends Equatable {
  final int id;
  final String name;

  const TeacherSubject({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
