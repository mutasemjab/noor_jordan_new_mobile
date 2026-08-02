import '../../../classes/data/models/class_models.dart';
import '../../../home/data/models/home_models.dart';
import '../../domain/entities/teacher_home_data.dart';

class TeacherStatsModel extends TeacherStats {
  const TeacherStatsModel({
    required super.classesCount,
    required super.totalStudents,
    required super.todayPeriods,
    required super.pendingAttendance,
  });

  factory TeacherStatsModel.fromJson(Map<String, dynamic> json) {
    return TeacherStatsModel(
      classesCount: (json['classes_count'] as num?)?.toInt() ?? 0,
      totalStudents: (json['total_students'] as num?)?.toInt() ?? 0,
      todayPeriods: (json['today_periods'] as num?)?.toInt() ?? 0,
      pendingAttendance: (json['pending_attendance'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'classes_count': classesCount,
        'total_students': totalStudents,
        'today_periods': todayPeriods,
        'pending_attendance': pendingAttendance,
      };
}

class TeacherHomeDataModel extends TeacherHomeData {
  const TeacherHomeDataModel({
    required super.teacherId,
    required super.teacherName,
    super.teacherAvatar,
    required TeacherStatsModel stats,
    required List<BannerModel> banners,
    required List<SchoolClassModel> classes,
  }) : super(stats: stats, banners: banners, classes: classes);

  factory TeacherHomeDataModel.fromJson({
    required Map<String, dynamic> homeJson,
    required List<dynamic> bannersJson,
    required List<dynamic> classesJson,
  }) {
    final teacherMap = homeJson['teacher'] as Map<String, dynamic>? ?? {};
    final statsMap = homeJson['stats'] as Map<String, dynamic>? ?? {};

    return TeacherHomeDataModel(
      teacherId: (teacherMap['id'] as num?)?.toInt() ?? 0,
      teacherName: teacherMap['name'] as String? ?? '',
      teacherAvatar: teacherMap['avatar'] as String?,
      stats: TeacherStatsModel.fromJson(statsMap),
      banners: bannersJson
          .map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      classes: classesJson
          .map((e) => SchoolClassModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  factory TeacherHomeDataModel.fromCacheJson(Map<String, dynamic> json) =>
      TeacherHomeDataModel.fromJson(
        homeJson: json,
        bannersJson: json['banners'] as List<dynamic>? ?? [],
        classesJson: json['classes'] as List<dynamic>? ?? [],
      );

  Map<String, dynamic> toJson() => {
        'teacher': {
          'id': teacherId,
          'name': teacherName,
          'avatar': teacherAvatar,
        },
        'stats': (stats as TeacherStatsModel).toJson(),
        'banners': (banners as List<BannerModel>)
            .map((b) => b.toJson())
            .toList(),
        'classes': (classes as List<SchoolClassModel>)
            .map((c) => c.toJson())
            .toList(),
      };
}
