# Dart 및 Web 테스트

이 디렉토리는 공개 Dart API, MethodChannel 직렬화, 브라우저 JS 브리지를 검증한다.
실제 Channel Talk 계정이나 네이티브 SDK 세션을 시작하지 않는다.

| 파일 | 케이스 | 역할 |
| --- | --- | --- |
| [channel_talk_flutter_test.dart](channel_talk_flutter_test.dart) | 6 | 플랫폼 위임과 태그 제한 |
| [channel_talk_flutter_config_test.dart][config] | 23 | 설정 생략·빈 값·enum·상세 boot·태그 경계 |
| [boot_with_status_test.dart](boot_with_status_test.dart) | 7 | 상태 문자열·채널 전달·오류 |
| [channel_talk_flutter_method_channel_test.dart][channel] | 11 | 채널 인자·지연 응답·오류 |
| [channel_talk_options_test.dart](channel_talk_options_test.dart) | 8 | 새 공개 옵션→채널, 여백·초기 프로필 |
| [channel_talk_flutter_events_test.dart][events] | 12 | 네이티브 이벤트 수신·리스너 수명 |
| [channel_talk_all_api_contract_test.dart][all-channel] | 56 | bool API 27종의 인자·응답·오류, 상세 상태 |
| [channel_talk_flutter_web_test.dart][web] | 38 | JS 옵션·콜백·이벤트·미지원 기능 |
| [channel_talk_web_all_api_contract_test.dart][all-web] | 42 | 명령·인자·오류, 미지원 9종, 공개 리스너 |

[config]: channel_talk_flutter_config_test.dart
[channel]: channel_talk_flutter_method_channel_test.dart
[events]: channel_talk_flutter_events_test.dart
[web]: channel_talk_flutter_web_test.dart
[all-channel]: channel_talk_all_api_contract_test.dart
[all-web]: channel_talk_web_all_api_contract_test.dart

저장소 루트에서 실행한다. Web 테스트는 Chrome을 별도로 지정해야 한다.

```sh
rtk proxy flutter test test/channel_talk_flutter_test.dart \
  test/channel_talk_flutter_config_test.dart \
  test/channel_talk_flutter_method_channel_test.dart \
  test/channel_talk_flutter_events_test.dart \
  test/boot_with_status_test.dart \
  test/channel_talk_options_test.dart \
  test/channel_talk_all_api_contract_test.dart
rtk proxy flutter test --platform chrome test/channel_talk_flutter_web_test.dart \
  test/channel_talk_web_all_api_contract_test.dart
```

## 테스트 추가 시 유지할 패턴

- 공개 API 테스트는 `ChannelTalkFlutterPlatform.instance`를 fake로 교체하고 복구한다.
- 채널 테스트는 BinaryMessenger mock을 설치하고 호출 로그를 확인한 뒤 해제한다.
- 전체 채널 계약 테스트는 공개 API부터 codec까지 연결해 true/false/null 및 오류 상세를
  보존하는지 검사한다. Java/Swift SDK의 실제 성공을 검사하는 테스트로 표현하지 않는다.
- 이벤트 테스트는 codec을 통해 메시지를 주입하고 tearDown에서 수신 리스너를 해제한다.
- Web 테스트는 전역 `ChannelIO`를 교체하고 원래 함수로 복구한다.
- 전체 Web 계약 테스트는 미지원 메서드가 SDK 호출 없이 실패하는지, JS 호출 예외가
  성공으로 바뀌지 않는지 확인한다. 즉시 반환되는 true를 서버 처리 완료로 해석하지 않는다.
- SDK 콜백 기반 Future는 콜백 전 미완료, 성공/실패 후 결과를 각각 확인한다.
- null 생략, 명시적 `false`, 빈 목록, 커스텀 속성의 null을 구분해 검증한다.
- 리스너 교체/해제 후 기존 JS 콜백을 직접 호출하여 뒤늦은 이벤트를 확인한다.

Android 테스트 32개는 `android/src/test/`에 있으며 예제 Gradle 호스트에서 실행한다.
2026-09-29 전수 실행에서 VM 123개·Web 80개·Android JVM 32개의 235개가 통과했다.
샘플 widget 12개·부팅 변환 19개까지 포함하면 당시 자동 회귀는 266개다.
후속 iOS 수정에서 실제 Flutter codec 경계의 이벤트 스레드 회귀 5개를 추가했다.
관련 Dart 68개와 이 iOS RunnerTests 5개도 모두 통과했다.
macOS RunnerTests는 플랫폼 버전용 템플릿이므로 Channel Talk 기능 검증에서 제외한다.

공개 메서드 30개를 계약 테스트로 대조했지만 실제 SDK 기능 전체가 통과했다는 뜻은 아니다.
전체 실행 환경과 이전 검증 기록은 [테스트 가이드](../docs/TESTING.md),
실제 SDK의 플랫폼별 결과·보류 항목·발견 문제는
[전체 API QA 보고서](../docs/full_api_qa_2026_09_29.md)를 참조한다.
