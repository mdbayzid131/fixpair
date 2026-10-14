import Flutter
import UIKit
import UserNotifications
import PushKit
import CallKit
import AVFAudio
import flutter_callkit_incoming

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate, PKPushRegistryDelegate, CallkitIncomingAppDelegate, CXProviderDelegate {
  private var wasScreenLocked = false
  private var voipRegistry: PKPushRegistry?
  private var callKitProvider: CXProvider?
  private var activeCallUuid: UUID?
  private let callController = CXCallController()

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

    // Register plugins with self if possible (for foreground/normal launch)
    GeneratedPluginRegistrant.register(with: self)

    // Setup VoIP PushKit registry (critical for waking the app on incoming call)
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

  // MARK: - Native CallKit Provider
  private func getCallKitProvider() -> CXProvider {
    if let provider = self.callKitProvider {
      return provider
    }
    let config = CXProviderConfiguration(localizedName: "Fixpair")
    config.supportsVideo = true
    config.maximumCallGroups = 1
    config.maximumCallsPerCallGroup = 1
    config.supportedHandleTypes = [.generic, .phoneNumber, .emailAddress]
    if #available(iOS 11.0, *) {
      config.includesCallsInRecents = false
    }
    let provider = CXProvider(configuration: config)
    provider.setDelegate(self, queue: nil)
    self.callKitProvider = provider
    return provider
  }

  // MARK: - Flutter Engine & Custom Method Channels
  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    // Note: GeneratedPluginRegistrant was already registered in didFinishLaunchingWithOptions.
    // Do NOT call GeneratedPluginRegistrant.register again here, otherwise Flutter throws 'Duplicate plugin key'.

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

    let voipChannel = FlutterMethodChannel(name: "com.fixpair.app/native_voip", binaryMessenger: engineBridge.applicationRegistrar.messenger())
    voipChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      if call.method == "endNativeCall" {
        self?.endActiveNativeCall()
        result(true)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func endActiveNativeCall() {
    guard let activeUuid = self.activeCallUuid else { return }
    let endAction = CXEndCallAction(call: activeUuid)
    let transaction = CXTransaction(action: endAction)
    self.callController.request(transaction) { error in
      if let error = error {
        NSLog("[AppDelegate] Failed to end native CallKit call: \(error.localizedDescription)")
      } else {
        NSLog("[AppDelegate] Successfully ended native CallKit call")
      }
    }
    self.activeCallUuid = nil
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
    UserDefaults.standard.set(deviceToken, forKey: "DevicePushTokenVoIP")
  }

  func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
    SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP("")
    UserDefaults.standard.removeObject(forKey: "flutter.voip_token")
    UserDefaults.standard.removeObject(forKey: "DevicePushTokenVoIP")
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
    var callUuid: UUID
    if let rawId = dict["id"] as? String, let parsed = UUID(uuidString: rawId) {
      callUuid = parsed
    } else {
      callUuid = UUID()
    }
    let callId = callUuid.uuidString

    // ── Detect cancellation / rejection ──
    let typeFromString = (dict["type"] as? String ?? "").uppercased()
    let isCancelType = typeFromString == "CALL_CANCELLED"
      || typeFromString == "CALL_REJECTED"
      || typeFromString == "CANCEL_CALL"

    if isCancelType {
      NSLog("[AppDelegate] VoIP push is a cancellation/rejection, ending call: \(callId)")
      let cancelData = flutter_callkit_incoming.Data(id: callId, nameCaller: "", handle: "", type: 0)
      SwiftFlutterCallkitIncomingPlugin.sharedInstance?.endCall(cancelData)
      self.callKitProvider?.reportCall(with: callUuid, endedAt: Date(), reason: .remoteEnded)
      self.activeCallUuid = nil
      UserDefaults.standard.removeObject(forKey: "flutter.latest_call_payload")
      UserDefaults.standard.set(false, forKey: "flutter.call_accepted_pending")
      completion()
      return
    }

    // ── Build call data ──
    let nameCaller = dict["nameCaller"] as? String ?? "Consultant"
    let handle = dict["handle"] as? String ?? "Video Consultation"
    let isVideo: Bool
    if let boolVal = dict["isVideo"] as? Bool {
      isVideo = boolVal
    } else if let intVal = dict["type"] as? Int {
      isVideo = intVal == 1
    } else {
      isVideo = true
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

    self.activeCallUuid = callUuid

    // ── Show CallKit incoming call UI ──
    if let plugin = SwiftFlutterCallkitIncomingPlugin.sharedInstance {
      NSLog("[AppDelegate] Presenting incoming call via SwiftFlutterCallkitIncomingPlugin")
      plugin.showCallkitIncoming(data, fromPushKit: true) {
        completion()
      }
    } else {
      // ─────────────────────────────────────────────────────────────────────────
      // CRITICAL TERMINATED STATE FALLBACK:
      // When the app is woken in the terminated state by PushKit, Flutter's UI engine
      // has not booted, so SwiftFlutterCallkitIncomingPlugin.sharedInstance is nil.
      // Instead of silently dropping the call, we report directly via native CXProvider.
      // ─────────────────────────────────────────────────────────────────────────
      NSLog("[AppDelegate] SwiftFlutterCallkitIncomingPlugin.sharedInstance is nil. Reporting directly via native CXProvider!")
      let provider = self.getCallKitProvider()
      let callUpdate = CXCallUpdate()
      callUpdate.remoteHandle = CXHandle(type: .generic, value: handle)
      callUpdate.localizedCallerName = nameCaller
      callUpdate.hasVideo = isVideo
      callUpdate.supportsDTMF = false
      callUpdate.supportsHolding = false
      callUpdate.supportsGrouping = false
      callUpdate.supportsUngrouping = false

      provider.reportNewIncomingCall(with: callUuid, update: callUpdate) { error in
        if let error = error {
          NSLog("[AppDelegate] Native CXProvider report error: \(error.localizedDescription)")
        } else {
          NSLog("[AppDelegate] Native CXProvider successfully reported incoming call: \(callId)")
        }
        completion()
      }
    }
  }

  // MARK: - CXProviderDelegate (Native CallKit Delegate)
  func providerDidReset(_ provider: CXProvider) {
    NSLog("[AppDelegate] Native CXProvider reset")
    self.activeCallUuid = nil
  }

  func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
    NSLog("[AppDelegate] Native CXProvider: onAccept for \(action.callUUID.uuidString)")
    UserDefaults.standard.set(true, forKey: "flutter.call_accepted_pending")
    UserDefaults.standard.set(action.callUUID.uuidString, forKey: "flutter.call_accepted_id")
    action.fulfill()
  }

  func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
    NSLog("[AppDelegate] Native CXProvider: onEnd/Decline for \(action.callUUID.uuidString)")
    UserDefaults.standard.set(false, forKey: "flutter.call_accepted_pending")
    UserDefaults.standard.removeObject(forKey: "flutter.latest_call_payload")
    self.activeCallUuid = nil
    action.fulfill()
  }

  func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
    NSLog("[AppDelegate] Native CXProvider: Audio session activated")
  }

  func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
    NSLog("[AppDelegate] Native CXProvider: Audio session deactivated")
  }

  // MARK: - CallkitIncomingAppDelegate (User CallKit Interactions via Plugin)
  func onAccept(_ call: Call, _ action: CXAnswerCallAction) {
    NSLog("[AppDelegate] Plugin Call accepted: \(call.uuid.uuidString)")
    UserDefaults.standard.set(true, forKey: "flutter.call_accepted_pending")
    UserDefaults.standard.set(call.uuid.uuidString, forKey: "flutter.call_accepted_id")
    action.fulfill()
  }

  func onDecline(_ call: Call, _ action: CXEndCallAction) {
    NSLog("[AppDelegate] Plugin Call declined: \(call.uuid.uuidString)")
    UserDefaults.standard.set(false, forKey: "flutter.call_accepted_pending")
    UserDefaults.standard.removeObject(forKey: "flutter.latest_call_payload")
    self.activeCallUuid = nil
    action.fulfill()
  }

  func onEnd(_ call: Call, _ action: CXEndCallAction) {
    NSLog("[AppDelegate] Plugin Call ended: \(call.uuid.uuidString)")
    UserDefaults.standard.set(false, forKey: "flutter.call_accepted_pending")
    UserDefaults.standard.removeObject(forKey: "flutter.latest_call_payload")
    self.activeCallUuid = nil
    action.fulfill()
  }

  func onTimeOut(_ call: Call) {
    NSLog("[AppDelegate] Plugin Call timeout: \(call.uuid.uuidString)")
    UserDefaults.standard.set(false, forKey: "flutter.call_accepted_pending")
    self.activeCallUuid = nil
  }

  func didActivateAudioSession(_ audioSession: AVAudioSession) {
    NSLog("[AppDelegate] Plugin audio session activated")
  }

  func didDeactivateAudioSession(_ audioSession: AVAudioSession) {
    NSLog("[AppDelegate] Plugin audio session deactivated")
  }

  func providerDidReset() {
    NSLog("[AppDelegate] Plugin provider did reset")
    self.activeCallUuid = nil
  }
}

