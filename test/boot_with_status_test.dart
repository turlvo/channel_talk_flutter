import 'package:flutter/services.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:channel_talk_flutter/channel_talk_flutter.dart';
import 'package:channel_talk_flutter/channel_talk_flutter_method_channel.dart';

/// 상세 초기화 결과가 네이티브 문자열과 공개 상태 사이에서 보존되는지 확인한다.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const nativeStatuses = {
    'success': ChannelTalkBootStatus.success,
    'notInitialized': ChannelTalkBootStatus.notInitialized,
    'networkTimeout': ChannelTalkBootStatus.networkTimeout,
    'notAvailableVersion': ChannelTalkBootStatus.notAvailableVersion,
    'serviceUnderConstruction': ChannelTalkBootStatus.serviceUnderConstruction,
    'requirePayment': ChannelTalkBootStatus.requirePayment,
    'accessDenied': ChannelTalkBootStatus.accessDenied,
    'unknown': ChannelTalkBootStatus.unknown,
  };

  group('ChannelTalkBootStatus.fromNative', () {
    test('공개 상태 8개의 네이티브 문자열 계약을 보존한다', () {
      expect(
          ChannelTalkBootStatus.values, unorderedEquals(nativeStatuses.values));

      for (final entry in nativeStatuses.entries) {
        expect(entry.value.value, entry.key);
        expect(ChannelTalkBootStatus.fromNative(entry.key), entry.value);
      }
    });

    test('null과 알 수 없는 값은 성공으로 간주하지 않는다', () {
      for (final value in <String?>[null, '', 'somethingElse', 'SUCCESS']) {
        expect(
          ChannelTalkBootStatus.fromNative(value),
          ChannelTalkBootStatus.unknown,
          reason: '지원하지 않는 네이티브 상태: $value',
        );
      }
    });
  });

  group('MethodChannelChannelTalkFlutter.bootWithStatus', () {
    const channel = MethodChannel('channel_talk_flutter');
    final platform = MethodChannelChannelTalkFlutter();
    final log = <MethodCall>[];

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
      log.clear();
    });

    test('bootWithStatus 명령과 설정 전체를 한 번 전달한다', () async {
      const config = {
        'pluginKey': 'test-plugin-key',
        'memberId': 'test-member-id',
        'memberHash': 'test-member-hash',
        'language': 'ko',
        'appearance': 'dark',
        'unsubscribeEmail': false,
        'unsubscribeTexting': false,
        'trackDefaultEvent': false,
        'hidePopup': false,
      };
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        log.add(call);
        return 'networkTimeout';
      });

      final status = await platform.bootWithStatus(config);

      expect(status, ChannelTalkBootStatus.networkTimeout);
      expect(log.single.method, 'bootWithStatus');
      expect(log.single.arguments, config);
    });

    test('알 수 없는 네이티브 상태는 unknown으로 전달한다', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async => 'weird');

      expect(
        await platform.bootWithStatus({'pluginKey': 'test-plugin-key'}),
        ChannelTalkBootStatus.unknown,
      );
    });

    test('네이티브 상태 8개를 각각 대응하는 상세 결과로 전달한다', () async {
      for (final entry in nativeStatuses.entries) {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async => entry.key);

        expect(
          await platform.bootWithStatus({'pluginKey': 'test-plugin-key'}),
          entry.value,
          reason: '네이티브 상태: ${entry.key}',
        );
      }
    });

    test('네이티브 null 응답은 unknown으로 전달한다', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async => null);

      expect(
        await platform.bootWithStatus({'pluginKey': 'test-plugin-key'}),
        ChannelTalkBootStatus.unknown,
      );
    });

    test('플랫폼 예외의 코드와 세부 정보는 상태값으로 덮어쓰지 않는다', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        throw PlatformException(
          code: 'test-boot-error',
          message: 'Synthetic boot failure',
          details: {'retryable': false},
        );
      });

      await expectLater(
        platform.bootWithStatus({'pluginKey': 'test-plugin-key'}),
        throwsA(
          isA<PlatformException>()
              .having((error) => error.code, 'code', 'test-boot-error')
              .having(
                  (error) => error.message, 'message', 'Synthetic boot failure')
              .having(
                  (error) => error.details, 'details', {'retryable': false}),
        ),
      );
    });
  });
}
