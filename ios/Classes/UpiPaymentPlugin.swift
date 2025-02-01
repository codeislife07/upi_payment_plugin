import Flutter
import UIKit

public class SwiftUpiPaymentPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "upi_payment_plugin", binaryMessenger: registrar.messenger())
        let instance = SwiftUpiPaymentPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "getActiveUpiApps" {
            result(getActiveUpiApps())
        } else if call.method == "createSign" {
            result(createSignParameter(call))
        } else if call.method == "initiateUPIPayment" {
            initiateUPIPayment(call, result)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

    private func getActiveUpiApps() -> [String] {
        let schemes = ["upi://pay", "googlepay://", "phonepe://"]
        return schemes.filter { scheme in
            if let url = URL(string: scheme) {
                return UIApplication.shared.canOpenURL(url)
            }
            return false
        }
    }

    private func createSignParameter(_ call: FlutterMethodCall) -> String {
        guard let args = call.arguments as? [String: String] else { return "" }
        let data = "\(args["payeeUpiId"] ?? "")|\(args["payeeName"] ?? "")|\(args["amount"] ?? "")|\(args["transactionId"] ?? "")|\(args["transactionNote"] ?? "")|\(args["merchantCode"] ?? "")|\(args["link"] ?? "")|\(args["secretKey"] ?? "")"
        
        let hash = data.data(using: .utf8)?.base64EncodedString() ?? ""
        return hash
    }

    private func initiateUPIPayment(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: String],
              let payeeUpiId = args["payeeUpiId"],
              let amount = args["amount"],
              let appUrl = URL(string: "upi://pay?pa=\(payeeUpiId)&pn=\(args["payeeName"] ?? "")&am=\(amount)&cu=INR&tn=\(args["transactionNote"] ?? "")") else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid UPI parameters", details: nil))
            return
        }

        DispatchQueue.main.async {
            if UIApplication.shared.canOpenURL(appUrl) {
                UIApplication.shared.open(appUrl, options: [:], completionHandler: nil)
                result("UPI Payment Initiated")
            } else {
                result(FlutterError(code: "NO_UPI_APP", message: "No UPI app found", details: nil))
            }
        }
    }
}
