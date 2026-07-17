import 'package:dartz/dartz.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/storage/local_storage.dart';
import '../../domain/entities/student.dart';
import '../../domain/entities/teacher.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/student_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final LocalStorage _storage;
  final NetworkInfo _network;

  AuthRepositoryImpl(this._remote, this._storage, this._network);

  @override
  Future<Either<Failure, ({String token, Student student})>> loginStudent({
    required String phone,
    required String password,
  }) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      final result = await _remote.loginStudent(phone: phone, password: password);
      await _storage.saveToken(result.token);
      await _storage.saveUserType(AppConstants.userTypeStudent);
      await _storage.saveUserData((result.student as StudentModel).toJson());
      return Right((token: result.token, student: result.student));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.errors));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, ({String token, Teacher teacher})>> loginTeacher({
    required String email,
    required String password,
  }) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      final result = await _remote.loginTeacher(email: email, password: password);
      await _storage.saveToken(result.token);
      await _storage.saveUserType(AppConstants.userTypeTeacher);
      return Right((token: result.token, teacher: result.teacher));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.errors));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, ({String token, Student student})>> switchSibling(
      int siblingId) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      final result = await _remote.switchSibling(siblingId);
      await _storage.saveToken(result.token);
      await _storage.saveUserData((result.student as StudentModel).toJson());
      return Right((token: result.token, student: result.student));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    final userType = _storage.getUserType();
    final endpoint = userType == AppConstants.userTypeTeacher
        ? '/v1/teacher/auth/logout'
        : '/v1/student/auth/logout';
    try {
      await _remote.logout(endpoint);
    } catch (_) {}
    await _storage.clearUserSession();
    return const Right(null);
  }
}
