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
    final data = json['data'];
    final root = data is Map<String, dynamic> ? data : json;
    final contract = root['contract'];
    final contractJson = contract is Map<String, dynamic> ? contract : root;
    final paymentsList = (root['payments'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(PaymentModel.fromJson)
            .toList() ??
        [];
    return ContractModel(
      id: (contractJson['id'] as num?)?.toInt() ?? 0,
      totalAmount: (contractJson['total_amount'] as num? ?? 0).toDouble(),
      paidAmount: (contractJson['paid_amount'] as num? ?? 0).toDouble(),
      remainingAmount:
          (contractJson['remaining_amount'] as num? ?? 0).toDouble(),
      startDate: contractJson['start_date'] as String?,
      notes: contractJson['notes'] as String?,
      contractPdfUrl: contractJson['contract_pdf'] as String?,
      payments: paymentsList,
    );
  }

  /// Parses the different successful response shapes returned by the API.
  /// A missing/null contract is a valid empty state, not a parsing failure.
  static ContractModel? fromResponse(Object? responseData) {
    if (responseData is! Map<String, dynamic> || responseData.isEmpty) {
      return null;
    }

    final data = responseData['data'];
    if (responseData.containsKey('data') && data == null) return null;

    final root = data is Map<String, dynamic> ? data : responseData;
    final contract = root['contract'];
    if (root.containsKey('contract') && contract == null) return null;

    final contractJson = contract is Map<String, dynamic> ? contract : root;
    if (contractJson.isEmpty || contractJson['id'] is! num) return null;

    return ContractModel.fromJson(responseData);
  }
}
