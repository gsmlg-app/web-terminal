import Flutter
import UIKit
import ios_system

public class IosShellPlugin: NSObject, FlutterPlugin {
    private var isInitialized = false
    private var documentsPath: String = ""
    private var tmpPath: String = ""

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
        // Get paths
        let fileManager = FileManager.default

        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            documentsPath = documentsURL.path
        }

        tmpPath = NSTemporaryDirectory()

        // Initialize ios_system
        initializeEnvironment()

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

        // Create pipes for stdout and stderr
        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()

        // Save original file descriptors
        let originalStdout = dup(STDOUT_FILENO)
        let originalStderr = dup(STDERR_FILENO)

        // Redirect stdout and stderr to our pipes
        dup2(stdoutPipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
        dup2(stderrPipe.fileHandleForWriting.fileDescriptor, STDERR_FILENO)

        // Execute the command
        let exitCode = ios_system(command)

        // Flush and close write ends
        fflush(stdout)
        fflush(stderr)
        stdoutPipe.fileHandleForWriting.closeFile()
        stderrPipe.fileHandleForWriting.closeFile()

        // Restore original file descriptors
        dup2(originalStdout, STDOUT_FILENO)
        dup2(originalStderr, STDERR_FILENO)
        close(originalStdout)
        close(originalStderr)

        // Read output
        let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
        let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()

        let stdout = String(data: stdoutData, encoding: .utf8) ?? ""
        let stderr = String(data: stderrData, encoding: .utf8) ?? ""

        result([
            "exitCode": exitCode,
            "stdout": stdout,
            "stderr": stderr
        ])
    }

    private func listCommands(result: @escaping FlutterResult) {
        // Get list of available commands from ios_system
        if let commandsString = commandsAsString() {
            let commands = commandsString
                .components(separatedBy: ", ")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
            result(commands)
        } else {
            result([String]())
        }
    }

    private func isCommandAvailable(command: String, result: @escaping FlutterResult) {
        let available = ios_executable(command) != nil
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
