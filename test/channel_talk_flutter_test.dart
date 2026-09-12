import 'package:channel_talk_flutter/channel_talk_flutter.dart';
import 'package:channel_talk_flutter/channel_talk_flutter_method_channel.dart';
import 'package:channel_talk_flutter/channel_talk_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class FakeChannelTalkFlutterPlatform extends ChannelTalkFlutterPlatform
    with MockPlatformInterfaceMixin {
  bool? preventDefaultUrlClick;
  int hidePopupCallCount = 0;
  String? setPageValue;
  Map<String, dynamic>? setPageProfile;

  @override
  Future<bool?> hidePopup() async {
    hidePopupCallCount += 1;
    return true;
  }

  @override
  Future<bool?> setPage({
    String? page,
    Map<String, dynamic>? profile,
  }) async {
    setPageValue = page;
    setPageProfile = profile;
    return true;
  }

  @override
  Future<bool?> setPreventDefaultUrlClick(bool prevent) async {
    preventDefaultUrlClick = prevent;
    return true;
  }
}

void main() {
  final ChannelTalkFlutterPlatform initialPlatform =
      ChannelTalkFlutterPlatform.instance;

  tearDown(() {
    ChannelTalkFlutterPlatform.instance = initialPlatform;
  });

  test(
    '기본 플랫폼 구현은 method channel이다',
    () {
      expect(initialPlatform, isInstanceOf<MethodChannelChannelTalkFlutter>());
    },
  );

  test(
    'addTags는 10개를 초과하면 false를 반환한다',
    () async {
      final result = await ChannelTalk.addTags(
        tags: List<String>.filled(11, 'tag'),
      );

      expect(result, isFalse);
    },
  );

  test(
    'setPreventDefaultUrlClick은 플랫폼 구현으로 전달된다',
    () async {
      final fakePlatform = FakeChannelTalkFlutterPlatform();
      ChannelTalkFlutterPlatform.instance = fakePlatform;

      await ChannelTalk.setPreventDefaultUrlClick(prevent: true);

      expect(fakePlatform.preventDefaultUrlClick, isTrue);
    },
  );

  test(
    'hidePopup은 플랫폼 구현으로 전달된다',
    () async {
      final fakePlatform = FakeChannelTalkFlutterPlatform();
      ChannelTalkFlutterPlatform.instance = fakePlatform;

      await ChannelTalk.hidePopup();

      expect(fakePlatform.hidePopupCallCount, 1);
    },
  );

  test(
    'setPage는 page와 profile을 플랫폼 구현으로 전달한다',
    () async {
      final fakePlatform = FakeChannelTalkFlutterPlatform();
      ChannelTalkFlutterPlatform.instance = fakePlatform;

      await ChannelTalk.setPage(
        page: 'orders/detail',
        profile: {
          'orderId': 'A-100',
        },
      );

      expect(fakePlatform.setPageValue, 'orders/detail');
      expect(
        fakePlatform.setPageProfile,
        {
          'orderId': 'A-100',
        },
      );
    },
  );

  test(
    'setPage는 profile만 전달할 수 있다',
    () async {
      final fakePlatform = FakeChannelTalkFlutterPlatform();
      ChannelTalkFlutterPlatform.instance = fakePlatform;

      await ChannelTalk.setPage(
        profile: {
          'orderId': 'A-100',
        },
      );

      expect(fakePlatform.setPageValue, isNull);
      expect(
        fakePlatform.setPageProfile,
        {
          'orderId': 'A-100',
        },
      );
    },
  );
}
