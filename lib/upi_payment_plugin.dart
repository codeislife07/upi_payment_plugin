import 'package:flutter/services.dart';
import 'package:upi_payment_plugin/model/upi_app_model.dart';

class UpiPaymentPlugin {
  static const MethodChannel _channel = MethodChannel('upi_payment_plugin');

  /// Fetches the list of installed UPI apps.
  Future<List<UpiAppModel>> getUpiApps() async {
    try {
      final List<dynamic>? appsData =
          await _channel.invokeMethod<List<dynamic>>('getActiveUpiApps');
      if (appsData == null) return [];
      return appsData
          .map((app) => UpiAppModel.fromMap(Map<String, dynamic>.from(app)))
          .toList();
    } on PlatformException catch (e) {
      print("Error fetching UPI apps: ${e.message}");
      return [];
    }
  }

  /// Generates a signed transaction string in Base64 format.
  static Future<String> createSign({
    required String payeeUpiId,
    required String payeeName,
    required double amount,
    required String transactionId,
    required String transactionNote,
    required String merchantCode,
    required String link,
    required String secretKey,
  }) async {
    try {
      return await _channel.invokeMethod<String>('createSign', {
            'payeeUpiId': payeeUpiId,
            'payeeName': payeeName,
            'amount': amount.toStringAsFixed(2), // Ensures proper decimal format
            'transactionId': transactionId,
            'transactionNote': transactionNote,
            'merchantCode': merchantCode,
            'link': link,
            'secretKey': secretKey,
          }) ??
          '';
    } on PlatformException catch (e) {
      print("Error generating signature: ${e.message}");
      return '';
    }
  }

  /// Initiates a UPI payment with the selected app.
  static Future<String> initiateUPIPayment({
    required String payeeUpiId,
    required String payeeName,
    required double amount,
    required String transactionId,
    required String transactionNote,
    required String merchantCode,
    required String link,
    required String transactionRefId,
    required String packageName,
    required String secretKey,
  }) async {
    try {
      final String sign = await createSign(
        payeeUpiId: payeeUpiId,
        payeeName: payeeName,
        amount: amount,
        transactionId: transactionId,
        transactionNote: transactionNote,
        merchantCode: merchantCode,
        link: link,
        secretKey: secretKey,
      );

      return await _channel.invokeMethod<String>('initiateUPIPayment', {
            'payeeUpiId': payeeUpiId,
            'payeeName': payeeName,
            'amount': amount.toStringAsFixed(2),
            'transactionId': transactionId,
            'transactionNote': transactionNote,
            'merchantCode': merchantCode,
            'link': link,
            'transactionRefId': transactionRefId,
            'packageName': packageName,
            'sign': sign,
          }) ??
          'UPI Payment Failed';
    } on PlatformException catch (e) {
      print("Error initiating UPI Payment: ${e.message}");
      return 'Error: ${e.message}';
    }
  }
}
