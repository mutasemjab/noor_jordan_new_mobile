import 'package:equatable/equatable.dart';
import '../../domain/entities/student_profile.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}
class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final StudentProfile profile;
  const ProfileLoaded(this.profile);
  @override
  List<Object?> get props => [profile];
}

class ProfileUpdating extends ProfileState {
  final StudentProfile profile;
  const ProfileUpdating(this.profile);
  @override
  List<Object?> get props => [profile];
}

class ProfileUpdated extends ProfileState {
  final StudentProfile profile;
  const ProfileUpdated(this.profile);
  @override
  List<Object?> get props => [profile];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
  @override
  List<Object?> get props => [message];
}
