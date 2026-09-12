import 'dart:async';

import 'package:flutter/services.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:channel_talk_flutter/channel_talk_flutter_method_channel.dart';

/// 채널 직렬화뿐 아니라 지연된 결과와 네이티브 오류 전달을 검증한다.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('channel_talk_flutter');
  final log = <MethodCall>[];
  final platform = MethodChannelChannelTalkFlutter();

  setUp(() {
    log.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        log.add(methodCall);
        return true;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  for (final nativeResult in <bool?>[false, null]) {
    test('네이티브 결과 $nativeResult를 성공으로 바꾸지 않는다', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async => nativeResult);

      expect(await platform.isBooted(), nativeResult);
    });
  }

  test('네이티브 오류의 코드와 상세 정보를 호출자에게 전달한다', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      throw PlatformException(
        code: 'INITIALIZATION_FAILED',
        message: 'Test initialization failure',
        details: {'retryable': false},
      );
    });

    await expectLater(
      platform.boot({'pluginKey': 'test-plugin-key'}),
      throwsA(
        isA<PlatformException>()
            .having((error) => error.code, 'code', 'INITIALIZATION_FAILED')
            .having((error) => error.message, 'message',
                'Test initialization failure')
            .having((error) => error.details, 'details', {'retryable': false}),
      ),
    );
  });

  test('네이티브 미구현 메서드는 MissingPluginException으로 전달한다', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      throw MissingPluginException();
    });

    await expectLater(
        platform.showMessenger(), throwsA(isA<MissingPluginException>()));
  });

  test('boot은 네이티브 응답이 도착하기 전 성공을 반환하지 않는다', () async {
    final nativeResponse = Completer<bool>();
    bool completed = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) => nativeResponse.future);

    /// 지연된 플랫폼 결과의 완료 시점을 관찰한다.
    Future<bool?> observeBoot() async {
      final result = await platform.boot({'pluginKey': 'test-plugin-key'});
      completed = true;
      return result;
    }

    final result = observeBoot();
    await Future<void>.delayed(Duration.zero);
    expect(completed, isFalse);

    nativeResponse.complete(true);
    expect(await result, isTrue);
    expect(completed, isTrue);
  });

  test(
    'hidePopup은 올바른 메서드 이름으로 전달된다',
    () async {
      final result = await platform.hidePopup();

      expect(result, isTrue);
      expect(log, hasLength(1));
      expect(log.single.method, 'hidePopup');
      expect(log.single.arguments, isNull);
    },
  );

  test(
    'setPreventDefaultUrlClick은 prevent 인자를 전달한다',
    () async {
      final result = await platform.setPreventDefaultUrlClick(true);

      expect(result, isTrue);
      expect(log, hasLength(1));
      expect(log.single.method, 'setPreventDefaultUrlClick');
      expect(log.single.arguments, {'prevent': true});
    },
  );

  test(
    'openWorkflow는 workflowId를 전달한다',
    () async {
      final result = await platform.openWorkflow(workflowId: 'workflow-id');

      expect(result, isTrue);
      expect(log, hasLength(1));
      expect(log.single.method, 'openWorkflow');
      expect(log.single.arguments, {'workflowId': 'workflow-id'});
    },
  );

  test(
    'showMessenger는 인자 없이 호출된다',
    () async {
      final result = await platform.showMessenger();

      expect(result, isTrue);
      expect(log, hasLength(1));
      expect(log.single.method, 'showMessenger');
      expect(log.single.arguments, isNull);
    },
  );

  test(
    'setPage는 page와 profile을 전달한다',
    () async {
      final result = await platform.setPage(
        page: 'orders/detail',
        profile: {
          'orderId': 'A-100',
        },
      );

      expect(result, isTrue);
      expect(log, hasLength(1));
      expect(log.single.method, 'setPage');
      expect(
        log.single.arguments,
        {
          'page': 'orders/detail',
          'profile': {
            'orderId': 'A-100',
          },
        },
      );
    },
  );

  test(
    'setPage는 page 없이도 profile을 전달한다',
    () async {
      final result = await platform.setPage(
        profile: {
          'orderId': 'A-100',
        },
      );

      expect(result, isTrue);
      expect(log, hasLength(1));
      expect(log.single.method, 'setPage');
      expect(
        log.single.arguments,
        {
          'page': null,
          'profile': {
            'orderId': 'A-100',
          },
        },
      );
    },
  );
}
