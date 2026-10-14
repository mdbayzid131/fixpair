import Flutter
import UIKit
import UserNotifications
import PushKit
import CallKit
import AVFAudio
import flutter_callkit_incoming

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate, PKPushRegistryDelegate, CallkitIncomingAppDelegate {
  private var wasScreenLocked = false
  private var voipRegistry: PKPushRegistry?

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

    // ─────────────────────────────────────────────────────────────────────────
    // CRITICAL: Register Flutter plugins HERE, in didFinishLaunchingWithOptions.
    // When iOS wakes the app in the TERMINATED state for a VoIP PushKit push,
    // the Flutter UI engine is NOT started, so didInitializeImplicitFlutterEngine
    // is NEVER called. Without this registration SwiftFlutterCallkitIncomingPlugin
    // .sharedInstance remains nil and showCallkitIncoming silently does nothing,
    // causing iOS to terminate the wake-up without ever ringing.
    // ─────────────────────────────────────────────────────────────────────────
    GeneratedPluginRegistrant.register(with: self)

    // Setup VoIP PushKit registry
    let mainQueue = DispatchQueue.main
    let voip = PKPushRegistry(queue: mainQueue)
    voip.delegate = self
    voip.desiredPushTypes = [PKPushType.voIP]
    self.voipRegistry = voip

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
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

  // MARK: - Flutter Engine & Custom Method Channels
  // NOTE: GeneratedPluginRegistrant is intentionally NOT called here again —
  //       it was already registered above in didFinishLaunchingWithOptions.
  //       This delegate is only used for setting up custom method channels.
  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
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

  // MARK: - UNUserNotificationCenterDelegate (Missed Call Notifications)
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    CallkitNotificationManager.shared.userNotificationCenter(center, willPresent: notification, withCompletionHandler: completionHandler)
    if #available(iOS 14.0, *) {
      completionHandler([.banner, .badge, .sound])
    } else {
      completionHandler([.alert, .badge, .sound])
    }
  }

  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    if response.actionIdentifier == CallkitNotificationManager.CALLBACK_ACTION {
      let data = response.notification.request.content.userInfo as? [String: Any]
      SwiftFlutterCallkitIncomingPlugin.sharedInstance?.sendCallbackEvent(data)
    }
    completionHandler()
  }

  // MARK: - Recent Call History Integration (CallKit from Recents)
  override func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    guard let handleObj = userActivity.handle else {
      return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }
    guard let isVideo = userActivity.isVideo else {
      return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }
    let objData = handleObj.getDecryptHandle()
    let nameCaller = objData["nameCaller"] as? String ?? ""
    let handle = objData["handle"] as? String ?? ""
    let data = flutter_callkit_incoming.Data(id: UUID().uuidString, nameCaller: nameCaller, handle: handle, type: isVideo ? 1 : 0)
    SwiftFlutterCallkitIncomingPlugin.sharedInstance?.startCall(data, fromPushKit: true)
    return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
  }

  // MARK: - PKPushRegistryDelegate (VoIP Push Notifications)
  func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
    let deviceToken = credentials.token.map { String(format: "%02x", $0) }.joined()
    NSLog("[AppDelegate] VoIP token updated: \(deviceToken.prefix(10))...")
    SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP(deviceToken)
    UserDefaults.standard.set(deviceToken, forKey: "flutter.voip_token")
  }

  func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
    SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP("")
    UserDefaults.standard.removeObject(forKey: "flutter.voip_token")
  }

  func pushRegistry(
    _ registry: PKPushRegistry,
    didReceiveIncomingPushWith payload: PKPushPayload,
    for type: PKPushType,
    completion: @escaping () -> Void
  ) {
    guard type == .voIP else {
      completion()
      return
    }

    let dict = payload.dictionaryPayload
    NSLog("[AppDelegate] VoIP push received: \(dict)")

    // ── Resolve Call UUID ──
    var callId = dict["id"] as? String ?? ""
    if UUID(uuidString: callId) == nil {
      callId = UUID().uuidString
    }

    // ── Detect cancellation / rejection ──
    // IMPORTANT: Backend sends `type` as a String for cancel/reject payloads.
    // We check both String and Int forms to be safe.
    let typeFromString = (dict["type"] as? String ?? "").uppercased()
    let isCancelType = typeFromString == "CALL_CANCELLED"
      || typeFromString == "CALL_REJECTED"
      || typeFromString == "CANCEL_CALL"

    if isCancelType {
      NSLog("[AppDelegate] VoIP push is a cancellation/rejection, ending call: \(callId)")
      let cancelData = flutter_callkit_incoming.Data(id: callId, nameCaller: "", handle: "", type: 0)
      SwiftFlutterCallkitIncomingPlugin.sharedInstance?.endCall(cancelData)
      UserDefaults.standard.removeObject(forKey: "flutter.latest_call_payload")
      UserDefaults.standard.set(false, forKey: "flutter.call_accepted_pending")
      completion()
      return
    }

    // ── Build call data ──
    let nameCaller = dict["nameCaller"] as? String ?? "Consultant"
    let handle = dict["handle"] as? String ?? "Video Consultation"
    // `isVideo` can be Bool or Int(1) from the server
    let isVideo: Bool
    if let boolVal = dict["isVideo"] as? Bool {
      isVideo = boolVal
    } else if let intVal = dict["type"] as? Int {
      isVideo = intVal == 1
    } else {
      isVideo = true // default to video
    }

    let data = flutter_callkit_incoming.Data(id: callId, nameCaller: nameCaller, handle: handle, type: isVideo ? 1 : 0)
    data.appName = "Fixpair"
    data.duration = 35000

    // ── Collect extra fields for Dart side ──
    var extraMap: [String: Any] = [:]
    if let extra = dict["extra"] as? [String: Any] {
      extraMap = extra
    } else if let extra = dict["extra"] as? NSDictionary, let swiftDict = extra as? [String: Any] {
      extraMap = swiftDict
    }

    if extraMap["sessionId"] == nil, let sessId = dict["sessionId"] as? String { extraMap["sessionId"] = sessId }
    if extraMap["token"] == nil, let tok = dict["token"] as? String { extraMap["token"] = tok }
    if extraMap["channelName"] == nil, let ch = dict["channelName"] as? String { extraMap["channelName"] = ch }
    if extraMap["callerName"] == nil { extraMap["callerName"] = nameCaller }

    data.extra = NSDictionary(dictionary: extraMap)

    // ── Persist to UserDefaults so Dart can read on cold-start ──
    extraMap["callKitUuid"] = callId
    extraMap["timestamp"] = Int(Date().timeIntervalSince1970 * 1000)
    if let jsonData = try? JSONSerialization.data(withJSONObject: extraMap, options: []),
       let jsonString = String(data: jsonData, encoding: .utf8) {
      UserDefaults.standard.set(jsonString, forKey: "flutter.latest_call_payload")
    }

    // ── Show CallKit incoming call UI ──
    // sharedInstance MUST be non-nil here because we called GeneratedPluginRegistrant
    // in didFinishLaunchingWithOptions. The guard below is a belt-and-suspenders
    // fallback; if it ever fails, we still call completion() to avoid iOS penalising
    // the app for missing the 5-second PushKit deadline.
    guard let plugin = SwiftFlutterCallkitIncomingPlugin.sharedInstance else {
      NSLog("[AppDelegate] CRITICAL: SwiftFlutterCallkitIncomingPlugin.sharedInstance is nil — CallKit will not ring!")
      completion()
      return
    }

    plugin.showCallkitIncoming(data, fromPushKit: true) {
      completion()
    }
  }

  // MARK: - CallkitIncomingAppDelegate (User CallKit Interactions)
  func onAccept(_ call: Call, _ action: CXAnswerCallAction) {
    NSLog("[AppDelegate] Call accepted: \(call.uuid.uuidString)")
    UserDefaults.standard.set(true, forKey: "flutter.call_accepted_pending")
    UserDefaults.standard.set(call.uuid.uuidString, forKey: "flutter.call_accepted_id")
    action.fulfill()
  }

  func onDecline(_ call: Call, _ action: CXEndCallAction) {
    NSLog("[AppDelegate] Call declined: \(call.uuid.uuidString)")
    UserDefaults.standard.set(false, forKey: "flutter.call_accepted_pending")
    action.fulfill()
  }

  func onEnd(_ call: Call, _ action: CXEndCallAction) {
    UserDefaults.standard.set(false, forKey: "flutter.call_accepted_pending")
    action.fulfill()
  }

  func onTimeOut(_ call: Call) {
    NSLog("[AppDelegate] Call timed out: \(call.uuid.uuidString)")
    UserDefaults.standard.set(false, forKey: "flutter.call_accepted_pending")
  }

  func didActivateAudioSession(_ audioSession: AVAudioSession) {}

  func didDeactivateAudioSession(_ audioSession: AVAudioSession) {}

  func providerDidReset() {}
}
