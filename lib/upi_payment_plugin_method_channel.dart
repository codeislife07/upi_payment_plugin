import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'upi_payment_plugin_platform_interface.dart';

/// An implementation of [UpiPaymentPluginPlatform] that uses method channels.
class MethodChannelUpiPaymentPlugin extends UpiPaymentPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('upi_payment_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
