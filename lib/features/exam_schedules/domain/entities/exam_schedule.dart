import 'package:equatable/equatable.dart';

class ExamSchedule extends Equatable {
  final int id;
  final String name;
  final String? className;
  final String image;
  final String createdAt;

  const ExamSchedule({
    required this.id,
    required this.name,
    this.className,
    required this.image,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, className, image, createdAt];
}
