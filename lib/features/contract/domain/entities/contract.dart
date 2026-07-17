import 'package:equatable/equatable.dart';

class Payment extends Equatable {
  final int id;
  final double amount;
  final String paymentDate;
  final String? notes;
  final String? receiptUrl;

  const Payment({
    required this.id,
    required this.amount,
    required this.paymentDate,
    this.notes,
    this.receiptUrl,
  });

  @override
  List<Object?> get props => [id, amount, paymentDate, notes, receiptUrl];
}

class Contract extends Equatable {
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final String? startDate;
  final String? notes;
  final String? contractPdfUrl;
  final List<Payment> payments;

  const Contract({
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    this.startDate,
    this.notes,
    this.contractPdfUrl,
    this.payments = const [],
  });

  @override
  List<Object?> get props => [totalAmount, paidAmount, remainingAmount];
}
