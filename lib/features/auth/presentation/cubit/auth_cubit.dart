import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/usecases/login_student_usecase.dart';
import '../../domain/usecases/login_teacher_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginStudentUseCase _loginStudent;
  final LoginTeacherUseCase _loginTeacher;
  final LogoutUseCase _logout;
  final AuthRepository _repo;

  AuthCubit(
    this._loginStudent,
    this._loginTeacher,
    this._logout,
    this._repo,
  ) : super(const AuthInitial());

  Future<void> loginAsStudent({
    required String nationalId,
    required String password,
    String? fcmToken,
  }) async {
    emit(const AuthLoading());
    final result = await _loginStudent(
      nationalId: nationalId,
      password: password,
      fcmToken: fcmToken,
    );
    result.fold(
      (failure) => _handleFailure(failure),
      (data) => emit(StudentAuthenticated(data.student)),
    );
  }

  Future<void> loginAsTeacher({
    required String nationalId,
    required String password,
    String? fcmToken,
  }) async {
    emit(const AuthLoading());
    final result = await _loginTeacher(
      nationalId: nationalId,
      password: password,
      fcmToken: fcmToken,
    );
    result.fold(
      (failure) => _handleFailure(failure),
      (data) => emit(TeacherAuthenticated(data.teacher)),
    );
  }

  Future<void> switchSibling(int siblingId) async {
    emit(const SiblingSwitching());
    final result = await _repo.switchSibling(siblingId);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (data) => emit(StudentAuthenticated(data.student)),
    );
  }

  Future<void> logout() async {
    emit(const AuthLoading());
    await _logout();
    emit(const AuthLoggedOut());
  }

  void _handleFailure(Failure failure) {
    if (failure is ValidationFailure) {
      emit(AuthError(failure.message, validationErrors: failure.errors));
    } else {
      emit(AuthError(failure.message));
    }
  }
}
