import 'package:equatable/equatable.dart';
import '../../domain/entities/teacher_external_link.dart';

abstract class TeacherExternalLinksState extends Equatable {
  const TeacherExternalLinksState();
  @override
  List<Object?> get props => [];
}

class TeacherExternalLinksLoading extends TeacherExternalLinksState {
  const TeacherExternalLinksLoading();
}

class TeacherExternalLinksLoaded extends TeacherExternalLinksState {
  final List<TeacherExternalLink> links;
  const TeacherExternalLinksLoaded(this.links);
  @override
  List<Object?> get props => [links];
}

class TeacherExternalLinksError extends TeacherExternalLinksState {
  final String message;
  const TeacherExternalLinksError(this.message);
  @override
  List<Object?> get props => [message];
}
