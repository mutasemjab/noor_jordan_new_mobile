import 'package:equatable/equatable.dart';

class Sibling extends Equatable {
  final int id;
  final String name;
  final String className;

  const Sibling({required this.id, required this.name, required this.className});

  @override
  List<Object?> get props => [id, name, className];
}

class Student extends Equatable {
  final int id;
  final String name;
  final String? avatar;
  final String className;
  final String? phone;
  final List<Sibling> siblings;

  const Student({
    required this.id,
    required this.name,
    this.avatar,
    required this.className,
    this.phone,
    this.siblings = const [],
  });

  @override
  List<Object?> get props => [id, name, avatar, className, phone, siblings];
}
