// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter

import 'dart:js_interop';

import 'package:channel_talk_flutter/channel_talk_flutter.dart';
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
  Future<bool?> boot(Map<String, dynamic> config) {
    final Map<String, dynamic> bootOption = {
      'pluginKey': config['pluginKey'],
      'memberId': config['memberId'],
      'customLauncherSelector': config['customLauncherSelector'],
      'hideChannelButtonOnBoot': config['hideChannelButtonOnBoot'],
      'zIndex': config['zIndex'],
      'language': config['language'],
      'trackDefaultEvent': config['trackDefaultEvent'],
      'trackUtmSource': config['trackUtmSource'],
      'profile': {
        if (config['email'] != null) 'email': config['email'],
        if (config['mobileNumber'] != null)
          'mobileNumber': config['mobileNumber'],
        if (config['name'] != null) 'name': config['name'],
        if (config['avatarUrl'] != null) 'avatarUrl': config['avatarUrl'],
      },
      'unsubscribeEmail': config['unsubscribeEmail'],
      'unsubscribeTexting': config['unsubscribeTexting'],
      'memberHash': config['memberHash'],
      'hidePopup': config['hidePopup'],
      'appearance': config['appearance'],
    };
    channel_talk_service.boot(
      'boot',
      bootOption.jsify(),
      // BootOption(
      //   pluginKey: config['pluginKey'],
      //   memberId: config['memberId'],
      //   customLauncherSelector: config['customLauncherSelector'],
      //   hideChannelButtonOnBoot: config['hideChannelButtonOnBoot'],
      //   zIndex: config['zIndex'],
      //   language: config['language'],
      //   trackDefaultEvent: config['trackDefaultEvent'],
      //   trackUtmSource: config['trackUtmSource'],
      //   profile: config['email'] != null ||
      //           config['mobileNumber'] != null ||
      //           config['avatarUrl'] != null ||
      //           config['name'] != null
      //       ? Profile(
      //           email: config['email'],
      //           mobileNumber: config['mobileNumber'],
      //           name: config['name'],
      //           avatarUrl: config['avatarUrl'],
      //         )
      //       : null,
      //   unsubscribeEmail: config['unsubscribeEmail'],
      //   unsubscribeTexting: config['unsubscribeTexting'],
      //   memberHash: config['memberHash'],
      //   hidePopup: config['hidePopup'],
      //   appearance: config['appearance'],
      // ),
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
    final Map user = {
      'profile': {
        if (data['email'] != null) 'email': data['email'],
        if (data['mobileNumber'] != null) 'mobileNumber': data['mobileNumber'],
        if (data['name'] != null) 'name': data['name'],
        if (data['avatarUrl'] != null) 'avatarUrl': data['avatarUrl'],
        if (data['customAttributes'] != null) ...data['customAttributes'],
      },
      if (data['profileOnce'] != null) 'profileOnce': data['profileOnce'],
      if (data['unsubscribeEmail'] != null)
        'unsubscribeEmail': data['unsubscribeEmail'],
      if (data['unsubscribeTexting'] != null)
        'unsubscribeTexting': data['unsubscribeTexting'],
      if (data['tags'] != null) 'tags': data['tags'],
      if (data['language'] != null) 'language': data['language'],
    };
    channel_talk_service.updateUser(
      'updateUser',
      user.jsify(),
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
      tags.jsify(),
    );
    return Future.value(true);
  }

  @override
  Future<bool?> removeTags(List tags) {
    channel_talk_service.removeTags(
      'removeTags',
      tags.jsify(),
    );
    return Future.value(true);
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
}
