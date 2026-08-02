import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/chat_usecases.dart';
import 'teacher_contacts_state.dart';

class TeacherContactsCubit extends Cubit<TeacherContactsState> {
  final GetMyTeachersUseCase _getMyTeachers;

  TeacherContactsCubit(this._getMyTeachers) : super(const TeacherContactsLoading());

  Future<void> load() async {
    emit(const TeacherContactsLoading());
    final result = await _getMyTeachers();
    result.fold(
      (failure) => emit(TeacherContactsError(failure.message)),
      (teachers) => emit(TeacherContactsLoaded(teachers)),
    );
  }
}
