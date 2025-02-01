package com.example.upi_payment_plugin

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.drawable.BitmapDrawable
import android.net.Uri
import android.util.Base64
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class UpiPaymentPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "upi_payment_plugin")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getActiveUpiApps" -> result.success(getActiveUpiApps())
            "createSign" -> result.success(createSignParameter(call))
            "initiateUPIPayment" -> initiateUPIPayment(call, result)
            else -> result.notImplemented()
        }
    }

    private fun getActiveUpiApps(): List<Map<String, String>> {
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse("upi://pay"))
        val packageManager = activity?.packageManager ?: return (emptyList())

        try {
            val activities =
                packageManager.queryIntentActivities(intent, PackageManager.MATCH_DEFAULT_ONLY)
            val installedApps = activities.map {
                val packageName = it.activityInfo.packageName
                val appName = it.loadLabel(packageManager).toString()
                val iconBase64 = getAppIconBase64(packageName, packageManager)

                mapOf(
                    "packageName" to packageName,
                    "appName" to appName,
                    "icon" to iconBase64,
                    "priority" to it.priority.toString(),
                    "preferredOrder" to it.preferredOrder.toString()
                )
            }

            return (installedApps)
        } catch (ex: Exception) {
//            result.error("getInstalledUpiApps", "Exception occurred", ex.toString())
            return emptyList();
        }
    }



    private fun getAppIconBase64(packageName: String, pm: PackageManager): String {
        return try {
            val drawable = pm.getApplicationIcon(packageName)
            if (drawable is BitmapDrawable) {
                val bitmap = drawable.bitmap
                val stream = ByteArrayOutputStream()
                bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
                Base64.encodeToString(stream.toByteArray(), Base64.NO_WRAP)
            } else {
                ""
            }
        } catch (e: Exception) {
            ""
        }
    }

    private fun createSignParameter(call: MethodCall): String {
        val data = call.arguments as Map<String, String>
        val dataToSign = listOf(
            data["payeeUpiId"], data["payeeName"], data["amount"], data["transactionId"],
            data["transactionNote"], data["merchantCode"], data["link"], data["secretKey"]
        ).joinToString("|") { it ?: "" }

        return Base64.encodeToString(dataToSign.toByteArray(), Base64.NO_WRAP)
    }

    private fun initiateUPIPayment(call: MethodCall, result: MethodChannel.Result) {
        val args = call.arguments as Map<String, String>
        val uri = Uri.parse("upi://pay").buildUpon()
            .appendQueryParameter("pa", args["payeeUpiId"])
            .appendQueryParameter("pn", args["payeeName"])
            .appendQueryParameter("mc", args["merchantCode"])
            .appendQueryParameter("tid", args["transactionId"])
            .appendQueryParameter("tr", args["transactionRefId"])
            .appendQueryParameter("tn", args["transactionNote"])
            .appendQueryParameter("am", args["amount"])
            .appendQueryParameter("cu", "INR")
            .appendQueryParameter("url", args["link"])
            .appendQueryParameter("sign", args["sign"])
            .build()

        val intent = Intent(Intent.ACTION_VIEW, uri)
        args["packageName"]?.let { intent.setPackage(it) } // Only set package if provided

        activity?.startActivityForResult(intent, 1)
        result.success("UPI Payment Initiated")
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
