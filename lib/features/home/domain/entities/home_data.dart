import 'package:equatable/equatable.dart';

class Banner extends Equatable {
  final int id;
  final String imageUrl;
  final String? link;
  final bool isActive;

  const Banner({
    required this.id,
    required this.imageUrl,
    this.link,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, imageUrl, link, isActive];
}

class TopTeacher extends Equatable {
  final int id;
  final String name;
  final String? avatar;
  final int totalStudents;

  const TopTeacher({
    required this.id,
    required this.name,
    this.avatar,
    required this.totalStudents,
  });

  @override
  List<Object?> get props => [id, name, avatar, totalStudents];
}

class HomeStats extends Equatable {
  final int totalStudents;
  final int totalTeachers;
  final double attendancePercent;
  final int notificationsCount;
  final int todayPeriods;

  const HomeStats({
    required this.totalStudents,
    required this.totalTeachers,
    required this.attendancePercent,
    required this.notificationsCount,
    required this.todayPeriods,
  });

  @override
  List<Object?> get props => [
        totalStudents,
        totalTeachers,
        attendancePercent,
        notificationsCount,
        todayPeriods,
      ];
}

class StudentHomeData extends Equatable {
  final List<Banner> banners;
  final List<TopTeacher> topTeachers;
  final HomeStats stats;

  const StudentHomeData({
    required this.banners,
    required this.topTeachers,
    required this.stats,
  });

  @override
  List<Object?> get props => [banners, topTeachers, stats];
}
