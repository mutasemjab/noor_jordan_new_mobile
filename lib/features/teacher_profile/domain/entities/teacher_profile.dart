import 'package:equatable/equatable.dart';

class TeacherProfile extends Equatable {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? avatarUrl;
  final String subject;
  final String employeeNumber;

  const TeacherProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatarUrl,
    required this.subject,
    required this.employeeNumber,
  });

  @override
  List<Object?> get props => [id, name, email, phone, avatarUrl, subject, employeeNumber];
}
