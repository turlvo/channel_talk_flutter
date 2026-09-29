import 'package:flutter_test/flutter_test.dart';

import 'package:channel_talk_flutter/channel_talk_flutter.dart';
import 'package:channel_talk_flutter/channel_talk_flutter_platform_interface.dart';

import 'package:channel_talk_flutter_example/sample_boot.dart';

/// 파서가 최종 공개 API에 넘기는 옵션과 반환 경로를 기록한다.
class _RecordingBootPlatform extends ChannelTalkFlutterPlatform {
  final bootConfigs = <Map<String, dynamic>>[];
  final statusConfigs = <Map<String, dynamic>>[];
  bool bootResult = true;
  ChannelTalkBootStatus bootStatus = ChannelTalkBootStatus.success;

  /// 일반 부팅 및 웹 부팅 결과를 호출자에게 그대로 돌려준다.
  @override
  Future<bool?> boot(Map<String, dynamic> config) async {
    bootConfigs.add(config);
    return bootResult;
  }

  /// 상태 부팅이 bool로 축약되지 않는지 확인한다.
  @override
  Future<ChannelTalkBootStatus> bootWithStatus(
      Map<String, dynamic> config) async {
    statusConfigs.add(config);
    return bootStatus;
  }
}

/// 입력 오류로 SDK를 호출하지 않고 JSON 값의 의미를 보존하는지 검증한다.
void main() {
  late _RecordingBootPlatform platform;
  late ChannelTalkFlutterPlatform previousPlatform;

  setUp(() {
    previousPlatform = ChannelTalkFlutterPlatform.instance;
    platform = _RecordingBootPlatform();
    ChannelTalkFlutterPlatform.instance = platform;
  });

  tearDown(() {
    ChannelTalkFlutterPlatform.instance = previousPlatform;
  });

  test('정수·소수 여백을 double로 변환하고 프로필의 중첩 null을 유지한다', () async {
    final args = <String, dynamic>{
      'pluginKey': 'sample-plugin-key',
      'language': 'ko',
      'appearance': 'dark',
      'customAttributes': {
        'active': false,
        'points': 0,
        'metadata': {'removed': null},
      },
      'channelButtonOption': {
        'icon': 'headset',
        'position': 'left',
        'xMargin': 16,
        'yMargin': 23.5,
      },
      'bubbleOption': {'position': 'bottom', 'yMargin': 0},
    };

    expect(await runSampleBoot(args), isTrue);

    final config = platform.bootConfigs.single;
    expect(config['customAttributes'], args['customAttributes']);
    expect(config['language'], 'ko');
    expect(config['appearance'], 'dark');
    expect(config['channelButtonOption'], args['channelButtonOption']);
    final button = config['channelButtonOption'] as Map;
    expect(button['xMargin'], isA<double>());
    expect(button['yMargin'], isA<double>());
    expect(config['bubbleOption'], {'position': 'bottom', 'yMargin': 0.0});
    expect(platform.statusConfigs, isEmpty);
  });

  test('옵션 생략과 명시적 null은 플랫폼 설정에서 모두 생략된다', () async {
    for (final options in [
      <String, dynamic>{},
      {
        'channelButtonOption': null,
        'bubbleOption': null,
        'customAttributes': null
      },
    ]) {
      await runSampleBoot({'pluginKey': 'sample-plugin-key', ...options});

      expect(platform.bootConfigs.last, {'pluginKey': 'sample-plugin-key'});
    }
  });

  test('빈 배치 객체는 Dart 기본값을 적용하고 팝업 여백은 생략한다', () async {
    await runSampleBoot({
      'pluginKey': 'sample-plugin-key',
      'channelButtonOption': <String, dynamic>{},
      'bubbleOption': <String, dynamic>{},
    });

    expect(platform.bootConfigs.single['channelButtonOption'], {
      'icon': 'channel',
      'position': 'right',
      'xMargin': 20.0,
      'yMargin': 20.0,
    });
    expect(platform.bootConfigs.single['bubbleOption'], {'position': 'top'});
  });

  test('일반 부팅 실패와 상세 부팅 실패 상태를 바꾸지 않고 반환한다', () async {
    platform.bootResult = false;
    platform.bootStatus = ChannelTalkBootStatus.networkTimeout;

    expect(await runSampleBoot({'pluginKey': 'sample-plugin-key'}), isFalse);
    expect(
      await runSampleBoot({'pluginKey': 'sample-plugin-key'}, withStatus: true),
      ChannelTalkBootStatus.networkTimeout,
    );
    expect(platform.bootConfigs, hasLength(1));
    expect(platform.statusConfigs, hasLength(1));
  });

  test('웹 전용 옵션과 false·0·프로필 null을 그대로 전달한다', () async {
    final args = <String, dynamic>{
      'pluginKey': 'sample-plugin-key',
      'customLauncherSelector': '#sample-launcher',
      'hideChannelButtonOnBoot': false,
      'zIndex': 0,
      'trackUtmSource': false,
      'customAttributes': {'plan': 'sample', 'removedAt': null},
      'channelButtonOption': null,
      'bubbleOption': null,
    };

    expect(await runSampleBoot(args, forWeb: true), isTrue);

    final expected = Map<String, dynamic>.from(args)
      ..remove('channelButtonOption')
      ..remove('bubbleOption');
    expect(platform.bootConfigs.single, expected);
    expect(platform.statusConfigs, isEmpty);
  });

  final invalidEnumConfigs = <String, Map<String, dynamic>>{
    'language': {'language': 'unknown-language'},
    'appearance': {'appearance': 'unknown-appearance'},
    'button icon': {
      'channelButtonOption': {'icon': 'unknown-icon'},
    },
    'button position': {
      'channelButtonOption': {'position': 'center'},
    },
    'bubble position': {
      'bubbleOption': {'position': 'center'},
    },
  };
  for (final entry in invalidEnumConfigs.entries) {
    test('${entry.key} 오타는 Future 오류로 알리고 SDK를 호출하지 않는다', () async {
      await expectLater(
        runSampleBoot({'pluginKey': 'sample-plugin-key', ...entry.value}),
        throwsFormatException,
      );

      expect(platform.bootConfigs, isEmpty);
      expect(platform.statusConfigs, isEmpty);
    });
  }

  for (final option in [
    'customAttributes',
    'channelButtonOption',
    'bubbleOption'
  ]) {
    test('$option 객체 대신 배열을 입력하면 SDK 호출 전에 거부한다', () async {
      await expectLater(
        runSampleBoot({'pluginKey': 'sample-plugin-key', option: <dynamic>[]}),
        throwsFormatException,
      );

      expect(platform.bootConfigs, isEmpty);
    });
  }

  test('옵션 객체의 문자열이 아닌 키를 거부한다', () async {
    await expectLater(
      runSampleBoot({
        'pluginKey': 'sample-plugin-key',
        'customAttributes': {1: 'invalid-key'},
      }),
      throwsFormatException,
    );

    expect(platform.bootConfigs, isEmpty);
  });

  for (final margin in <Object>['20', double.nan, double.infinity]) {
    test('잘못된 숫자 여백 $margin은 SDK 호출 전에 거부한다', () async {
      await expectLater(
        runSampleBoot({
          'pluginKey': 'sample-plugin-key',
          'channelButtonOption': {'xMargin': margin},
        }),
        throwsFormatException,
      );

      expect(platform.bootConfigs, isEmpty);
    });
  }

  for (final option in ['channelButtonOption', 'bubbleOption']) {
    test('웹 실행에 $option 객체가 있으면 비동기 미지원 오류를 알린다', () async {
      await expectLater(
        runSampleBoot(
          {'pluginKey': 'sample-plugin-key', option: <String, dynamic>{}},
          forWeb: true,
        ),
        throwsUnsupportedError,
      );

      expect(platform.bootConfigs, isEmpty);
      expect(platform.statusConfigs, isEmpty);
    });
  }
}
