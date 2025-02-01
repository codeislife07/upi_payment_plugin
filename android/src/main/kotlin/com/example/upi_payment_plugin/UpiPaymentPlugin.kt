import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

class UpiPaymentPlugin(private val activity: Activity) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getActiveUpiApps" -> result.success(getActiveUpiApps())
            "createSign" -> result.success(createSignParameter(call))
            "initiateUPIPayment" -> initiateUPIPayment(call, result)
            else -> result.notImplemented()
        }
    }

    private fun getActiveUpiApps(): List<String> {
        val pm = activity.packageManager
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse("upi://pay"))
        val apps = pm.queryIntentActivities(intent, 0)
        return apps.map { it.activityInfo.packageName }
    }

    private fun createSignParameter(call: MethodCall): String {
        val data = call.arguments as Map<String, String>
        val payeeUpiId = data["payeeUpiId"] ?: ""
        val payeeName = data["payeeName"] ?: ""
        val amount = data["amount"] ?: ""
        val transactionId = data["transactionId"] ?: ""
        val transactionNote = data["transactionNote"] ?: ""
        val merchantCode = data["merchantCode"] ?: ""
        val link = data["link"] ?: ""
        val secretKey = data["secretKey"] ?: ""

        val dataToSign = "$payeeUpiId|$payeeName|$amount|$transactionId|$transactionNote|$merchantCode|$link|$secretKey"
        return android.util.Base64.encodeToString(dataToSign.toByteArray(), android.util.Base64.NO_WRAP)
    }

    private fun initiateUPIPayment(call: MethodCall, result: MethodChannel.Result) {
        val args = call.arguments as Map<String, String>
        val uri = Uri.parse("upi://pay")
            .buildUpon()
            .appendQueryParameter("pa", args["payeeUpiId"])
            .appendQueryParameter("pn", args["payeeName"])
            .appendQueryParameter("mc", args["merchantCode"])
            .appendQueryParameter("tid", args["transactionId"])
            .appendQueryParameter("tr", args["transactionRefId"])
            .appendQueryParameter("tn", args["transactionNote"])
            .appendQueryParameter("am", args["amount"])
            .appendQueryParameter("cu", "INR")
            .appendQueryParameter("url", args["link"])
            .build()

        val intent = Intent(Intent.ACTION_VIEW, uri)
        intent.setPackage(args["packageName"]) // Launch specific UPI app
        activity.startActivityForResult(intent, 1)
        result.success("UPI Payment Initiated")
    }

    companion object {
        @JvmStatic
        fun registerWith(registrar: PluginRegistry.Registrar) {
            val channel = MethodChannel(registrar.messenger(), "upi_payment_plugin")
            val activity = registrar.activity()
            if (activity == null) {
                //result.error("NULL_ACTIVITY", "Activity is null", null)
                return
            }
            val plugin = UpiPaymentPlugin(activity)

            channel.setMethodCallHandler(plugin)
        }
    }
}
