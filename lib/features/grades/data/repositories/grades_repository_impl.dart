import 'dart:convert';

import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/storage/local_storage.dart';
import '../../domain/entities/grade.dart';
import '../../domain/repositories/grades_repository.dart';
import '../datasources/grades_remote_datasource.dart';
import '../models/grades_models.dart';

const _kCacheKey = 'cached_grades';

class GradesRepositoryImpl implements GradesRepository {
  final GradesRemoteDataSource _remoteDataSource;
  final LocalStorage _localStorage;
  final NetworkInfo _networkInfo;

  GradesRepositoryImpl(
    this._remoteDataSource,
    this._localStorage,
    this._networkInfo,
  );

  @override
  Future<Either<Failure, List<SubjectGrades>>> getGrades() async {
    final isConnected = await _networkInfo.isConnected;

    if (isConnected) {
      try {
        final grades = await _remoteDataSource.getGrades();
        await _localStorage.cacheData(
          _kCacheKey,
          grades.map((g) => (g as SubjectGradesModel).toJson()).toList(),
        );
        return Right(grades);
      } on NetworkException {
        return _getCachedGrades();
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (_) {
        return const Left(UnknownFailure());
      }
    } else {
      return _getCachedGrades();
    }
  }

  Either<Failure, List<SubjectGrades>> _getCachedGrades() {
    final cached = _localStorage.getCachedData(_kCacheKey);
    if (cached != null) {
      try {
        final list = cached as List<dynamic>;
        final grades = list
            .map((e) =>
                SubjectGradesModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return Right(grades);
      } catch (_) {
        return const Left(NetworkFailure());
      }
    }
    return const Left(NetworkFailure());
  }
}
