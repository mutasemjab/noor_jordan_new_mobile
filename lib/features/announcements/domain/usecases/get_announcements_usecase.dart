import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/announcement.dart';
import '../repositories/announcements_repository.dart';

class GetAnnouncementsUseCase {
  final AnnouncementsRepository _repo;
  GetAnnouncementsUseCase(this._repo);

  Future<Either<Failure, List<Announcement>>> call({
    int page = 1,
    bool isTeacher = false,
  }) =>
      _repo.getAnnouncements(page: page, isTeacher: isTeacher);
}
