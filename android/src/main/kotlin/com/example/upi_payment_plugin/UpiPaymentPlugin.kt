package com.example.upi_payment_plugin

import android.app.Activity
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
import io.flutter.plugin.common.PluginRegistry
import java.io.ByteArrayOutputStream

class UpiPaymentPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var pendingResult: MethodChannel.Result? = null
    private val requestCode = 2024

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
        val packageManager = activity?.packageManager ?: return emptyList()

        val intent = Intent(Intent.ACTION_VIEW).apply {
            data = Uri.parse("upi://pay")
        }

        return try {
            val activities = packageManager.queryIntentActivities(intent, PackageManager.MATCH_ALL)
            activities.map {
                val packageName = it.activityInfo.packageName
                val appName = it.loadLabel(packageManager).toString()
                val iconBase64 = getAppIconBase64(packageName, packageManager)

                mapOf(
                    "packageName" to packageName,
                    "appName" to appName,
                    "icon" to iconBase64
                )
            }
        } catch (ex: Exception) {
            emptyList()
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
            data["transactionNote"], data["merchantCode"], data["link"], 
            data["secretKey"]
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
        args["packageName"]?.let { intent.setPackage(it) } // Set specific UPI app if provided

        if (activity?.let { intent.resolveActivity(it.packageManager) } == null) {
            result.success("upi_app_not_found")
            return
        }

        pendingResult = result
        activity?.startActivityForResult(intent, requestCode)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == this.requestCode && pendingResult != null) {
            if (data != null) {
                val response = data.getStringExtra("response") ?: "invalid_response"
                pendingResult?.success(response)
            } else {
                pendingResult?.success("user_cancelled")
            }
            pendingResult = null
            return true
        }
        return false
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
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
