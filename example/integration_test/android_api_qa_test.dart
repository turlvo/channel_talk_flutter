// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:channel_talk_flutter/channel_talk_flutter.dart';
import 'package:channel_talk_flutter/channel_talk_flutter_platform_interface.dart';
import 'package:integration_test/integration_test.dart';

import 'package:channel_talk_flutter_example/main.dart' as sample;

const _PLUGIN_KEY = String.fromEnvironment('CHANNEL_TALK_PLUGIN_KEY');
const _ALLOW_SERVER_MUTATIONS =
    bool.fromEnvironment('QA_ALLOW_SERVER_MUTATIONS');
const _QA_DIRECTORY =
    '/data/user/0/com.kuku.channel_talk_flutter_example/files';

/// 실제 Android SDK에 공개 API를 호출하고 개인정보 없는 결과만 기록한다.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Android public API live SDK QA', (tester) async {
    expect(_PLUGIN_KEY, isNotEmpty, reason: '임시 dart-define 파일의 키가 필요합니다.');
    sample.main();
    await tester.pumpAndSettle();
    final results = <Map<String, Object?>>[];
    final events = <String, int>{};

    /// 특정 시나리오가 실패해도 나머지 API 검증과 정리를 계속한다.
    Future<void> check(
      String name,
      FutureOr<Object?> Function() action, {
      Object? expected = true,
      String? expectedError,
    }) async {
      const mutationCases = {
        'track',
        'updateUser.customAttributes',
        'updateUser.profileOnce.repeat',
        'addTags',
        'removeTags',
        'updateUser.cleanup',
      };
      if (!_ALLOW_SERVER_MUTATIONS && mutationCases.contains(name)) {
        results.add({'case': name, 'pass': null, 'status': 'approval_pending'});
        return;
      }
      try {
        final value = await Future<Object?>.sync(action)
            .timeout(const Duration(seconds: 45));
        results.add({
          'case': name,
          'pass': expectedError == null && value == expected,
          'result': value is Enum ? value.name : value
        });
      } on PlatformException catch (error) {
        results.add({
          'case': name,
          'pass': error.code == expectedError,
          'error': error.code
        });
      } catch (error) {
        results.add({
          'case': name,
          'pass': false,
          'error': error.runtimeType.toString()
        });
      }
      // 사용자 객체, 이벤트 payload, 토큰과 키는 결과에 포함하지 않는다.
      // ignore: avoid_print
      print('QA_RESULT ${jsonEncode(results.last)}');
    }

    /// 외부 ADB 캡처가 네이티브 화면을 포함하도록 현재 단계를 표시한다.
    Future<void> screenshotStage(String stage) async {
      await File('$_QA_DIRECTORY/qa_stage').writeAsString(stage);
      await Future<void>.delayed(const Duration(seconds: 4));
    }

    /// 이벤트 발생 횟수만 수집하여 개인정보 payload 저장을 피한다.
    void listener(ChannelTalkEvent event, dynamic payload) {
      events.update(event.name, (value) => value + 1, ifAbsent: () => 1);
    }

    await tester.runAsync(() async {
      await Directory(_QA_DIRECTORY).create(recursive: true);
      await check('shutdown.initial', ChannelTalk.shutdown);
      await check('isBooted.before', ChannelTalk.isBooted, expected: false);
      await check(
          'setDebugMode.true', () => ChannelTalk.setDebugMode(flag: true));
      await check(
          'setDebugMode.false', () => ChannelTalk.setDebugMode(flag: false));
      await check('setListener', () {
        ChannelTalk.setListener(listener);
        return true;
      });
      await check('updateUser.beforeBoot', () => ChannelTalk.updateUser(),
          expectedError: 'UNAVAILABLE');
      await check('boot', () => ChannelTalk.boot(pluginKey: _PLUGIN_KEY));
      await check('isBooted.after', ChannelTalk.isBooted);
      await check('bootWithStatus',
          () => ChannelTalk.bootWithStatus(pluginKey: _PLUGIN_KEY),
          expected: ChannelTalkBootStatus.success);
      await check('bootForWeb.mobileRouting',
          () => ChannelTalk.bootForWeb(pluginKey: _PLUGIN_KEY));
      await check('showChannelButton', ChannelTalk.showChannelButton);
      await screenshotStage('button_visible');
      await check('hideChannelButton', ChannelTalk.hideChannelButton);
      await screenshotStage('button_hidden');
      await check('showMessenger', ChannelTalk.showMessenger);
      await screenshotStage('messenger');
      await check('hideMessenger', ChannelTalk.hideMessenger);
      await check(
          'setPage',
          () => ChannelTalk.setPage(
              page: 'qa/android/20260929', profile: {'qaPage': 'android'}));
      await check('setPage.null', () => ChannelTalk.setPage());
      await check('resetPage', ChannelTalk.resetPage);
      await check(
          'track',
          () => ChannelTalk.track(
              eventName: 'QAAndroidApiCheck',
              properties: {'platform': 'android'}));
      await check('track.empty', () => ChannelTalk.track(eventName: ''),
          expectedError: 'UNAVAILABLE');
      await check(
          'updateUser.customAttributes',
          () => ChannelTalk.updateUser(
              customAttributes: {'qaAndroid20260929': 'initial'},
              profileOnce: {'qaAndroidOnce20260929': 'initial'}));
      await check(
          'updateUser.profileOnce.repeat',
          () => ChannelTalk.updateUser(
              customAttributes: {'qaAndroid20260929': 'updated'},
              profileOnce: {'qaAndroidOnce20260929': 'replacement'}));
      await check(
          'addTags', () => ChannelTalk.addTags(tags: ['qa_android_20260929']));
      await check('removeTags',
          () => ChannelTalk.removeTags(tags: ['qa_android_20260929']));
      await check(
          'addTags.overLimit',
          () => ChannelTalk.addTags(
              tags: List.generate(11, (index) => 'qa_$index')),
          expected: false);
      await check('addTags.empty', () => ChannelTalk.addTags(tags: []),
          expectedError: 'UNAVAILABLE');
      await check('removeTags.empty', () => ChannelTalk.removeTags(tags: []),
          expectedError: 'UNAVAILABLE');
      for (final appearance in Appearance.values) {
        await check('setAppearance.${appearance.name}',
            () => ChannelTalk.setAppearance(appearance: appearance));
        if (appearance == Appearance.dark) {
          await ChannelTalk.showMessenger();
          await screenshotStage('messenger_dark');
          await ChannelTalk.hideMessenger();
        }
      }
      await ChannelTalk.setAppearance(appearance: Appearance.system);
      await check('hidePopup.noPopup', ChannelTalk.hidePopup);
      await check('setPreventDefaultUrlClick.true',
          () => ChannelTalk.setPreventDefaultUrlClick(prevent: true));
      await check('setPreventDefaultUrlClick.false',
          () => ChannelTalk.setPreventDefaultUrlClick(prevent: false));
      await check('openChat.prefillOnly',
          () => ChannelTalk.openChat(message: 'QA draft only'));
      await screenshotStage('chat_draft');
      await ChannelTalk.hideMessenger();
      await check('openWorkflow.noId', ChannelTalk.openWorkflow);
      await screenshotStage('workflow_no_id');
      await ChannelTalk.hideMessenger();
      await check('initPushToken.empty',
          () => ChannelTalk.initPushToken(deviceToken: ''),
          expectedError: 'UNAVAILABLE');
      await check(
          'isChannelPushNotification.other',
          () => ChannelTalk.isChannelPushNotification(
              content: {'qa': 'not_channel_push'}),
          expected: false);
      await check(
          'receivePushNotification.other',
          () => ChannelTalk.receivePushNotification(
              content: {'qa': 'not_channel_push'}));
      await check('receivePushNotification.empty',
          () => ChannelTalk.receivePushNotification(content: {}),
          expectedError: 'UNAVAILABLE');
      await check(
          'storePushNotification.unsupported',
          () => ChannelTalk.storePushNotification(
              content: {'qa': 'not_channel_push'}),
          expectedError: 'UNAVAILABLE');
      await check('hasStoredPushNotification.empty',
          ChannelTalk.hasStoredPushNotification,
          expected: false);
      await check('openStoredPushNotification.empty',
          ChannelTalk.openStoredPushNotification);
      await Future<void>.delayed(const Duration(seconds: 1));
      final beforeRemove = events['onShowMessenger'] ?? 0;
      await check('setListener.eventReceived', () => beforeRemove > 0);
      await check('removeListener', () {
        ChannelTalk.removeListener();
        return true;
      });
      await ChannelTalk.showMessenger();
      await Future<void>.delayed(const Duration(seconds: 1));
      await ChannelTalk.hideMessenger();
      await check('removeListener.noCallback',
          () => (events['onShowMessenger'] ?? 0) == beforeRemove);
      ChannelTalk.setListener(listener);
      await ChannelTalk.showMessenger();
      await Future<void>.delayed(const Duration(seconds: 1));
      await ChannelTalk.hideMessenger();
      await check('setListener.reregister',
          () => (events['onShowMessenger'] ?? 0) > beforeRemove);
      await check(
          'updateUser.cleanup',
          () => ChannelTalk.updateUser(customAttributes: {
                'qaAndroid20260929': null,
                'qaAndroidOnce20260929': null
              }));
      await check('sleep', ChannelTalk.sleep);
      await check(
          'boot.afterSleep', () => ChannelTalk.boot(pluginKey: _PLUGIN_KEY));
      await check('shutdown.final', ChannelTalk.shutdown);
      await check('isBooted.final', ChannelTalk.isBooted, expected: false);
      ChannelTalk.removeListener();
      // ignore: avoid_print
      print('QA_REPORT ${jsonEncode({'results': results, 'events': events})}');
      await File('$_QA_DIRECTORY/qa_stage').writeAsString('complete');
      await File('$_QA_DIRECTORY/qa_results.json')
          .writeAsString(jsonEncode({'results': results, 'events': events}));
    });
    binding.reportData = {'results': results, 'events': events};
    expect(
        results.where((result) =>
            result['status'] != 'approval_pending' && result['pass'] != true),
        isEmpty);
  }, timeout: const Timeout(Duration(minutes: 12)));
}
