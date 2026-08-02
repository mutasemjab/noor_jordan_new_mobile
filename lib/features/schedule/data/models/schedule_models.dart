import '../../domain/entities/schedule.dart';

class ClassScheduleModel extends ClassSchedule {
  const ClassScheduleModel({
    required super.classId,
    required super.className,
    super.scheduleImage,
  });

  factory ClassScheduleModel.fromJson(Map<String, dynamic> json) {
    return ClassScheduleModel(
      classId: (json['class_id'] as num?)?.toInt() ?? 0,
      className: json['class_name'] as String? ?? '',
      scheduleImage: json['schedule_image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'class_id': classId,
      'class_name': className,
      'schedule_image': scheduleImage,
    };
  }
}
