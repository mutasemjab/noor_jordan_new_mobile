import 'package:equatable/equatable.dart';
import '../../domain/entities/grade.dart';

abstract class GradesState extends Equatable {
  const GradesState();

  @override
  List<Object?> get props => [];
}

class GradesInitial extends GradesState {
  const GradesInitial();
}

class GradesLoading extends GradesState {
  const GradesLoading();
}

class GradesLoaded extends GradesState {
  final List<SubjectGrades> grades;
  final String? selectedFilter;

  const GradesLoaded({
    required this.grades,
    this.selectedFilter,
  });

  List<SubjectGrades> get filteredGrades {
    if (selectedFilter == null) return grades;
    return grades
        .where((g) => g.subjectId.toString() == selectedFilter)
        .toList();
  }

  GradesLoaded copyWith({
    List<SubjectGrades>? grades,
    Object? selectedFilter = _sentinel,
  }) {
    return GradesLoaded(
      grades: grades ?? this.grades,
      selectedFilter: selectedFilter == _sentinel
          ? this.selectedFilter
          : selectedFilter as String?,
    );
  }

  @override
  List<Object?> get props => [grades, selectedFilter];
}

class GradesError extends GradesState {
  final String message;

  const GradesError(this.message);

  @override
  List<Object?> get props => [message];
}

const Object _sentinel = Object();
