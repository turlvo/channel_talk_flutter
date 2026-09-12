import 'package:flutter_test/flutter_test.dart';

import 'package:channel_talk_flutter/channel_talk_flutter.dart';
import 'package:channel_talk_flutter/channel_talk_flutter_platform_interface.dart';

/// 실제 SDK 없이 공개 API가 전달하는 설정과 호출 횟수를 기록한다.
class _RecordingChannelTalkPlatform extends ChannelTalkFlutterPlatform {
  Map<String, dynamic>? bootConfig;
  Map<String, dynamic>? bootStatusConfig;
  Map<String, dynamic>? userData;
  List<dynamic>? addedTags;
  int addTagsCallCount = 0;
  int bootStatusCallCount = 0;
  bool? result = true;
  ChannelTalkBootStatus bootStatusResult = ChannelTalkBootStatus.success;

  /// 초기화 옵션의 생략 여부를 원본 설정에서 확인할 수 있게 한다.
  @override
  Future<bool?> boot(Map<String, dynamic> config) async {
    bootConfig = config;
    return result;
  }

  /// 상세 초기화가 기존 bool API를 거치지 않고 설정과 상태를 보존하는지 확인한다.
  @override
  Future<ChannelTalkBootStatus> bootWithStatus(
      Map<String, dynamic> config) async {
    bootStatusConfig = config;
    bootStatusCallCount += 1;
    return bootStatusResult;
  }

  /// 부분 갱신이 기존 값을 덮어쓰는 옵션을 추가하는지 확인한다.
  @override
  Future<bool?> updateUser(Map<String, dynamic> data) async {
    userData = data;
    return result;
  }

  /// 유효하지 않은 태그 요청이 플랫폼까지 도달하는지 확인한다.
  @override
  Future<bool?> addTags(List<dynamic> tags) async {
    addedTags = tags;
    addTagsCallCount += 1;
    return result;
  }
}

/// 공개 API의 부분 설정과 플랫폼 결과 전달 계약을 검증한다.
void main() {
  late ChannelTalkFlutterPlatform originalPlatform;
  late _RecordingChannelTalkPlatform platform;

  setUp(() {
    originalPlatform = ChannelTalkFlutterPlatform.instance;
    platform = _RecordingChannelTalkPlatform();
    ChannelTalkFlutterPlatform.instance = platform;
  });

  tearDown(() {
    ChannelTalkFlutterPlatform.instance = originalPlatform;
  });

  test('boot는 생략한 선택 옵션을 플랫폼에 추가하지 않는다', () async {
    await ChannelTalk.boot(pluginKey: 'test-plugin-key');

    expect(platform.bootConfig, {'pluginKey': 'test-plugin-key'});
  });

  test('boot는 회원 식별자와 프로필을 손실 없이 전달한다', () async {
    await ChannelTalk.boot(
      pluginKey: 'test-plugin-key',
      memberId: 'test-member-id',
      memberHash: 'test-member-hash',
      name: '테스트 사용자',
      email: 'tester@example.invalid',
      mobileNumber: '+820000000000',
      avatarUrl: 'https://example.invalid/avatar.png',
    );

    expect(platform.bootConfig, {
      'pluginKey': 'test-plugin-key',
      'memberId': 'test-member-id',
      'memberHash': 'test-member-hash',
      'name': '테스트 사용자',
      'email': 'tester@example.invalid',
      'mobileNumber': '+820000000000',
      'avatarUrl': 'https://example.invalid/avatar.png',
    });
  });

  test('boot는 명시한 false를 생략하지 않는다', () async {
    await ChannelTalk.boot(
      pluginKey: 'test-plugin-key',
      unsubscribeEmail: false,
      unsubscribeTexting: false,
      trackDefaultEvent: false,
      hidePopup: false,
    );

    expect(platform.bootConfig, {
      'pluginKey': 'test-plugin-key',
      'unsubscribeEmail': false,
      'unsubscribeTexting': false,
      'trackDefaultEvent': false,
      'hidePopup': false,
    });
  });

  test('bootWithStatus는 생략한 선택 옵션 없이 상세 초기화를 한 번 요청한다', () async {
    await ChannelTalk.bootWithStatus(pluginKey: 'test-plugin-key');

    expect(platform.bootStatusConfig, {'pluginKey': 'test-plugin-key'});
    expect(platform.bootStatusCallCount, 1);
    expect(platform.bootConfig, isNull);
  });

  test('bootWithStatus는 boot와 동일한 전체 설정을 전달한다', () async {
    await ChannelTalk.boot(
      pluginKey: 'test-plugin-key',
      memberId: 'test-member-id',
      memberHash: 'test-member-hash',
      name: '테스트 사용자',
      email: 'tester@example.invalid',
      mobileNumber: '+820000000000',
      avatarUrl: 'https://example.invalid/avatar.png',
      language: Language.korean,
      unsubscribeEmail: true,
      unsubscribeTexting: false,
      trackDefaultEvent: false,
      hidePopup: true,
      appearance: Appearance.dark,
    );
    await ChannelTalk.bootWithStatus(
      pluginKey: 'test-plugin-key',
      memberId: 'test-member-id',
      memberHash: 'test-member-hash',
      name: '테스트 사용자',
      email: 'tester@example.invalid',
      mobileNumber: '+820000000000',
      avatarUrl: 'https://example.invalid/avatar.png',
      language: Language.korean,
      unsubscribeEmail: true,
      unsubscribeTexting: false,
      trackDefaultEvent: false,
      hidePopup: true,
      appearance: Appearance.dark,
    );

    expect(platform.bootStatusConfig, platform.bootConfig);
    expect(platform.bootStatusConfig, {
      'pluginKey': 'test-plugin-key',
      'memberId': 'test-member-id',
      'memberHash': 'test-member-hash',
      'name': '테스트 사용자',
      'email': 'tester@example.invalid',
      'mobileNumber': '+820000000000',
      'avatarUrl': 'https://example.invalid/avatar.png',
      'language': 'ko',
      'unsubscribeEmail': true,
      'unsubscribeTexting': false,
      'trackDefaultEvent': false,
      'hidePopup': true,
      'appearance': 'dark',
    });
  });

  test('bootWithStatus는 명시한 false를 생략하지 않는다', () async {
    await ChannelTalk.bootWithStatus(
      pluginKey: 'test-plugin-key',
      unsubscribeEmail: false,
      unsubscribeTexting: false,
      trackDefaultEvent: false,
      hidePopup: false,
    );

    expect(platform.bootStatusConfig, {
      'pluginKey': 'test-plugin-key',
      'unsubscribeEmail': false,
      'unsubscribeTexting': false,
      'trackDefaultEvent': false,
      'hidePopup': false,
    });
  });

  test('bootWithStatus는 명시한 빈 문자열을 생략하지 않는다', () async {
    await ChannelTalk.bootWithStatus(
      pluginKey: 'test-plugin-key',
      memberId: '',
      memberHash: '',
      name: '',
      email: '',
      mobileNumber: '',
      avatarUrl: '',
    );

    expect(platform.bootStatusConfig, {
      'pluginKey': 'test-plugin-key',
      'memberId': '',
      'memberHash': '',
      'name': '',
      'email': '',
      'mobileNumber': '',
      'avatarUrl': '',
    });
  });

  test('bootWithStatus는 플랫폼의 상세 결과 8개를 그대로 반환한다', () async {
    for (final status in ChannelTalkBootStatus.values) {
      platform.bootStatusResult = status;

      expect(
        await ChannelTalk.bootWithStatus(pluginKey: 'test-plugin-key'),
        status,
      );
    }

    expect(platform.bootStatusCallCount, ChannelTalkBootStatus.values.length);
    expect(platform.bootConfig, isNull);
  });

  test('bootForWeb은 생략한 웹 옵션과 공통 옵션을 추가하지 않는다', () async {
    await ChannelTalk.bootForWeb(pluginKey: 'test-plugin-key');

    expect(platform.bootConfig, {'pluginKey': 'test-plugin-key'});
  });

  test('bootForWeb은 공통 회원 정보를 플랫폼 초기화에 전달한다', () async {
    await ChannelTalk.bootForWeb(
      pluginKey: 'test-plugin-key',
      memberId: 'test-member-id',
      memberHash: 'test-member-hash',
      name: '테스트 사용자',
      email: 'tester@example.invalid',
      mobileNumber: '+820000000000',
      avatarUrl: 'https://example.invalid/avatar.png',
    );

    expect(platform.bootConfig, {
      'pluginKey': 'test-plugin-key',
      'memberId': 'test-member-id',
      'memberHash': 'test-member-hash',
      'name': '테스트 사용자',
      'email': 'tester@example.invalid',
      'mobileNumber': '+820000000000',
      'avatarUrl': 'https://example.invalid/avatar.png',
    });
  });

  test('bootForWeb은 웹 옵션의 false와 zIndex 0을 보존한다', () async {
    await ChannelTalk.bootForWeb(
      pluginKey: 'test-plugin-key',
      customLauncherSelector: '#test-launcher',
      hideChannelButtonOnBoot: false,
      zIndex: 0,
      trackUtmSource: false,
    );

    expect(platform.bootConfig, {
      'pluginKey': 'test-plugin-key',
      'customLauncherSelector': '#test-launcher',
      'hideChannelButtonOnBoot': false,
      'zIndex': 0,
      'trackUtmSource': false,
    });
  });

  test('bootForWeb은 공통 옵션의 명시적 false를 보존한다', () async {
    await ChannelTalk.bootForWeb(
      pluginKey: 'test-plugin-key',
      unsubscribeEmail: false,
      unsubscribeTexting: false,
      trackDefaultEvent: false,
      hidePopup: false,
    );

    expect(platform.bootConfig, {
      'pluginKey': 'test-plugin-key',
      'unsubscribeEmail': false,
      'unsubscribeTexting': false,
      'trackDefaultEvent': false,
      'hidePopup': false,
    });
  });

  test('언어는 모든 공개 설정 API에서 SDK 언어 코드로 전달된다', () async {
    final languageCodes = {
      Language.english: 'en',
      Language.korean: 'ko',
      Language.japanese: 'ja',
      Language.device: 'device',
    };

    for (final entry in languageCodes.entries) {
      await ChannelTalk.boot(
        pluginKey: 'test-plugin-key',
        language: entry.key,
      );
      expect(platform.bootConfig!['language'], entry.value);

      await ChannelTalk.bootWithStatus(
        pluginKey: 'test-plugin-key',
        language: entry.key,
      );
      expect(platform.bootStatusConfig!['language'], entry.value);

      await ChannelTalk.bootForWeb(
        pluginKey: 'test-plugin-key',
        language: entry.key,
      );
      expect(platform.bootConfig!['language'], entry.value);

      await ChannelTalk.updateUser(language: entry.key);
      expect(platform.userData, {'language': entry.value});
    }
  });

  test('테마는 모든 초기화 API에서 SDK 문자열로 전달된다', () async {
    final appearanceValues = {
      Appearance.system: 'system',
      Appearance.light: 'light',
      Appearance.dark: 'dark',
    };

    for (final entry in appearanceValues.entries) {
      await ChannelTalk.boot(
        pluginKey: 'test-plugin-key',
        appearance: entry.key,
      );
      expect(platform.bootConfig!['appearance'], entry.value);

      await ChannelTalk.bootWithStatus(
        pluginKey: 'test-plugin-key',
        appearance: entry.key,
      );
      expect(platform.bootStatusConfig!['appearance'], entry.value);

      await ChannelTalk.bootForWeb(
        pluginKey: 'test-plugin-key',
        appearance: entry.key,
      );
      expect(platform.bootConfig!['appearance'], entry.value);
    }
  });

  test('updateUser는 모든 인자 생략 시 기존 정보를 초기화할 값을 추가하지 않는다', () async {
    await ChannelTalk.updateUser();

    expect(platform.userData, isEmpty);
  });

  test('updateUser는 이름만 바꾸면 언어와 태그 및 수신 설정을 건드리지 않는다', () async {
    await ChannelTalk.updateUser(name: '변경된 테스트 이름');

    expect(platform.userData, {'name': '변경된 테스트 이름'});
  });

  test('updateUser는 프로필의 명시적 빈 문자열을 보존한다', () async {
    await ChannelTalk.updateUser(
      name: '',
      email: '',
      mobileNumber: '',
      avatarUrl: '',
    );

    expect(platform.userData, {
      'name': '',
      'email': '',
      'mobileNumber': '',
      'avatarUrl': '',
    });
  });

  test('updateUser는 명시적 false로 수신 거부를 해제할 수 있다', () async {
    await ChannelTalk.updateUser(
      unsubscribeEmail: false,
      unsubscribeTexting: false,
    );

    expect(platform.userData, {
      'unsubscribeEmail': false,
      'unsubscribeTexting': false,
    });
  });

  test('updateUser는 빈 태그 목록과 빈 사용자 속성을 생략하지 않는다', () async {
    await ChannelTalk.updateUser(
      tags: [],
      customAttributes: {},
    );

    expect(platform.userData, {
      'tags': <String>[],
      'customAttributes': <String, dynamic>{},
    });
  });

  test('updateUser는 사용자 속성의 null과 중첩된 빈 값 및 false를 보존한다', () async {
    await ChannelTalk.updateUser(
      customAttributes: const {
        'obsoleteField': null,
        'testPreferences': {
          'enabled': false,
          'count': 0,
          'label': '',
          'items': <String>[],
        },
      },
    );

    expect(platform.userData, {
      'customAttributes': {
        'obsoleteField': null,
        'testPreferences': {
          'enabled': false,
          'count': 0,
          'label': '',
          'items': <String>[],
        },
      },
    });
  });

  test('addTags는 정확히 10개를 순서와 내용 그대로 한 번 전달한다', () async {
    final expectedTags =
        List<String>.generate(10, (index) => 'test-tag-$index');

    final result =
        await ChannelTalk.addTags(tags: List<String>.of(expectedTags));

    expect(result, isTrue);
    expect(platform.addTagsCallCount, 1);
    expect(platform.addedTags, orderedEquals(expectedTags));
  });

  test('addTags는 11개일 때 플랫폼을 호출하지 않는다', () async {
    final tags = List<String>.generate(11, (index) => 'test-tag-$index');

    final result = await ChannelTalk.addTags(tags: tags);

    expect(result, isFalse);
    expect(platform.addTagsCallCount, 0);
    expect(platform.addedTags, isNull);
  });

  test('공개 설정 API는 플랫폼의 false와 null 결과를 성공으로 바꾸지 않는다', () async {
    for (final result in <bool?>[false, null]) {
      platform.result = result;

      expect(await ChannelTalk.boot(pluginKey: 'test-plugin-key'), result);
      expect(
          await ChannelTalk.bootForWeb(pluginKey: 'test-plugin-key'), result);
      expect(await ChannelTalk.updateUser(name: '테스트 사용자'), result);
      expect(await ChannelTalk.addTags(tags: ['test-tag']), result);
    }
  });
}
