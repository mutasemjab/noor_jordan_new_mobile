import '../../domain/entities/teacher_profile.dart';

class TeacherProfileModel extends TeacherProfile {
  const TeacherProfileModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    super.avatarUrl,
    required super.subject,
    required super.employeeNumber,
  });

  factory TeacherProfileModel.fromJson(Map<String, dynamic> json) {
    return TeacherProfileModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      avatarUrl: json['avatar'] as String?,
      subject: json['subject'] as String? ?? '',
      employeeNumber: (json['employee_number'] ?? json['employeeNumber'] ?? '') as String,
    );
  }
}
