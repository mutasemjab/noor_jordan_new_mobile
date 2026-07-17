import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/teacher_profile.dart';
import '../../domain/repositories/teacher_profile_repository.dart';
import '../datasources/teacher_profile_remote_datasource.dart';

class TeacherProfileRepositoryImpl implements TeacherProfileRepository {
  final TeacherProfileRemoteDataSource _remote;
  final NetworkInfo _network;

  TeacherProfileRepositoryImpl(this._remote, this._network);

  @override
  Future<Either<Failure, TeacherProfile>> getProfile() async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await _remote.getProfile());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, TeacherProfile>> updateProfile({
    required String name,
    required String phone,
    String? avatarPath,
  }) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await _remote.updateProfile(name: name, phone: phone, avatarPath: avatarPath));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
