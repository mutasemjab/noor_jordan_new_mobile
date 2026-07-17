import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_teacher_profile_usecase.dart';
import '../../domain/usecases/update_teacher_profile_usecase.dart';
import 'teacher_profile_state.dart';

class TeacherProfileCubit extends Cubit<TeacherProfileState> {
  final GetTeacherProfileUseCase _getProfile;
  final UpdateTeacherProfileUseCase _updateProfile;

  TeacherProfileCubit(this._getProfile, this._updateProfile) : super(TeacherProfileInitial());

  Future<void> loadProfile() async {
    emit(TeacherProfileLoading());
    final result = await _getProfile();
    result.fold(
      (f) => emit(TeacherProfileError(f.message)),
      (p) => emit(TeacherProfileLoaded(p)),
    );
  }

  Future<void> updateProfile({required String name, required String phone, String? avatarPath}) async {
    final current = state;
    if (current is! TeacherProfileLoaded && current is! TeacherProfileUpdated) return;
    final profile = current is TeacherProfileLoaded ? current.profile : (current as TeacherProfileUpdated).profile;
    emit(TeacherProfileUpdating(profile));
    final result = await _updateProfile(name: name, phone: phone, avatarPath: avatarPath);
    result.fold(
      (f) => emit(TeacherProfileError(f.message)),
      (p) => emit(TeacherProfileUpdated(p)),
    );
  }
}
