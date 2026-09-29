@TestOn('browser')
library;

import 'dart:js_interop';

import 'package:flutter_test/flutter_test.dart';

import 'package:channel_talk_flutter/channel_talk_flutter.dart';
import 'package:channel_talk_flutter/channel_talk_flutter_platform_interface.dart';
import 'package:channel_talk_flutter/channel_talk_flutter_web.dart';

@JS('ChannelIO')
external JSFunction? get _channelIo;

@JS('ChannelIO')
external set _channelIo(JSFunction? callback);

typedef _BoolCall = Future<bool?> Function();

/// 원격 SDK와 서버를 사용하지 않고 공개 API의 브라우저 전달 계약을 검증한다.
void main() {
  late ChannelTalkFlutterPlatform previousPlatform;
  JSFunction? previousChannelIo;
  final calls = <(String, JSAny?, JSAny?)>[];
  bool shouldThrow = false;

  setUp(() {
    previousPlatform = ChannelTalkFlutterPlatform.instance;
    ChannelTalkFlutterPlatform.instance = ChannelTalkFlutterWeb();
    previousChannelIo = _channelIo;
    calls.clear();
    shouldThrow = false;
    _channelIo = ((String command, [JSAny? first, JSAny? second]) {
      if (shouldThrow) throw StateError('Synthetic SDK invocation failure');
      calls.add((command, first, second));
    }).toJS;
  });

  tearDown(() {
    ChannelTalkFlutterPlatform.instance = previousPlatform;
    _channelIo = previousChannelIo;
  });

  final commands = <String, (_BoolCall, List<Object?>)>{
    'shutdown': (ChannelTalk.shutdown, [null, null]),
    'showChannelButton': (ChannelTalk.showChannelButton, [null, null]),
    'hideChannelButton': (ChannelTalk.hideChannelButton, [null, null]),
    'showMessenger': (ChannelTalk.showMessenger, [null, null]),
    'hideMessenger': (ChannelTalk.hideMessenger, [null, null]),
    'openChat': (
      () => ChannelTalk.openChat(chatId: 'contract-chat'),
      ['contract-chat', null],
    ),
    'track': (
      () => ChannelTalk.track(
            eventName: 'contract-event',
            properties: {'count': 0, 'enabled': false},
          ),
      [
        'contract-event',
        {'count': 0, 'enabled': false}
      ],
    ),
    'setPage': (
      () => ChannelTalk.setPage(page: 'contract/page', profile: {'count': 0}),
      [
        'contract/page',
        {'count': 0}
      ],
    ),
    'resetPage': (ChannelTalk.resetPage, [null, null]),
    'openWorkflow': (
      () => ChannelTalk.openWorkflow(workflowId: 'contract-workflow'),
      ['contract-workflow', null],
    ),
    'setAppearance': (
      () => ChannelTalk.setAppearance(appearance: Appearance.dark),
      ['dark', null],
    ),
    'hidePopup': (ChannelTalk.hidePopup, [null, null]),
  };

  for (final entry in commands.entries) {
    final (invoke, arguments) = entry.value;
    test('${entry.key}: JS 명령 및 인자 보존, 호출 후 true 반환', () async {
      expect(await invoke(), isTrue);
      expect(calls, hasLength(1));
      expect(calls.single.$1, entry.key);
      expect([calls.single.$2.dartify(), calls.single.$3.dartify()], arguments);
    });

    test('${entry.key}: JS 호출 예외를 true로 바꾸지 않음', () async {
      shouldThrow = true;
      // Future.sync는 동기·비동기 오류를 모두 관찰하며 런타임 구현을 바꾸지 않는다.
      await expectLater(Future<bool?>.sync(invoke), throwsStateError);
      expect(calls, isEmpty);
    });
  }

  final callbackCommands = <String, (_BoolCall, String, Object?)>{
    'boot': (
      () => ChannelTalk.boot(pluginKey: 'contract-test-key'),
      'boot',
      {'pluginKey': 'contract-test-key'},
    ),
    'bootForWeb': (
      () => ChannelTalk.bootForWeb(pluginKey: 'contract-test-key', zIndex: 0),
      'boot',
      {'pluginKey': 'contract-test-key', 'zIndex': 0},
    ),
    'updateUser': (
      () => ChannelTalk.updateUser(customAttributes: {'contractCount': 0}),
      'updateUser',
      {
        'profile': {'contractCount': 0}
      },
    ),
    'addTags': (
      () => ChannelTalk.addTags(tags: ['contract-tag']),
      'addTags',
      ['contract-tag'],
    ),
    'removeTags': (
      () => ChannelTalk.removeTags(tags: ['contract-tag']),
      'removeTags',
      ['contract-tag'],
    ),
  };

  for (final entry in callbackCommands.entries) {
    final (invoke, command, argument) = entry.value;
    test('${entry.key}: 공개 API의 콜백 대기 및 성공·실패 응답 보존', () async {
      for (final succeeds in [true, false]) {
        calls.clear();
        bool completed = false;
        final result = invoke().whenComplete(() => completed = true);
        await Future<void>.delayed(Duration.zero);
        expect(completed, isFalse);
        expect(calls, hasLength(1));
        expect(calls.single.$1, command);
        expect(calls.single.$2.dartify(), argument);
        (calls.single.$3 as JSFunction).callAsFunction(
          null,
          succeeds ? null : {'message': 'Synthetic SDK error'}.jsify(),
        );
        expect(await result, succeeds);
      }
    });
  }

  final unsupported = <String, _BoolCall>{
    'sleep': ChannelTalk.sleep,
    'initPushToken': () =>
        ChannelTalk.initPushToken(deviceToken: 'synthetic-token'),
    'isChannelPushNotification': () =>
        ChannelTalk.isChannelPushNotification(content: {}),
    'receivePushNotification': () =>
        ChannelTalk.receivePushNotification(content: {}),
    'storePushNotification': () =>
        ChannelTalk.storePushNotification(content: {}),
    'hasStoredPushNotification': ChannelTalk.hasStoredPushNotification,
    'openStoredPushNotification': ChannelTalk.openStoredPushNotification,
    'isBooted': ChannelTalk.isBooted,
    'setDebugMode': () => ChannelTalk.setDebugMode(flag: false),
  };

  for (final entry in unsupported.entries) {
    test('${entry.key}: Web 미지원은 명시적 오류이며 SDK를 호출하지 않음', () async {
      await expectLater(
        Future<bool?>.sync(entry.value),
        throwsA(isA<UnimplementedError>().having(
          (error) => error.message,
          'message',
          contains(entry.key),
        )),
      );
      expect(calls, isEmpty);
    });
  }

  test('선택 인자 생략 및 appearance enum 전체가 JS에 전달됨', () async {
    await ChannelTalk.openChat();
    expect([calls.last.$2.dartify(), calls.last.$3.dartify()], [null, null]);
    await ChannelTalk.openWorkflow();
    expect(calls.last.$2.dartify(), isNull);
    await ChannelTalk.track(eventName: 'contract-event');
    expect(calls.last.$3.dartify(), isNull);
    await ChannelTalk.setPage(page: 'contract/page');
    expect(calls.last.$3.dartify(), isNull);
    for (final appearance in Appearance.values) {
      await ChannelTalk.setAppearance(appearance: appearance);
      expect(calls.last.$2.dartify(), appearance.value);
    }
  });

  test('공개 URL 기본 동작 설정은 false만 허용하고 SDK 호출 없이 처리', () async {
    expect(await ChannelTalk.setPreventDefaultUrlClick(prevent: false), isTrue);
    await expectLater(
      ChannelTalk.setPreventDefaultUrlClick(prevent: true),
      throwsUnsupportedError,
    );
    expect(calls, isEmpty);
  });

  test('공개 bootWithStatus는 오류 콜백을 unknown으로 보존', () async {
    final status = ChannelTalk.bootWithStatus(pluginKey: 'contract-test-key');
    (calls.single.$3 as JSFunction).callAsFunction(
      null,
      {'message': 'Synthetic SDK error'}.jsify(),
    );
    expect(await status, ChannelTalkBootStatus.unknown);
  });

  test('공개 리스너는 Web 이벤트 7개를 등록하고 제거 뒤 지연 이벤트를 무시', () {
    final events = <ChannelTalkEvent>[];
    ChannelTalk.setListener(
        (ChannelTalkEvent event, dynamic data) => events.add(event));
    expect(calls.first.$1, 'clearCallbacks');
    expect(calls.map((call) => call.$1), [
      'clearCallbacks',
      'onShowMessenger',
      'onHideMessenger',
      'onChatCreated',
      'onBadgeChanged',
      'onFollowUpChanged',
      'onUrlClicked',
      'onPopupDataReceived',
    ]);
    final oldShow = calls[1].$2 as JSFunction;
    oldShow.callAsFunction(null);
    expect(events, [ChannelTalkEvent.onShowMessenger]);
    ChannelTalk.removeListener();
    expect(calls.last.$1, 'clearCallbacks');
    oldShow.callAsFunction(null);
    expect(events, hasLength(1));
    ChannelTalk.setListener(
        (ChannelTalkEvent event, dynamic data) => events.add(event));
    final newShow = calls[calls.length - 7].$2 as JSFunction;
    newShow.callAsFunction(null);
    expect(events, hasLength(2));
  });
}
