import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:channel_talk_flutter/channel_talk_flutter.dart';
import 'package:channel_talk_flutter/channel_talk_flutter_platform_interface.dart';

import 'package:channel_talk_flutter_example/main.dart';

/// 샘플 UI가 공개 API에 전달하는 값만 기록하고 실제 SDK 호출은 방지한다.
class _RecordingPlatform extends ChannelTalkFlutterPlatform {
  final bootConfigs = <Map<String, dynamic>>[];
  final statusConfigs = <Map<String, dynamic>>[];
  final userUpdates = <Map<String, dynamic>>[];
  ChannelTalkDelegate? listener;

  /// bool 부팅 경로의 최종 플랫폼 설정을 기록한다.
  @override
  Future<bool?> boot(Map<String, dynamic> config) async {
    bootConfigs.add(Map<String, dynamic>.from(config));
    return true;
  }

  /// 상세 부팅 경로가 일반 boot로 바뀌지 않는지 확인한다.
  @override
  Future<ChannelTalkBootStatus> bootWithStatus(
      Map<String, dynamic> config) async {
    statusConfigs.add(Map<String, dynamic>.from(config));
    return ChannelTalkBootStatus.success;
  }

  /// 사용자 업데이트의 생략·빈 값·null 전달을 확인한다.
  @override
  Future<bool?> updateUser(Map<String, dynamic> data) async {
    userUpdates.add(Map<String, dynamic>.from(data));
    return true;
  }

  /// SDK 이벤트를 테스트에서 전달할 수 있도록 콜백을 보관한다.
  @override
  void setListener(ChannelTalkDelegate delegate) {
    listener = delegate;
  }

  /// 샘플의 명시적 리스너 해제를 반영한다.
  @override
  void removeListener() {
    listener = null;
  }
}

/// 실제 MaterialApp 문맥에서 샘플과 Toast overlay를 준비한다.
Future<void> _pumpSample(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: MyApp()));
  await tester.pumpAndSettle();
}

/// Flutter가 테스트 종료 불변식을 검사하기 전에 Toast의 타이머를 소진한다.
Future<void> _finishSample(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 4));
  await tester.pumpAndSettle();
  await tester.pumpWidget(const SizedBox.shrink());
}

/// 실제 목록의 버튼을 눌러 JSON 입력 다이얼로그를 연다.
Future<Map<String, dynamic>> _openPayloadDialog(
  WidgetTester tester,
  String buttonLabel,
) async {
  final button = find.widgetWithText(ElevatedButton, buttonLabel);
  await tester.scrollUntilVisible(
    button,
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(button);
  await tester.pumpAndSettle();
  final field = tester.widget<TextField>(find.byType(TextField));
  return (jsonDecode(field.controller!.text) as Map).cast<String, dynamic>();
}

/// 사용자가 JSON을 편집하고 OK를 누르는 경로를 그대로 실행한다.
Future<void> _submitPayload(
  WidgetTester tester,
  Map<String, dynamic> payload,
) async {
  await tester.enterText(find.byType(TextField), jsonEncode(payload));
  final submit = find.widgetWithText(TextButton, 'OK');
  await tester.ensureVisible(submit);
  await tester.tap(submit);
  await tester.pumpAndSettle();
}

/// 샘플의 입력·실행·팝업 표시가 플랫폼 공개 계약과 연결되는지 검증한다.
void main() {
  late _RecordingPlatform platform;
  late ChannelTalkFlutterPlatform previousPlatform;

  setUp(() {
    previousPlatform = ChannelTalkFlutterPlatform.instance;
    platform = _RecordingPlatform();
    ChannelTalkFlutterPlatform.instance = platform;
  });

  tearDown(() {
    ChannelTalkFlutterPlatform.instance = previousPlatform;
  });

  for (final button in ['boot', 'bootWithStatus', 'bootForWeb']) {
    testWidgets('$button 기본 JSON은 신규 프로필과 지원하는 배치 옵션을 보여준다', (tester) async {
      await _pumpSample(tester);
      final defaults = await _openPayloadDialog(tester, button);

      expect(defaults['customAttributes'], isA<Map>());
      if (button == 'bootForWeb') {
        expect(defaults.containsKey('channelButtonOption'), isFalse);
        expect(defaults.containsKey('bubbleOption'), isFalse);
      } else {
        expect(defaults['channelButtonOption'], isA<Map>());
        expect(defaults['bubbleOption'], isA<Map>());
      }

      await tester.ensureVisible(find.widgetWithText(TextButton, 'Cancel'));
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();
      expect(platform.bootConfigs, isEmpty);
      expect(platform.statusConfigs, isEmpty);
      await _finishSample(tester);
    });

    testWidgets('$button JSON 편집은 프로필과 타입 변환된 옵션을 플랫폼에 전달한다', (tester) async {
      await _pumpSample(tester);
      await _openPayloadDialog(tester, button);
      final payload = <String, dynamic>{
        'pluginKey': 'sample-plugin-key',
        'name': 'Sample name',
        'customAttributes': {'active': false, 'points': 0, 'expiredAt': null},
        if (button != 'bootForWeb')
          'channelButtonOption': {
            'icon': 'headset',
            'position': 'left',
            'xMargin': 12.5,
            'yMargin': 0,
          },
        if (button != 'bootForWeb')
          'bubbleOption': {'position': 'bottom', 'yMargin': 0},
        if (button == 'bootForWeb') 'hideChannelButtonOnBoot': false,
      };

      await _submitPayload(tester, payload);

      final config = button == 'bootWithStatus'
          ? platform.statusConfigs.single
          : platform.bootConfigs.single;
      expect(config['pluginKey'], 'sample-plugin-key');
      expect(config['customAttributes'], payload['customAttributes']);
      if (button != 'bootForWeb') {
        expect(config['channelButtonOption'], payload['channelButtonOption']);
        expect(config['bubbleOption'], payload['bubbleOption']);
        final channelOption = config['channelButtonOption'] as Map;
        expect(channelOption['xMargin'], isA<double>());
        expect(channelOption['yMargin'], isA<double>());
      } else {
        expect(config.containsKey('channelButtonOption'), isFalse);
        expect(config.containsKey('bubbleOption'), isFalse);
        expect(config['hideChannelButtonOnBoot'], isFalse);
      }
      if (button == 'bootWithStatus') {
        expect(platform.bootConfigs, isEmpty);
        expect(find.text('Result: success'), findsOneWidget);
      } else {
        expect(platform.statusConfigs, isEmpty);
      }
      await _finishSample(tester);
    });
  }

  for (final button in ['boot', 'bootWithStatus']) {
    testWidgets('$button 기본 배치 옵션을 JSON에서 삭제하면 생략해 전달한다', (tester) async {
      await _pumpSample(tester);
      final payload = await _openPayloadDialog(tester, button);
      payload.remove('channelButtonOption');
      payload.remove('bubbleOption');

      await _submitPayload(tester, payload);

      final config = button == 'bootWithStatus'
          ? platform.statusConfigs.single
          : platform.bootConfigs.single;
      expect(config.containsKey('channelButtonOption'), isFalse);
      expect(config.containsKey('bubbleOption'), isFalse);
      await _finishSample(tester);
    });
  }

  for (final profileOnce in <Map<String, dynamic>>[
    {},
    {'source': 'sample', 'subscribed': false, 'rank': 0, 'campaign': null},
  ]) {
    testWidgets('updateUser profileOnce의 빈 값과 false·0·null을 보존한다: $profileOnce',
        (tester) async {
      await _pumpSample(tester);
      final defaults = await _openPayloadDialog(tester, 'updateUser');
      expect(defaults['profileOnce'], isA<Map>());
      final payload = <String, dynamic>{
        'unsubscribeEmail': false,
        'customAttributes': {'active': false, 'points': 0, 'removedAt': null},
        'profileOnce': profileOnce,
      };

      await _submitPayload(tester, payload);

      final update = platform.userUpdates.single;
      expect(update['profileOnce'], profileOnce);
      expect(update['customAttributes'], payload['customAttributes']);
      expect(update['unsubscribeEmail'], isFalse);
      expect(update.containsKey('language'), isFalse);
      await _finishSample(tester);
    });
  }

  testWidgets('profileOnce만 입력하면 기본 JSON의 이름·언어·다른 속성을 보내지 않는다',
      (tester) async {
    await _pumpSample(tester);
    await _openPayloadDialog(tester, 'updateUser');

    await _submitPayload(tester, {
      'profileOnce': {'signupSource': 'sample'},
    });

    expect(platform.userUpdates.single, {
      'profileOnce': {'signupSource': 'sample'},
    });
    await _finishSample(tester);
  });

  testWidgets('팝업은 원본 timestamp만 화면에 표시하고 메시지 본문은 표시하지 않는다', (tester) async {
    await _pumpSample(tester);
    expect(find.text('최근 팝업 timestamp: 수신 대기'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'register listener'));
    await tester.pumpAndSettle();

    platform.listener!(ChannelTalkEvent.onPopupDataReceived, {
      'timestamp': 1725000123456,
      'message': 'sample-private-popup-body',
      'name': 'Sample sender',
    });
    await tester.pump();

    expect(find.text('최근 팝업 timestamp: 1725000123456'), findsOneWidget);
    expect(find.textContaining('sample-private-popup-body'), findsNothing);
    expect(find.textContaining('Sample sender'), findsNothing);
    await _finishSample(tester);
    expect(platform.listener, isNull);
  });
}
