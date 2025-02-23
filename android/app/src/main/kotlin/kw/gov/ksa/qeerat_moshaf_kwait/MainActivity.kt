package kw.gov.ksa.qeerat_moshaf_kwait

import android.util.Log
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : AudioServiceActivity() {
    private val CHANNEL = "kw.gov.qsa.quranapp.kqaplatformchannel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAssetFileContent" -> {
                    Log.d("MainActivity", "getAssetFileContent called")
                    val packageName = call.argument<String>("packageName")
                    val filename = call.argument<String>("filename")
                    Log.d("MainActivity", "packageName: $packageName, filename: $filename")
                    if (packageName != null && filename != null) {
                        val content = getAssetFileContent(packageName, filename)
                        if (content != null) {
                            result.success(content)
                        } else {
                            result.error("UNAVAILABLE", "Asset content not available.", null)
                        }
                    } else {
                        result.error("INVALID_ARGUMENTS", "Package name or filename is null.", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getAssetFileContent(packageName: String?, filename: String): ByteArray? {
        return try {
//            packageName?.let {
//                val packageContext = applicationContext.createPackageContext(it, 0)
//                val assetFilePath = filename
//                Log.d("MainActivity", "Attempting to open asset file: $assetFilePath")
//                packageContext.assets.open(assetFilePath).use { inputStream ->
//                    inputStream.readBytes()
//                }
//            }
            val assetFilePath = filename
            Log.d("MainActivity", "Attempting to open asset file: $assetFilePath")
            assets.open(assetFilePath).use { inputStream ->
                inputStream.readBytes()
            }
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }
}