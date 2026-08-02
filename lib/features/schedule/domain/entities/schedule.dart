import 'package:equatable/equatable.dart';

class ClassSchedule extends Equatable {
  final int classId;
  final String className;
  final String? scheduleImage;

  const ClassSchedule({
    required this.classId,
    required this.className,
    this.scheduleImage,
  });

  @override
  List<Object?> get props => [classId, className, scheduleImage];
}
