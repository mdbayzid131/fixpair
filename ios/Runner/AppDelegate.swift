import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var wasScreenLocked = false

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(protectedDataUnavailable),
      name: UIApplication.protectedDataWillBecomeUnavailableNotification,
      object: nil
    )
    
    // Clear badge count on app launch
    clearBadge()
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
    // Clear badge count whenever user opens/switches to the app
    clearBadge()
  }

  private func clearBadge() {
    UIApplication.shared.applicationIconBadgeNumber = 0
    if #available(iOS 16.0, *) {
      UNUserNotificationCenter.current().setBadgeCount(0, withCompletionHandler: nil)
    }
  }

  @objc private func protectedDataUnavailable() {
    wasScreenLocked = true
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let lockChannel = FlutterMethodChannel(name: "com.fixpair.app/device_lock", binaryMessenger: engineBridge.applicationRegistrar.messenger())
    lockChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      if call.method == "isDeviceLocked" {
        let isLocked = !(UIApplication.shared.isProtectedDataAvailable) || (self?.wasScreenLocked ?? false)
        self?.wasScreenLocked = false
        result(isLocked)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    let badgeChannel = FlutterMethodChannel(name: "com.fixpair.app/badge", binaryMessenger: engineBridge.applicationRegistrar.messenger())
    badgeChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      if call.method == "clearBadge" {
        self?.clearBadge()
        result(true)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
