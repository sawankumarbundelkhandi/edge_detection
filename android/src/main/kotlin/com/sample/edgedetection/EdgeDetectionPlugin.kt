package com.sample.edgedetection

import android.app.Activity
import android.content.Intent
import com.sample.edgedetection.scan.ScanActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

class EdgeDetectionPlugin : FlutterPlugin, ActivityAware {
    private var handler: EdgeDetectionHandler? = null
    
    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        handler = EdgeDetectionHandler()
        val channel = MethodChannel(
                binding.binaryMessenger, "edge_detection"
        )
        channel.setMethodCallHandler(handler)
    }
    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {}
    
    override fun onAttachedToActivity(activityPluginBinding: ActivityPluginBinding) {
        handler?.setActivityPluginBinding(activityPluginBinding)
    }
    override fun onDetachedFromActivityForConfigChanges() {}
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}
    override fun onDetachedFromActivity() {}
}

class EdgeDetectionHandler : MethodCallHandler, PluginRegistry.ActivityResultListener {
    private var activityPluginBinding: ActivityPluginBinding? = null
    private var result: Result? = null
    private var methodCall: MethodCall? = null
    
    fun setActivityPluginBinding(activityPluginBinding: ActivityPluginBinding) {
        activityPluginBinding.addActivityResultListener(this)
        this.activityPluginBinding = activityPluginBinding
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when {
            getActivity() == null -> {
                result.error(
                        "no_activity",
                        "edge_detection plugin requires a foreground activity.",
                        null
                )
                return
            }
            call.method.equals("edge_detect") -> {
                openCameraActivity(call, result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }
    
    private fun getActivity(): Activity? {
        return activityPluginBinding?.activity
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == REQUEST_CODE) {
            if (resultCode == Activity.RESULT_OK) {
                if (null != data && null != data.extras) {
                    val filePath = data.extras!!.getString(SCANNED_RESULT)
                    finishWithSuccess(filePath)
                }
            } else if (resultCode == Activity.RESULT_CANCELED) {
                finishWithSuccess(null)
            }
            return true
        }
        return false
    }

    private fun openCameraActivity(call: MethodCall, result: Result) {
        if (!setPendingMethodCallAndResult(call, result)) {
            finishWithAlreadyActiveError()
            return
        }

        val intent = Intent(Intent(getActivity()?.applicationContext, ScanActivity::class.java))
        getActivity()?.startActivityForResult(intent, REQUEST_CODE)
    }

    private fun setPendingMethodCallAndResult(
        methodCall: MethodCall,
        result: Result
    ): Boolean {
        if (this.result != null) {
            return false
        }
        this.methodCall = methodCall
        this.result = result
        return true
    }

    private fun finishWithAlreadyActiveError() {
        finishWithError("already_active", "Edge detection is already active")
    }

    private fun finishWithError(errorCode: String, errorMessage: String) {
        result?.error(errorCode, errorMessage, null)
        clearMethodCallAndResult()
    }

    private fun finishWithSuccess(imagePath: String?) {
        result?.success(imagePath)
        clearMethodCallAndResult()
    }

    private fun clearMethodCallAndResult() {
        methodCall = null
        result = null
    }
}
