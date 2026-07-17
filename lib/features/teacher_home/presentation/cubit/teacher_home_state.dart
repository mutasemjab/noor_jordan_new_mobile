import 'package:equatable/equatable.dart';
import '../../domain/entities/teacher_home_data.dart';

abstract class TeacherHomeState extends Equatable {
  const TeacherHomeState();

  @override
  List<Object?> get props => [];
}

class TeacherHomeInitial extends TeacherHomeState {
  const TeacherHomeInitial();
}

class TeacherHomeLoading extends TeacherHomeState {
  const TeacherHomeLoading();
}

class TeacherHomeLoaded extends TeacherHomeState {
  final TeacherHomeData data;

  const TeacherHomeLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class TeacherHomeError extends TeacherHomeState {
  final String message;

  const TeacherHomeError(this.message);

  @override
  List<Object?> get props => [message];
}
