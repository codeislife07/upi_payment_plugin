#import "UpiPaymentPlugin.h"
#if __has_include(<flutter_upi_india/flutter_upi_india-Swift.h>)
#import <upi_payment_plugin/upi_payment_plugin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "upi_payment_plugin-Swift.h"
#endif

@implementation UpiPaymentPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [UpiPaymentPlugin registerWithRegistrar:registrar];
}
@end