import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/contract_model.dart';

abstract class ContractRemoteDataSource {
  Future<ContractModel> getContract();
}

class ContractRemoteDataSourceImpl implements ContractRemoteDataSource {
  final Dio _dio;
  ContractRemoteDataSourceImpl(this._dio);

  @override
  Future<ContractModel> getContract() async {
    try {
      final response = await _dio.get(ApiEndpoints.studentContract);
      return ContractModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) throw const NetworkException();
      throw ServerException(e.message ?? 'خطأ في الخادم');
    }
  }
}
