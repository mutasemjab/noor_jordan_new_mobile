import '../../domain/entities/subject.dart';

class SubjectModel extends Subject {
  const SubjectModel({
    required super.id,
    required super.nameAr,
    super.teacherName,
    super.teacherAvatar,
    super.icon,
    super.colorClass,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    final teacher = json['teacher'] as Map<String, dynamic>?;
    return SubjectModel(
      id: json['id'] as int,
      nameAr: json['name_ar'] as String? ?? json['name'] as String? ?? '',
      teacherName: teacher?['name'] as String?,
      teacherAvatar: teacher?['avatar'] as String?,
      icon: json['icon'] as String?,
      colorClass: json['color_class'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_ar': nameAr,
      'teacher': {
        'name': teacherName,
        'avatar': teacherAvatar,
      },
      'icon': icon,
      'color_class': colorClass,
    };
  }
}
