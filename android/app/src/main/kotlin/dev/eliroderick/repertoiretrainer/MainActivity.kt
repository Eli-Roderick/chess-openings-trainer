package dev.eliroderick.repertoiretrainer

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Process
import android.os.SystemClock
import android.provider.OpenableColumns
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var intentChannel: MethodChannel? = null

    /** A file this activity was started with, until Dart asks for it. */
    private var pendingFile: Map<String, Any>? = null

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
        // PGN files opened or shared from other apps (P13).
        pendingFile = readFile(intent)
        intentChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "rt/intent",
        ).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "initialFile" -> {
                        result.success(pendingFile)
                        pendingFile = null
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        readFile(intent)?.let { intentChannel?.invokeMethod("fileOpened", it) }
    }

    /** `{name, bytes}` of the file in a VIEW or SEND intent, or null. */
    private fun readFile(intent: Intent?): Map<String, Any>? {
        if (intent == null) return null
        val uri: Uri? = when (intent.action) {
            Intent.ACTION_VIEW -> intent.data
            Intent.ACTION_SEND -> streamOf(intent)
            else -> null
        }
        if (uri == null) {
            // Shared text (a PGN pasted into the share sheet).
            val text = if (intent.action == Intent.ACTION_SEND) {
                intent.getStringExtra(Intent.EXTRA_TEXT)
            } else {
                null
            }
            return text?.let { mapOf("name" to "shared.pgn", "bytes" to it.toByteArray()) }
        }
        return try {
            // Capped far above the import limit: the app still reports
            // E-SIZE for a too-large file without reading all of it.
            val bytes = contentResolver.openInputStream(uri)?.use { input ->
                input.readNBytesCompat(20 * 1024 * 1024 + 1)
            } ?: return null
            mapOf("name" to displayName(uri), "bytes" to bytes)
        } catch (e: Exception) {
            null
        }
    }

    @Suppress("DEPRECATION")
    private fun streamOf(intent: Intent): Uri? =
        if (Build.VERSION.SDK_INT >= 33) {
            intent.getParcelableExtra(Intent.EXTRA_STREAM, Uri::class.java)
        } else {
            intent.getParcelableExtra(Intent.EXTRA_STREAM)
        }

    private fun displayName(uri: Uri): String =
        contentResolver.query(uri, arrayOf(OpenableColumns.DISPLAY_NAME), null, null, null)
            ?.use { c -> if (c.moveToFirst()) c.getString(0) else null }
            ?: uri.lastPathSegment
            ?: "opened.pgn"
}

/** Reads at most [max] bytes (InputStream.readNBytes needs API 33). */
private fun java.io.InputStream.readNBytesCompat(max: Int): ByteArray {
    val out = java.io.ByteArrayOutputStream()
    val buffer = ByteArray(64 * 1024)
    while (out.size() < max) {
        val n = read(buffer, 0, minOf(buffer.size, max - out.size()))
        if (n < 0) break
        out.write(buffer, 0, n)
    }
    return out.toByteArray()
}
