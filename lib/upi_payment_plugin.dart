import 'package:flutter/services.dart';

class UpiPaymentPlugin {
  static const MethodChannel _channel = MethodChannel('upi_payment_plugin');

  static Future<String?> initiateUPIPayment({
    required String packageName,
    required String merchantUPI,
    required String merchantName,
    required String transactionId,
    required String orderId,
    required String note,
    required String amount,
    required String currency,
  }) async {
    String upiUri =
        "upi://pay?pa=$merchantUPI&pn=$merchantName&tid=$transactionId&tr=$orderId&tn=$note&am=$amount&cu=$currency";

    final String? result = await _channel.invokeMethod('initiateUPIPayment', {
      "packageName": packageName,
      "upiUri": upiUri,
    });

    return result;
  }
}
