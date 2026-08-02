import '../../domain/entities/exam_schedule.dart';

class ExamScheduleModel extends ExamSchedule {
  const ExamScheduleModel({
    required super.id,
    required super.name,
    super.className,
    required super.image,
    required super.createdAt,
  });

  factory ExamScheduleModel.fromJson(Map<String, dynamic> json) {
    return ExamScheduleModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      className: json['class_name'] as String?,
      image: json['image'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}
