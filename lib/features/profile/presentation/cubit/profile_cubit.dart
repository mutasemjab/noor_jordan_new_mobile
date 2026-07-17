import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetProfileUseCase _getProfile;
  final UpdateProfileUseCase _updateProfile;

  ProfileCubit(this._getProfile, this._updateProfile) : super(ProfileInitial());

  Future<void> loadProfile() async {
    emit(ProfileLoading());
    final result = await _getProfile();
    result.fold(
      (f) => emit(ProfileError(f.message)),
      (p) => emit(ProfileLoaded(p)),
    );
  }

  Future<void> updateProfile({required String name, required String phone, String? avatarPath}) async {
    final current = state;
    if (current is! ProfileLoaded && current is! ProfileUpdated) return;
    final profile = current is ProfileLoaded ? current.profile : (current as ProfileUpdated).profile;
    emit(ProfileUpdating(profile));
    final result = await _updateProfile(name: name, phone: phone, avatarPath: avatarPath);
    result.fold(
      (f) => emit(ProfileError(f.message)),
      (p) => emit(ProfileUpdated(p)),
    );
  }
}
