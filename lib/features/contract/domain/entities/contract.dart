import 'package:equatable/equatable.dart';

class Payment extends Equatable {
  final int id;
  final String receiptNumber;
  final double amount;
  final String paidAt;
  final String? notes;

  const Payment({
    required this.id,
    required this.receiptNumber,
    required this.amount,
    required this.paidAt,
    this.notes,
  });

  @override
  List<Object?> get props => [id, receiptNumber, amount, paidAt, notes];
}

class Contract extends Equatable {
  final int id;
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final String? startDate;
  final String? notes;
  final String? contractPdfUrl;
  final List<Payment> payments;

  const Contract({
    required this.id,
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    this.startDate,
    this.notes,
    this.contractPdfUrl,
    this.payments = const [],
  });

  @override
  List<Object?> get props => [
        id,
        totalAmount,
        paidAmount,
        remainingAmount,
        startDate,
        notes,
        contractPdfUrl,
        payments,
      ];
}
