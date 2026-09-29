import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:channel_talk_flutter/channel_talk_flutter.dart';
import 'package:channel_talk_flutter/channel_talk_flutter_platform_interface.dart';
import 'package:channel_talk_flutter_example/main.dart' as sample;
import 'package:integration_test/integration_test.dart';

/// 실제 iOS SDK의 상담 생성 이벤트를 세 번 관찰한다. 초안은 전송하지 않는다.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const pluginKey = String.fromEnvironment('CHANNEL_TALK_PLUGIN_KEY');
  final rounds = <Map<String, Object?>>[];

  /// 종료 호출의 즉시 반환과 SDK 비동기 상태 전환을 구분한다.
  Future<void> waitForShutdown(WidgetTester tester) async {
    final timeout = Stopwatch()..start();
    while (await ChannelTalk.isBooted() == true) {
      if (timeout.elapsed > const Duration(seconds: 10)) {
        fail('SDK 종료 상태가 10초 안에 반영되지 않았다.');
      }
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('iOS 실제 onChatCreated 전달 3회 검증', (tester) async {
    expect(pluginKey, isNotEmpty, reason: '임시 환경 파일로 SDK 키를 제공해야 한다.');
    sample.main();
    await tester.pumpAndSettle();
    expect(await ChannelTalk.setDebugMode(flag: false), true);
    expect(await ChannelTalk.shutdown(), true);
    await waitForShutdown(tester);

    try {
      for (var round = 1; round <= 3; round++) {
        final created = Completer<void>();
        final events = <String, int>{};
        ChannelTalk.setListener((event, arguments) {
          events[event.name] = (events[event.name] ?? 0) + 1;
          if (event == ChannelTalkEvent.onChatCreated && !created.isCompleted) {
            created.complete();
          }
        });
        final booted = await ChannelTalk.boot(
          pluginKey: pluginKey,
          trackDefaultEvent: false,
        ).timeout(const Duration(seconds: 30));
        expect(booted, true);
        expect(await ChannelTalk.isBooted(), true);
        expect(
          await ChannelTalk.openChat(message: 'QA DRAFT - DO NOT SEND'),
          true,
        );
        await created.future.timeout(const Duration(seconds: 20));
        await tester.pumpAndSettle(const Duration(seconds: 1));
        expect(events[ChannelTalkEvent.onChatCreated.name], 1);
        if (round == 1) {
          await binding.takeScreenshot('ios_event_thread_fix_chat');
        }
        expect(await ChannelTalk.hideMessenger(), true);
        expect(await ChannelTalk.shutdown(), true);
        await waitForShutdown(tester);
        ChannelTalk.removeListener();
        rounds.add({
          'round': round,
          'boot': booted,
          'chatCreatedCount': events[ChannelTalkEvent.onChatCreated.name],
          'events': events,
          'shutdownCompleted': true,
        });
        // ignore: avoid_print
        print('IOS_EVENT_THREAD_QA ${jsonEncode(rounds.last)}');
      }
    } finally {
      await ChannelTalk.hideMessenger();
      await ChannelTalk.shutdown();
      await waitForShutdown(tester);
      ChannelTalk.removeListener();
      binding.reportData = {...?binding.reportData, 'rounds': rounds};
    }
    expect(rounds, hasLength(3));
  }, timeout: const Timeout(Duration(minutes: 5)));
}
