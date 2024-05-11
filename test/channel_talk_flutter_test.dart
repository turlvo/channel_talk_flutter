// import 'package:flutter_test/flutter_test.dart';
// import 'package:channel_talk_flutter/channel_talk_flutter.dart';
// import 'package:channel_talk_flutter/channel_talk_flutter_platform_interface.dart';
// import 'package:channel_talk_flutter/channel_talk_flutter_method_channel.dart';
// import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// class MockChannelTalkFlutterPlatform
//     with MockPlatformInterfaceMixin
//     implements ChannelTalkFlutterPlatform {

//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
// }

// void main() {
//   final ChannelTalkFlutterPlatform initialPlatform = ChannelTalkFlutterPlatform.instance;

//   test('$MethodChannelChannelTalkFlutter is the default instance', () {
//     expect(initialPlatform, isInstanceOf<MethodChannelChannelTalkFlutter>());
//   });

//   test('getPlatformVersion', () async {
//     ChannelTalkFlutter channelTalkFlutterPlugin = ChannelTalkFlutter();
//     MockChannelTalkFlutterPlatform fakePlatform = MockChannelTalkFlutterPlatform();
//     ChannelTalkFlutterPlatform.instance = fakePlatform;

//     expect(await channelTalkFlutterPlugin.getPlatformVersion(), '42');
//   });
// }
