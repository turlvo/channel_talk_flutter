// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter

import 'dart:js';

import 'package:channel_talk_flutter/web/channel_io_service.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'channel_talk_flutter_platform_interface.dart';

import 'package:channel_talk_flutter/web/channel_io_service.dart'
    as channel_talk_service;

/// A web implementation of the ChannelTalkFlutterPlatform of the ChannelTalkFlutter plugin.
class ChannelTalkFlutterWeb extends ChannelTalkFlutterPlatform {
  /// Constructs a ChannelTalkFlutterWeb
  ChannelTalkFlutterWeb();

  static void registerWith(Registrar registrar) {
    ChannelTalkFlutterPlatform.instance = ChannelTalkFlutterWeb();
  }

  @override
  Future<bool?> boot(config) {
    channel_talk_service.boot(
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
  Future<bool?> openChat(Map<String, dynamic> data) {
    channel_talk_service.openChat('openChat', data);
    return Future.value(true);
  }

  @override
  Future<bool?> track(Map<String, dynamic> data) {
    channel_talk_service.openChat('track', data);
    return Future.value(true);
  }

  @override
  Future<bool?> updateUser(Map<String, dynamic> data) {
    final UserObject user = UserObject(
      profile: data['email'] != null ||
              data['mobileNumber'] != null ||
              data['avatarUrl'] != null ||
              data['name'] != null
          ? Profile(
              email: data['email'],
              mobileNumber: data['mobileNumber'],
              name: data['name'],
              avatarUrl: data['avatarUrl'],
            )
          : null,
      profileOnce: data['profileOnce'],
      unsubscribeEmail: data['unsubscribeEmail'],
      unsubscribeTexting: data['unsubscribeTexting'],
      tags: data['tags'],
      language: data['language'],
    );
    channel_talk_service.updateUser(
      'updateUser',
      user,
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
  Future<bool?> setPage(page) {
    channel_talk_service.setPage('setPage', page);
    return Future.value(true);
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
    channel_talk_service.addTags(
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
    channel_talk_service.removeTags(
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
