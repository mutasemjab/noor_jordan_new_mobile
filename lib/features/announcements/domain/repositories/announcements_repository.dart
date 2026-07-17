import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/announcement.dart';

abstract class AnnouncementsRepository {
  Future<Either<Failure, List<Announcement>>> getAnnouncements({
    int page = 1,
    bool isTeacher = false,
  });
  Future<Either<Failure, Announcement>> getAnnouncementDetail(int id,
      {bool isTeacher = false});
}
