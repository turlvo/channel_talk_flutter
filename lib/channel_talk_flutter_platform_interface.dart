import 'package:channel_talk_flutter/channel_talk_flutter.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'channel_talk_flutter_method_channel.dart';

typedef ChannelTalkDelegate = Function(
    ChannelTalkEvent event, dynamic arguments);

enum ChannelTalkEvent {
  onShowMessenger,
  onHideMessenger,
  onChatCreated,
  onBadgeChanged,
  onFollowUpChanged,
  onUrlClicked,
  onPopupDataReceived,
  onPushNotificationClicked, // For only Android
}

abstract class ChannelTalkFlutterPlatform extends PlatformInterface {
  /// Constructs a ChannelTalkFlutterPlatform.
  ChannelTalkFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static ChannelTalkFlutterPlatform _instance =
      MethodChannelChannelTalkFlutter();

  /// The default instance of [ChannelTalkFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelChannelTalkFlutter].
  static ChannelTalkFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ChannelTalkFlutterPlatform] when
  /// they register themselves.
  static set instance(ChannelTalkFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  void setListener(ChannelTalkDelegate delegate) {
    throw UnimplementedError('setListener() has not been implemented.');
  }

  // Removes the callback listener if it exists
  void removeListener() {
    throw UnimplementedError('removeListener() has not been implemented.');
  }

  Future<bool?> boot(Map<String, dynamic> config) {
    throw UnimplementedError('boot() has not been implemented.');
  }

  Future<bool?> sleep() {
    throw UnimplementedError('sleep() has not been implemented.');
  }

  Future<bool?> shutdown() {
    throw UnimplementedError('shutdown() has not been implemented.');
  }

  Future<bool?> showChannelButton() {
    throw UnimplementedError('showChannelButton() has not been implemented.');
  }

  Future<bool?> hideChannelButton() {
    throw UnimplementedError('hideChannelButton() has not been implemented.');
  }

  Future<bool?> showMessenger() {
    throw UnimplementedError('showMessenger() has not been implemented.');
  }

  Future<bool?> hideMessenger() {
    throw UnimplementedError('hideMessenger() has not been implemented.');
  }

  Future<bool?> openChat({
    String? chatId,
    String? message,
  }) {
    throw UnimplementedError('openChat() has not been implemented.');
  }

  Future<bool?> track({
    required String eventName,
    Map<String, dynamic>? properties,
  }) {
    throw UnimplementedError('track() has not been implemented.');
  }

  Future<bool?> updateUser(Map<String, dynamic> data) {
    throw UnimplementedError('updateUser() has not been implemented.');
  }

  Future<bool?> initPushToken(
    String deviceToken,
  ) {
    throw UnimplementedError('initPushToken() has not been implemented.');
  }

  Future<bool?> isChannelPushNotification(
    Map<String, dynamic> content,
  ) {
    throw UnimplementedError(
        'isChannelPushNotification() has not been implemented.');
  }

  Future<bool?> receivePushNotification(
    Map<String, dynamic> content,
  ) {
    throw UnimplementedError(
        'receivePushNotification() has not been implemented.');
  }

  Future<bool?> storePushNotification(
    Map<String, dynamic> content,
  ) {
    throw UnimplementedError(
        'storePushNotification() has not been implemented.');
  }

  Future<bool?> hasStoredPushNotification() {
    throw UnimplementedError(
        'hasStoredPushNotification() has not been implemented.');
  }

  Future<bool?> openStoredPushNotification() {
    throw UnimplementedError(
        'openStoredPushNotification() has not been implemented.');
  }

  Future<bool?> isBooted() {
    throw UnimplementedError('isBooted() has not been implemented.');
  }

  Future<bool?> setDebugMode(
    bool flag,
  ) {
    throw UnimplementedError('setDebugMode() has not been implemented.');
  }

  Future<bool?> setPage(String page) {
    throw UnimplementedError('setPage() has not been implemented.');
  }

  Future<bool?> resetPage() {
    throw UnimplementedError('resetPage() has not been implemented.');
  }

  Future<bool?> addTags(List tags) {
    throw UnimplementedError('addTags() has not been implemented.');
  }

  Future<bool?> removeTags(List tags) {
    throw UnimplementedError('removeTags() has not been implemented.');
  }

  Future<bool?> openWorkflow({
    String? workflowId,
  }) {
    throw UnimplementedError('openWorkflow() has not been implemented.');
  }

  Future<bool?> setAppearance(Appearance appearance) {
    throw UnimplementedError('setAppearance() has not been implemented.');
  }

  Future<bool?> hidePopup() {
    throw UnimplementedError('hidePopup() has not been implemented.');
  }
}
