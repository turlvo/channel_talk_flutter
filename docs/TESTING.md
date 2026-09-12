# 테스트와 검증 가이드

기록 기준: 2026-09-12. 기존 회귀 테스트 확장과 원격 API 통합을 반영해 총 108개를 검증한다.
현재 테스트 범위와 실행 명령, 이전 SDK 점검의 검증 기록을 구분해 설명한다.

## 현재 자동 테스트

| 계층 | 파일 | 개수 | 검증 대상 |
| --- | --- | --- | --- |
| 공개 Dart API | [API 테스트](../test/channel_talk_flutter_test.dart) | 6 | 기본 구현, 일부 위임, 태그 상한 |
| 공개 API 설정 | [설정 테스트][config] | 23 | null·false·빈 값, enum, 상세 boot, 태그 경계 |
| boot 상태 | [상태 테스트][status] | 7 | 상태 8종, null·미지원 상태, 채널·오류 |
| MethodChannel | [채널 테스트][channel] | 11 | 명령·인자, 지연 결과, 오류 보존 |
| 네이티브 이벤트 수신 | [이벤트 테스트][events] | 12 | 이벤트 8종, 리스너 수명, 미지원 이벤트 |
| Web | [브라우저 테스트][web] | 27 | JS 변환, 상세 boot, 콜백 순서, 리스너 수명 |
| Android | [네이티브 테스트][android] | 22 | 요청 본문, 상세 boot, 콜백 결과 1회 완료 |

[config]: ../test/channel_talk_flutter_config_test.dart
[status]: ../test/boot_with_status_test.dart
[channel]: ../test/channel_talk_flutter_method_channel_test.dart
[events]: ../test/channel_talk_flutter_events_test.dart
[web]: ../test/channel_talk_flutter_web_test.dart
[android]: ../android/src/test/java/com/kuku/channel_talk_flutter/ChannelTalkFlutterPluginTest.java

표의 개수는 실행되는 테스트 케이스 수이며 공개 API 전체의 개수가 아니다.
Web의 27개에는 4개 작업에 대한 성공/실패 반복 등록 8개가 포함된다.
동일 계약을 여러 enum 값이나 API에서 확인하는 테스트 내부 반복은 별도 개수로 세지 않는다.

### Dart와 MethodChannel

- 공개 API 테스트는 기본 플랫폼이 MethodChannel 구현인지 확인한다.
- `hidePopup`, `setPreventDefaultUrlClick`, `setPage`의 플랫폼 위임을 확인한다.
- `setPage`는 page/profile 동시 전달과 profile 단독 전달을 확인한다.
- 설정 테스트는 boot·bootForWeb·updateUser의 선택값 생략, false·빈 값·중첩 null을 확인한다.
- 모든 Language·Appearance 문자열, 웹 전용 옵션과 zIndex 0을 검증한다.
- bootWithStatus는 boot와 같은 설정을 전달하고 상세 상태 8개를 보존하는지 확인한다.
  알 수 없는 상태·null의 unknown 변환과 플랫폼 예외 전달도 검증한다.
- `addTags`는 정확히 10개를 한 번 전달하고 11개는 플랫폼 호출 없이 거절하는지 확인한다.
- 채널 테스트는 위 3개 API와 `openWorkflow`, `showMessenger`의 명령을 확인한다.
- 네이티브 false/null 결과, PlatformException 코드·메시지·상세 데이터,
  MissingPluginException과 boot의 지연 완료를 확인한다.
- 이벤트 테스트는 codec으로 네이티브 메시지를 주입해 이벤트 8종의 종류·payload를 확인한다.
  리스너 교체, 반복 해제, 재등록, 미지원 이벤트 오류도 검증한다.
- BinaryMessenger를 대체하므로 실제 Android/iOS 핸들러는 실행하지 않는다.

### Web

`@TestOn('browser')`와 `dart:js_interop`을 사용하므로 Chrome에서 별도로 실행한다.
전역 `ChannelIO`를 JS 함수로 대체하며 원격 SDK 로딩이나 네트워크 요청은 하지 않는다.

- `boot`, `updateUser`, `addTags`, `removeTags`가 SDK 콜백을 기다리는지 확인한다.
- 성공은 `true`, 사용자 인자가 없는 실패는 `false`, 동기 예외는 Future 오류로 확인한다.
- bootWithStatus도 콜백을 기다리고 성공은 success, 실패는 unknown, JS 예외는 오류로 전달한다.
- 중복 SDK 콜백은 처음의 성공/실패 결과를 유지하며 동시 요청의 결과가 섞이지 않는지 확인한다.
- boot의 null 생략, 명시적 `false`, 사용자 필드의 profile 변환을 확인한다.
- updateUser의 빈 profile 생략, 커스텀 속성의 null, `profileOnce`를 확인한다.
- 배지·프로필·팝업·메신저 표시 이벤트를 Dart 값으로 변환하는지 확인한다.
- 교체/해제된 리스너의 뒤늦은 콜백 무시와 URL 기본 동작 차단을 확인한다.
- 교체된 URL 콜백은 이벤트·차단에 영향을 주지 않고 재등록 후에는 차단 기본값을 확인한다.
- 인자 없는 `onChatCreated`, setPage 인자 전달, null page 거부를 확인한다.

### Android

JUnit 4.13.2와 Mockito 5.14.2를 사용한다. 버전과 SDK 의존성의 기준은
[android/build.gradle](../android/build.gradle)이다.
`ChannelIO`의 정적 호출을 mock 처리하여 실제 상담 세션이나 서버에 연결하지 않는다.
`UserData`와 `BootConfig`는 실제 SDK 객체를 사용한다.

- updateUser의 생략/null 설정 보존, 빈 태그로 초기화, 명시적 `false`를 확인한다.
- 실제 SDK 요청 본문을 직렬화해 부분 업데이트의 필드 누락 여부를 확인한다.
- device 언어의 boot 기본값과 updateUser의 기존 언어 보존을 확인한다.
- 화면 구성 변경 후 Activity 교체 및 detach 이후 UI 호출 거부를 확인한다.
- 초기화 실패와 푸시 토큰 등록 실패가 Dart 오류로 전달되는지 확인한다.
- boot 콜백 전에는 결과나 리스너 등록이 없고, 성공 상태와 user가 모두 있어야 성공한다.
- boot 이전 updateUser는 SDK 호출 없이 거절한다.
- bootWithStatus의 성공·networkTimeout 문자열 반환과 리스너 등록 조건도 확인한다.
- updateUser·addTags·removeTags에서 오류와 user가 함께 오면 오류만 반환한다.
  오류와 user가 모두 null인 경우에도 false로 완료하며 결과 응답은 정확히 한 번인지 확인한다.

## 실행 방법

최소 Dart 3.3 / Flutter 3.19 환경이 필요하다. 각 플랫폼의 SDK와 도구도 준비한다.
아래 명령은 RTK를 사용하는 프로젝트 작업 규칙을 따른다.

저장소 루트에서 정적 분석과 VM 테스트 5개 파일을 명시적으로 실행한다.

```sh
rtk proxy flutter pub get
rtk proxy flutter analyze
rtk proxy flutter test test/channel_talk_flutter_test.dart \
  test/channel_talk_flutter_config_test.dart \
  test/channel_talk_flutter_method_channel_test.dart \
  test/channel_talk_flutter_events_test.dart \
  test/boot_with_status_test.dart
rtk proxy flutter test --platform chrome test/channel_talk_flutter_web_test.dart
```

Android는 Flutter 엔진 클래스가 필요하므로 플러그인의 `android/`를 단독 빌드하는 대신
`example/android/`를 Gradle 호스트로 사용한다. 이 호스트의 Gradle 래퍼는 8.10.2다.
먼저 `example/`에서 의존성을 준비하고 Android SDK 경로 등 로컬 설정을 확인한다.

```sh
# 실행 위치: example/
rtk proxy flutter pub get
# 실행 위치: example/android/
rtk proxy ./gradlew :channel_talk_flutter:testDebugUnitTest --no-daemon
rtk proxy ./gradlew :app:assembleDebug --no-daemon
```

예제 Web 및 iOS 시뮬레이터 빌드는 `example/`에서 실행한다.
iOS 빌드는 macOS, Xcode, CocoaPods와 iOS SDK 준비가 필요하다.

```sh
# 실행 위치: example/
rtk proxy flutter build web
rtk proxy flutter build ios --simulator --debug --no-codesign
```

빌드 성공은 브리지의 컴파일과 패키징 검증이며 SDK 기능의 실제 사용 검증과 구분한다.

## 예제의 템플릿 테스트

- [example/test/widget_test.dart](../example/test/widget_test.dart)는 `Running on:` 문구를
  찾는 예전 템플릿이다. 현재 예제 UI와 어긋나므로 플러그인 회귀 검증으로 사용하지 않는다.
- [iOS RunnerTests](../example/ios/RunnerTests/RunnerTests.swift)는 구현되지 않은
  `getPlatformVersion`을 호출하는 템플릿이다. 실제 Channel Talk 기능 테스트가 아니다.
- [macOS RunnerTests](../example/macos/RunnerTests/RunnerTests.swift)는 플랫폼 버전
  템플릿만 다룬다. macOS의 Channel Talk API 지원을 입증하지 않는다.

예제 테스트를 실행하거나 확장할 때는 먼저 현재 앱 및 플랫폼 계약에 맞게 교체한다.

## 보강할 범위

- 아직 다루지 않은 공개 API 인자와 플랫폼별 필수값·미지원 명령 처리.
- Java·Swift 이벤트 Handler가 SDK 데이터를 만드는 과정과 실제 채널을 통한 왕복.
  현재 이벤트 테스트는 Dart 수신 쪽을 검증한다.
- iOS의 부분 업데이트, null 처리, 오류/결과를 정확히 한 번 반환하는 동작.
- Web의 전역 콜백 해제가 외부 코드와 함께 사용할 때 미치는 영향과 실제 SDK 로딩.
- 실제 기기에서 상담 생성·첨부·사용자 전환·URL 열기, APNs/FCM 수신 및 클릭.

실제 계정, 네트워크, SDK UI, 호스트 앱의 Firebase 의존성 조합은 현재 mock 기반
테스트의 검증 범위 밖이다. 변경한 계층의 자동 테스트와 필요한 실제 앱 시나리오를 구분한다.

## 기존 검증 기록

[SDK 호환성 점검](sdk_compatibility_audit.md)의 기존 기록에는 Flutter 3.19.6/3.44.1의
정적 분석과 Dart 12개, Chrome 19개, Android 10개 테스트 통과가 기재되어 있다.
iOS 시뮬레이터 빌드와 Android 예제 assembleDebug 통과도 해당 기록에 포함된다.
이는 그 점검 당시의 결과이며 아래 확장된 테스트 실행 결과와 구분한다.

## 회귀 테스트 확장 검증

2026-09-12에 런타임 소스 변경 없이 테스트 50개를 추가하고 다음을 실행했다.

- Flutter 3.19.6 / Dart 3.3.4: VM 테스트 47개 통과.
- 같은 Flutter SDK와 Chrome: Web 테스트 24개 통과.
- 예제 Gradle 8.10.2 / Java 21.0.10: Android 테스트 20개 통과, 실패·오류·skip 0개.
- `rtk proxy flutter analyze --no-pub`: 문제 없음.
- 변경한 테스트·문서의 줄 길이·링크와 `rtk git diff --check`: 통과.

위 테스트 명령을 의존성이 준비된 환경에서 실행했고 Flutter 명령에는 `--no-pub`를 사용했다.
Android는 `:channel_talk_flutter:testDebugUnitTest --no-daemon`만 실행했다.
기존 AGP 8.1.0/compileSdk 35와 Java target 8 경고는 남아 있으며 테스트는 통과했다.
이번 추가 작업에서는 iOS·예제 앱 빌드와 실제 서버 연결 시나리오를 재검증하지 않았다.

## 원격 변경 통합 검증

원격 main의 bootWithStatus와 iOS SPM 지원을 통합하면서 상태·옵션 보존 회귀를 보강했다.
같은 날 최종 Dart VM 59개, Chrome 27개, Android 22개가 통과했다.
원격 테스트 4개와 통합 회귀 13개를 추가로 포함해 합계 108개다.
Flutter 3.19.6/Dart 3.3.4와 예제 Gradle 8.10.2/Java 21.0.10으로 실행했다.

iOS는 생성 파일 변경이 작업 트리에 섞이지 않도록 임시 복사본에서 Flutter 3.44.1로 검증한다.
예제 pubspec의 `flutter.config.enable-swift-package-manager`를 true/false로 바꾸어
SPM과 CocoaPods 경로를 구분하며, 두 경로 모두 ChannelIOSDK 13.3.0을 사용한다.
명령은 `flutter pub get` 뒤 `flutter build ios --simulator --debug --no-codesign --no-pub`이며
각 명령 앞에는 동일하게 `rtk proxy`를 붙인다.
SPM·CocoaPods 시뮬레이터 빌드가 모두 통과했다.
Xcode가 해석한 SDK 13.3.0 리비전을 두 Package.resolved에 반영했다.

새 검증 결과에는 실행 날짜, 도구/SDK 버전, 명령, 실패 또는 미검증 범위를 함께 남긴다.
