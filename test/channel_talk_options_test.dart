import 'package:flutter/services.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:channel_talk_flutter/channel_talk_flutter.dart';
import 'package:channel_talk_flutter/channel_talk_flutter_method_channel.dart';
import 'package:channel_talk_flutter/channel_talk_flutter_platform_interface.dart';

/// 공개 옵션이 실제 MethodChannel 코덱을 통과해도 값과 생략 규칙을 유지하는지 확인한다.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('channel_talk_flutter');
  final calls = <MethodCall>[];
  late ChannelTalkFlutterPlatform originalPlatform;

  setUp(() {
    originalPlatform = ChannelTalkFlutterPlatform.instance;
    ChannelTalkFlutterPlatform.instance = MethodChannelChannelTalkFlutter();
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return call.method == 'bootWithStatus' ? 'success' : true;
    });
  });

  tearDown(() {
    ChannelTalkFlutterPlatform.instance = originalPlatform;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  const attributes = <String, dynamic>{
    'name': null,
    'testPreferences': {
      'enabled': false,
      'count': 0,
      'label': '',
      'items': <String>[],
    },
  };
  final bootCalls = <String, Future<Object?> Function()>{
    'boot': () => ChannelTalk.boot(
          pluginKey: 'test-plugin-key',
          name: '테스트 사용자',
          customAttributes: attributes,
        ),
    'bootWithStatus': () => ChannelTalk.bootWithStatus(
          pluginKey: 'test-plugin-key',
          name: '테스트 사용자',
          customAttributes: attributes,
        ),
    'bootForWeb': () => ChannelTalk.bootForWeb(
          pluginKey: 'test-plugin-key',
          name: '테스트 사용자',
          customAttributes: attributes,
        ),
  };

  for (final entry in bootCalls.entries) {
    test('${entry.key}의 커스텀 속성은 null과 중첩 값을 채널까지 보존한다', () async {
      final result = await entry.value();

      expect(result,
          entry.key == 'bootWithStatus' ? ChannelTalkBootStatus.success : true);
      expect(calls, hasLength(1));
      expect(
          calls.single.method, entry.key == 'bootForWeb' ? 'boot' : entry.key);
      expect(calls.single.arguments, {
        'pluginKey': 'test-plugin-key',
        'name': '테스트 사용자',
        'customAttributes': attributes,
      });
    });
  }

  test('두 부팅 API가 같은 모바일 옵션을 네이티브 계약 값으로 전달한다', () async {
    const button = ChannelButtonOption(
      icon: ChannelButtonIcon.chatQuestionFilled,
      position: ChannelButtonPosition.left,
      xMargin: 0,
      yMargin: 12.5,
    );
    const bubble = BubbleOption(position: BubblePosition.bottom, yMargin: 0);

    await ChannelTalk.boot(
      pluginKey: 'test-plugin-key',
      channelButtonOption: button,
      bubbleOption: bubble,
    );
    await ChannelTalk.bootWithStatus(
      pluginKey: 'test-plugin-key',
      channelButtonOption: button,
      bubbleOption: bubble,
    );

    expect(calls.map((call) => call.method), ['boot', 'bootWithStatus']);
    for (final call in calls) {
      expect(call.arguments, {
        'pluginKey': 'test-plugin-key',
        'channelButtonOption': {
          'icon': 'chatQuestionFilled',
          'position': 'left',
          'xMargin': 0.0,
          'yMargin': 12.5,
        },
        'bubbleOption': {'position': 'bottom', 'yMargin': 0.0},
      });
    }
  });

  test('명시한 기본 버튼 옵션과 팝업 여백 생략이 구분된다', () async {
    await ChannelTalk.boot(
      pluginKey: 'test-plugin-key',
      channelButtonOption: const ChannelButtonOption(),
      bubbleOption: const BubbleOption(),
    );

    expect(calls.single.arguments, {
      'pluginKey': 'test-plugin-key',
      'channelButtonOption': {
        'icon': 'channel',
        'position': 'right',
        'xMargin': 20.0,
        'yMargin': 20.0,
      },
      'bubbleOption': {'position': 'top'},
    });
  });

  test('profileOnce는 일반 프로필과 별도로 네이티브에 전달된다', () async {
    await ChannelTalk.updateUser(
      name: '테스트 사용자',
      customAttributes: {'testPlan': 'current'},
      profileOnce: {'testPlan': 'initial', 'testCounter': 0, 'testFlag': false},
    );

    expect(calls.single.method, 'updateUser');
    expect(calls.single.arguments, {
      'name': '테스트 사용자',
      'customAttributes': {'testPlan': 'current'},
      'profileOnce': {
        'testPlan': 'initial',
        'testCounter': 0,
        'testFlag': false
      },
    });
  });

  test('profileOnce의 생략과 명시한 빈 Map 및 null 값을 구분한다', () async {
    await ChannelTalk.updateUser();
    await ChannelTalk.updateUser(profileOnce: {});
    await ChannelTalk.updateUser(profileOnce: {'testField': null});

    expect(calls.map((call) => call.arguments), [
      <String, dynamic>{},
      {'profileOnce': <String, dynamic>{}},
      {
        'profileOnce': {'testField': null}
      },
    ]);
  });

  test('NaN과 무한대 여백은 네이티브를 호출하기 전에 거절한다', () {
    for (final margin in [
      double.nan,
      double.infinity,
      double.negativeInfinity
    ]) {
      expect(
        () => ChannelTalk.boot(
          pluginKey: 'test-plugin-key',
          channelButtonOption: ChannelButtonOption(xMargin: margin),
        ),
        throwsArgumentError,
      );
      expect(
        () => ChannelTalk.bootWithStatus(
          pluginKey: 'test-plugin-key',
          channelButtonOption: ChannelButtonOption(yMargin: margin),
        ),
        throwsArgumentError,
      );
      expect(
        () => ChannelTalk.boot(
          pluginKey: 'test-plugin-key',
          bubbleOption: BubbleOption(yMargin: margin),
        ),
        throwsArgumentError,
      );
    }
    expect(calls, isEmpty);
  });
}
