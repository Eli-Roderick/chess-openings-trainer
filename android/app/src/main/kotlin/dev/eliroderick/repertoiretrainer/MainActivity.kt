package dev.eliroderick.repertoiretrainer

import android.os.Process
import android.os.SystemClock
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Native helpers (docs/plan/10-testing-and-quality.md §6; P06 adds
        // nativeLibraryDir for the engine).
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "rt/native")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // Milliseconds since this process started (API 24+).
                    "processStartElapsedMs" -> result.success(
                        SystemClock.elapsedRealtime() - Process.getStartElapsedRealtime()
                    )
                    else -> result.notImplemented()
                }
            }
    }
}
