import Flutter
import UIKit

public class UpiPaymentPlugin: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "upi_payment_plugin", binaryMessenger: registrar.messenger())
        let instance = UpiPaymentPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "initiateUPIPayment" {
            guard let args = call.arguments as? [String: Any],
                  let upiUri = args["upiUri"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing required arguments", details: nil))
                return
            }

            if let url = URL(string: upiUri), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:]) { success in
                    result(success ? "UPI Payment initiated" : "Failed to open UPI app")
                }
            } else {
                result(FlutterError(code: "FAILED_TO_OPEN", message: "Could not open UPI app", details: nil))
            }
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
}
