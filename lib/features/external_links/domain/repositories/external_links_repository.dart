import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/external_link.dart';

abstract class ExternalLinksRepository {
  Future<Either<Failure, List<ExternalLink>>> getExternalLinks();
}
