import 'package:flutter/services.dart';
import 'package:upi_payment_plugin/model/upi_app_model.dart';

class UpiPaymentPlugin {
  static const MethodChannel _channel = MethodChannel('upi_payment_plugin');

  Future<List<UpiAppModel>> getUpiApps() async {
    final List<dynamic>? appsData = await _channel.invokeMethod<List<dynamic>>('getActiveUpiApps');
    if (appsData == null) return [];
    return appsData.map((app) => UpiAppModel.fromMap(Map<String, dynamic>.from(app))).toList();
  }

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
    return await _channel.invokeMethod('createSign', {
      'payeeUpiId': payeeUpiId,
      'payeeName': payeeName,
      'amount': amount.toString(),
      'transactionId': transactionId,
      'transactionNote': transactionNote,
      'merchantCode': merchantCode,
      'link': link,
      'secretKey': secretKey,
    });
  }

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
  }) async {
    return await _channel.invokeMethod('initiateUPIPayment', {
      'payeeUpiId': payeeUpiId,
      'payeeName': payeeName,
      'amount': amount.toString(),
      'transactionId': transactionId,
      'transactionNote': transactionNote,
      'merchantCode': merchantCode,
      'link': link,
      'transactionRefId': transactionRefId,
      'packageName': packageName,
    });
  }
}
