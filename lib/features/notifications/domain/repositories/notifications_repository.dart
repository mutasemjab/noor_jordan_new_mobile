import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/app_notification.dart';

abstract class NotificationsRepository {
  Future<Either<Failure, NotificationsData>> getNotifications();
  Future<Either<Failure, void>> markRead(int id);
  Future<Either<Failure, void>> markAllRead();
}
