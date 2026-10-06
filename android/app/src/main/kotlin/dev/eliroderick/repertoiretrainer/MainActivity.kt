package dev.eliroderick.repertoiretrainer

import android.os.Process
import android.os.SystemClock
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Native helpers (docs/plan/10-testing-and-quality.md §6,
        // docs/plan/05-engine.md §2).
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "rt/native")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // Milliseconds since this process started (API 24+).
                    "processStartElapsedMs" -> result.success(
                        SystemClock.elapsedRealtime() - Process.getStartElapsedRealtime()
                    )
                    // Where Stockfish is installed (libstockfish.so); the
                    // only app directory Android lets us execute from.
                    "nativeLibraryDir" -> result.success(applicationInfo.nativeLibraryDir)
                    else -> result.notImplemented()
                }
            }
    }
}
