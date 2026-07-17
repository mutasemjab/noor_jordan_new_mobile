import 'package:equatable/equatable.dart';
import '../../domain/entities/school_class.dart';

abstract class ClassesState extends Equatable {
  const ClassesState();
  @override
  List<Object?> get props => [];
}

class ClassesInitial extends ClassesState {}
class ClassesLoading extends ClassesState {}

class ClassesLoaded extends ClassesState {
  final List<SchoolClass> classes;
  const ClassesLoaded(this.classes);
  @override
  List<Object?> get props => [classes];
}

class ClassStudentsLoading extends ClassesState {
  final SchoolClass schoolClass;
  const ClassStudentsLoading(this.schoolClass);
  @override
  List<Object?> get props => [schoolClass];
}

class ClassStudentsLoaded extends ClassesState {
  final SchoolClass schoolClass;
  final List<ClassStudent> students;
  final String searchQuery;

  const ClassStudentsLoaded(this.schoolClass, this.students, {this.searchQuery = ''});

  List<ClassStudent> get filtered => searchQuery.isEmpty
      ? students
      : students.where((s) => s.name.contains(searchQuery) || s.studentNumber.contains(searchQuery)).toList();

  ClassStudentsLoaded copyWith({String? searchQuery}) =>
      ClassStudentsLoaded(schoolClass, students, searchQuery: searchQuery ?? this.searchQuery);

  @override
  List<Object?> get props => [schoolClass, students, searchQuery];
}

class ClassesError extends ClassesState {
  final String message;
  const ClassesError(this.message);
  @override
  List<Object?> get props => [message];
}
