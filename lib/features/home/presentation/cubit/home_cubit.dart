import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/local_storage.dart';
import '../../domain/usecases/get_student_home_usecase.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetStudentHomeUseCase _getStudentHome;
  final LocalStorage _localStorage;

  HomeCubit({
    required GetStudentHomeUseCase getStudentHome,
    required LocalStorage localStorage,
  })  : _getStudentHome = getStudentHome,
        _localStorage = localStorage,
        super(const HomeInitial());

  Future<void> load() async {
    emit(const HomeLoading());
    await _fetchData();
  }

  Future<void> refresh() async {
    await _fetchData();
  }

  Future<void> _fetchData() async {
    final result = await _getStudentHome();
    result.fold(
      (failure) => emit(HomeError(failure.message)),
      (data) {
        final cachedUpdateTime = _localStorage.getLastUpdateTime(
          AppConstants.cachedHomeKey,
        );
        emit(HomeLoaded(data, cachedUpdateTime: cachedUpdateTime));
      },
    );
  }
}
