import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'upi_payment_plugin_method_channel.dart';

abstract class UpiPaymentPluginPlatform extends PlatformInterface {
  /// Constructs a UpiPaymentPluginPlatform.
  UpiPaymentPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static UpiPaymentPluginPlatform _instance = MethodChannelUpiPaymentPlugin();

  /// The default instance of [UpiPaymentPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelUpiPaymentPlugin].
  static UpiPaymentPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [UpiPaymentPluginPlatform] when
  /// they register themselves.
  static set instance(UpiPaymentPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
