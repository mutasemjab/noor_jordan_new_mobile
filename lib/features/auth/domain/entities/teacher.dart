import 'package:equatable/equatable.dart';

class Teacher extends Equatable {
  final int id;
  final String name;
  final String? avatar;
  final String? email;
  final String? phone;
  final String? gender;

  const Teacher({
    required this.id,
    required this.name,
    this.avatar,
    this.email,
    this.phone,
    this.gender,
  });

  @override
  List<Object?> get props => [id, name, avatar, email, phone, gender];
}
