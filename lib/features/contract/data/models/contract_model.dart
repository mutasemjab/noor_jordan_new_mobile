import '../../domain/entities/contract.dart';

class PaymentModel extends Payment {
  const PaymentModel({
    required super.id,
    required super.receiptNumber,
    required super.amount,
    required super.paidAt,
    super.notes,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        receiptNumber: json['receipt_number'] as String? ?? '',
        amount: (json['amount'] as num? ?? 0).toDouble(),
        paidAt: json['paid_at'] as String? ?? '',
        notes: json['notes'] as String?,
      );
}

class ContractModel extends Contract {
  const ContractModel({
    required super.id,
    required super.totalAmount,
    required super.paidAmount,
    required super.remainingAmount,
    super.startDate,
    super.notes,
    super.contractPdfUrl,
    super.payments,
  });

  factory ContractModel.fromJson(Map<String, dynamic> json) {
    final root = json['data'] as Map<String, dynamic>? ?? json;
    final contractJson = root['contract'] as Map<String, dynamic>? ?? {};
    final paymentsList = (root['payments'] as List<dynamic>?)
            ?.map((p) => PaymentModel.fromJson(p as Map<String, dynamic>))
            .toList() ??
        [];
    return ContractModel(
      id: (contractJson['id'] as num?)?.toInt() ?? 0,
      totalAmount: (contractJson['total_amount'] as num? ?? 0).toDouble(),
      paidAmount: (contractJson['paid_amount'] as num? ?? 0).toDouble(),
      remainingAmount: (contractJson['remaining_amount'] as num? ?? 0).toDouble(),
      startDate: contractJson['start_date'] as String?,
      notes: contractJson['notes'] as String?,
      contractPdfUrl: contractJson['contract_pdf'] as String?,
      payments: paymentsList,
    );
  }
}
