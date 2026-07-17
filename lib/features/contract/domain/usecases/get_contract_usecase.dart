import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/contract.dart';
import '../repositories/contract_repository.dart';

class GetContractUseCase {
  final ContractRepository _repo;
  GetContractUseCase(this._repo);
  Future<Either<Failure, Contract>> call() => _repo.getContract();
}
