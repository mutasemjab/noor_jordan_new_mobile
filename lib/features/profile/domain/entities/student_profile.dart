import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/student.dart';

class StudentProfile extends Equatable {
  final int id;
  final String name;
  final String? phone;
  final String? avatar;
  final String className;
  final List<Sibling> siblings;

  const StudentProfile({
    required this.id,
    required this.name,
    this.phone,
    this.avatar,
    required this.className,
    this.siblings = const [],
  });

  @override
  List<Object?> get props => [id, name, phone, avatar, className, siblings];
}
