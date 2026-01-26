package app.gsmlg.android_shell

import android.content.Context
import android.content.pm.ApplicationInfo
import android.os.Build
import android.util.Log
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
        private const val TAG = "AndroidShellPlugin"
        private const val VERSION = "1.0.1"  // Bumped version for new approach
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

    /**
     * Gets the native library directory which has execute permissions.
     * On modern Android, /data is mounted noexec, but native libs can execute.
     */
    private fun getNativeLibDir(): String {
        val appInfo: ApplicationInfo = context.applicationInfo
        return appInfo.nativeLibraryDir
    }

    private fun initialize(result: Result) {
        try {
            val filesDir = context.filesDir.absolutePath
            val arch = getArchitecture()
            val prefix = "$filesDir/usr"

            // Use native lib dir for executables (has execute permissions)
            val nativeLibDir = getNativeLibDir()
            val binPath = "$prefix/bin"

            Log.d(TAG, "Initializing shell environment")
            Log.d(TAG, "filesDir: $filesDir")
            Log.d(TAG, "nativeLibDir: $nativeLibDir")
            Log.d(TAG, "arch: $arch")

            // Check if already initialized with current version
            val versionFile = File(prefix, ".shell_version")
            if (versionFile.exists() && versionFile.readText().trim() == VERSION) {
                // Already initialized
                Log.d(TAG, "Already initialized with version $VERSION")
                result.success(mapOf(
                    "filesDir" to filesDir,
                    "prefix" to prefix,
                    "binPath" to binPath,
                    "homePath" to "$filesDir/home",
                    "shellPath" to "$binPath/sh",
                    "nativeLibDir" to nativeLibDir,
                    "arch" to arch
                ))
                return
            }

            // Create directories
            File(binPath).mkdirs()
            File("$prefix/etc").mkdirs()
            File("$filesDir/home").mkdirs()
            File("$filesDir/tmp").mkdirs()

            // Extract busybox for current architecture to native lib dir
            val busyboxPath = extractBusyboxToNativeDir(arch, nativeLibDir, binPath)
            Log.d(TAG, "Busybox extracted to: $busyboxPath")

            // Install busybox applets (create symlinks/copies in binPath)
            installBusyboxApplets(busyboxPath, binPath)

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
                "nativeLibDir" to nativeLibDir,
                "arch" to arch
            ))
        } catch (e: Exception) {
            Log.e(TAG, "Failed to initialize shell", e)
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

    /**
     * Extracts busybox to a location with execute permissions.
     * On modern Android, we need to use the native library directory or
     * use a workaround to run the binary.
     *
     * @return The path to the executable busybox binary
     */
    @Throws(IOException::class)
    private fun extractBusyboxToNativeDir(arch: String, nativeLibDir: String, binPath: String): String {
        val assetPath = "shell/$arch/busybox"

        // First, extract to files/usr/bin (for reference and as fallback)
        val binFile = File(binPath, "busybox")
        context.assets.open(assetPath).use { input ->
            FileOutputStream(binFile).use { output ->
                input.copyTo(output)
            }
        }
        binFile.setExecutable(true, false)
        binFile.setReadable(true, false)

        // The native lib dir should already contain our binary if we include it correctly
        // But if it's loaded from assets, we need a workaround

        // On Android 10+, we can try using the linker to load the binary
        // For now, let's use the /system/bin/sh approach with busybox as a fallback

        // Check if the files dir binary is executable
        if (canExecute(binFile.absolutePath)) {
            Log.d(TAG, "Busybox is executable at ${binFile.absolutePath}")
            return binFile.absolutePath
        }

        // If files dir doesn't work, try copying to cache dir (sometimes has exec perms)
        val cacheDir = context.cacheDir
        val cacheBusybox = File(cacheDir, "busybox")
        binFile.copyTo(cacheBusybox, overwrite = true)
        cacheBusybox.setExecutable(true, false)
        cacheBusybox.setReadable(true, false)

        if (canExecute(cacheBusybox.absolutePath)) {
            Log.d(TAG, "Busybox is executable at ${cacheBusybox.absolutePath}")
            return cacheBusybox.absolutePath
        }

        // Last resort: check native lib dir for any existing busybox
        val nativeLibBusybox = File(nativeLibDir, "libbusybox.so")
        if (nativeLibBusybox.exists() && canExecute(nativeLibBusybox.absolutePath)) {
            Log.d(TAG, "Using native lib busybox at ${nativeLibBusybox.absolutePath}")
            return nativeLibBusybox.absolutePath
        }

        // If nothing works, we'll need to use a different approach
        // Use /system/bin/sh as the shell (basic but works)
        Log.w(TAG, "Cannot execute busybox, falling back to /system/bin/sh")
        return "/system/bin/sh"
    }

    /**
     * Tests if a binary can be executed.
     */
    private fun canExecute(path: String): Boolean {
        return try {
            val process = Runtime.getRuntime().exec(arrayOf(path, "--help"))
            val exitCode = process.waitFor()
            Log.d(TAG, "canExecute($path): exitCode=$exitCode")
            true
        } catch (e: Exception) {
            Log.d(TAG, "canExecute($path): failed - ${e.message}")
            false
        }
    }

    @Throws(IOException::class)
    private fun installBusyboxApplets(busyboxPath: String, binPath: String) {
        // If using system shell, skip applet installation
        if (busyboxPath == "/system/bin/sh") {
            Log.d(TAG, "Using system shell, skipping applet installation")
            // Just create a symlink for sh
            val shFile = File("$binPath/sh")
            if (!shFile.exists()) {
                // Create a script that calls /system/bin/sh
                shFile.writeText("#!/system/bin/sh\nexec /system/bin/sh \"\$@\"\n")
                shFile.setExecutable(true, false)
            }
            return
        }

        // Get list of applets by running busybox --list
        Log.d(TAG, "Getting busybox applets from: $busyboxPath")
        val process = Runtime.getRuntime().exec(arrayOf(busyboxPath, "--list"))
        val applets = process.inputStream.bufferedReader().readLines()
            .filter { it.isNotBlank() }

        val exitCode = process.waitFor()
        Log.d(TAG, "busybox --list returned ${applets.size} applets, exitCode=$exitCode")

        // Create wrapper scripts for each applet instead of symlinks
        // This avoids the noexec issue by using the shell to invoke busybox
        for (applet in applets) {
            val appletFile = File("$binPath/$applet")

            // Create a wrapper script
            appletFile.writeText("#!/system/bin/sh\nexec $busyboxPath $applet \"\$@\"\n")
            appletFile.setExecutable(true, false)
        }

        // Ensure 'sh' exists and points to busybox sh
        val shFile = File("$binPath/sh")
        if (!shFile.exists() || !applets.contains("sh")) {
            shFile.writeText("#!/system/bin/sh\nexec $busyboxPath sh \"\$@\"\n")
            shFile.setExecutable(true, false)
        }

        Log.d(TAG, "Installed ${applets.size} applet wrappers")
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
            Log.d(TAG, "Extracted profile to $destFile")
        } catch (e: IOException) {
            Log.w(TAG, "Profile extraction failed (optional): ${e.message}")
            // Profile is optional, ignore if not present
        }
    }
}
