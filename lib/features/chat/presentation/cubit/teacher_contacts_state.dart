import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_contact.dart';

abstract class TeacherContactsState extends Equatable {
  const TeacherContactsState();
  @override
  List<Object?> get props => [];
}

class TeacherContactsLoading extends TeacherContactsState {
  const TeacherContactsLoading();
}

class TeacherContactsLoaded extends TeacherContactsState {
  final List<ChatContact> teachers;
  const TeacherContactsLoaded(this.teachers);
  @override
  List<Object?> get props => [teachers];
}

class TeacherContactsError extends TeacherContactsState {
  final String message;
  const TeacherContactsError(this.message);
  @override
  List<Object?> get props => [message];
}
