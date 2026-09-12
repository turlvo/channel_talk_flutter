# Dart 및 Web 테스트

이 디렉토리는 공개 Dart API, MethodChannel 직렬화, 브라우저 JS 브리지를 검증한다.
실제 Channel Talk 계정이나 네이티브 SDK 세션을 시작하지 않는다.

| 파일 | 케이스 | 역할 |
| --- | --- | --- |
| [channel_talk_flutter_test.dart](channel_talk_flutter_test.dart) | 6 | 플랫폼 위임과 태그 제한 |
| [channel_talk_flutter_config_test.dart][config] | 23 | 설정 생략·빈 값·enum·상세 boot·태그 경계 |
| [boot_with_status_test.dart](boot_with_status_test.dart) | 7 | 상태 문자열·채널 전달·오류 |
| [channel_talk_flutter_method_channel_test.dart][channel] | 11 | 채널 인자·지연 응답·오류 |
| [channel_talk_flutter_events_test.dart][events] | 12 | 네이티브 이벤트 수신·리스너 수명 |
| [channel_talk_flutter_web_test.dart](channel_talk_flutter_web_test.dart) | 27 | JS 옵션·콜백·이벤트·리스너 |

[config]: channel_talk_flutter_config_test.dart
[channel]: channel_talk_flutter_method_channel_test.dart
[events]: channel_talk_flutter_events_test.dart

저장소 루트에서 실행한다. Web 테스트는 Chrome을 별도로 지정해야 한다.

```sh
rtk proxy flutter test test/channel_talk_flutter_test.dart \
  test/channel_talk_flutter_config_test.dart \
  test/channel_talk_flutter_method_channel_test.dart \
  test/channel_talk_flutter_events_test.dart \
  test/boot_with_status_test.dart
rtk proxy flutter test --platform chrome test/channel_talk_flutter_web_test.dart
```

## 테스트 추가 시 유지할 패턴

- 공개 API 테스트는 `ChannelTalkFlutterPlatform.instance`를 fake로 교체하고 복구한다.
- 채널 테스트는 BinaryMessenger mock을 설치하고 호출 로그를 확인한 뒤 해제한다.
- 이벤트 테스트는 codec을 통해 메시지를 주입하고 tearDown에서 수신 리스너를 해제한다.
- Web 테스트는 전역 `ChannelIO`를 교체하고 원래 함수로 복구한다.
- SDK 콜백 기반 Future는 콜백 전 미완료, 성공/실패 후 결과를 각각 확인한다.
- null 생략, 명시적 `false`, 빈 목록, 커스텀 속성의 null을 구분해 검증한다.
- 리스너 교체/해제 후 기존 JS 콜백을 직접 호출하여 뒤늦은 이벤트를 확인한다.

Android 테스트 22개는 `android/src/test/`에 있으며 예제 Gradle 호스트에서 실행한다.
VM 59개·Web 27개·Android 22개를 합쳐 현재 회귀 테스트는 108개다.
예제의 widget/iOS/macOS 템플릿 테스트는 현재 플러그인 기능의 검증 기준이 아니다.
전체 실행 환경, 남은 공백, 기존 검증 기록은 [테스트 가이드](../docs/TESTING.md)를 참조한다.
