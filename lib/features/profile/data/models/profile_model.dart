import '../../../auth/data/models/student_model.dart';
import '../../domain/entities/student_profile.dart';

class StudentProfileModel extends StudentProfile {
  const StudentProfileModel({
    required super.id,
    required super.name,
    super.phone,
    super.avatar,
    required super.className,
    super.siblings,
  });

  factory StudentProfileModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final siblingList = (data['siblings'] as List<dynamic>?)
            ?.map((s) => SiblingModel.fromJson(s as Map<String, dynamic>))
            .toList() ??
        [];
    return StudentProfileModel(
      id: data['id'] as int,
      name: (data['name'] ?? '') as String,
      phone: data['phone'] as String?,
      avatar: data['avatar'] as String?,
      className: (data['class'] ?? data['class_name'] ?? '') as String,
      siblings: siblingList,
    );
  }
}
