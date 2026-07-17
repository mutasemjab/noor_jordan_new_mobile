import 'package:equatable/equatable.dart';
import '../../domain/entities/contract.dart';

abstract class ContractState extends Equatable {
  const ContractState();
  @override
  List<Object?> get props => [];
}

class ContractInitial extends ContractState {}
class ContractLoading extends ContractState {}

class ContractLoaded extends ContractState {
  final Contract contract;
  const ContractLoaded(this.contract);
  @override
  List<Object?> get props => [contract];
}

class ContractError extends ContractState {
  final String message;
  const ContractError(this.message);
  @override
  List<Object?> get props => [message];
}
