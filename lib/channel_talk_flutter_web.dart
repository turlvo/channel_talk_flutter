// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:js_interop';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'channel_talk_flutter.dart';
import 'channel_talk_flutter_platform_interface.dart';
import 'web/channel_io_service.dart' as channel_talk_service;

/// A web implementation of the ChannelTalkFlutterPlatform of the ChannelTalkFlutter plugin.
class ChannelTalkFlutterWeb extends ChannelTalkFlutterPlatform {
  /// Constructs a ChannelTalkFlutterWeb
  ChannelTalkFlutterWeb();

  ChannelTalkDelegate? _channelTalkDelegate;
  bool _preventDefaultUrlClick = false;
  int _listenerGeneration = 0;

  /// Completes only when the SDK reports that the requested operation finished.
  Future<bool> _runWithCallback(
      void Function(JSFunction callback) operation) async {
    final completer = Completer<bool>();
    operation(((JSAny? error, [JSAny? user]) {
      if (!completer.isCompleted) {
        completer.complete(error == null);
      }
    }).toJS);
    return completer.future;
  }

  Object? _toDartValue(JSAny? value) {
    return value?.dartify();
  }

  void _dispatchEvent(
    int generation,
    ChannelTalkEvent event,
    dynamic arguments,
  ) {
    if (generation != _listenerGeneration) {
      return;
    }

    final ChannelTalkDelegate? callback = _channelTalkDelegate;
    if (callback == null) {
      return;
    }

    callback(event, arguments);
  }

  bool _handleUrlClicked(int generation, JSAny? url) {
    if (generation != _listenerGeneration) {
      return false;
    }

    final ChannelTalkDelegate? callback = _channelTalkDelegate;
    if (callback == null) {
      return false;
    }

    callback(ChannelTalkEvent.onUrlClicked, _toDartValue(url));
    return _preventDefaultUrlClick;
  }

  static void registerWith(Registrar registrar) {
    ChannelTalkFlutterPlatform.instance = ChannelTalkFlutterWeb();
  }

  @override
  void setListener(ChannelTalkDelegate delegate) {
    _listenerGeneration += 1;
    final int generation = _listenerGeneration;
    _channelTalkDelegate = delegate;

    channel_talk_service.clearCallbacks('clearCallbacks');
    channel_talk_service.onShowMessenger(
      'onShowMessenger',
      (() {
        _dispatchEvent(generation, ChannelTalkEvent.onShowMessenger, {});
      }).toJS,
    );
    channel_talk_service.onHideMessenger(
      'onHideMessenger',
      (() {
        _dispatchEvent(generation, ChannelTalkEvent.onHideMessenger, {});
      }).toJS,
    );
    channel_talk_service.onChatCreated(
      'onChatCreated',
      (([JSAny? chat]) {
        _dispatchEvent(
          generation,
          ChannelTalkEvent.onChatCreated,
          _toDartValue(chat),
        );
      }).toJS,
    );
    channel_talk_service.onBadgeChanged(
      'onBadgeChanged',
      ((JSAny? unread, JSAny? alert) {
        _dispatchEvent(
          generation,
          ChannelTalkEvent.onBadgeChanged,
          {
            'unread': _toDartValue(unread),
            'alert': _toDartValue(alert),
          },
        );
      }).toJS,
    );
    channel_talk_service.onFollowUpChanged(
      'onFollowUpChanged',
      ((JSAny? profile) {
        _dispatchEvent(
          generation,
          ChannelTalkEvent.onFollowUpChanged,
          _toDartValue(profile),
        );
      }).toJS,
    );
    channel_talk_service.onUrlClicked(
      'onUrlClicked',
      ((JSAny? url) {
        return _handleUrlClicked(generation, url);
      }).toJS,
    );
    channel_talk_service.onPopupDataReceived(
      'onPopupDataReceived',
      ((JSAny? popupData) {
        _dispatchEvent(
          generation,
          ChannelTalkEvent.onPopupDataReceived,
          _toDartValue(popupData),
        );
      }).toJS,
    );
  }

  @override
  void removeListener() {
    _listenerGeneration += 1;
    _channelTalkDelegate = null;
    _preventDefaultUrlClick = false;
    channel_talk_service.clearCallbacks('clearCallbacks');
  }

  @override
  Future<bool?> boot(Map<String, dynamic> config) {
    final profile = <String, dynamic>{
      if (config['email'] != null) 'email': config['email'],
      if (config['mobileNumber'] != null)
        'mobileNumber': config['mobileNumber'],
      if (config['name'] != null) 'name': config['name'],
      if (config['avatarUrl'] != null) 'avatarUrl': config['avatarUrl'],
    };
    final Map<String, dynamic> bootOption = {
      'pluginKey': config['pluginKey'],
      'memberId': config['memberId'],
      'customLauncherSelector': config['customLauncherSelector'],
      'hideChannelButtonOnBoot': config['hideChannelButtonOnBoot'],
      'zIndex': config['zIndex'],
      'language': config['language'],
      'trackDefaultEvent': config['trackDefaultEvent'],
      'trackUtmSource': config['trackUtmSource'],
      if (profile.isNotEmpty) 'profile': profile,
      'unsubscribeEmail': config['unsubscribeEmail'],
      'unsubscribeTexting': config['unsubscribeTexting'],
      'memberHash': config['memberHash'],
      'hidePopup': config['hidePopup'],
      'appearance': config['appearance'],
    }..removeWhere((key, value) => value == null);
    return _runWithCallback((callback) {
      channel_talk_service.boot(
        'boot',
        bootOption.jsify(),
        callback,
      );
    });
  }

  @override
  Future<ChannelTalkBootStatus> bootWithStatus(
      Map<String, dynamic> config) async {
    // Web only exposes callback success or failure, so failure has no detailed status.
    final booted = await boot(config);
    return booted == true
        ? ChannelTalkBootStatus.success
        : ChannelTalkBootStatus.unknown;
  }

  @override
  Future<bool?> shutdown() {
    channel_talk_service.shutdown('shutdown');
    return Future.value(true);
  }

  @override
  Future<bool?> showChannelButton() {
    channel_talk_service.showChannelButton('showChannelButton');

    return Future.value(true);
  }

  @override
  Future<bool?> hideChannelButton() {
    channel_talk_service.hideChannelButton('hideChannelButton');
    return Future.value(true);
  }

  @override
  Future<bool?> showMessenger() {
    channel_talk_service.showMessenger('showMessenger');
    return Future.value(true);
  }

  @override
  Future<bool?> hideMessenger() {
    channel_talk_service.hideMessenger('hideMessenger');
    return Future.value(true);
  }

  @override
  Future<bool?> openChat({
    String? chatId,
    String? message,
  }) {
    channel_talk_service.openChat(
      'openChat',
      chatId,
      message,
    );
    return Future.value(true);
  }

  @override
  Future<bool?> track({
    required String eventName,
    Map<String, dynamic>? properties,
  }) {
    channel_talk_service.track(
      'track',
      eventName,
      properties.jsify(),
    );
    return Future.value(true);
  }

  @override
  Future<bool?> updateUser(Map<String, dynamic> data) {
    final profile = <String, dynamic>{
      if (data['email'] != null) 'email': data['email'],
      if (data['mobileNumber'] != null) 'mobileNumber': data['mobileNumber'],
      if (data['name'] != null) 'name': data['name'],
      if (data['avatarUrl'] != null) 'avatarUrl': data['avatarUrl'],
      if (data['customAttributes'] != null) ...data['customAttributes'],
    };
    final user = <String, dynamic>{
      if (profile.isNotEmpty) 'profile': profile,
      if (data['profileOnce'] != null) 'profileOnce': data['profileOnce'],
      if (data['unsubscribeEmail'] != null)
        'unsubscribeEmail': data['unsubscribeEmail'],
      if (data['unsubscribeTexting'] != null)
        'unsubscribeTexting': data['unsubscribeTexting'],
      if (data['tags'] != null) 'tags': data['tags'],
      if (data['language'] != null) 'language': data['language'],
    };
    return _runWithCallback((callback) {
      channel_talk_service.updateUser(
        'updateUser',
        user.jsify(),
        callback,
      );
    });
  }

  @override
  Future<bool?> setPage({
    String? page,
    Map<String, dynamic>? profile,
  }) async {
    if (page == null) {
      throw ArgumentError.notNull('page');
    }
    channel_talk_service.setPage(
      'setPage',
      page.toJS,
      profile.jsify(),
    );
    return true;
  }

  @override
  Future<bool?> resetPage() {
    channel_talk_service.resetPage('resetPage');
    return Future.value(true);
  }

  @override
  Future<bool?> addTags(
    List tags,
  ) {
    return _runWithCallback((callback) {
      channel_talk_service.addTags(
        'addTags',
        tags.jsify(),
        callback,
      );
    });
  }

  @override
  Future<bool?> removeTags(List tags) {
    return _runWithCallback((callback) {
      channel_talk_service.removeTags(
        'removeTags',
        tags.jsify(),
        callback,
      );
    });
  }

  @override
  Future<bool?> openWorkflow({
    String? workflowId,
  }) {
    channel_talk_service.openWorkflow(
      'openWorkflow',
      workflowId,
    );
    return Future.value(true);
  }

  @override
  Future<bool?> setAppearance(
    Appearance appearance,
  ) {
    channel_talk_service.setAppearance('setAppearance', appearance.value);
    return Future.value(true);
  }

  @override
  Future<bool?> hidePopup() {
    channel_talk_service.hidePopup('hidePopup');
    return Future.value(true);
  }

  @override
  Future<bool?> setPreventDefaultUrlClick(bool prevent) {
    _preventDefaultUrlClick = prevent;
    return Future.value(true);
  }
}
