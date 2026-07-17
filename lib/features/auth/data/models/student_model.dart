import '../../domain/entities/student.dart';

class SiblingModel extends Sibling {
  const SiblingModel({
    required super.id,
    required super.name,
    required super.className,
  });

  factory SiblingModel.fromJson(Map<String, dynamic> json) => SiblingModel(
        id: json['id'] as int,
        name: json['name'] as String,
        className: (json['class'] ?? json['class_name'] ?? '') as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'class': className,
      };
}

class StudentModel extends Student {
  const StudentModel({
    required super.id,
    required super.name,
    super.avatar,
    required super.className,
    super.phone,
    super.siblings,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    final siblingsList = (json['siblings'] as List<dynamic>?)
            ?.map((s) => SiblingModel.fromJson(s as Map<String, dynamic>))
            .toList() ??
        [];
    return StudentModel(
      id: json['id'] as int,
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
      className: (json['class'] ?? json['class_name'] ?? '') as String,
      phone: json['phone'] as String?,
      siblings: siblingsList,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatar': avatar,
        'class': className,
        'phone': phone,
        'siblings': siblings
            .map((s) => SiblingModel(id: s.id, name: s.name, className: s.className).toJson())
            .toList(),
      };
}
