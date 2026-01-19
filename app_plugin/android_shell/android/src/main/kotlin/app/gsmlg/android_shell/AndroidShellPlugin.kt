package app.gsmlg.android_shell

import android.content.Context
import android.os.Build
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File
import java.io.FileOutputStream
import java.io.IOException

class AndroidShellPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    companion object {
        private const val VERSION = "1.0.0"
        private const val CHANNEL_NAME = "app.gsmlg/android_shell"
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initialize" -> initialize(result)
            "getArchitecture" -> result.success(getArchitecture())
            "isInitialized" -> result.success(isInitialized())
            "getVersion" -> result.success(getInstalledVersion())
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun initialize(result: Result) {
        try {
            val filesDir = context.filesDir.absolutePath
            val arch = getArchitecture()
            val prefix = "$filesDir/usr"
            val binPath = "$prefix/bin"

            // Check if already initialized with current version
            val versionFile = File(prefix, ".shell_version")
            if (versionFile.exists() && versionFile.readText().trim() == VERSION) {
                // Already initialized
                result.success(mapOf(
                    "filesDir" to filesDir,
                    "prefix" to prefix,
                    "binPath" to binPath,
                    "homePath" to "$filesDir/home",
                    "shellPath" to "$binPath/sh",
                    "arch" to arch
                ))
                return
            }

            // Create directories
            File(binPath).mkdirs()
            File("$prefix/etc").mkdirs()
            File("$filesDir/home").mkdirs()
            File("$filesDir/tmp").mkdirs()

            // Extract busybox for current architecture
            extractBusybox(arch, binPath)

            // Install busybox applets (create symlinks)
            installBusyboxApplets(binPath)

            // Extract profile
            extractProfile("$prefix/etc")

            // Write version marker
            versionFile.writeText(VERSION)

            result.success(mapOf(
                "filesDir" to filesDir,
                "prefix" to prefix,
                "binPath" to binPath,
                "homePath" to "$filesDir/home",
                "shellPath" to "$binPath/sh",
                "arch" to arch
            ))
        } catch (e: Exception) {
            result.error("INIT_ERROR", "Failed to initialize shell: ${e.message}", null)
        }
    }

    private fun getArchitecture(): String {
        val supportedAbis = Build.SUPPORTED_ABIS
        return when {
            supportedAbis.contains("arm64-v8a") -> "arm64-v8a"
            supportedAbis.contains("armeabi-v7a") -> "armeabi-v7a"
            supportedAbis.contains("x86_64") -> "x86_64"
            supportedAbis.contains("x86") -> "x86"
            else -> "arm64-v8a" // Default fallback
        }
    }

    private fun isInitialized(): Boolean {
        val versionFile = File(context.filesDir, "usr/.shell_version")
        return versionFile.exists() && versionFile.readText().trim() == VERSION
    }

    private fun getInstalledVersion(): String? {
        val versionFile = File(context.filesDir, "usr/.shell_version")
        return if (versionFile.exists()) versionFile.readText().trim() else null
    }

    @Throws(IOException::class)
    private fun extractBusybox(arch: String, binPath: String) {
        val assetPath = "shell/$arch/busybox"
        val destFile = File(binPath, "busybox")

        context.assets.open(assetPath).use { input ->
            FileOutputStream(destFile).use { output ->
                input.copyTo(output)
            }
        }

        // Make executable
        destFile.setExecutable(true, false)
    }

    @Throws(IOException::class)
    private fun installBusyboxApplets(binPath: String) {
        val busyboxPath = "$binPath/busybox"

        // Get list of applets by running busybox --list
        val process = Runtime.getRuntime().exec(arrayOf(busyboxPath, "--list"))
        val applets = process.inputStream.bufferedReader().readLines()
            .filter { it.isNotBlank() }

        process.waitFor()

        // Create symlinks for each applet
        for (applet in applets) {
            val symlinkPath = "$binPath/$applet"
            val symlinkFile = File(symlinkPath)

            // Remove existing file/symlink
            if (symlinkFile.exists()) {
                symlinkFile.delete()
            }

            // Create symlink using ln -s via busybox
            try {
                val linkProcess = Runtime.getRuntime().exec(
                    arrayOf(busyboxPath, "ln", "-sf", busyboxPath, symlinkPath)
                )
                linkProcess.waitFor()
            } catch (e: Exception) {
                // Symlink creation may fail, try copying instead
                File(busyboxPath).copyTo(symlinkFile, overwrite = true)
                symlinkFile.setExecutable(true, false)
            }
        }

        // Ensure 'sh' exists
        val shFile = File("$binPath/sh")
        if (!shFile.exists()) {
            try {
                Runtime.getRuntime().exec(
                    arrayOf(busyboxPath, "ln", "-sf", busyboxPath, "$binPath/sh")
                ).waitFor()
            } catch (e: Exception) {
                File(busyboxPath).copyTo(shFile, overwrite = true)
                shFile.setExecutable(true, false)
            }
        }
    }

    @Throws(IOException::class)
    private fun extractProfile(etcPath: String) {
        try {
            val assetPath = "shell/profile"
            val destFile = File(etcPath, "profile")

            context.assets.open(assetPath).use { input ->
                FileOutputStream(destFile).use { output ->
                    input.copyTo(output)
                }
            }
        } catch (e: IOException) {
            // Profile is optional, ignore if not present
        }
    }
}
