import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/school_class.dart';
import '../../domain/usecases/get_classes_usecase.dart';
import '../../domain/usecases/get_class_students_usecase.dart';
import 'classes_state.dart';

class ClassesCubit extends Cubit<ClassesState> {
  final GetClassesUseCase _getClasses;
  final GetClassStudentsUseCase _getStudents;

  ClassesCubit(this._getClasses, this._getStudents) : super(ClassesInitial());

  Future<void> loadClasses() async {
    emit(ClassesLoading());
    final result = await _getClasses();
    result.fold(
      (f) => emit(ClassesError(f.message)),
      (classes) => emit(ClassesLoaded(classes)),
    );
  }

  Future<void> loadStudents(SchoolClass schoolClass) async {
    emit(ClassStudentsLoading(schoolClass));
    final result = await _getStudents(schoolClass.id);
    result.fold(
      (f) => emit(ClassesError(f.message)),
      (students) => emit(ClassStudentsLoaded(schoolClass, students)),
    );
  }

  void search(String query) {
    final current = state;
    if (current is ClassStudentsLoaded) {
      emit(current.copyWith(searchQuery: query));
    }
  }
}
