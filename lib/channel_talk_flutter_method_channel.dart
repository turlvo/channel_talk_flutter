import 'package:channel_talk_flutter/channel_talk_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'channel_talk_flutter_platform_interface.dart';

/// An implementation of [ChannelTalkFlutterPlatform] that uses method channels.
class MethodChannelChannelTalkFlutter extends ChannelTalkFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('channel_talk_flutter');
  static ChannelTalkDelegate? _channelTalkDelegate;

  @override
  void setListener(ChannelTalkDelegate delegate) {
    _channelTalkDelegate = delegate;
    methodChannel.setMethodCallHandler(_handleMethod);
  }

  // Removes the callback listener if it exists
  @override
  void removeListener() {
    methodChannel.setMethodCallHandler(null);
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    final ChannelTalkDelegate? callback = _channelTalkDelegate;
    if (callback == null) {
      return;
    }

    switch (call.method) {
      case 'onShowMessenger':
        return callback(ChannelTalkEvent.onShowMessenger, {});
      case 'onHideMessenger':
        return callback(ChannelTalkEvent.onHideMessenger, {});
      case 'onChatCreated':
        return callback(ChannelTalkEvent.onChatCreated, call.arguments);
      case 'onBadgeChanged':
        return callback(ChannelTalkEvent.onBadgeChanged, call.arguments);
      case 'onFollowUpChanged':
        return callback(ChannelTalkEvent.onFollowUpChanged, call.arguments);
      case 'onUrlClicked':
        return callback(ChannelTalkEvent.onUrlClicked, call.arguments);
      case 'onPopupDataReceived':
        return callback(ChannelTalkEvent.onPopupDataReceived, call.arguments);
      case 'onPushNotificationClicked':
        return callback(
            ChannelTalkEvent.onPushNotificationClicked, call.arguments);
      default:
        throw Exception('Not supported event');
    }
  }

  @override
  Future<bool?> boot(config) {
    return methodChannel.invokeMethod('boot', config);
  }

  @override
  Future<bool?> sleep() {
    return methodChannel.invokeMethod('sleep');
  }

  @override
  Future<bool?> shutdown() {
    return methodChannel.invokeMethod('shutdown');
  }

  @override
  Future<bool?> showChannelButton() {
    return methodChannel.invokeMethod('showChannelButton');
  }

  @override
  Future<bool?> hideChannelButton() {
    return methodChannel.invokeMethod('hideChannelButton');
  }

  @override
  Future<bool?> showMessenger() {
    return methodChannel.invokeMethod('showMessenger');
  }

  @override
  Future<bool?> hideMessenger() {
    return methodChannel.invokeMethod('hideMessenger');
  }

  @override
  Future<bool?> openChat({
    String? chatId,
    String? message,
  }) {
    return methodChannel.invokeMethod(
      'openChat',
      {
        'chatId': chatId,
        'message': message,
      },
    );
  }

  @override
  Future<bool?> track({
    required String eventName,
    Map<String, dynamic>? properties,
  }) {
    return methodChannel.invokeMethod(
      'track',
      {
        'eventName': eventName,
        if (properties != null) 'properties': properties,
      },
    );
  }

  @override
  Future<bool?> updateUser(Map<String, dynamic> data) {
    return methodChannel.invokeMethod(
      'updateUser',
      data,
    );
  }

  @override
  Future<bool?> initPushToken(
    String deviceToken,
  ) {
    return methodChannel.invokeMethod('initPushToken', {
      'deviceToken': deviceToken,
    });
  }

  @override
  Future<bool?> isChannelPushNotification(
    Map<String, dynamic> content,
  ) {
    return methodChannel.invokeMethod('isChannelPushNotification', {
      'content': content,
    });
  }

  @override
  Future<bool?> receivePushNotification(
    Map<String, dynamic> content,
  ) {
    return methodChannel.invokeMethod('receivePushNotification', {
      'content': content,
    });
  }

  @override
  Future<bool?> storePushNotification(
    Map<String, dynamic> content,
  ) {
    return methodChannel.invokeMethod('storePushNotification', {
      'content': content,
    });
  }

  @override
  Future<bool?> hasStoredPushNotification() {
    return methodChannel.invokeMethod('hasStoredPushNotification');
  }

  @override
  Future<bool?> openStoredPushNotification() {
    return methodChannel.invokeMethod('openStoredPushNotification');
  }

  @override
  Future<bool?> isBooted() {
    return methodChannel.invokeMethod('isBooted');
  }

  @override
  Future<bool?> setDebugMode(
    bool flag,
  ) {
    return methodChannel.invokeMethod('setDebugMode', {
      'flag': flag,
    });
  }

  @override
  Future<bool?> setPage(String page) {
    return methodChannel.invokeMethod('setPage', {
      'page': page,
    });
  }

  @override
  Future<bool?> resetPage() {
    return methodChannel.invokeMethod('resetPage');
  }

  @override
  Future<bool?> addTags(List tags) {
    return methodChannel.invokeMethod('addTags', {
      'tags': tags,
    });
  }

  @override
  Future<bool?> removeTags(List tags) {
    return methodChannel.invokeMethod('removeTags', {
      'tags': tags,
    });
  }

  @override
  Future<bool?> openSupportBot({
    required supportBotId,
    String? message,
  }) {
    return methodChannel.invokeMethod('openSupportBot', {
      'supportBotId': supportBotId,
      'message': message,
    });
  }

  @override
  Future<bool?> setAppearance(Appearance appearance) {
    return methodChannel.invokeMethod('setAppearance', {
      'appearance': appearance.value,
    });
  }
}
