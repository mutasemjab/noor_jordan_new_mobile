import '../../domain/entities/home_data.dart';

class BannerModel extends Banner {
  const BannerModel({
    required super.id,
    required super.image,
    super.link,
    required super.isActive,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: (json['id'] as num).toInt(),
      image: json['image'] as String? ?? '',
      link: json['link'] as String?,
      isActive: json['is_active'] == true || json['is_active'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'link': link,
      'is_active': isActive,
    };
  }
}

class TopTeacherModel extends TopTeacher {
  const TopTeacherModel({
    required super.id,
    required super.name,
    super.avatar,
    required super.totalStudents,
  });

  factory TopTeacherModel.fromJson(Map<String, dynamic> json) {
    return TopTeacherModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      avatar: json['avatar'] as String?,
      totalStudents: (json['total_students'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'total_students': totalStudents,
    };
  }
}

class HomeStatsModel extends HomeStats {
  const HomeStatsModel({
    required super.totalStudents,
    required super.totalTeachers,
    required super.attendancePercent,
    required super.notificationsCount,
    required super.todayPeriods,
  });

  factory HomeStatsModel.fromJson(Map<String, dynamic> json) {
    return HomeStatsModel(
      totalStudents: (json['total_students'] as num?)?.toInt() ?? 0,
      totalTeachers: (json['total_teachers'] as num?)?.toInt() ?? 0,
      attendancePercent: (json['attendance_percent'] as num?)?.toDouble() ?? 0.0,
      notificationsCount: (json['notifications_count'] as num?)?.toInt() ?? 0,
      todayPeriods: (json['today_periods'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_students': totalStudents,
      'total_teachers': totalTeachers,
      'attendance_percent': attendancePercent,
      'notifications_count': notificationsCount,
      'today_periods': todayPeriods,
    };
  }
}

class StudentHomeDataModel extends StudentHomeData {
  const StudentHomeDataModel({
    required List<BannerModel> banners,
    required List<TopTeacherModel> topTeachers,
    required HomeStatsModel stats,
  }) : super(banners: banners, topTeachers: topTeachers, stats: stats);

  factory StudentHomeDataModel.fromJson({
    required Map<String, dynamic> homeJson,
    required List<dynamic> bannersJson,
  }) {
    final statsRaw = homeJson['stats'] as Map<String, dynamic>? ?? homeJson;
    return StudentHomeDataModel(
      banners: bannersJson
          .map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      topTeachers: (homeJson['top_teachers'] as List<dynamic>? ?? [])
          .map((e) => TopTeacherModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      stats: HomeStatsModel.fromJson(statsRaw),
    );
  }

  factory StudentHomeDataModel.fromCacheJson(Map<String, dynamic> json) {
    return StudentHomeDataModel(
      banners: (json['banners'] as List<dynamic>? ?? [])
          .map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      topTeachers: (json['top_teachers'] as List<dynamic>? ?? [])
          .map((e) => TopTeacherModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      stats: HomeStatsModel.fromJson(
          json['stats'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'banners': banners
          .map((b) => BannerModel(
                id: b.id,
                image: b.image,
                link: b.link,
                isActive: b.isActive,
              ).toJson())
          .toList(),
      'top_teachers': topTeachers
          .map((t) => TopTeacherModel(
                id: t.id,
                name: t.name,
                avatar: t.avatar,
                totalStudents: t.totalStudents,
              ).toJson())
          .toList(),
      'stats': HomeStatsModel(
        totalStudents: stats.totalStudents,
        totalTeachers: stats.totalTeachers,
        attendancePercent: stats.attendancePercent,
        notificationsCount: stats.notificationsCount,
        todayPeriods: stats.todayPeriods,
      ).toJson(),
    };
  }
}
