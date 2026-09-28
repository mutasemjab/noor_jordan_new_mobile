import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/external_link.dart';
import '../repositories/external_links_repository.dart';

class GetExternalLinksUseCase {
  final ExternalLinksRepository _repository;
  GetExternalLinksUseCase(this._repository);
  Future<Either<Failure, List<ExternalLink>>> call() => _repository.getExternalLinks();
}
