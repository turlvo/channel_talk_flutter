import 'package:channel_talk_flutter/channel_talk_flutter.dart';

/// 샘플 JSON을 공개 API의 타입으로 변환해 선택한 부팅 함수를 실행한다.
///
/// [withStatus]는 상세 상태를 반환하며 [forWeb]은 웹 전용 부팅 함수를 선택한다.
/// 웹 부팅에는 모바일 버튼·말풍선 옵션을 전달할 수 없다.
Future<Object?> runSampleBoot(
  Map<String, dynamic> args, {
  bool withStatus = false,
  bool forWeb = false,
}) async {
  if (forWeb) {
    if (args['channelButtonOption'] != null || args['bubbleOption'] != null) {
      throw UnsupportedError('웹 부팅은 모바일 버튼·말풍선 옵션을 지원하지 않습니다.');
    }
    return _runWebBoot(args);
  }

  final boot = withStatus ? ChannelTalk.bootWithStatus : ChannelTalk.boot;
  return boot(
    pluginKey: args['pluginKey'] as String,
    memberId: args['memberId'] as String?,
    memberHash: args['memberHash'] as String?,
    email: args['email'] as String?,
    name: args['name'] as String?,
    mobileNumber: args['mobileNumber'] as String?,
    avatarUrl: args['avatarUrl'] as String?,
    language:
        _parseEnum(args['language'], Language.values, (value) => value.value),
    unsubscribeEmail: args['unsubscribeEmail'] as bool?,
    unsubscribeTexting: args['unsubscribeTexting'] as bool?,
    trackDefaultEvent: args['trackDefaultEvent'] as bool?,
    hidePopup: args['hidePopup'] as bool?,
    appearance: _parseEnum(
        args['appearance'], Appearance.values, (value) => value.value),
    customAttributes: _parseMap(args['customAttributes']),
    channelButtonOption: _parseChannelButtonOption(args['channelButtonOption']),
    bubbleOption: _parseBubbleOption(args['bubbleOption']),
  );
}

/// 웹 전용 인자까지 포함해 공개 웹 부팅 API에 전달한다.
Future<bool?> _runWebBoot(Map<String, dynamic> args) {
  return ChannelTalk.bootForWeb(
    pluginKey: args['pluginKey'] as String,
    memberId: args['memberId'] as String?,
    memberHash: args['memberHash'] as String?,
    email: args['email'] as String?,
    name: args['name'] as String?,
    mobileNumber: args['mobileNumber'] as String?,
    avatarUrl: args['avatarUrl'] as String?,
    customLauncherSelector: args['customLauncherSelector'] as String?,
    hideChannelButtonOnBoot: args['hideChannelButtonOnBoot'] as bool?,
    zIndex: args['zIndex'] as int?,
    language:
        _parseEnum(args['language'], Language.values, (value) => value.value),
    trackDefaultEvent: args['trackDefaultEvent'] as bool?,
    trackUtmSource: args['trackUtmSource'] as bool?,
    unsubscribeEmail: args['unsubscribeEmail'] as bool?,
    unsubscribeTexting: args['unsubscribeTexting'] as bool?,
    hidePopup: args['hidePopup'] as bool?,
    appearance: _parseEnum(
        args['appearance'], Appearance.values, (value) => value.value),
    customAttributes: _parseMap(args['customAttributes']),
  );
}

/// 옵션 객체가 있을 때만 모델 기본값을 적용하고 JSON 숫자를 double로 변환한다.
ChannelButtonOption? _parseChannelButtonOption(Object? value) {
  final options = _parseMap(value);
  if (options == null) return null;

  return ChannelButtonOption(
    icon: _parseEnum(
          options['icon'],
          ChannelButtonIcon.values,
          (value) => value.value,
        ) ??
        ChannelButtonIcon.channel,
    position: _parseEnum(
          options['position'],
          ChannelButtonPosition.values,
          (value) => value.value,
        ) ??
        ChannelButtonPosition.right,
    xMargin: _parseMargin(options['xMargin']) ?? 20.0,
    yMargin: _parseMargin(options['yMargin']) ?? 20.0,
  );
}

/// 말풍선의 여백 생략과 명시적인 0을 구분해 SDK 기본 동작을 유지한다.
BubbleOption? _parseBubbleOption(Object? value) {
  final options = _parseMap(value);
  if (options == null) return null;

  return BubbleOption(
    position: _parseEnum(
          options['position'],
          BubblePosition.values,
          (value) => value.value,
        ) ??
        BubblePosition.top,
    yMargin: _parseMargin(options['yMargin']),
  );
}

/// 문자열 키를 확인하면서 커스텀 속성의 null과 중첩 값을 그대로 보존한다.
Map<String, dynamic>? _parseMap(Object? value) {
  if (value == null) return null;
  if (value is! Map || value.keys.any((key) => key is! String)) {
    throw const FormatException('객체 형식의 옵션이 필요합니다.');
  }
  return Map<String, dynamic>.from(value);
}

/// enum의 공개 채널 값과 정확히 일치하는 항목을 찾고 오타는 오류로 알린다.
T? _parseEnum<T>(
  Object? value,
  List<T> values,
  String Function(T) wireValue,
) {
  if (value == null) return null;
  for (final candidate in values) {
    if (wireValue(candidate) == value) return candidate;
  }
  throw const FormatException('지원하지 않는 옵션 값입니다.');
}

/// JSON 정수와 소수를 모두 허용하되 레이아웃으로 표현할 수 없는 숫자는 거부한다.
double? _parseMargin(Object? value) {
  if (value == null) return null;
  if (value is! num || !value.isFinite) {
    throw const FormatException('유한한 숫자 여백이 필요합니다.');
  }
  return value.toDouble();
}
