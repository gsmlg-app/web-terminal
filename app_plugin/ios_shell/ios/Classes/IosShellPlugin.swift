import Flutter
import UIKit
import ios_system
import files
import shell
import text
import tar
import awk

// Direct function references to command main functions from external frameworks
@_silgen_name("ls_main") func ls_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("pwd_main") func pwd_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("cat_main") func cat_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("echo_main") func echo_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("mkdir_main") func mkdir_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("touch_main") func touch_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("rm_main") func rm_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("rmdir_main") func rmdir_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("cp_main") func cp_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("mv_main") func mv_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("ln_main") func ln_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("chmod_main") func chmod_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("head_main") func head_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("tail_main") func tail_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("grep_main") func grep_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("wc_main") func wc_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("sort_main") func sort_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("uniq_main") func uniq_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("tr_main") func tr_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("diff_main") func diff_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("sed_main") func sed_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("date_main") func date_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("env_main") func env_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("printenv_main") func printenv_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("uname_main") func uname_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("basename_main") func basename_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("dirname_main") func dirname_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("realpath_main") func realpath_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("find_main") func find_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("xargs_main") func xargs_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("tar_main") func tar_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("awk_main") func awk_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("df_main") func df_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("du_main") func du_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("gzip_main") func gzip_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("less_main") func less_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("stat_main") func stat_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("id_main") func id_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("sleep_main") func sleep_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
@_silgen_name("tee_main") func tee_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32

// Command dispatch function type
typealias CommandMain = (Int32, UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32

public class IosShellPlugin: NSObject, FlutterPlugin {
    private var isInitialized = false
    private var documentsPath: String = ""
    private var tmpPath: String = ""

    // Map of command names to their main functions
    private static let commandMap: [String: CommandMain] = [
        // files framework
        "ls": ls_main,
        "cat": cat_main,
        "cp": cp_main,
        "mv": mv_main,
        "rm": rm_main,
        "mkdir": mkdir_main,
        "rmdir": rmdir_main,
        "touch": touch_main,
        "chmod": chmod_main,
        "ln": ln_main,
        "df": df_main,
        "du": du_main,
        "gzip": gzip_main,
        "gunzip": gzip_main,
        "less": less_main,
        "stat": stat_main,
        // shell framework
        "pwd": pwd_main,
        "echo": echo_main,
        "env": env_main,
        "printenv": printenv_main,
        "date": date_main,
        "uname": uname_main,
        "id": id_main,
        "basename": basename_main,
        "dirname": dirname_main,
        "realpath": realpath_main,
        "find": find_main,
        "xargs": xargs_main,
        "sleep": sleep_main,
        "tee": tee_main,
        // text framework
        "head": head_main,
        "tail": tail_main,
        "grep": grep_main,
        "wc": wc_main,
        "sort": sort_main,
        "uniq": uniq_main,
        "tr": tr_main,
        "diff": diff_main,
        "sed": sed_main,
        // tar framework
        "tar": tar_main,
        // awk framework
        "awk": awk_main,
    ]

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "app.gsmlg/ios_shell",
            binaryMessenger: registrar.messenger()
        )
        let instance = IosShellPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            initialize(result: result)
        case "execute":
            if let args = call.arguments as? [String: Any],
               let command = args["command"] as? String {
                execute(command: command, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing command", details: nil))
            }
        case "listCommands":
            listCommands(result: result)
        case "isCommandAvailable":
            if let args = call.arguments as? [String: Any],
               let command = args["command"] as? String {
                isCommandAvailable(command: command, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing command", details: nil))
            }
        case "isInitialized":
            result(isInitialized)
        case "setCurrentDirectory":
            if let args = call.arguments as? [String: Any],
               let path = args["path"] as? String {
                setCurrentDirectory(path: path, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing path", details: nil))
            }
        case "getCurrentDirectory":
            getCurrentDirectory(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func initialize(result: @escaping FlutterResult) {
        let fileManager = FileManager.default

        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            documentsPath = documentsURL.path
        }

        tmpPath = NSTemporaryDirectory()

        // Load framework symbols into global namespace so ios_system can find them
        let frameworkNames = ["files", "shell", "text", "tar", "awk"]
        for name in frameworkNames {
            if let frameworkBundle = Bundle(identifier: "Nicolas-Holzschuch.\(name)") ??
                                     Bundle(path: Bundle.main.privateFrameworksPath! + "/\(name).framework") {
                let path = frameworkBundle.executablePath!
                let handle = dlopen(path, RTLD_NOW | RTLD_GLOBAL)
                if handle == nil {
                    NSLog("[IosShell] Failed to load \(name): \(String(cString: dlerror()))")
                } else {
                    NSLog("[IosShell] Loaded \(name) framework globally")
                }
            }
        }

        // Enable sideLoading so ios_system reads commandDictionary.plist from main bundle
        sideLoading = true

        // Initialize ios_system - reads commandDictionary.plist from main bundle
        initializeEnvironment()

        NSLog("[IosShell] ios_system initialized with command dictionary")

        // Set the mini root to sandbox the shell
        ios_setMiniRoot(documentsPath)

        // Create bin directory for user scripts
        let binPath = (documentsPath as NSString).appendingPathComponent("bin")
        try? fileManager.createDirectory(atPath: binPath, withIntermediateDirectories: true)

        // Set up environment variables
        setenv("HOME", documentsPath, 1)
        setenv("PATH", "\(binPath):/usr/bin:/bin", 1)
        setenv("TMPDIR", tmpPath, 1)
        setenv("TERM", "xterm-256color", 1)
        setenv("LANG", "en_US.UTF-8", 1)
        setenv("CLICOLOR", "1", 1)

        // Change to home directory
        FileManager.default.changeCurrentDirectoryPath(documentsPath)

        isInitialized = true

        NSLog("[IosShell] Initialized with \(IosShellPlugin.commandMap.count) commands available")

        result([
            "documentsPath": documentsPath,
            "homePath": documentsPath,
            "tmpPath": tmpPath,
            "binPath": binPath,
            "initialized": "true"
        ])
    }

    private func execute(command: String, result: @escaping FlutterResult) {
        guard isInitialized else {
            result(FlutterError(code: "NOT_INITIALIZED", message: "Shell not initialized", details: nil))
            return
        }

        // Parse command
        let trimmed = command.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            result(["exitCode": 0, "stdout": "", "stderr": ""])
            return
        }

        // Create temporary files for stdout and stderr capture
        let stdoutPath = tmpPath + "/ios_shell_stdout_\(ProcessInfo.processInfo.globallyUniqueString)"
        let stderrPath = tmpPath + "/ios_shell_stderr_\(ProcessInfo.processInfo.globallyUniqueString)"

        // Create the files
        FileManager.default.createFile(atPath: stdoutPath, contents: nil)
        FileManager.default.createFile(atPath: stderrPath, contents: nil)

        // Redirect command output using shell redirection
        // This works because ios_system handles redirections internally
        let redirectedCommand = "\(trimmed) > \"\(stdoutPath)\" 2> \"\(stderrPath)\""

        // Execute via ios_system with redirection
        let exitCode = ios_system(redirectedCommand)

        // Read output from temp files
        let stdoutStr = (try? String(contentsOfFile: stdoutPath, encoding: .utf8)) ?? ""
        let stderrStr = (try? String(contentsOfFile: stderrPath, encoding: .utf8)) ?? ""

        // Clean up temp files
        try? FileManager.default.removeItem(atPath: stdoutPath)
        try? FileManager.default.removeItem(atPath: stderrPath)

        result([
            "exitCode": exitCode,
            "stdout": stdoutStr,
            "stderr": stderrStr
        ])
    }

    private func listCommands(result: @escaping FlutterResult) {
        // Return commands from our command map plus ios_system built-ins
        var commands = Array(IosShellPlugin.commandMap.keys)
        commands.append(contentsOf: ["cd", "alias", "unalias", "true", "type", "export", "setenv", "unsetenv"])
        result(commands.sorted())
    }

    private func isCommandAvailable(command: String, result: @escaping FlutterResult) {
        let available = IosShellPlugin.commandMap[command] != nil ||
                       ["cd", "alias", "unalias", "true", "type", "export", "setenv", "unsetenv"].contains(command)
        result(available)
    }

    private func setCurrentDirectory(path: String, result: @escaping FlutterResult) {
        let success = FileManager.default.changeCurrentDirectoryPath(path)
        result(success)
    }

    private func getCurrentDirectory(result: @escaping FlutterResult) {
        let cwd = FileManager.default.currentDirectoryPath
        result(cwd)
    }
}
