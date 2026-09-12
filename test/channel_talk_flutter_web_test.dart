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

/// Verifies the browser bridge without loading the remote SDK or making network requests.
void main() {
  late ChannelTalkFlutterWeb platform;
  JSFunction? previousChannelIo;
  final calls = <String, List<JSAny?>>{};
  final callbacks = <String, JSFunction>{};
  final listeners = <String, JSFunction>{};

  setUp(() {
    platform = ChannelTalkFlutterWeb();
    calls.clear();
    callbacks.clear();
    listeners.clear();
    previousChannelIo = _channelIo;
    _channelIo = ((String command, [JSAny? first, JSAny? second]) {
      calls[command] = [first, second];
      if (command == 'clearCallbacks') {
        listeners.clear();
      } else if (command.startsWith('on')) {
        listeners[command] = first as JSFunction;
      } else if (second != null) {
        if (command == 'boot' ||
            command == 'updateUser' ||
            command == 'addTags' ||
            command == 'removeTags') {
          callbacks[command] = second as JSFunction;
        }
      }
    }).toJS;
  });

  tearDown(() {
    _channelIo = previousChannelIo;
  });

  final operations = <String, Future<bool?> Function()>{
    'boot': () => platform.boot({'pluginKey': 'test-plugin-key'}),
    'updateUser': () => platform.updateUser({'name': 'Test user'}),
    'addTags': () => platform.addTags(['test-tag']),
    'removeTags': () => platform.removeTags(['test-tag']),
  };

  for (final entry in operations.entries) {
    test('${entry.key}은 SDK 성공 콜백까지 기다린다', () async {
      bool completed = false;

      Future<bool?> observeResult() async {
        final result = await entry.value();
        completed = true;
        return result;
      }

      final result = observeResult();
      await Future<void>.delayed(Duration.zero);
      expect(completed, isFalse);

      callbacks[entry.key]!.callAsFunction(
        null,
        null,
        {'id': 'test-user'}.jsify(),
      );
      expect(await result, isTrue);
    });

    test('${entry.key}은 사용자 인자가 없는 실패 콜백을 false로 전달한다', () async {
      final result = entry.value();

      callbacks[entry.key]!.callAsFunction(
        null,
        {'message': 'SDK operation failed'}.jsify(),
      );

      expect(await result, isFalse);
    });
  }

  test('SDK 성공 이후 중복 실패 콜백은 첫 성공 결과를 바꾸지 않는다', () async {
    for (final entry in operations.entries) {
      final result = entry.value();
      final callback = callbacks[entry.key]!;

      callback.callAsFunction(null, null);
      callback.callAsFunction(null, {'message': 'Duplicate failure'}.jsify());

      expect(
        await result,
        isTrue,
        reason: entry.key,
      );
    }
  });

  test('SDK 실패 이후 중복 성공 콜백은 첫 실패 결과를 바꾸지 않는다', () async {
    for (final entry in operations.entries) {
      final result = entry.value();
      final callback = callbacks[entry.key]!;

      callback.callAsFunction(null, {'message': 'Initial failure'}.jsify());
      callback.callAsFunction(null, null);

      expect(
        await result,
        isFalse,
        reason: entry.key,
      );
    }
  });

  test('동시에 요청한 같은 API는 콜백 도착 순서와 무관하게 각 결과를 전달한다', () async {
    for (final entry in operations.entries) {
      final firstResult = entry.value();
      final firstCallback = callbacks[entry.key]!;
      final secondResult = entry.value();
      final secondCallback = callbacks[entry.key]!;

      secondCallback.callAsFunction(
          null, {'message': 'Second request failed'}.jsify());
      firstCallback.callAsFunction(null, null);

      expect(
        await firstResult,
        isTrue,
        reason: entry.key,
      );
      expect(
        await secondResult,
        isFalse,
        reason: entry.key,
      );
    }
  });

  for (final succeeds in [true, false]) {
    test('bootWithStatus는 SDK 콜백을 기다리고 성공 여부 $succeeds를 반영한다', () async {
      bool completed = false;

      /// 원격 API가 기존 비동기 boot 계약을 우회하지 않는지 확인한다.
      Future<ChannelTalkBootStatus> observeStatus() async {
        final status =
            await platform.bootWithStatus({'pluginKey': 'test-plugin-key'});
        completed = true;
        return status;
      }

      final result = observeStatus();
      await Future<void>.delayed(Duration.zero);
      expect(completed, isFalse);

      callbacks['boot']!.callAsFunction(
        null,
        succeeds ? null : {'message': 'Test boot failure'}.jsify(),
      );

      expect(
        await result,
        succeeds
            ? ChannelTalkBootStatus.success
            : ChannelTalkBootStatus.unknown,
      );
    });
  }

  test('bootWithStatus는 JS 호출 예외를 성공 상태로 바꾸지 않는다', () async {
    /// JS interop이 지원하는 void 반환형으로 호출 실패를 모사한다.
    void throwStatusError(
      String command,
      JSAny? options,
      JSFunction callback,
    ) {
      throw StateError('Test SDK failure');
    }

    _channelIo = throwStatusError.toJS;

    await expectLater(
      platform.bootWithStatus({'pluginKey': 'test-plugin-key'}),
      throwsStateError,
    );
  });

  test('SDK 호출 중 동기 예외는 Future 오류로 전달한다', () async {
    void throwSdkError(
      String command,
      JSAny? options,
      JSFunction callback,
    ) {
      throw StateError('SDK invocation failed');
    }

    _channelIo = throwSdkError.toJS;

    await expectLater(
      platform.boot({'pluginKey': 'test-plugin-key'}),
      throwsStateError,
    );
  });

  test('boot은 미지정 옵션을 생략하고 false 설정을 보존한다', () async {
    final result = platform.boot({
      'pluginKey': 'test-plugin-key',
      'memberId': null,
      'hidePopup': false,
    });

    expect(calls['boot']!.first.dartify(), {
      'pluginKey': 'test-plugin-key',
      'hidePopup': false,
    });

    callbacks['boot']!.callAsFunction(null, null, null);
    expect(await result, isTrue);
  });

  test('boot은 지정한 사용자 프로필을 전달한다', () async {
    final result = platform.boot({
      'pluginKey': 'test-plugin-key',
      'name': 'Test user',
      'email': 'test@example.com',
    });

    expect(calls['boot']!.first.dartify(), {
      'pluginKey': 'test-plugin-key',
      'profile': {'name': 'Test user', 'email': 'test@example.com'},
    });

    callbacks['boot']!.callAsFunction(null, null, null);
    expect(await result, isTrue);
  });

  test('updateUser는 태그만 변경할 때 금지된 빈 profile을 보내지 않는다', () async {
    final result = platform.updateUser({
      'tags': ['test-tag'],
      'unsubscribeEmail': false,
    });

    expect(calls['updateUser']!.first.dartify(), {
      'tags': ['test-tag'],
      'unsubscribeEmail': false,
    });

    callbacks['updateUser']!.callAsFunction(null, null, null);
    expect(await result, isTrue);
  });

  test('updateUser는 커스텀 프로필과 profileOnce를 전달한다', () async {
    final result = platform.updateUser({
      'name': 'Test user',
      'customAttributes': {'plan': 'pro', 'expiredAt': null},
      'profileOnce': {'source': 'website'},
    });

    expect(calls['updateUser']!.first.dartify(), {
      'profile': {'name': 'Test user', 'plan': 'pro', 'expiredAt': null},
      'profileOnce': {'source': 'website'},
    });

    callbacks['updateUser']!.callAsFunction(null, null, null);
    expect(await result, isTrue);
  });

  test('리스너는 배지와 프로필 및 팝업 데이터를 Dart 값으로 전달한다', () {
    final events = <Map<String, dynamic>>[];
    platform.setListener((event, arguments) {
      events.add({'event': event, 'arguments': arguments});
    });

    listeners['onBadgeChanged']!.callAsFunction(null, 3.toJS, 1.toJS);
    listeners['onFollowUpChanged']!
        .callAsFunction(null, {'name': 'Test user'}.jsify());
    listeners['onPopupDataReceived']!
        .callAsFunction(null, {'chatId': 'test-chat'}.jsify());
    listeners['onShowMessenger']!.callAsFunction(null);

    expect(events, [
      {
        'event': ChannelTalkEvent.onBadgeChanged,
        'arguments': {'unread': 3, 'alert': 1},
      },
      {
        'event': ChannelTalkEvent.onFollowUpChanged,
        'arguments': {'name': 'Test user'},
      },
      {
        'event': ChannelTalkEvent.onPopupDataReceived,
        'arguments': {'chatId': 'test-chat'},
      },
      {'event': ChannelTalkEvent.onShowMessenger, 'arguments': {}},
    ]);
  });

  test('교체 및 제거된 리스너는 뒤늦은 이벤트를 무시한다', () {
    final events = <ChannelTalkEvent>[];
    platform.setListener((event, arguments) => events.add(event));
    final staleCallback = listeners['onShowMessenger']!;

    platform.setListener((event, arguments) => events.add(event));
    staleCallback.callAsFunction(null);
    expect(events, isEmpty);

    final activeCallback = listeners['onShowMessenger']!;
    activeCallback.callAsFunction(null);
    expect(events, [ChannelTalkEvent.onShowMessenger]);

    platform.removeListener();
    expect(listeners, isEmpty);
    activeCallback.callAsFunction(null);
    expect(events, [ChannelTalkEvent.onShowMessenger]);
  });

  test('onChatCreated는 웹 SDK의 인자 없는 콜백을 처리한다', () {
    ChannelTalkEvent? receivedEvent;
    Object? receivedArguments;
    platform.setListener((event, arguments) {
      receivedEvent = event;
      receivedArguments = arguments;
    });

    listeners['onChatCreated']!.callAsFunction(null);

    expect(receivedEvent, ChannelTalkEvent.onChatCreated);
    expect(receivedArguments, isNull);
  });

  test('URL 리스너는 기본 동작 차단 설정과 제거를 반영한다', () async {
    final urls = <String>[];
    platform.setListener((event, arguments) => urls.add(arguments as String));
    final callback = listeners['onUrlClicked']!;
    final url = 'https://example.com'.toJS;

    expect(callback.callAsFunction(null, url).dartify(), isFalse);
    await platform.setPreventDefaultUrlClick(true);
    expect(callback.callAsFunction(null, url).dartify(), isTrue);
    expect(urls, ['https://example.com', 'https://example.com']);

    platform.removeListener();
    expect(callback.callAsFunction(null, url).dartify(), isFalse);
    expect(urls, hasLength(2));
  });

  test('교체된 URL 콜백은 이벤트를 전달하거나 기본 동작을 차단하지 않는다', () async {
    final previousUrls = <String>[];
    final activeUrls = <String>[];
    platform.setListener(
        (event, arguments) => previousUrls.add(arguments as String));
    await platform.setPreventDefaultUrlClick(true);
    final previousCallback = listeners['onUrlClicked']!;

    platform
        .setListener((event, arguments) => activeUrls.add(arguments as String));
    final activeCallback = listeners['onUrlClicked']!;
    final url = 'https://example.com/replaced-listener'.toJS;

    expect(previousCallback.callAsFunction(null, url).dartify(), isFalse);
    expect(previousUrls, isEmpty);
    expect(activeUrls, isEmpty);

    expect(activeCallback.callAsFunction(null, url).dartify(), isTrue);
    expect(previousUrls, isEmpty);
    expect(activeUrls, ['https://example.com/replaced-listener']);
  });

  test('리스너 제거 후 재등록하면 URL 차단이 기본값으로 돌아간다', () async {
    final events = <ChannelTalkEvent>[];
    platform.setListener((event, arguments) => events.add(event));
    await platform.setPreventDefaultUrlClick(true);
    final removedCallback = listeners['onUrlClicked']!;

    platform.removeListener();
    platform.setListener((event, arguments) => events.add(event));
    final activeCallback = listeners['onUrlClicked']!;
    final url = 'https://example.com/new-listener'.toJS;

    expect(removedCallback.callAsFunction(null, url).dartify(), isFalse);
    expect(events, isEmpty);
    expect(activeCallback.callAsFunction(null, url).dartify(), isFalse);
    expect(events, [ChannelTalkEvent.onUrlClicked]);

    await platform.setPreventDefaultUrlClick(true);
    expect(activeCallback.callAsFunction(null, url).dartify(), isTrue);
    expect(
        events, [ChannelTalkEvent.onUrlClicked, ChannelTalkEvent.onUrlClicked]);
  });

  test('setPage는 페이지와 채팅 프로필을 전달한다', () async {
    expect(
      await platform
          .setPage(page: 'orders/detail', profile: {'orderId': 'A-100'}),
      isTrue,
    );
    expect(calls['setPage']![0].dartify(), 'orders/detail');
    expect(calls['setPage']![1].dartify(), {'orderId': 'A-100'});
  });

  test('setPage는 웹 SDK에서 허용하지 않는 null 페이지를 거부한다', () async {
    await expectLater(
      platform.setPage(profile: {'orderId': 'A-100'}),
      throwsArgumentError,
    );
    expect(calls.containsKey('setPage'), isFalse);
  });
}
