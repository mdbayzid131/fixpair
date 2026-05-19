package com.fixpair.app

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.app.PictureInPictureParams
import android.util.Rational
import android.os.Build

class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "fixpair/pip"
    private var isCallActive = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "setCallActive" -> {
                    isCallActive = call.argument<Boolean>("isActive") ?: false
                    result.success(true)
                }
                "enterPip" -> {
                    val entered = enterPipMode()
                    result.success(entered)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun enterPipMode(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            try {
                val params = PictureInPictureParams.Builder()
                    .setAspectRatio(Rational(2, 3))
                    .build()
                return enterPictureInPictureMode(params)
            } catch (e: Exception) {
                return false
            }
        }
        return false
    }

    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        if (isCallActive) {
            enterPipMode()
        }
    }
}
