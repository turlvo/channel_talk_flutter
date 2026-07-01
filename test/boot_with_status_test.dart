import 'package:channel_talk_flutter/channel_talk_flutter.dart';
import 'package:channel_talk_flutter/channel_talk_flutter_method_channel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ChannelTalkBootStatus.fromNative', () {
    test('round-trips every known status string', () {
      for (final status in ChannelTalkBootStatus.values) {
        expect(ChannelTalkBootStatus.fromNative(status.value), status);
      }
    });

    test('falls back to unknown for null or unrecognized values', () {
      expect(
        ChannelTalkBootStatus.fromNative(null),
        ChannelTalkBootStatus.unknown,
      );
      expect(
        ChannelTalkBootStatus.fromNative('somethingElse'),
        ChannelTalkBootStatus.unknown,
      );
    });
  });

  group('MethodChannelChannelTalkFlutter.bootWithStatus', () {
    const channel = MethodChannel('channel_talk_flutter');
    final platform = MethodChannelChannelTalkFlutter();
    final log = <MethodCall>[];

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
      log.clear();
    });

    test('invokes the "bootWithStatus" command and decodes the status',
        () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        log.add(call);
        return 'networkTimeout';
      });

      final status = await platform.bootWithStatus({'pluginKey': 'k'});

      expect(status, ChannelTalkBootStatus.networkTimeout);
      expect(log.single.method, 'bootWithStatus');
      expect((log.single.arguments as Map)['pluginKey'], 'k');
    });

    test('decodes an unrecognized native status as unknown', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async => 'weird');

      expect(
        await platform.bootWithStatus({'pluginKey': 'k'}),
        ChannelTalkBootStatus.unknown,
      );
    });
  });
}
