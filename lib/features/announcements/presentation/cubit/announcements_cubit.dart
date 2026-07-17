import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_announcements_usecase.dart';
import 'announcements_state.dart';

class AnnouncementsCubit extends Cubit<AnnouncementsState> {
  final GetAnnouncementsUseCase _useCase;
  bool _isTeacher = false;

  AnnouncementsCubit(this._useCase) : super(AnnouncementsInitial());

  Future<void> loadAnnouncements({bool isTeacher = false}) async {
    _isTeacher = isTeacher;
    emit(AnnouncementsLoading());
    final result = await _useCase(page: 1, isTeacher: isTeacher);
    result.fold(
      (f) => emit(AnnouncementsError(f.message)),
      (items) => emit(AnnouncementsLoaded(items, hasMore: items.length >= 15, currentPage: 1)),
    );
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! AnnouncementsLoaded || current is AnnouncementsLoadingMore) return;
    if (!current.hasMore) return;
    emit(AnnouncementsLoadingMore(current.items, hasMore: current.hasMore, currentPage: current.currentPage));
    final nextPage = current.currentPage + 1;
    final result = await _useCase(page: nextPage, isTeacher: _isTeacher);
    result.fold(
      (f) => emit(AnnouncementsLoaded(current.items, hasMore: false, currentPage: current.currentPage)),
      (items) => emit(AnnouncementsLoaded([...current.items, ...items],
          hasMore: items.length >= 15, currentPage: nextPage)),
    );
  }
}
