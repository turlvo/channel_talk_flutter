@JS()
library web_api_qa;

import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:channel_talk_flutter/channel_talk_flutter.dart';
import 'package:channel_talk_flutter/channel_talk_flutter_platform_interface.dart';

import 'package:channel_talk_flutter_example/main.dart' as sample;
import 'package:channel_talk_flutter_example/sample_boot.dart';

@JS('channelTalkQa')
external set _qaRunner(JSFunction value);

@JS('channelTalkQaEvents')
external set _qaEvents(JSFunction value);

final List<Map<String, Object?>> _events = [];

/// 샘플의 실제 호스트와 SDK를 유지하며 공개 Dart API를 브라우저에서 검증한다.
///
/// plugin key와 요청 데이터는 실행 시에만 전달하며 출력하지 않는다.
/// 실행 예: flutter run -d web-server -t integration_test/web_api_qa.dart
void main() {
  sample.main();
  _qaRunner = ((JSString method, JSString payload) {
    return _run(method.toDart, payload.toDart).toJS;
  }).toJS;
  _qaEvents = (() => jsonEncode(_events).toJS).toJS;
}

/// 테스트의 대기 한도를 적용하되 패키지 자체의 완료 시점·반환형은 바꾸지 않는다.
Future<JSString> _run(String method, String payload) async {
  final watch = Stopwatch()..start();
  try {
    final args = Map<String, dynamic>.from(jsonDecode(payload) as Map);
    final value =
        await _invoke(method, args).timeout(const Duration(seconds: 20));
    return jsonEncode({
      'method': method,
      'completed': true,
      'value': value is ChannelTalkBootStatus ? value.value : value,
      'elapsedMs': watch.elapsedMilliseconds,
    }).toJS;
  } catch (error) {
    return jsonEncode({
      'method': method,
      'completed': error is! TimeoutException,
      'errorType': error.runtimeType.toString(),
      'elapsedMs': watch.elapsedMilliseconds,
    }).toJS;
  }
}

/// 실제 이벤트가 Dart에 도착했는지만 기록하며 프로필·URL·메시지는 저장하지 않는다.
void _onEvent(ChannelTalkEvent event, dynamic arguments) {
  _events.add({
    'event': event.name,
    'at': DateTime.now().millisecondsSinceEpoch,
    if (event == ChannelTalkEvent.onPopupDataReceived)
      'hasTimestamp': arguments is Map && arguments['timestamp'] != null,
  });
}

/// 공개 API를 직접 호출해 JS SDK만 호출하는 우회 검증과 구분한다.
Future<Object?> _invoke(String method, Map<String, dynamic> args) async {
  switch (method) {
    case 'setListener':
      ChannelTalk.setListener(_onEvent);
      return null;
    case 'removeListener':
      ChannelTalk.removeListener();
      return null;
    case 'boot':
      return runSampleBoot(args);
    case 'bootWithStatus':
      return runSampleBoot(args, withStatus: true);
    case 'bootForWeb':
      return runSampleBoot(args, forWeb: true);
    case 'sleep':
      return ChannelTalk.sleep();
    case 'shutdown':
      return ChannelTalk.shutdown();
    case 'showChannelButton':
      return ChannelTalk.showChannelButton();
    case 'hideChannelButton':
      return ChannelTalk.hideChannelButton();
    case 'showMessenger':
      return ChannelTalk.showMessenger();
    case 'hideMessenger':
      return ChannelTalk.hideMessenger();
    case 'openChat':
      return ChannelTalk.openChat(
          chatId: args['chatId'], message: args['message']);
    case 'track':
      return ChannelTalk.track(
        eventName: args['eventName'] as String,
        properties: (args['properties'] as Map?)?.cast<String, dynamic>(),
      );
    case 'updateUser':
      return ChannelTalk.updateUser(
        name: args['name'],
        email: args['email'],
        mobileNumber: args['mobileNumber'],
        avatarUrl: args['avatarUrl'],
        language: args['language'] == null
            ? null
            : Language.values
                .firstWhere((value) => value.value == args['language']),
        unsubscribeEmail: args['unsubscribeEmail'],
        unsubscribeTexting: args['unsubscribeTexting'],
        tags: (args['tags'] as List?)?.cast<String>(),
        customAttributes:
            (args['customAttributes'] as Map?)?.cast<String, dynamic>(),
        profileOnce: (args['profileOnce'] as Map?)?.cast<String, dynamic>(),
      );
    case 'initPushToken':
      return ChannelTalk.initPushToken(
          deviceToken: args['deviceToken'] as String);
    case 'isChannelPushNotification':
      return ChannelTalk.isChannelPushNotification(
        content: Map<String, dynamic>.from(args['content'] as Map),
      );
    case 'receivePushNotification':
      return ChannelTalk.receivePushNotification(
        content: Map<String, dynamic>.from(args['content'] as Map),
      );
    case 'storePushNotification':
      return ChannelTalk.storePushNotification(
        content: Map<String, dynamic>.from(args['content'] as Map),
      );
    case 'hasStoredPushNotification':
      return ChannelTalk.hasStoredPushNotification();
    case 'openStoredPushNotification':
      return ChannelTalk.openStoredPushNotification();
    case 'isBooted':
      return ChannelTalk.isBooted();
    case 'setDebugMode':
      return ChannelTalk.setDebugMode(flag: args['flag'] as bool);
    case 'setPage':
      return ChannelTalk.setPage(
        page: args['page'],
        profile: (args['profile'] as Map?)?.cast<String, dynamic>(),
      );
    case 'resetPage':
      return ChannelTalk.resetPage();
    case 'addTags':
      return ChannelTalk.addTags(tags: args['tags'] as List);
    case 'removeTags':
      return ChannelTalk.removeTags(tags: args['tags'] as List);
    case 'openWorkflow':
      return ChannelTalk.openWorkflow(workflowId: args['workflowId']);
    case 'setAppearance':
      return ChannelTalk.setAppearance(
        appearance: Appearance.values
            .firstWhere((value) => value.value == args['appearance']),
      );
    case 'hidePopup':
      return ChannelTalk.hidePopup();
    case 'setPreventDefaultUrlClick':
      return ChannelTalk.setPreventDefaultUrlClick(
          prevent: args['prevent'] as bool);
    default:
      throw ArgumentError.value(method, 'method', '등록되지 않은 QA 명령');
  }
}
