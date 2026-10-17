import Cocoa
import FlutterMacOS
import Network

@main
class AppDelegate: FlutterAppDelegate {
  private var localNetworkBrowser: NWBrowser?

  override func applicationDidFinishLaunching(_ notification: Notification) {
    requestLocalNetworkPermission()
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  private func requestLocalNetworkPermission() {
    let parameters = NWParameters()
    parameters.includePeerToPeer = true
    let browser = NWBrowser(
      for: .bonjour(type: "_ssh._tcp", domain: nil),
      using: parameters
    )
    localNetworkBrowser = browser
    browser.stateUpdateHandler = { [weak self] state in
      switch state {
      case .ready, .failed, .cancelled:
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
          self?.localNetworkBrowser?.cancel()
          self?.localNetworkBrowser = nil
        }
      default:
        break
      }
    }
    browser.start(queue: .main)
  }
}

