import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:channel_talk_flutter/channel_talk_flutter.dart';
import 'package:channel_talk_flutter/channel_talk_flutter_platform_interface.dart';
import 'package:integration_test/integration_test.dart';

import 'package:channel_talk_flutter_example/main.dart' as sample;

/// 실제 iOS SDK 응답만 기록하며 키와 사용자 payload는 출력하지 않는다.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const pluginKey = String.fromEnvironment('CHANNEL_TALK_PLUGIN_KEY');
  const memberId = String.fromEnvironment('CHANNEL_TALK_QA_MEMBER_ID');
  const allowDataWrites =
      bool.fromEnvironment('CHANNEL_TALK_ALLOW_DATA_WRITES');
  final rows = <Map<String, Object?>>[];
  final events = <ChannelTalkEvent, int>{};
  final failures = <String>[];

  /// 서버 완료 여부와 브리지 호출 성공을 구분할 수 있도록 개별 결과를 남긴다.
  Future<Object?> runApi(
    String name,
    Future<Object?> Function() action, {
    Object? expected = true,
    String? errorCode,
  }) async {
    final timer = Stopwatch()..start();
    try {
      final value = await action().timeout(const Duration(seconds: 40));
      final safe = value is ChannelTalkBootStatus ? value.value : value;
      final ok = errorCode == null && safe == expected;
      rows.add({
        'case': name,
        'result': safe,
        'ok': ok,
        'ms': timer.elapsedMilliseconds
      });
      if (!ok) failures.add(name);
      // ignore: avoid_print
      print('IOS_QA ${jsonEncode(rows.last)}');
      return value;
    } catch (error) {
      final code = error is PlatformException
          ? error.code
          : error.runtimeType.toString();
      final ok = code == errorCode;
      rows.add({
        'case': name,
        'errorType': code,
        'ok': ok,
        'ms': timer.elapsedMilliseconds
      });
      if (!ok) failures.add(name);
      // ignore: avoid_print
      print('IOS_QA ${jsonEncode(rows.last)}');
      return null;
    }
  }

  /// 이벤트 인자의 사용자 정보를 수집하지 않고 종류와 횟수만 확인한다.
  void listen() {
    ChannelTalk.setListener((event, arguments) {
      events[event] = (events[event] ?? 0) + 1;
    });
  }

  testWidgets('iOS 공개 API 실제 SDK 검증', (tester) async {
    expect(pluginKey, isNotEmpty, reason: '임시 환경 파일로 SDK 키를 제공해야 한다.');
    if (allowDataWrites) {
      expect(memberId, isNotEmpty, reason: '검증 전용 회원 식별자를 제공해야 한다.');
    }
    sample.main();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('ios_sample_start');
    await runApi(
        'setDebugMode(false)', () => ChannelTalk.setDebugMode(flag: false));
    await runApi('shutdown.initial', ChannelTalk.shutdown);
    await runApi('isBooted.beforeBoot', ChannelTalk.isBooted, expected: false);
    await runApi('updateUser.beforeBoot', () => ChannelTalk.updateUser(),
        errorCode: 'updateUser');
    listen();
    await runApi(
        'boot',
        () => ChannelTalk.boot(
              pluginKey: pluginKey,
              memberId: allowDataWrites ? memberId : null,
              language: Language.korean,
              trackDefaultEvent: false,
              customAttributes:
                  allowDataWrites ? const {'qaIosApi': 'boot'} : null,
              channelButtonOption: const ChannelButtonOption(),
              bubbleOption: const BubbleOption(),
            ));
    await runApi('isBooted.afterBoot', ChannelTalk.isBooted);
    await runApi('showChannelButton', ChannelTalk.showChannelButton);
    await tester.pumpAndSettle(const Duration(milliseconds: 600));
    await binding.takeScreenshot('ios_channel_button_visible');
    await runApi('hideChannelButton', ChannelTalk.hideChannelButton);
    await tester.pumpAndSettle(const Duration(milliseconds: 600));
    await binding.takeScreenshot('ios_channel_button_hidden');
    await runApi('showMessenger', ChannelTalk.showMessenger);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await binding.takeScreenshot('ios_messenger_light');
    await runApi('setAppearance.dark',
        () => ChannelTalk.setAppearance(appearance: Appearance.dark));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await binding.takeScreenshot('ios_messenger_dark');
    await runApi('setAppearance.light',
        () => ChannelTalk.setAppearance(appearance: Appearance.light));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await binding.takeScreenshot('ios_messenger_explicit_light');
    await runApi('setAppearance.system',
        () => ChannelTalk.setAppearance(appearance: Appearance.system));
    await runApi('hideMessenger', ChannelTalk.hideMessenger);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    final shows = events[ChannelTalkEvent.onShowMessenger] ?? 0;
    final hides = events[ChannelTalkEvent.onHideMessenger] ?? 0;
    ChannelTalk.removeListener();
    await runApi('showMessenger.afterRemove', ChannelTalk.showMessenger);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await runApi('hideMessenger.afterRemove', ChannelTalk.hideMessenger);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    final removed = (events[ChannelTalkEvent.onShowMessenger] ?? 0) == shows &&
        (events[ChannelTalkEvent.onHideMessenger] ?? 0) == hides;
    rows.add({'case': 'removeListener.eventsStopped', 'ok': removed});
    if (!removed) failures.add('removeListener.eventsStopped');
    listen();
    await runApi('showMessenger.afterReregister', ChannelTalk.showMessenger);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await runApi('hideMessenger.afterReregister', ChannelTalk.hideMessenger);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    final resumed = (events[ChannelTalkEvent.onShowMessenger] ?? 0) > shows &&
        (events[ChannelTalkEvent.onHideMessenger] ?? 0) > hides;
    rows.add({'case': 'setListener.eventsResumed', 'ok': resumed});
    if (!resumed) failures.add('setListener.eventsResumed');
    await runApi(
        'setPage.pageAndProfile',
        () => ChannelTalk.setPage(
              page: 'qa-ios-api',
              profile: const {'qaIosChat': true},
            ));
    await runApi(
        'setPage.profileOnly',
        () => ChannelTalk.setPage(
              profile: const {'qaIosChat': null},
            ));
    await runApi('resetPage', ChannelTalk.resetPage);
    if (allowDataWrites) {
      await runApi(
          'track',
          () => ChannelTalk.track(
                eventName: 'qa_ios_api_check',
                properties: const {'qa': true},
              ));
      await runApi(
          'updateUser.profileOnce',
          () => ChannelTalk.updateUser(
                customAttributes: const {'qaIosApi': 'updated'},
                profileOnce: const {'qaIosOnce': 'first'},
              ));
      await runApi(
          'updateUser.profileOnceAgain',
          () => ChannelTalk.updateUser(
                profileOnce: const {'qaIosOnce': 'second'},
              ));
      await runApi('updateUser.tags',
          () => ChannelTalk.updateUser(tags: ['qa-ios-initial']));
      await runApi(
          'addTags', () => ChannelTalk.addTags(tags: ['qa-ios-added']));
      await runApi(
          'addTags.overLimit',
          () => ChannelTalk.addTags(
                tags:
                    List<String>.generate(11, (index) => 'qa-ios-limit-$index'),
              ),
          expected: false);
      await runApi(
          'removeTags', () => ChannelTalk.removeTags(tags: ['qa-ios-added']));
      await runApi(
          'updateUser.emptyTags', () => ChannelTalk.updateUser(tags: []));
    } else {
      for (final name in [
        'track',
        'updateUser.profile',
        'updateUser.profileOnce',
        'updateUser.tags',
        'addTags',
        'removeTags'
      ]) {
        rows.add({'case': name, 'skipped': '서버 데이터 변경 승인 필요'});
      }
    }
    await runApi('hidePopup.noPopup', ChannelTalk.hidePopup);
    await runApi('setPreventDefaultUrlClick.true',
        () => ChannelTalk.setPreventDefaultUrlClick(prevent: true));
    await runApi('setPreventDefaultUrlClick.false',
        () => ChannelTalk.setPreventDefaultUrlClick(prevent: false));
    await runApi('isChannelPushNotification.empty',
        () => ChannelTalk.isChannelPushNotification(content: const {}),
        expected: false);
    await runApi('receivePushNotification.empty',
        () => ChannelTalk.receivePushNotification(content: const {}));
    await runApi('storePushNotification.empty',
        () => ChannelTalk.storePushNotification(content: const {}));
    await runApi('hasStoredPushNotification.empty',
        ChannelTalk.hasStoredPushNotification,
        expected: false);
    await runApi('openStoredPushNotification.empty',
        ChannelTalk.openStoredPushNotification);
    await runApi('openWorkflow.null', ChannelTalk.openWorkflow);
    await runApi('openWorkflow.invalid',
        () => ChannelTalk.openWorkflow(workflowId: 'qa-no-workflow'));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await binding.takeScreenshot('ios_workflow_invalid');
    await runApi('hideMessenger.afterWorkflow', ChannelTalk.hideMessenger);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await runApi('openChat.prefill',
        () => ChannelTalk.openChat(message: 'QA DRAFT - DO NOT SEND'));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await binding.takeScreenshot('ios_chat_prefill');
    await runApi('hideMessenger.afterChat', ChannelTalk.hideMessenger);
    if (allowDataWrites) {
      await runApi(
          'updateUser.cleanup',
          () => ChannelTalk.updateUser(
                customAttributes: const {'qaIosApi': null, 'qaIosOnce': null},
                tags: [],
              ));
    }
    await runApi('sleep', ChannelTalk.sleep);
    await runApi('shutdown.afterSleep', ChannelTalk.shutdown);
    await runApi(
        'bootWithStatus',
        () => ChannelTalk.bootWithStatus(
              pluginKey: pluginKey,
              memberId: allowDataWrites ? memberId : null,
              trackDefaultEvent: false,
            ),
        expected: 'success');
    await runApi('shutdown.beforeWebBoot', ChannelTalk.shutdown);
    await runApi(
        'bootForWeb.onIOS',
        () => ChannelTalk.bootForWeb(
              pluginKey: pluginKey,
              memberId: allowDataWrites ? memberId : null,
              trackDefaultEvent: false,
              hideChannelButtonOnBoot: true,
              zIndex: 0,
            ));
    await runApi('shutdown.final', ChannelTalk.shutdown);
    await runApi('isBooted.afterShutdown', ChannelTalk.isBooted,
        expected: false);
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    await runApi('isBooted.afterShutdown500ms', ChannelTalk.isBooted,
        expected: false);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await runApi('isBooted.afterShutdown2500ms', ChannelTalk.isBooted,
        expected: false);
    await runApi('initPushToken.empty',
        () => ChannelTalk.initPushToken(deviceToken: ''));
    ChannelTalk.removeListener();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('ios_sample_finished');
    binding.reportData = {
      ...?binding.reportData,
      'cases': rows,
      'events': {
        for (final event in events.entries) event.key.name: event.value,
      },
      'failures': failures
    };
    // ignore: avoid_print
    print('IOS_QA_SUMMARY ${jsonEncode({
          'cases': rows,
          'events': {
            for (final entry in events.entries) entry.key.name: entry.value
          },
          'failures': failures
        })}');
    expect(failures, isEmpty);
  }, timeout: const Timeout(Duration(minutes: 15)));
}
