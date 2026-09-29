import 'package:flutter/services.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:channel_talk_flutter/channel_talk_flutter.dart';
import 'package:channel_talk_flutter/channel_talk_flutter_method_channel.dart';
import 'package:channel_talk_flutter/channel_talk_flutter_platform_interface.dart';

typedef _BoolCall = Future<bool?> Function();

/// 실제 네이티브 대신 codec 경계를 통과시켜 기존 호출자의 응답 계약을 고정한다.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('channel_talk_flutter');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late ChannelTalkFlutterPlatform previousPlatform;
  final calls = <MethodCall>[];
  Object? nativeResult;
  Object? nativeError;

  setUp(() {
    previousPlatform = ChannelTalkFlutterPlatform.instance;
    ChannelTalkFlutterPlatform.instance = MethodChannelChannelTalkFlutter();
    calls.clear();
    nativeResult = true;
    nativeError = null;
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      if (nativeError != null) throw nativeError!;
      return nativeResult;
    });
  });

  tearDown(() {
    ChannelTalk.removeListener();
    ChannelTalkFlutterPlatform.instance = previousPlatform;
    messenger.setMockMethodCallHandler(channel, null);
  });

  final operations = <String, (_BoolCall, String, Object?)>{
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
    'sleep': (ChannelTalk.sleep, 'sleep', null),
    'shutdown': (ChannelTalk.shutdown, 'shutdown', null),
    'showChannelButton': (
      ChannelTalk.showChannelButton,
      'showChannelButton',
      null
    ),
    'hideChannelButton': (
      ChannelTalk.hideChannelButton,
      'hideChannelButton',
      null
    ),
    'showMessenger': (ChannelTalk.showMessenger, 'showMessenger', null),
    'hideMessenger': (ChannelTalk.hideMessenger, 'hideMessenger', null),
    'openChat': (
      () => ChannelTalk.openChat(chatId: 'contract-chat'),
      'openChat',
      {'chatId': 'contract-chat', 'message': null},
    ),
    'track': (
      () => ChannelTalk.track(
          eventName: 'contract-event', properties: {'count': 0}),
      'track',
      {
        'eventName': 'contract-event',
        'properties': {'count': 0}
      },
    ),
    'updateUser': (
      () => ChannelTalk.updateUser(unsubscribeEmail: false, tags: []),
      'updateUser',
      {'unsubscribeEmail': false, 'tags': []},
    ),
    'initPushToken': (
      () => ChannelTalk.initPushToken(deviceToken: 'synthetic-token'),
      'initPushToken',
      {'deviceToken': 'synthetic-token'},
    ),
    'isChannelPushNotification': (
      () => ChannelTalk.isChannelPushNotification(content: {'contract': true}),
      'isChannelPushNotification',
      {
        'content': {'contract': true}
      },
    ),
    'receivePushNotification': (
      () => ChannelTalk.receivePushNotification(content: {'contract': true}),
      'receivePushNotification',
      {
        'content': {'contract': true}
      },
    ),
    'storePushNotification': (
      () => ChannelTalk.storePushNotification(content: {'contract': true}),
      'storePushNotification',
      {
        'content': {'contract': true}
      },
    ),
    'hasStoredPushNotification': (
      ChannelTalk.hasStoredPushNotification,
      'hasStoredPushNotification',
      null,
    ),
    'openStoredPushNotification': (
      ChannelTalk.openStoredPushNotification,
      'openStoredPushNotification',
      null,
    ),
    'isBooted': (ChannelTalk.isBooted, 'isBooted', null),
    'setDebugMode': (
      () => ChannelTalk.setDebugMode(flag: false),
      'setDebugMode',
      {'flag': false},
    ),
    'setPage': (
      () => ChannelTalk.setPage(profile: {'contractCount': 0}),
      'setPage',
      {
        'page': null,
        'profile': {'contractCount': 0}
      },
    ),
    'resetPage': (ChannelTalk.resetPage, 'resetPage', null),
    'addTags': (
      () => ChannelTalk.addTags(tags: ['contract-tag']),
      'addTags',
      {
        'tags': ['contract-tag']
      },
    ),
    'removeTags': (
      () => ChannelTalk.removeTags(tags: ['contract-tag']),
      'removeTags',
      {
        'tags': ['contract-tag']
      },
    ),
    'openWorkflow': (
      () => ChannelTalk.openWorkflow(workflowId: 'contract-workflow'),
      'openWorkflow',
      {'workflowId': 'contract-workflow'},
    ),
    'setAppearance': (
      () => ChannelTalk.setAppearance(appearance: Appearance.dark),
      'setAppearance',
      {'appearance': 'dark'},
    ),
    'hidePopup': (ChannelTalk.hidePopup, 'hidePopup', null),
    'setPreventDefaultUrlClick': (
      () => ChannelTalk.setPreventDefaultUrlClick(prevent: false),
      'setPreventDefaultUrlClick',
      {'prevent': false},
    ),
  };

  for (final entry in operations.entries) {
    final (invoke, command, arguments) = entry.value;
    test('${entry.key}: 공개 API부터 codec까지 인자 및 true/false/null 보존', () async {
      for (final result in <bool?>[true, false, null]) {
        nativeResult = result;
        calls.clear();
        expect(await invoke(), result);
        expect(calls, hasLength(1));
        expect(calls.single.method, command);
        expect(calls.single.arguments, arguments);
      }
    });

    test('${entry.key}: 플랫폼 상세 오류와 미구현 오류를 성공으로 바꾸지 않음', () async {
      nativeError = PlatformException(
        code: 'CONTRACT_FAILURE',
        message: 'Synthetic failure',
        details: {'attempt': 0, 'retryable': false},
      );
      await expectLater(
        invoke(),
        throwsA(isA<PlatformException>()
            .having((e) => e.code, 'code', 'CONTRACT_FAILURE')
            .having((e) => e.message, 'message', 'Synthetic failure')
            .having((e) => e.details, 'details',
                {'attempt': 0, 'retryable': false})),
      );
      nativeError = MissingPluginException('Synthetic missing implementation');
      await expectLater(invoke(), throwsA(isA<MissingPluginException>()));
    });
  }

  test('bootWithStatus: 공개 API도 모든 상태 및 알 수 없는 상태 변환을 보존', () async {
    for (final status in ChannelTalkBootStatus.values) {
      nativeResult = status.value;
      expect(
        await ChannelTalk.bootWithStatus(pluginKey: 'contract-test-key'),
        status,
      );
      expect(calls.last.method, 'bootWithStatus');
      expect(calls.last.arguments, {'pluginKey': 'contract-test-key'});
    }
    for (final value in <String?>[null, 'future-sdk-status']) {
      nativeResult = value;
      expect(
        await ChannelTalk.bootWithStatus(pluginKey: 'contract-test-key'),
        ChannelTalkBootStatus.unknown,
      );
    }
  });

  test('선택 인자 생략은 SDK가 해석할 null 또는 누락 형태를 보존', () async {
    await ChannelTalk.openChat();
    expect(calls.last.arguments, {'chatId': null, 'message': null});
    await ChannelTalk.openWorkflow();
    expect(calls.last.arguments, {'workflowId': null});
    await ChannelTalk.track(eventName: 'contract-event');
    expect(calls.last.arguments, {'eventName': 'contract-event'});
    await ChannelTalk.setPage();
    expect(calls.last.arguments, {'page': null});
  });
}
