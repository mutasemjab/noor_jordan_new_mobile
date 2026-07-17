import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_teacher_home_usecase.dart';
import 'teacher_home_state.dart';

class TeacherHomeCubit extends Cubit<TeacherHomeState> {
  final GetTeacherHomeUseCase _getHome;

  TeacherHomeCubit(this._getHome) : super(const TeacherHomeInitial());

  Future<void> load() async {
    emit(const TeacherHomeLoading());
    await _fetch();
  }

  Future<void> refresh() async => _fetch();

  Future<void> _fetch() async {
    final result = await _getHome();
    result.fold(
      (failure) => emit(TeacherHomeError(failure.message)),
      (data) => emit(TeacherHomeLoaded(data)),
    );
  }
}
