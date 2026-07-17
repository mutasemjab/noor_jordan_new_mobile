import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_read_usecase.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final GetNotificationsUseCase _getNotificationsUseCase;
  final MarkReadUseCase _markReadUseCase;

  NotificationsCubit(this._getNotificationsUseCase, this._markReadUseCase)
      : super(const NotificationsInitial());

  Future<void> load() async {
    emit(const NotificationsLoading());
    final result = await _getNotificationsUseCase();
    result.fold(
      (failure) => emit(NotificationsError(failure.message)),
      (data) => emit(NotificationsLoaded(data)),
    );
  }

  Future<void> markRead(int id) async {
    final current = state;
    if (current is! NotificationsLoaded) return;

    // Optimistic update
    final updatedNotifications = current.data.notifications.map((n) {
      if (n.id == id && !n.isRead) return n.copyWith(isRead: true);
      return n;
    }).toList();

    final wasUnread = current.data.notifications.any((n) => n.id == id && !n.isRead);
    final newUnreadCount = wasUnread
        ? (current.data.unreadCount - 1).clamp(0, current.data.unreadCount)
        : current.data.unreadCount;

    final optimisticData = NotificationsData(
      unreadCount: newUnreadCount,
      notifications: updatedNotifications,
    );
    emit(NotificationsLoaded(optimisticData));

    // API call
    await _markReadUseCase.markRead(id);
  }

  Future<void> markAllRead() async {
    final current = state;
    if (current is! NotificationsLoaded) return;

    // Optimistic update
    final updatedNotifications =
        current.data.notifications.map((n) => n.copyWith(isRead: true)).toList();

    final optimisticData = NotificationsData(
      unreadCount: 0,
      notifications: updatedNotifications,
    );
    emit(NotificationsLoaded(optimisticData));

    // API call
    await _markReadUseCase.markAllRead();
  }
}
