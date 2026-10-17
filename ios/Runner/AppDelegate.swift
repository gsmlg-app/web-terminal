import Flutter
import Network
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var localNetworkBrowser: NWBrowser?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    requestLocalNetworkPermission()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
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

