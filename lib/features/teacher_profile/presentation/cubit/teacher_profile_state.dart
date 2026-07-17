import 'package:equatable/equatable.dart';
import '../../domain/entities/teacher_profile.dart';

abstract class TeacherProfileState extends Equatable {
  const TeacherProfileState();
  @override
  List<Object?> get props => [];
}

class TeacherProfileInitial extends TeacherProfileState {}
class TeacherProfileLoading extends TeacherProfileState {}

class TeacherProfileLoaded extends TeacherProfileState {
  final TeacherProfile profile;
  const TeacherProfileLoaded(this.profile);
  @override
  List<Object?> get props => [profile];
}

class TeacherProfileUpdating extends TeacherProfileState {
  final TeacherProfile profile;
  const TeacherProfileUpdating(this.profile);
  @override
  List<Object?> get props => [profile];
}

class TeacherProfileUpdated extends TeacherProfileState {
  final TeacherProfile profile;
  const TeacherProfileUpdated(this.profile);
  @override
  List<Object?> get props => [profile];
}

class TeacherProfileError extends TeacherProfileState {
  final String message;
  const TeacherProfileError(this.message);
  @override
  List<Object?> get props => [message];
}
