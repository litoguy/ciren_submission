import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    NotificationCenter.default.addObserver(self, selector: #selector(onDidBecomeActive),
                                           name: UIApplication.didBecomeActiveNotification, object: nil)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  @objc private func onDidBecomeActive() {
    applyIconForCurrentAppearance()
  }

  private func applyIconForCurrentAppearance() {
    guard UIApplication.shared.supportsAlternateIcons else { return }
    var style: UIUserInterfaceStyle = .light
    if #available(iOS 13.0, *) {
      if let w = self.window {
        style = w.traitCollection.userInterfaceStyle
      } else {
        style = UIScreen.main.traitCollection.userInterfaceStyle
      }
      if style == .unspecified {
        style = .light
      }
    }
    let desired: String? = (style == .dark) ? "AppIconDark" : nil
    let current = UIApplication.shared.alternateIconName
    if current != desired {
      UIApplication.shared.setAlternateIconName(desired, completionHandler: nil)
    }
  }
}
