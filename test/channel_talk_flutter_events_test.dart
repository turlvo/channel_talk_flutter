import 'package:flutter/services.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:channel_talk_flutter/channel_talk_flutter_method_channel.dart';
import 'package:channel_talk_flutter/channel_talk_flutter_platform_interface.dart';

/// 네이티브 메시지를 실제 채널 codec으로 보내 이벤트 수신 계약을 검증한다.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const codec = StandardMethodCodec();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late MethodChannelChannelTalkFlutter platform;

  setUp(() {
    platform = MethodChannelChannelTalkFlutter();
  });

  tearDown(() {
    platform.removeListener();
  });

  /// 네이티브 SDK의 채널 요청과 응답을 모사해 private dispatcher 호출을 피한다.
  Future<Object?> sendEvent(String method, [Object? arguments]) async {
    final response = await messenger.handlePlatformMessage(
      platform.methodChannel.name,
      codec.encodeMethodCall(MethodCall(method, arguments)),
      null,
    );
    return response == null ? null : codec.decodeEnvelope(response);
  }

  final eventCases =
      <String, ({ChannelTalkEvent event, Object? arguments, Object? expected})>{
    'onShowMessenger': (
      event: ChannelTalkEvent.onShowMessenger,
      arguments: '',
      expected: <String, Object?>{},
    ),
    'onHideMessenger': (
      event: ChannelTalkEvent.onHideMessenger,
      arguments: null,
      expected: <String, Object?>{},
    ),
    'onChatCreated': (
      event: ChannelTalkEvent.onChatCreated,
      arguments: 'test-chat',
      expected: 'test-chat',
    ),
    'onBadgeChanged': (
      event: ChannelTalkEvent.onBadgeChanged,
      arguments: {'unread': 3, 'alert': 0},
      expected: {'unread': 3, 'alert': 0},
    ),
    'onFollowUpChanged': (
      event: ChannelTalkEvent.onFollowUpChanged,
      arguments: {'name': 'Test user', 'subscribed': false},
      expected: {'name': 'Test user', 'subscribed': false},
    ),
    'onUrlClicked': (
      event: ChannelTalkEvent.onUrlClicked,
      arguments: 'https://example.com/help',
      expected: 'https://example.com/help',
    ),
    'onPopupDataReceived': (
      event: ChannelTalkEvent.onPopupDataReceived,
      arguments: {'chatId': 'test-chat', 'avatarUrl': null, 'message': 'Test'},
      expected: {'chatId': 'test-chat', 'avatarUrl': null, 'message': 'Test'},
    ),
    'onPushNotificationClicked': (
      event: ChannelTalkEvent.onPushNotificationClicked,
      arguments: 'test-push-chat',
      expected: 'test-push-chat',
    ),
  };

  for (final entry in eventCases.entries) {
    test('${entry.key}은 이벤트 종류와 데이터를 한 번 전달한다', () async {
      final received = <({ChannelTalkEvent event, Object? arguments})>[];
      platform.setListener((event, arguments) {
        received.add((event: event, arguments: arguments));
      });

      await sendEvent(entry.key, entry.value.arguments);

      expect(received, hasLength(1));
      expect(received.single.event, entry.value.event);
      expect(received.single.arguments, entry.value.expected);
    });
  }

  test('리스너 교체 후에는 새 리스너만 이벤트를 받는다', () async {
    final previousEvents = <ChannelTalkEvent>[];
    final currentEvents = <ChannelTalkEvent>[];
    platform.setListener((event, arguments) => previousEvents.add(event));
    platform.setListener((event, arguments) => currentEvents.add(event));

    await sendEvent('onShowMessenger');

    expect(previousEvents, isEmpty);
    expect(currentEvents, [ChannelTalkEvent.onShowMessenger]);
  });

  test('리스너를 반복 해제해도 이후 네이티브 이벤트를 전달하지 않는다', () async {
    final events = <ChannelTalkEvent>[];
    platform.setListener((event, arguments) => events.add(event));
    platform.removeListener();
    platform.removeListener();

    await sendEvent('onShowMessenger');

    expect(events, isEmpty);
  });

  test('해제 후 다시 등록한 리스너는 이벤트를 정상 수신한다', () async {
    final previousEvents = <ChannelTalkEvent>[];
    final currentEvents = <ChannelTalkEvent>[];
    platform.setListener((event, arguments) => previousEvents.add(event));
    platform.removeListener();
    platform.setListener((event, arguments) => currentEvents.add(event));

    await sendEvent('onHideMessenger');

    expect(previousEvents, isEmpty);
    expect(currentEvents, [ChannelTalkEvent.onHideMessenger]);
  });

  test('지원하지 않는 이벤트는 리스너 호출 없이 오류로 응답한다', () async {
    final events = <ChannelTalkEvent>[];
    platform.setListener((event, arguments) => events.add(event));

    await expectLater(
      sendEvent('unsupportedEvent'),
      throwsA(isA<PlatformException>()),
    );

    expect(events, isEmpty);
  });
}
