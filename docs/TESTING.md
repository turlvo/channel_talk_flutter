# 테스트와 검증 가이드

기록 기준: 2026-09-29. 플러그인 회귀 테스트 240개와 샘플 앱 테스트 31개를 구분한다.
현재 테스트 범위와 실행 명령, 이전 SDK 점검의 검증 기록을 구분해 설명한다.

## 현재 자동 테스트

| 계층 | 파일 | 개수 | 검증 대상 |
| --- | --- | --- | --- |
| 공개 Dart API | [API 테스트](../test/channel_talk_flutter_test.dart) | 6 | 기본 구현, 일부 위임, 태그 상한 |
| 공개 API 설정 | [설정 테스트][config] | 23 | null·false·빈 값, enum, 상세 boot, 태그 경계 |
| boot 상태 | [상태 테스트][status] | 7 | 상태 8종, null·미지원 상태, 채널·오류 |
| MethodChannel | [채널 테스트][channel] | 11 | 명령·인자, 지연 결과, 오류 보존 |
| 새 공개 옵션→채널 | [옵션 테스트][options] | 8 | 커스텀 속성·profileOnce·배치·유효하지 않은 여백 |
| 네이티브 이벤트 수신 | [이벤트 테스트][events] | 12 | 이벤트 8종, 리스너 수명, 미지원 이벤트 |
| 공개 API 전체 채널 계약 | [전체 채널 계약][all-channel] | 56 | bool API 27종의 인자·응답·오류, 상세 상태 |
| Web | [브라우저 테스트][web] | 38 | JS 변환, 상세 boot, 콜백 순서, 미지원 설정 |
| Web 전체 공개 계약 | [전체 Web 계약][all-web] | 42 | 명령·인자·오류, 미지원 9종, 공개 리스너 |
| Android | [네이티브 테스트][android] | 32 | 요청 본문, 상세 boot, 옵션·팝업·콜백 결과 |
| iOS 이벤트 | [네이티브 이벤트][ios-events] | 5 | 메인 스레드·동기 전달·payload·순서·URL 반환 |

[config]: ../test/channel_talk_flutter_config_test.dart
[status]: ../test/boot_with_status_test.dart
[channel]: ../test/channel_talk_flutter_method_channel_test.dart
[options]: ../test/channel_talk_options_test.dart
[events]: ../test/channel_talk_flutter_events_test.dart
[web]: ../test/channel_talk_flutter_web_test.dart
[android]: ../android/src/test/java/com/kuku/channel_talk_flutter/
[all-channel]: ../test/channel_talk_all_api_contract_test.dart
[all-web]: ../test/channel_talk_web_all_api_contract_test.dart
[ios-events]: ../example/ios/RunnerTests/RunnerTests.swift

VM 123개 + Web 80개 + Android JVM 32개 + iOS XCTest 5개 = 플러그인 240개다.
전수 검증에서 샘플 31개를 포함한 266개가 통과했고, 후속 iOS 수정에서 XCTest 5개를 추가했다.
후속 수정은 관련 Dart 검사 68개와 XCTest 5개를 실행했으며 나머지를 다시 실행하지 않았다.
표의 개수는 실행되는 테스트 케이스 수이며 공개 API 전체의 개수가 아니다.
Web의 38개에는 4개 작업에 대한 성공/실패 반복 등록 8개가 포함된다.
동일 계약을 여러 enum 값이나 API에서 확인하는 테스트 내부 반복은 별도 개수로 세지 않는다.

### Dart와 MethodChannel

- 공개 API 테스트는 기본 플랫폼이 MethodChannel 구현인지 확인한다.
- `hidePopup`, `setPreventDefaultUrlClick`, `setPage`의 플랫폼 위임을 확인한다.
- `setPage`는 page/profile 동시 전달과 profile 단독 전달을 확인한다.
- 설정 테스트는 boot·bootForWeb·updateUser의 선택값 생략, false·빈 값·중첩 null을 확인한다.
- 새 옵션 테스트는 공개 API부터 실제 MethodChannel 코덱까지 연결해 커스텀 속성·
  profileOnce·버튼·팝업 옵션을 확인한다. 기본 옵션과 여백 생략, 0, NaN·무한대를 구분한다.
- 모든 Language·Appearance 문자열, 웹 전용 옵션과 zIndex 0을 검증한다.
- bootWithStatus는 boot와 같은 설정을 전달하고 상세 상태 8개를 보존하는지 확인한다.
  알 수 없는 상태·null의 unknown 변환과 플랫폼 예외 전달도 검증한다.
- `addTags`는 정확히 10개를 한 번 전달하고 11개는 플랫폼 호출 없이 거절하는지 확인한다.
- 채널 테스트는 위 3개 API와 `openWorkflow`, `showMessenger`의 명령을 확인한다.
- 네이티브 false/null 결과, PlatformException 코드·메시지·상세 데이터,
  MissingPluginException과 boot의 지연 완료를 확인한다.
- 이벤트 테스트는 codec으로 네이티브 메시지를 주입해 이벤트 8종의 종류·payload를 확인한다.
  리스너 교체, 반복 해제, 재등록, 미지원 이벤트 오류도 검증한다.
- 전체 채널 계약 테스트는 bool? 반환 공개 API 27개 각각을 실제 codec 경계로 호출한다.
  인자와 true/false/null, PlatformException의 코드·메시지·상세 데이터,
  MissingPluginException을 보존하는지 확인한다. 상세 boot 상태와 선택 인자 생략도 확인한다.
- BinaryMessenger를 대체하므로 실제 Android/iOS 핸들러는 실행하지 않는다.

### Web

`@TestOn('browser')`와 `dart:js_interop`을 사용하므로 Chrome에서 별도로 실행한다.
전역 `ChannelIO`를 JS 함수로 대체하며 원격 SDK 로딩이나 네트워크 요청은 하지 않는다.

- `boot`, `updateUser`, `addTags`, `removeTags`가 SDK 콜백을 기다리는지 확인한다.
- 콜백 기반 API는 성공 `true`, 사용자 인자가 없는 실패 `false`, 호출 예외는 Future 오류다.
- bootWithStatus도 콜백을 기다리고 성공은 success, 실패는 unknown, JS 예외는 오류로 전달한다.
- 중복 SDK 콜백은 처음의 성공/실패 결과를 유지하며 동시 요청의 결과가 섞이지 않는지 확인한다.
- boot의 null 생략, 명시적 `false`, 사용자 필드의 profile 변환을 확인한다.
- 공개 부팅 API 3개에서 커스텀 속성이 JS profile의 기본 값보다 우선하는지 확인한다.
- boot·bootWithStatus의 모바일 옵션은 SDK 호출 전 비동기 오류로 거절하며 null은 허용한다.
- updateUser의 빈 profile 생략, 커스텀 속성의 null, `profileOnce`를 확인한다.
- 배지·프로필·팝업·메신저 표시 이벤트를 Dart 값으로 변환하는지 확인한다.
- 교체/해제된 리스너의 뒤늦은 콜백을 무시하는지 확인한다.
- 실제 SDK처럼 URL 콜백 반환값을 버리는 mock으로 이벤트 관찰 동작을 확인한다.
  URL 차단 true는 비동기 미지원 오류, false는 성공 no-op이며 리스너가 보존되는지 확인한다.
- 인자 없는 `onChatCreated`, setPage 인자 전달, null page 거부를 확인한다.
- 전체 Web 계약 테스트는 메신저·상담 버튼·상담 열기·워크플로·페이지·추적·테마·팝업 등
  기존 테스트에서 빠졌던 명령의 인자와 JS 호출 오류 전달을 검증한다.
- Web 미지원 9개 API는 SDK 호출 없이 UnimplementedError를 발생시키는지 확인한다.
  공개 부팅·갱신·태그 메서드의 콜백 대기와 리스너 공개 진입점도 함께 검사한다.
- 즉시 응답형 메서드의 true는 JS 호출 완료이며, 서버나 화면 처리를 완료했다는 뜻은 아니다.

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
- 두 부팅 경로의 커스텀 속성 우선 병합·null, profileOnce의 요청 JSON을 확인한다.
- 실제 SDK 객체로 버튼 아이콘 18개, 배치·소수 여백·기본값·잘못된 옵션을 확인한다.
- 팝업 Handler의 기존 필드와 nullable message, long timestamp 전달을 확인한다.
- updateUser·addTags·removeTags에서 오류와 user가 함께 오면 오류만 반환한다.
  오류와 user가 모두 null인 경우에도 false로 완료하며 결과 응답은 정확히 한 번인지 확인한다.

## 실행 방법

최소 Dart 3.3 / Flutter 3.19 환경이 필요하다. 각 플랫폼의 SDK와 도구도 준비한다.
아래 명령은 RTK를 사용하는 프로젝트 작업 규칙을 따른다.

저장소 루트에서 정적 분석과 VM 테스트 7개 파일, Chrome 테스트 2개 파일을 실행한다.

```sh
rtk proxy flutter pub get
rtk proxy flutter analyze
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

## 샘플 앱 테스트와 네이티브 템플릿

- [샘플 widget 테스트](../example/test/widget_test.dart)는 부팅 버튼·JSON 편집·취소,
  공개 API 호출 인자와 팝업 timestamp 표시를 검증한다. SDK는 기록용 플랫폼으로 대체한다.
- [샘플 부팅 변환 테스트](../example/test/sample_boot_test.dart)는 JSON 옵션의 enum·숫자·
  기본값·생략·잘못된 입력·Web 전용 인자를 확인한다.
- [iOS RunnerTests](../example/ios/RunnerTests/RunnerTests.swift)는 실제 FlutterMethodChannel과
  기록용 BinaryMessenger로 이벤트의 메인 스레드 전송·payload·정확히 한 번 전달을 확인한다.
  SDK 서버를 연결하지 않으며, 실제 SDK 상담 생성은 별도 integration test에서 확인한다.
- [macOS RunnerTests](../example/macos/RunnerTests/RunnerTests.swift)는 플랫폼 버전
  템플릿만 다룬다. macOS의 Channel Talk API 지원을 입증하지 않는다.

샘플 테스트는 `example/`에서 실행한다. macOS 템플릿은 Channel Talk 검증으로 사용하지 않는다.

```sh
rtk proxy flutter test test/widget_test.dart test/sample_boot_test.dart
rtk proxy flutter analyze --no-pub
```

### iOS 네이티브 이벤트 회귀

`RunnerTests`는 키 없이 Handler를 호출하고 실제 Flutter codec/messenger 경계를 검사한다.
Flutter 3.44.1과 CocoaPods를 사용한 임시 복사본의 `example/`에서 설정을 준비했다.

```sh
rtk proxy flutter build ios --simulator --debug --config-only --no-codesign
# 실행 위치: example/ios/
rtk proxy xcodebuild test \
  -workspace Runner.xcworkspace -scheme Runner -configuration Debug \
  -destination 'platform=iOS Simulator,id=<TEST_SIMULATOR_UDID>' \
  -derivedDataPath /private/tmp/channel-talk-event-tests-derived \
  -resultBundlePath /private/tmp/channel-talk-event-tests.xcresult \
  -only-testing:RunnerTests -parallel-testing-enabled NO \
  CODE_SIGNING_ALLOWED=NO DART_DEFINES= FLUTTER_TARGET=lib/main.dart
```

사용 가능한 전용 시뮬레이터 ID와 아직 존재하지 않는 결과 경로를 지정한다.
2026-09-29에 같은 XCTest 5개를 수정 전후로 비교했다. 수정 전은 백그라운드 스레드 검사
4개 실패/main 동기 전달 1개 통과, 수정 후는 5개 통과 및 xcodebuild 정상 종료였다.
수정 전 결과 정리가 멈춘 프로세스는 종료했으며 당시 판정에는 XCTest 로그를 사용했다.
수정 후 실제 SDK 상담 생성 3회와 관련 Dart 검사 68개도 통과했다.
상세 범위·제약은 [iOS 이벤트 수정 기록](ios_event_thread_fix_2026_09_29.md)을 참고한다.

## 보강할 범위

- 자동 계약 테스트로 확인한 공개 API를 실제 SDK에서 같은 인자·실패 조건으로 검증.
  각 플랫폼의 미지원 API 및 관리자 설정·실제 푸시가 필요한 시나리오는 별도로 구분한다.
- Swift 팝업 객체와 Android 팝업 이외의 이벤트 변환 및 실제 채널 왕복 확대.
  Swift의 상담·메신저·배지·프로필·URL 이벤트와 Android 팝업 Handler는 네이티브 회귀가 있다.
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

## 누락 옵션 대응 검증

2026-09-12에 부팅 커스텀 속성, profileOnce, 모바일 배치 옵션, Android 팝업 timestamp와
Web 미지원 설정 처리를 추가하면서 회귀 테스트를 29개 보강했다.

- Flutter 3.19.6 / Dart 3.3.4: 위 VM 테스트 6개 파일의 67개 통과.
- 같은 SDK와 Chrome: Web 테스트 38개 통과.
- Gradle 8.10.2 / Java 21.0.10: Android 테스트 32개와 예제 assembleDebug 통과.
  `:channel_talk_flutter:testDebugUnitTest :app:assembleDebug --no-daemon`으로 실행했다.
- Flutter 3.44.1 / ChannelIOSDK 13.3.0: 최종 공유 Swift 소스로 SPM·CocoaPods 시뮬레이터
  빌드 모두 통과. 위 원격 변경 통합 검증과 같은 임시 복사본·명령으로 실행했다.
- 별도의 임시 iOS 검증 코드로 실제 SDK의 BootConfig.profile 저장 사전, 버튼 아이콘 18개,
  배치 기본값·여백·잘못된 인자를 확인했다. 기본 프로필과 커스텀 속성을 먼저 병합해
  중복 키 우선순위·NSNull·불리언·숫자 값이 보존되고 경쟁하는 기본 필드가 없음을 확인했다.
  이 확인은 아래 자동 회귀 137개에 포함하지 않으며 HTTP 직렬화·서버 수신 검증은 아니다.
- `rtk proxy flutter analyze --no-pub`: 문제 없음.
- 팝업 이벤트 fixture에 64비트 timestamp·null message를 반영한 뒤 이벤트 12개 재실행 통과.
- 내부 문서 링크·새 Dart 파일 줄 길이·`rtk git diff --check`: 통과.

VM과 Chrome 명령에는 `--no-pub`를 사용했다. 합계 137개는 서버 접속 없는 자동 테스트이며,
실제 계정의 프로필 저장·상담·팝업 UI·푸시 수신 및 클릭은 이번 검증에 포함하지 않았다.

## 샘플 앱 추가 검증

2026-09-15에 샘플 앱의 누락된 SDK 옵션을 연결하고 이전 widget 템플릿을 교체했다.

- Flutter 3.19.6 / Dart 3.3.4에서 widget 테스트 12개, 부팅 변환 테스트 19개, 합계 31개 통과.
  `example/`에서 위 샘플 테스트 명령에 `--no-pub --reporter expanded`를 추가해 실행했다.
- `example/`의 `rtk proxy flutter analyze --no-pub`: 문제 없음.
- 로컬 Web 실행으로 새 부팅 버튼과 JSON 입력 창, timestamp 표시 영역을 확인했다.
- 문서 내부 링크·`rtk git diff --check`: 통과.

샘플 테스트는 SDK를 기록용 플랫폼으로 대체한다. 브라우저 확인은 입력 화면까지 수행했으며,
실제 plugin key를 통한 부팅·프로필 저장·팝업 수신은 별도 테스트 채널에서 확인해야 한다.
플러그인 소스·SDK 버전은 이 샘플 보완에서 바꾸지 않았으며 위 137개를 다시 실행하지 않았다.

## 실제 Web SDK 연결 검증

2026-09-29에 현재 샘플을 실제 CDN SDK와 사용자 제공 테스트 키로 실행했다.
부팅 API 3종, 메신저·상담 버튼 표시/숨김, 리스너 해제·재등록과 Web 입력 거절을 확인했다.
가상 잘못된 키는 HTTP 422 이후 약 147초 동안 SDK 콜백이 없어 Future가 완료되지 않았다.
정상 키로 재부팅하면 복구됐다. 기존 응답 계약을 바꾸는 런타임 수정은 하지 않았다.

프로필·태그의 서버 변경은 승인 대기이며 팝업 timestamp·상담·모바일 푸시는 미검증이다.
환경, 개별 결과와 한계는 [실제 Web SDK 검증 기록](web_sdk_qa_2026_09_29.md)을 참고한다.

## 전체 API 계약 및 실제 SDK 점검: 2026-09-29

기존 응답 처리 보존을 확인하기 위해 VM 계약 테스트 56개와 Chrome 계약 테스트 42개를
추가했다. 공개 ChannelTalk 메서드 30개를 기존·신규 테스트에서 대조했다.

- Flutter 3.19.6 / Dart 3.3.4: VM 123개와 샘플 31개 통과.
- 같은 Flutter SDK / Chrome 154.0.8037.58: Web mock 80개 통과.
- Android JVM 32개 재실행 통과. 플러그인 합계 235개, 샘플 포함 266개다.
- 위 VM·Chrome·샘플 명령에 `--no-pub --reporter expanded`를 추가해 실행했다.
- 신규 QA 실행 도구의 분석 항목을 정리한 후 저장소 루트의
  `rtk proxy flutter analyze --no-pub`는 문제 없이 통과했다.
- 신규 계약 테스트는 가상 키·토큰·데이터만 사용하며 런타임 응답 처리를 바꾸지 않았다.

실제 SDK 호출 점검은 위 자동 테스트 개수에 포함하지 않는다. Android는 44개 검사가
기대와 일치했고 서버 쓰기 6개는 보류했다. iOS는 44개 검사가 기대와 일치했으나
shutdown 직후 isBooted 상태 1개가 예상과 달랐고, 서버 쓰기 6개는 보류했다.
iOS onChatCreated의 비메인스레드 채널 호출 문제도 3회 중 3회 재현했다.
Web에서는 27종 API를 45회 호출했으며 정상 서버 쓰기 검증은 완료하지 못했다.

이 수치는 모든 실기능의 통과를 의미하지 않는다. 각 플랫폼의 명령 호출·응답 검사와
서버 저장·푸시·이벤트 수신의 검증 범위 및 발견 사항은
[전체 API QA 보고서](full_api_qa_2026_09_29.md)를 기준으로 확인한다.
