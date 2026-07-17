import '../../domain/entities/contract.dart';

class PaymentModel extends Payment {
  const PaymentModel({
    required super.id,
    required super.amount,
    required super.paymentDate,
    super.notes,
    super.receiptUrl,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
        id: json['id'] as int,
        amount: (json['amount'] as num).toDouble(),
        paymentDate: (json['payment_date'] ?? json['date'] ?? '') as String,
        notes: json['notes'] as String?,
        receiptUrl: json['receipt_url'] as String?,
      );
}

class ContractModel extends Contract {
  const ContractModel({
    required super.totalAmount,
    required super.paidAmount,
    required super.remainingAmount,
    super.startDate,
    super.notes,
    super.contractPdfUrl,
    super.payments,
  });

  factory ContractModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final paymentList = (data['payments'] as List<dynamic>?)
            ?.map((p) => PaymentModel.fromJson(p as Map<String, dynamic>))
            .toList() ??
        [];
    return ContractModel(
      totalAmount: (data['total_amount'] as num? ?? 0).toDouble(),
      paidAmount: (data['paid_amount'] as num? ?? 0).toDouble(),
      remainingAmount: (data['remaining_amount'] as num? ?? 0).toDouble(),
      startDate: data['start_date'] as String?,
      notes: data['notes'] as String?,
      contractPdfUrl: data['contract_pdf'] as String?,
      payments: paymentList,
    );
  }
}
