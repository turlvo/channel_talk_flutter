import CoreFoundation
import Foundation

import ChannelIOFront

/// 네이티브 SDK 호출 전에 잘못된 MethodChannel 인자를 구분한다.
enum ChannelTalkArgumentError: Error {
  case invalidValue
}

/// 기존 버튼 배치를 보존하면서 Flutter의 선택적 부트 설정을 SDK 객체로 변환한다.
struct ChannelTalkBootOptions {
  let customAttributes: [String: Any]?
  let profile: Profile
  let channelButtonOption: ChannelButtonOption
  let bubbleOption: BubbleOption?

  /// 버튼 옵션 전체가 생략된 경우에만 기존 왼쪽 배치를 유지한다.
  init(arguments: [String: Any]) throws {
    customAttributes = try Self.optionalMap(arguments["customAttributes"])
    profile = Self.makeProfile(arguments: arguments, customAttributes: customAttributes)
    channelButtonOption = try Self.buttonOption(arguments["channelButtonOption"])
    bubbleOption = try Self.popupOption(arguments["bubbleOption"])
  }

  /// SDK의 기본 필드와 속성 사전이 충돌하지 않도록 우선순위를 결정한 뒤 한 번 설정한다.
  private static func makeProfile(
    arguments: [String: Any],
    customAttributes: [String: Any]?
  ) -> Profile {
    var values: [String: Any] = [:]
    for key in ["email", "name", "mobileNumber", "avatarUrl"] {
      if let value = arguments[key] as? String { values[key] = value }
    }
    if let customAttributes = customAttributes {
      values.merge(customAttributes) { _, customValue in customValue }
    }
    let profile = Profile()
    for (key, value) in values {
      profile.set(propertyKey: key, value: value as AnyObject)
    }
    return profile
  }

  /// 생략된 사전과 잘못된 값을 구분하고 직렬화할 수 없는 프로필 숫자를 거부한다.
  static func optionalMap(_ value: Any?) throws -> [String: Any]? {
    guard let value = value, !(value is NSNull) else { return nil }
    guard let map = value as? [String: Any] else {
      throw ChannelTalkArgumentError.invalidValue
    }
    try validateFiniteNumbers(map)
    return map
  }

  /// 프로필의 중첩 값도 확인하여 비유한 숫자가 SDK 직렬화까지 전달되지 않게 한다.
  private static func validateFiniteNumbers(_ value: Any) throws {
    if let number = value as? NSNumber, !number.doubleValue.isFinite {
      throw ChannelTalkArgumentError.invalidValue
    }
    if let map = value as? [String: Any] {
      for item in map.values { try validateFiniteNumbers(item) }
    } else if let array = value as? [Any] {
      for item in array { try validateFiniteNumbers(item) }
    }
  }

  /// 제공된 버튼 옵션은 SDK 기본값을 사용하고 생략된 옵션은 기존 배치를 유지한다.
  private static func buttonOption(_ value: Any?) throws -> ChannelButtonOption {
    guard let map = try optionalMap(value) else {
      return ChannelButtonOption(position: .left, xMargin: 16, yMargin: 23)
    }
    guard Set(map.keys).isSubset(of: ["icon", "position", "xMargin", "yMargin"]) else {
      throw ChannelTalkArgumentError.invalidValue
    }
    let icons: [String: ChannelButtonIcon] = [
      "channel": .channel,
      "chatBubbleFilled": .chatBubbleFilled,
      "chatProgressFilled": .chatProgressFilled,
      "chatQuestionFilled": .chatQuestionFilled,
      "chatLightningFilled": .chatLightningFilled,
      "chatBubbleAltFilled": .chatBubbleAltFilled,
      "smsFilled": .smsFilled,
      "commentFilled": .commentFilled,
      "sendForwardFilled": .sendForwardFilled,
      "helpFilled": .helpFilled,
      "chatProgress": .chatProgress,
      "chatQuestion": .chatQuestion,
      "chatBubbleAlt": .chatBubbleAlt,
      "sms": .sms,
      "comment": .comment,
      "sendForward": .sendForward,
      "communication": .communication,
      "headset": .headset,
    ]
    let iconName = try string(map, key: "icon", defaultValue: "channel")
    let positionName = try string(map, key: "position", defaultValue: "right")
    guard let icon = icons[iconName], ["left", "right"].contains(positionName) else {
      throw ChannelTalkArgumentError.invalidValue
    }
    return try ChannelButtonOption(
      icon: icon,
      position: positionName == "left" ? .left : .right,
      xMargin: margin(map, key: "xMargin") ?? 20,
      yMargin: margin(map, key: "yMargin") ?? 20
    )
  }

  /// 팝업 위치만 지정한 경우 여백을 설정하지 않아 SDK 기본값을 보존한다.
  private static func popupOption(_ value: Any?) throws -> BubbleOption? {
    guard let map = try optionalMap(value) else { return nil }
    guard Set(map.keys).isSubset(of: ["position", "yMargin"]) else {
      throw ChannelTalkArgumentError.invalidValue
    }
    let positionName = try string(map, key: "position", defaultValue: "top")
    guard ["top", "bottom"].contains(positionName) else {
      throw ChannelTalkArgumentError.invalidValue
    }
    let position: BubblePosition = positionName == "top" ? .top : .bottom
    if let yMargin = try margin(map, key: "yMargin") {
      return BubbleOption(position: position, yMargin: yMargin)
    }
    return BubbleOption(position: position)
  }

  /// 생략되거나 null인 enum 값에는 기본값을 쓰고 잘못된 타입은 거부한다.
  private static func string(
    _ map: [String: Any],
    key: String,
    defaultValue: String
  ) throws -> String {
    guard let value = map[key], !(value is NSNull) else { return defaultValue }
    guard let text = value as? String else { throw ChannelTalkArgumentError.invalidValue }
    return text
  }

  /// NSNumber로 여백을 변환하며 boolean과 Float 범위를 벗어나는 값을 거부한다.
  private static func margin(
    _ map: [String: Any],
    key: String
  ) throws -> Float? {
    guard let value = map[key], !(value is NSNull) else { return nil }
    guard let number = value as? NSNumber,
      CFGetTypeID(number) != CFBooleanGetTypeID(),
      number.doubleValue.isFinite,
      number.floatValue.isFinite else {
      throw ChannelTalkArgumentError.invalidValue
    }
    return number.floatValue
  }
}
