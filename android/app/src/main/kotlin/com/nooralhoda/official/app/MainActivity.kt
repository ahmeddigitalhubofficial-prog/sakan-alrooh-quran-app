package com.nooralhoda.official.app

import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.nooralhoda.official.app/device_ecosystem"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getDeviceEcosystem" -> {
                    val manufacturer = Build.MANUFACTURER?.lowercase() ?: ""
                    val brand = Build.BRAND?.lowercase() ?: ""
                    val isHuawei = manufacturer.contains("huawei") || brand.contains("huawei") ||
                                   manufacturer.contains("honor") || brand.contains("honor")
                    result.success(if (isHuawei) "huawei" else "google")
                }
                else -> result.notImplemented()
            }
        }
    }

    // Catch and suppress late background FlutterJNI detachment race conditions (e.g. ImageReader / CameraX)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        val defaultHandler = Thread.getDefaultUncaughtExceptionHandler()
        Thread.setDefaultUncaughtExceptionHandler { thread, throwable ->
            val message = throwable.message
            if (throwable is RuntimeException &&
                message != null &&
                message.contains("FlutterJNI is not attached to native")) {
                android.util.Log.w("MainActivity", "Suppressed detached FlutterJNI exception in background", throwable)
                return@setDefaultUncaughtExceptionHandler
            }
            defaultHandler?.uncaughtException(thread, throwable)
        }
    }
}
