import Flutter
import UIKit
import ChannelIOFront

public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    ChannelIO.initialize(application)
}

public class SwiftChannelTalkFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "channel_talk", binaryMessenger: registrar.messenger())
    let instance = SwiftChannelTalkFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    registrar.addApplicationDelegate(instance) 
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
      case "boot":
        self.boot(call, result)
      case "sleep":
        self.sleep(call, result)
      case "shutdown":
        self.shutdown(call, result)
      case "showChannelButton":
        self.showChannelButton(call, result)
      case "hideChannelButton":
        self.hideChannelButton(call, result)
      case "showMessenger":
        self.showMessenger(call, result)
      case "hideMessenger":
        self.hideMessenger(call, result)
      case "openChat":
        self.openChat(call, result)
      case "track":
        self.track(call, result)
      case "updateUser":
        self.updateUser(call, result)
      case "initPushToken":
        self.initPushToken(call, result)
      case "isChannelPushNotification":
        self.isChannelPushNotification(call, result)
      case "receivePushNotification":
        self.receivePushNotification(call, result)
      case "storePushNotification":
        self.storePushNotification(call, result)
      case "hasStoredPushNotification":
        self.hasStoredPushNotification(call, result)
      case "openStoredPushNotification":
        self.openStoredPushNotification(call, result)
      case "isBooted":
        self.isBooted(call, result)
      case "setDebugMode":
        self.setDebugMode(call, result)
      case "setPage":
        self.setPage(call, result)
      case "resetPage":
        self.resetPage(call, result)
      default:
        result(FlutterMethodNotImplemented)
    }
  }

  private func boot(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    guard let argMaps = call.arguments as? Dictionary<String, Any>, 
      let pluginKey = argMaps["pluginKey"] as? String else {
      result(FlutterError(code: call.method, message: "Missing argument", details: nil))
      return
    }

    let profile = Profile()
    if let email = argMaps["email"] as? String {
      profile.set(email: email)
    }
    if let name = argMaps["name"] as? String {
      profile.set(name: name)
    }
    if let mobileNumber = argMaps["mobileNumber"] as? String {
      profile.set(mobileNumber: mobileNumber)
    }
    
    let buttonOption = ChannelButtonOption.init(
      position: .left,
      xMargin: 16,
      yMargin: 23
    )

    let memberHash = argMaps["memberHash"] as? String
    let memberId = argMaps["memberId"] as? String
    let trackDefaultEvent = argMaps["trackDefaultEvent"] as? Bool
    let hidePopup = argMaps["hidePopup"] as? Bool

    let language = argMaps["language"] as? String
    var enumLanguage: LanguageOption = LanguageOption.korean
    switch language {
      case "english":
        enumLanguage = LanguageOption.english
      case "korean":
        enumLanguage = LanguageOption.korean
      case "japanese":
        enumLanguage = LanguageOption.japanese
      default:
        enumLanguage = LanguageOption.device
        
    }

    let bootConfig = BootConfig.init(
      pluginKey: pluginKey,
      memberId: memberId,
      memberHash: memberHash,
      profile: profile,
      channelButtonOption: buttonOption,
      hidePopup: hidePopup ?? false,
      trackDefaultEvent: trackDefaultEvent ?? false,
      language: enumLanguage
    )

    ChannelIO.boot(with: bootConfig) { (completion, user) in
      if completion == .success, let _ = user {
        // Success
        result(true)
      } else {
        // Fail
        result(false)

      }
    }
  }

  private func sleep(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    ChannelIO.sleep()
    result(true)
  }

  private func shutdown(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    ChannelIO.shutdown()
    result(true)
  }

  private func showChannelButton(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    ChannelIO.showChannelButton()
    result(true)
  }

  private func hideChannelButton(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    ChannelIO.hideChannelButton()
    result(true)
  }

  private func showMessenger(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    ChannelIO.showMessenger()
    result(true)
  }

  private func hideMessenger(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    ChannelIO.hideMessenger()
    result(true)
  }

  private func openChat(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    guard let argMaps = call.arguments as? Dictionary<String, Any> else {
        result(FlutterError(code: call.method, message: "Missing argument", details: nil))
        return
    }

    let chatId = argMaps["chatId"] as? String
    let message = argMaps["message"] as? String

    ChannelIO.openChat(with: chatId, message: message)
    result(true)
  }

  private func track(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    guard let argMaps = call.arguments as? Dictionary<String, Any>,
      let eventName = argMaps["eventName"] as? String else {
      result(FlutterError(code: call.method, message: "Missing argument", details: nil))
      return
    }
    
    let properties = argMaps["properties"] as? Dictionary<String, Any>

    ChannelIO.track(eventName: eventName, eventProperty: properties)
    result(true)
  }

  private func updateUser(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    if (!ChannelIO.isBooted) {
      result(FlutterError(code: call.method, message: "Channel Talk is not booted", details: nil))
      return
    }
    guard let argMaps = call.arguments as? Dictionary<String, Any> else {
      result(FlutterError(code: call.method, message: "Missing argument", details: nil))
      return
    }

    var profile: [String:Any] = [:]
    if let name = argMaps["name"] {
        profile["name"] = name
    }
    if let mobileNumber = argMaps["mobileNumber"] {
      profile["mobileNumber"] = mobileNumber
    }
    if let email = argMaps["email"] {
      profile["email"] = email
    }
    if let avatarUrl = argMaps["avatarUrl"] {
      profile["avatarUrl"] = avatarUrl
    }        
    if let customAttributes = argMaps["customAttributes"] as? Dictionary<String, Any> {
        for (key, value) in customAttributes {
            profile[key] = value
        }
    }

    let language = argMaps["language"] as? String
    var enumLanguage: LanguageOption = LanguageOption.korean
    switch language {
      case "english":
        enumLanguage = LanguageOption.english
      case "korean":
        enumLanguage = LanguageOption.korean
      case "japanese":
        enumLanguage = LanguageOption.japanese
      default:
        enumLanguage = LanguageOption.device
        
    }
    let tags = argMaps["tags"] as? [String]

    let userData = UpdateUserParamBuilder()
      .with(language: enumLanguage)
      .with(tags: tags)
      .with(profile: profile)
      .build()

    ChannelIO.updateUser(param: userData) { (error, user) in
      if let _ = user, user != nil {
        result(true)
      } else if let error = error {
        NSLog(error.localizedDescription)
        result(FlutterError(code: call.method, message: error.localizedDescription, details: nil))
      }
    }
    
  }

  private func initPushToken(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    guard let argMaps = call.arguments as? Dictionary<String, Any>,
      let deviceToken = argMaps["deviceToken"] as? String else {
      result(FlutterError(code: call.method, message: "Missing argument", details: nil))
      return
    }
    
    ChannelIO.initPushToken(tokenString: deviceToken)
    result(true)
  }

  private func isChannelPushNotification(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    guard let argMaps = call.arguments as? Dictionary<String, Any>,
      let content = argMaps["content"] as? [AnyHashable : Any] else {
      result(FlutterError(code: call.method, message: "Missing argument", details: nil))
      return
    }
    
    let res: Bool = ChannelIO.isChannelPushNotification(content)
    result(Bool(res))
  }

  private func receivePushNotification(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    guard let argMaps = call.arguments as? Dictionary<String, Any>,
      let content = argMaps["content"] as? [AnyHashable : Any] else {
      result(FlutterError(code: call.method, message: "Missing argument", details: nil))
      return
    }
    
    ChannelIO.receivePushNotification(content)
    result(true)
  }

  private func storePushNotification(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    guard let argMaps = call.arguments as? Dictionary<String, Any>,
      let content = argMaps["content"] as? [AnyHashable : Any] else {
      result(FlutterError(code: call.method, message: "Missing argument", details: nil))
      return
    }
    
    ChannelIO.storePushNotification(content)
    result(true)
  }

  private func hasStoredPushNotification(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    let res: Bool = ChannelIO.hasStoredPushNotification()
    result(Bool(res))
  }

  private func openStoredPushNotification(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    ChannelIO.openStoredPushNotification()
    result(true)
  }

  private func isBooted(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    result(Bool(ChannelIO.isBooted))
  }

  private func setDebugMode(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    guard let argMaps = call.arguments as? Dictionary<String, Any>,
      let flag = argMaps["flag"] as? Bool else {
      result(FlutterError(code: call.method, message: "Missing argument", details: nil))
      return
    }
    
    ChannelIO.setDebugMode(with: flag)
    result(true)
  }

  private func setPage(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    guard let argMaps = call.arguments as? Dictionary<String, Any>,
      let page = argMaps["page"] as? String else {
      result(FlutterError(code: call.method, message: "Missing argument", details: nil))
      return
    }
    
    ChannelIO.setPage(page)
    result(true)
  }

  private func resetPage(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    ChannelIO.resetPage()
    result(true)
  }
}
