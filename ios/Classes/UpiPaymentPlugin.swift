import Flutter
import UIKit

public class SwiftUpiPaymentPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "upi_payment_plugin", binaryMessenger: registrar.messenger())
        let instance = SwiftUpiPaymentPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getActiveUpiApps":
            result(getActiveUpiApps())
        case "createSign":
            result(createSignParameter(call))
        case "initiateUPIPayment":
            initiateUPIPayment(call, result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    /// Get installed UPI apps with name, package, and icon
    private func getActiveUpiApps() -> [[String: String]] {
        let upiSchemes = [
            "phonepe://", "tez://", "gpay://", "paytm://", "bhim://",
            "upi://pay", "ybl://", "amazon://", "freecharge://"
        ]

        var upiApps: [[String: String]] = []
        for scheme in upiSchemes {
            if let url = URL(string: scheme), UIApplication.shared.canOpenURL(url) {
                let appName = getAppName(from: scheme)
                let appIconBase64 = getAppIconBase64(from: scheme)

                upiApps.append([
                    "packageName": scheme,
                    "appName": appName,
                    "icon": appIconBase64
                ])
            }
        }
        return upiApps
    }

    /// Extracts app name based on URL scheme
    private func getAppName(from scheme: String) -> String {
        let appNames: [String: String] = [
            "phonepe://": "PhonePe",
            "tez://": "Google Pay",
            "gpay://": "Google Pay",
            "paytm://": "Paytm",
            "bhim://": "BHIM",
            "upi://pay": "UPI App",
            "ybl://": "Yes Bank",
            "amazon://": "Amazon Pay",
            "freecharge://": "FreeCharge"
        ]
        return appNames[scheme] ?? "Unknown UPI App"
    }

    /// Converts app icon to Base64 string
    private func getAppIconBase64(from scheme: String) -> String {
        guard let bundleId = getBundleId(for: scheme),
              let appIcon = UIImage(named: bundleId)?.pngData() else {
            return ""
        }
        return appIcon.base64EncodedString()
    }

    /// Gets bundle identifier for UPI apps
    private func getBundleId(for scheme: String) -> String? {
        let bundleIds: [String: String] = [
            "phonepe://": "com.phonepe.app",
            "tez://": "com.google.android.apps.nbu.paisa.user",
            "gpay://": "com.google.android.apps.nbu.paisa.user",
            "paytm://": "net.one97.paytm",
            "bhim://": "in.org.npci.upiapp",
            "upi://pay": "in.org.npci.upiapp",
            "ybl://": "com.yesbank.upi",
            "amazon://": "in.amazon.mShop.android.shopping",
            "freecharge://": "com.freecharge.android"
        ]
        return bundleIds[scheme]
    }

    /// Creates a signed transaction string in Base64 format
    private func createSignParameter(_ call: FlutterMethodCall) -> String {
        guard let args = call.arguments as? [String: String] else { return "" }
        let data = [
            args["payeeUpiId"] ?? "",
            args["payeeName"] ?? "",
            args["amount"] ?? "",
            args["transactionId"] ?? "",
            args["transactionNote"] ?? "",
            args["merchantCode"] ?? "",
            args["link"] ?? "",
            args["secretKey"] ?? ""
        ].joined(separator: "|")

        return Data(data.utf8).base64EncodedString()
    }

    /// Initiates a UPI payment in the selected app
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
