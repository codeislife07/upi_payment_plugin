import 'package:flutter_test/flutter_test.dart';
import 'package:upi_payment_plugin/upi_payment_plugin.dart';
import 'package:upi_payment_plugin/upi_payment_plugin_platform_interface.dart';
import 'package:upi_payment_plugin/upi_payment_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockUpiPaymentPluginPlatform
    with MockPlatformInterfaceMixin
    implements UpiPaymentPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final UpiPaymentPluginPlatform initialPlatform = UpiPaymentPluginPlatform.instance;

  test('$MethodChannelUpiPaymentPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelUpiPaymentPlugin>());
  });

  test('getPlatformVersion', () async {
    UpiPaymentPlugin upiPaymentPlugin = UpiPaymentPlugin();
    MockUpiPaymentPluginPlatform fakePlatform = MockUpiPaymentPluginPlatform();
    UpiPaymentPluginPlatform.instance = fakePlatform;

    expect(await upiPaymentPlugin.getPlatformVersion(), '42');
  });
}
