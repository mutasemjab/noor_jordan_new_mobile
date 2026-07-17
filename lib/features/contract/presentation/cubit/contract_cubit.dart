import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_contract_usecase.dart';
import 'contract_state.dart';

class ContractCubit extends Cubit<ContractState> {
  final GetContractUseCase _useCase;
  ContractCubit(this._useCase) : super(ContractInitial());

  Future<void> load() async {
    emit(ContractLoading());
    final result = await _useCase();
    result.fold(
      (f) => emit(ContractError(f.message)),
      (contract) => emit(ContractLoaded(contract)),
    );
  }
}
