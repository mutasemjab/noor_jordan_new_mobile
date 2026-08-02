import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/teacher_video.dart';
import '../../domain/repositories/teacher_videos_repository.dart';
import '../datasources/teacher_videos_remote_datasource.dart';

class TeacherVideosRepositoryImpl implements TeacherVideosRepository {
  final TeacherVideosRemoteDataSource _remote;
  final NetworkInfo _network;

  TeacherVideosRepositoryImpl(this._remote, this._network);

  @override
  Future<Either<Failure, List<TeacherVideo>>> getClassVideos(int classId) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await _remote.getClassVideos(classId));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> createVideo({
    required int classId,
    required int subjectId,
    required String title,
    required String youtubeUrl,
  }) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      await _remote.createVideo(classId: classId, subjectId: subjectId, title: title, youtubeUrl: youtubeUrl);
      return const Right(null);
    } on NetworkException {
      return const Left(NetworkFailure());
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteVideo({required int classId, required int videoId}) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      await _remote.deleteVideo(classId: classId, videoId: videoId);
      return const Right(null);
    } on NetworkException {
      return const Left(NetworkFailure());
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
