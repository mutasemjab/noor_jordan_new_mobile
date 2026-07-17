import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/contract.dart';
import '../../domain/repositories/contract_repository.dart';
import '../datasources/contract_remote_datasource.dart';

class ContractRepositoryImpl implements ContractRepository {
  final ContractRemoteDataSource _remote;
  final NetworkInfo _network;

  ContractRepositoryImpl(this._remote, this._network);

  @override
  Future<Either<Failure, Contract>> getContract() async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await _remote.getContract());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
