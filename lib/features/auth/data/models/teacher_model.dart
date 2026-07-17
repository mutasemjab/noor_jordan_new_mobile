import '../../domain/entities/teacher.dart';

class TeacherModel extends Teacher {
  const TeacherModel({
    required super.id,
    required super.name,
    super.avatar,
    super.email,
    super.phone,
    super.gender,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) => TeacherModel(
        id: json['id'] as int,
        name: json['name'] as String,
        avatar: json['avatar'] as String?,
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        gender: json['gender'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatar': avatar,
        'email': email,
        'phone': phone,
        'gender': gender,
      };
}
