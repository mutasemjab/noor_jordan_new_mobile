import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcements_repository.dart';
import '../datasources/announcements_remote_datasource.dart';

class AnnouncementsRepositoryImpl implements AnnouncementsRepository {
  final AnnouncementsRemoteDataSource _remote;
  final NetworkInfo _network;

  AnnouncementsRepositoryImpl(this._remote, this._network);

  @override
  Future<Either<Failure, List<Announcement>>> getAnnouncements({
    int page = 1,
    bool isTeacher = false,
  }) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      final items = await _remote.getAnnouncements(page: page, isTeacher: isTeacher);
      return Right(items);
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Announcement>> getAnnouncementDetail(int id,
      {bool isTeacher = false}) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      final item = await _remote.getAnnouncementDetail(id, isTeacher: isTeacher);
      return Right(item);
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
