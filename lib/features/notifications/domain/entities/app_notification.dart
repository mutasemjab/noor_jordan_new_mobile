import 'package:equatable/equatable.dart';

class AppNotification extends Equatable {
  final int id;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final String createdAt;

  /// Extra routing info from the backend (ids etc.); may be null.
  final Map<String, dynamic>? data;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.data,
  });

  AppNotification copyWith({
    int? id,
    String? title,
    String? body,
    String? type,
    bool? isRead,
    String? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      data: data,
    );
  }

  @override
  List<Object?> get props => [id, title, body, type, isRead, createdAt, data];
}

class NotificationsData extends Equatable {
  final int unreadCount;
  final List<AppNotification> notifications;

  const NotificationsData({
    required this.unreadCount,
    required this.notifications,
  });

  @override
  List<Object?> get props => [unreadCount, notifications];
}
