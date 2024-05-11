// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter

import 'dart:js';

import 'package:channel_talk_flutter/web/channel_io_service.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'channel_talk_flutter_platform_interface.dart';

import 'package:channel_talk_flutter/web/channel_io_service.dart'
    as channel_talk;

/// A web implementation of the ChannelTalkFlutterPlatform of the ChannelTalkFlutter plugin.
class ChannelTalkFlutterWeb extends ChannelTalkFlutterPlatform {
  /// Constructs a ChannelTalkFlutterWeb
  ChannelTalkFlutterWeb();

  static void registerWith(Registrar registrar) {
    ChannelTalkFlutterPlatform.instance = ChannelTalkFlutterWeb();
  }

  @override
  Future<bool?> boot(config) {
    channel_talk.boot(
      'boot',
      BootOption(
        pluginKey: config['pluginKey'],
        memberId: config['memberId'],
        customLauncherSelector: config['customLauncherSelector'],
        hideChannelButtonOnBoot: config['hideChannelButtonOnBoot'],
        zIndex: config['zIndex'],
        language: config['language'],
        trackDefaultEvent: config['trackDefaultEvent'],
        trackUtmSource: config['trackUtmSource'],
        profile: config['profile'],
        unsubscribeEmail: config['unsubscribeEmail'],
        unsubscribeTexting: config['unsubscribeTexting'],
        memberHash: config['memberHash'],
        hidePopup: config['hidePopup'],
        appearance: config['appearance'],
      ),
      allowInterop(
        (error, user) {
          if (error != null) {
          } else {}
        },
      ),
    );

    return Future.value(true);
  }

  @override
  Future<bool?> shutdown() {
    channel_talk.shutdown('shutdown');
    return Future.value(true);
  }

  @override
  Future<bool?> showChannelButton() {
    channel_talk.showChannelButton('showChannelButton');

    return Future.value(true);
  }

  @override
  Future<bool?> hideChannelButton() {
    channel_talk.hideChannelButton('hideChannelButton');
    return Future.value(true);
  }

  @override
  Future<bool?> showMessenger() {
    channel_talk.showMessenger('showMessenger');
    return Future.value(true);
  }

  @override
  Future<bool?> hideMessenger() {
    channel_talk.hideMessenger('hideMessenger');
    return Future.value(true);
  }

  @override
  Future<bool?> openChat(Map<String, dynamic> data) {
    return Future.value(true);
  }

  @override
  Future<bool?> track(Map<String, dynamic> data) {
    return Future.value(true);
  }

  @override
  Future<bool?> updateUser(Map<String, dynamic> data) {
    return Future.value(true);
  }

  @override
  Future<bool?> hasStoredPushNotification() {
    return Future.value(true);
  }

  @override
  Future<bool?> openStoredPushNotification() {
    return Future.value(true);
  }

  @override
  Future<bool?> setDebugMode(
    bool flag,
  ) {
    return Future.value(true);
  }

  @override
  Future<bool?> setPage(page) {
    channel_talk.setPage('setPage', page);
    return Future.value(true);
  }

  @override
  Future<bool?> resetPage() {
    channel_talk.resetPage('resetPage');
    return Future.value(true);
  }

  @override
  Future<bool?> addTags(
    List tags,
  ) {
    channel_talk.addTags(
      'addTags',
      tags,
      allowInterop(
        (error, user) {
          if (error != null) {
          } else {}
        },
      ),
    );
    return Future.value(true);
  }

  @override
  Future<bool?> removeTags(List tags) {
    channel_talk.removeTags(
      'removeTags',
      tags,
      allowInterop(
        (error, user) {
          if (error != null) {
          } else {}
        },
      ),
    );
    return Future.value(true);
  }
}
