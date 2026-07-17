import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/notifications_repository.dart';

class MarkReadUseCase {
  final NotificationsRepository _repository;

  MarkReadUseCase(this._repository);

  Future<Either<Failure, void>> markRead(int id) {
    return _repository.markRead(id);
  }

  Future<Either<Failure, void>> markAllRead() {
    return _repository.markAllRead();
  }
}
