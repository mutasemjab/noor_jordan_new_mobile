import 'package:equatable/equatable.dart';

class Subject extends Equatable {
  final int id;
  final String nameAr;
  final String? teacherName;
  final String? teacherAvatar;
  final String? icon;
  final String? colorClass;

  const Subject({
    required this.id,
    required this.nameAr,
    this.teacherName,
    this.teacherAvatar,
    this.icon,
    this.colorClass,
  });

  @override
  List<Object?> get props => [id, nameAr, teacherName, teacherAvatar, icon, colorClass];
}
