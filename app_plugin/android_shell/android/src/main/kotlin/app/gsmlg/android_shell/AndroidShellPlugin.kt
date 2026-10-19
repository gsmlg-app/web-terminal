package app.gsmlg.android_shell

import android.content.Context
import android.content.pm.ApplicationInfo
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.util.concurrent.Executors

class AndroidShellPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private val executor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

    companion object {
        private const val TAG = "AndroidShellPlugin"
        private const val VERSION = "2.0.0"  // PRoot + Alpine Linux Rootfs
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

    private fun getNativeLibDir(): String {
        val appInfo: ApplicationInfo = context.applicationInfo
        return appInfo.nativeLibraryDir
    }

    private fun getArchitecture(): String {
        val supportedAbis = Build.SUPPORTED_ABIS
        return when {
            supportedAbis.contains("arm64-v8a") -> "arm64-v8a"
            supportedAbis.contains("x86_64") -> "x86_64"
            supportedAbis.contains("armeabi-v7a") -> "armeabi-v7a"
            supportedAbis.contains("x86") -> "x86"
            else -> "arm64-v8a"
        }
    }

    private fun isInitialized(): Boolean {
        val versionFile = File(context.filesDir, "rootfs/.rootfs_version")
        val prootBin = File(getNativeLibDir(), "libproot.so")
        return versionFile.exists() && versionFile.readText().trim() == VERSION && prootBin.exists()
    }

    private fun getInstalledVersion(): String? {
        val versionFile = File(context.filesDir, "rootfs/.rootfs_version")
        return if (versionFile.exists()) versionFile.readText().trim() else null
    }

    private fun initialize(result: Result) {
        executor.execute {
            try {
                val filesDir = context.filesDir.absolutePath
                val arch = getArchitecture()
                val rootfsDir = File(filesDir, "rootfs")
                val tmpDir = File(filesDir, "tmp")
                val nativeLibDir = getNativeLibDir()
                val prootBin = File(nativeLibDir, "libproot.so")

                Log.d(TAG, "Initializing PRoot + Alpine Linux shell environment")
                Log.d(TAG, "filesDir: $filesDir")
                Log.d(TAG, "nativeLibDir: $nativeLibDir")
                Log.d(TAG, "arch: $arch")

                val versionFile = File(rootfsDir, ".rootfs_version")
                if (versionFile.exists() && versionFile.readText().trim() == VERSION && prootBin.exists()) {
                    Log.d(TAG, "Already initialized with version $VERSION")
                    mainHandler.post {
                        result.success(buildResultMap(filesDir, rootfsDir, nativeLibDir, prootBin, tmpDir, arch))
                    }
                    return@execute
                }

                rootfsDir.mkdirs()
                tmpDir.mkdirs()

                // Extract Alpine Linux minirootfs from assets
                val assetPath = "shell/$arch/rootfs.tar.gz"
                Log.d(TAG, "Extracting rootfs from asset: $assetPath")

                context.assets.open(assetPath).use { assetStream ->
                    TarExtractor.extractGzipTar(
                        inputStream = assetStream,
                        targetDir = rootfsDir
                    )
                }

                // Apply essential rootfs configurations
                configureRootfs(rootfsDir)

                // Write version marker
                versionFile.writeText(VERSION)
                Log.d(TAG, "Rootfs extraction and configuration completed successfully")

                mainHandler.post {
                    result.success(buildResultMap(filesDir, rootfsDir, nativeLibDir, prootBin, tmpDir, arch))
                }
            } catch (e: Exception) {
                Log.e(TAG, "Failed to initialize shell environment", e)
                mainHandler.post {
                    result.error("INIT_ERROR", "Failed to initialize rootfs: ${e.message}", null)
                }
            }
        }
    }

    private fun buildResultMap(
        filesDir: String,
        rootfsDir: File,
        nativeLibDir: String,
        prootBin: File,
        tmpDir: File,
        arch: String
    ): Map<String, String> {
        return mapOf(
            "filesDir" to filesDir,
            "rootfsPath" to rootfsDir.absolutePath,
            "nativeLibDir" to nativeLibDir,
            "prootPath" to prootBin.absolutePath,
            "loaderPath" to File(nativeLibDir, "libloader.so").absolutePath,
            "loader32Path" to File(nativeLibDir, "libloader32.so").absolutePath,
            "tmpPath" to tmpDir.absolutePath,
            "homePath" to File(rootfsDir, "root").absolutePath,
            "arch" to arch
        )
    }

    private fun configureRootfs(rootfsDir: File) {
        val etcDir = File(rootfsDir, "etc").apply { mkdirs() }
        val rootDir = File(rootfsDir, "root").apply { mkdirs() }

        // 1. DNS resolver
        val resolvFile = File(etcDir, "resolv.conf")
        resolvFile.writeText("nameserver 8.8.8.8\nnameserver 1.1.1.1\n")

        // 2. Hosts
        val hostsFile = File(etcDir, "hosts")
        if (!hostsFile.exists()) {
            hostsFile.writeText("127.0.0.1 localhost\n::1 localhost\n")
        }

        // 3. Setup user profile
        val profileContent = """
            # Default profile for Web Terminal
            export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
            export HOME=/root
            export USER=root
            export TERM=xterm-256color
            export PS1='\[\033[01;32m\]\u@android\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]# '
            alias ll='ls -la'
            alias l='ls -lah'

        """.trimIndent() + "\n"

        val userProfile = File(rootDir, ".profile")
        if (!userProfile.exists()) {
            userProfile.writeText(profileContent)
        }

        // 4. Extract bundled custom profile if present
        try {
            val customProfile = context.assets.open("shell/profile").bufferedReader().use { it.readText() }
            val profileD = File(etcDir, "profile.d").apply { mkdirs() }
            File(profileD, "web_terminal.sh").writeText(customProfile)
        } catch (e: IOException) {
            // Optional custom profile
        }
    }
}
