import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/contract.dart';

abstract class ContractRepository {
  Future<Either<Failure, Contract>> getContract();
}
