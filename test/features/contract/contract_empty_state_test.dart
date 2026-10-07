import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor/core/error/failures.dart';
import 'package:noor/features/contract/data/datasources/contract_remote_datasource.dart';
import 'package:noor/features/contract/data/models/contract_model.dart';
import 'package:noor/features/contract/domain/entities/contract.dart';
import 'package:noor/features/contract/domain/repositories/contract_repository.dart';
import 'package:noor/features/contract/domain/usecases/get_contract_usecase.dart';
import 'package:noor/features/contract/presentation/cubit/contract_cubit.dart';
import 'package:noor/features/contract/presentation/cubit/contract_state.dart';

class _EmptyContractRepository implements ContractRepository {
  @override
  Future<Either<Failure, Contract?>> getContract() async => const Right(null);
}

void main() {
  group('empty financial contract', () {
    test('recognizes empty successful API response shapes', () {
      expect(ContractModel.fromResponse(null), isNull);
      expect(ContractModel.fromResponse(<String, dynamic>{}), isNull);
      expect(
        ContractModel.fromResponse(<String, dynamic>{'data': null}),
        isNull,
      );
      expect(
        ContractModel.fromResponse(<String, dynamic>{
          'data': <String, dynamic>{'contract': null},
        }),
        isNull,
      );
      expect(
        ContractModel.fromResponse(<String, dynamic>{
          'data': <String, dynamic>{
            'contract': <String, dynamic>{},
            'payments': <dynamic>[],
          },
        }),
        isNull,
      );
    });

    test('parses an uploaded contract', () {
      final contract = ContractModel.fromResponse(<String, dynamic>{
        'data': <String, dynamic>{
          'contract': <String, dynamic>{
            'id': 12,
            'total_amount': 1000,
            'paid_amount': 400,
            'remaining_amount': 600,
          },
          'payments': <dynamic>[],
        },
      });

      expect(contract, isNotNull);
      expect(contract!.id, 12);
      expect(contract.remainingAmount, 600);
    });

    test('emits a dedicated empty state instead of an error', () async {
      final cubit = ContractCubit(
        GetContractUseCase(_EmptyContractRepository()),
      );

      await cubit.load();

      expect(cubit.state, isA<ContractEmpty>());
      await cubit.close();
    });

    test('treats a 404 from the contract endpoint as empty', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) => handler.reject(
            DioException.badResponse(
              statusCode: 404,
              requestOptions: options,
              response: Response<void>(
                requestOptions: options,
                statusCode: 404,
              ),
            ),
          ),
        ),
      );

      final contract = await ContractRemoteDataSourceImpl(dio).getContract();

      expect(contract, isNull);
    });
  });
}
