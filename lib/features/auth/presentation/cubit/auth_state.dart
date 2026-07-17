import 'package:equatable/equatable.dart';
import '../../domain/entities/student.dart';
import '../../domain/entities/teacher.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class StudentAuthenticated extends AuthState {
  final Student student;
  const StudentAuthenticated(this.student);
  @override
  List<Object?> get props => [student];
}

class TeacherAuthenticated extends AuthState {
  final Teacher teacher;
  const TeacherAuthenticated(this.teacher);
  @override
  List<Object?> get props => [teacher];
}

class AuthError extends AuthState {
  final String message;
  final Map<String, List<String>>? validationErrors;
  const AuthError(this.message, {this.validationErrors});
  @override
  List<Object?> get props => [message, validationErrors];
}

class AuthLoggedOut extends AuthState {
  const AuthLoggedOut();
}

class SiblingSwitching extends AuthState {
  const SiblingSwitching();
}
