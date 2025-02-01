import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:upi_payment_plugin/upi_payment_plugin_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelUpiPaymentPlugin platform = MethodChannelUpiPaymentPlugin();
  const MethodChannel channel = MethodChannel('upi_payment_plugin');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
