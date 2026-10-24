package com.sunnyHayesx.candyCrush

import io.flutter.embedding.android.FlutterActivity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "prismleafvale/privacy")
            .setMethodCallHandler { call, result ->
                if (call.method != "openPrivacyPolicy") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                try {
                    startActivity(Intent(Intent.ACTION_VIEW,
                        Uri.parse("https://sonnyhayesx.github.io/app-privacy-policy/"))
                        .addCategory(Intent.CATEGORY_BROWSABLE))
                    result.success(null)
                } catch (error: ActivityNotFoundException) {
                    result.error("browser_unavailable", "No browser is available", null)
                } catch (error: SecurityException) {
                    result.error("browser_blocked", "Browser launch was blocked", null)
                }
            }
    }
}
