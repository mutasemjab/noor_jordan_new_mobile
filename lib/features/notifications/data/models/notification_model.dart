import '../../domain/entities/app_notification.dart';

class AppNotificationModel extends AppNotification {
  const AppNotificationModel({
    required super.id,
    required super.title,
    required super.body,
    required super.type,
    required super.isRead,
    required super.createdAt,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      type: json['type'] as String? ?? 'general',
      isRead: (json['is_read'] as bool?) ?? false,
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'is_read': isRead,
      'created_at': createdAt,
    };
  }
}

class NotificationsDataModel extends NotificationsData {
  const NotificationsDataModel({
    required super.unreadCount,
    required super.notifications,
  });

  factory NotificationsDataModel.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    final notifs = dataList
        .map((e) => AppNotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return NotificationsDataModel(
      unreadCount: json['unread_count'] as int? ?? 0,
      notifications: notifs,
    );
  }
}
