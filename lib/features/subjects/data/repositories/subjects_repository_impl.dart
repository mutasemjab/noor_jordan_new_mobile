import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/subject.dart';
import '../../domain/entities/subject_video.dart';
import '../../domain/repositories/subjects_repository.dart';
import '../datasources/subjects_remote_datasource.dart';

class SubjectsRepositoryImpl implements SubjectsRepository {
  final SubjectsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  SubjectsRepositoryImpl(this.remoteDataSource, this.networkInfo);

  @override
  Future<Either<Failure, List<Subject>>> getSubjects() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final subjects = await remoteDataSource.getSubjects();
      return Right(subjects);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on NotFoundException {
      return const Left(NotFoundFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<SubjectVideo>>> getSubjectVideos(int subjectId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final videos = await remoteDataSource.getSubjectVideos(subjectId);
      return Right(videos);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on NotFoundException {
      return const Left(NotFoundFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }
}
