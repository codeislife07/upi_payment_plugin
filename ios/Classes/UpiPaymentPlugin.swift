import Flutter
import UIKit

public class UpiPaymentPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "upi_payment_plugin", binaryMessenger: registrar.messenger())
        let instance = UpiPaymentPlugin()
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
                let appIconBase64 = getAppIconBase64(for: scheme)

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
    private func getAppIconBase64(for scheme: String) -> String {
        guard let bundleId = getBundleId(for: scheme),
              let appIcon = getAppIcon(bundleId: bundleId),
              let imageData = appIcon.pngData() else {
            return ""
        }
        return imageData.base64EncodedString()
    }

    /// Gets app icon from bundle
    private func getAppIcon(bundleId: String) -> UIImage? {
        guard let app = UIApplication.shared.delegate as? UIApplicationDelegate,
              let icon = app.value(forKeyPath: "iconsByBundleIdentifier.\(bundleId)") as? UIImage else {
            return nil
        }
        return icon
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
              let amount = args["amount"] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid UPI parameters", details: nil))
            return
        }

        var urlComponents = URLComponents(string: "upi://pay")
        urlComponents?.queryItems = [
            URLQueryItem(name: "pa", value: payeeUpiId),
            URLQueryItem(name: "pn", value: args["payeeName"] ?? ""),
            URLQueryItem(name: "mc", value: args["merchantCode"]),
            URLQueryItem(name: "tid", value: args["transactionId"]),
            URLQueryItem(name: "tr", value: args["transactionRefId"]),
            URLQueryItem(name: "tn", value: args["transactionNote"]),
            URLQueryItem(name: "am", value: amount),
            URLQueryItem(name: "cu", value: "INR"),
            URLQueryItem(name: "url", value: args["link"]),
            URLQueryItem(name: "sign", value: args["sign"])
        ].compactMap { $0 }

        guard let appUrl = urlComponents?.url else {
            result(FlutterError(code: "INVALID_URL", message: "Unable to create UPI URL", details: nil))
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
