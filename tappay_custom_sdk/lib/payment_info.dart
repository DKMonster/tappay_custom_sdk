class PaymentInfo {
  final String amount;
  final String currency;
  final String orderNumber;

  PaymentInfo({
    required this.amount,
    required this.currency,
    required this.orderNumber,
  });

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'currency': currency,
        'orderNumber': orderNumber,
      };
}

class PaymentResult {
  final bool success;
  final String? message;
  final String? transactionId;
  final Map<String, dynamic>? data;

  PaymentResult({
    required this.success,
    this.message,
    this.transactionId,
    this.data,
  });

  factory PaymentResult.fromJson(Map<String, dynamic> json) {
    return PaymentResult(
      success: json['success'] as bool,
      message: json['message'] as String?,
      transactionId: json['transactionId'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}
