# Channel.io SDK 호환성 점검

점검일: 2026-09-12. 작업 시작 시 존재하던 미커밋 변경을 포함한 상태를 기준으로 점검했다.
기존 `setPage(profile)`와 Web 이벤트 구현을 보존하면서 아래 문제를 수정했다.

## SDK 버전

| 플랫폼 | 점검 시작 설정 | 반영 버전 | 확인 근거 |
| --- | --- | --- | --- |
| Android | 13.3.0 | 13.5.0 | [공식 Maven 메타데이터](https://maven.channel.io/maven2/io/channel/plugin-android/maven-metadata.xml) |
| iOS | 13.1.0 | 13.3.0 | [공식 배포 podspec](https://mobile-static.channel.io/ios/latest/xcframework.podspec), [정식 릴리스](https://github.com/channel-io/channel-talk-ios-framework/releases/tag/13.3.0) |

최신 배포는 2026-09-10에 확인된다. 점검 시점의 공식 변경 문서는 Android 13.4.1,
iOS 13.2.2까지만 설명하므로 최신 버전의 상세 변경을 추정하지 않았다.
공개된 변경에는 Android URL 열기 오류 및 채팅 안정성 개선, iOS 잘못된 썸네일 크기로
인한 크래시 수정, 양 플랫폼 캐러셀 메시지 지원 등이 있다.
[Android 변경 문서](https://developers.channel.io/en/articles/c0fcc35c),
[iOS 변경 문서](https://developers.channel.io/en/articles/99b22b7e).

## 발견한 문제와 조치

| 우선순위 | 문제와 영향 | 조치 |
| --- | --- | --- |
| 높음 | Android 최신 SDK가 기존 google/Maven Central 설정에서 해석되지 않아 빌드 실패 | `io.channel` 그룹에 한정하여 공식 Maven 저장소 추가 |
| 높음 | iOS `setPage`가 optional 사전을 non-optional SDK 인자로 전달하여 컴파일 불가 | profile 생략 시 SDK 기본값과 같은 빈 사전 전달 |
| 높음 | Android 화면 재생성 후 파괴된 Activity 참조 유지 | detach 시 해제, reattach 시 새 Activity 연결 |
| 높음 | Android `updateUser(name: ...)`도 언어와 태그를 강제 설정 | 호출자가 제공한 필드만 SDK Builder에 전달 |
| 높음 | iOS 부분 업데이트가 언어·태그·마케팅 수신 설정을 덮어쓸 수 있음 | 생략한 필드를 Builder에 전달하지 않음; boot의 nullable 수신 설정도 보존 |
| 높음 | Web boot/프로필/태그 API가 SDK 완료 전 무조건 성공 반환 | SDK 콜백까지 기다리고 오류가 있으면 false 반환 |
| 중간 | Web 프로필 없는 사용자 업데이트가 금지된 빈 profile 객체를 전송 | 비어 있는 profile 생략 |
| 중간 | Web 상담 생성 콜백은 인자가 없는데 필수 인자를 요구 | 인자 없는 SDK 콜백 허용 |
| 중간 | Web에 null page를 전달하는 기존 브리지가 공식 계약 위반 | ArgumentError로 거부; 초기화는 resetPage 사용 |
| 중간 | iOS updateUser 콜백에서 user/error 모두 nil이면 Future 미완료 | 모든 콜백 경로에서 정확히 한 번 결과 반환 |
| 중간 | Android 푸시 토큰 등록 예외가 성공으로 처리됨 | 실패를 MethodChannel 오류로 전달 |
| 중간 | Web에서 Dart 3.3 JS interop을 쓰지만 Dart 2.17부터 지원한다고 선언 | 최소 Dart 3.3 / Flutter 3.19로 정정 |

이번 수정은 SDK API 호환 문제와 기존 브리지 결함을 함께 다룬다.
Activity 수명주기나 부분 업데이트 문제를 최신 SDK에서 새로 발생한 회귀로 단정하지 않는다.

## 적용 시 확인할 차이

- iOS 15.0, Android API 21 이상은 유지한다. Android 플러그인의 compileSdk는 35다.
- `ChannelTalk.setPage(page: ...)` 호출은 그대로 사용할 수 있다. 직접 플랫폼 구현을
  작성했다면 override를 named parameters 방식으로 변경해야 한다.
- Web은 `setPage`에 page가 필요하다. Android/iOS는 null page를 허용한다.
- Web SDK 콜백 실패는 false로 반환한다. JS 호출 자체의 예외는 Future 오류로 전달된다.
- Android `Language.device`는 boot에서 기기 언어를 사용하고, updateUser에서는 현재
  언어를 유지한다. Android SDK의 명시적 언어 enum은 한국어/일본어/영어뿐이다.
- Web의 `isBooted`, `sleep`, 네이티브 푸시 API는 미지원이다. Web listener 등록/해제는
  SDK의 전역 `clearCallbacks`를 사용하므로 다른 코드에서 등록한 콜백에도 영향을 준다.
- macOS는 pubspec에 등록되어 있지만 현재 네이티브 구현은 템플릿 수준이다.
  Channel Talk API의 macOS 지원으로 해석하면 안 된다. 이번 모바일/Web 대응에 포함하지 않았다.
- Firebase Messaging 20.1.0 의존성은 남아 있다. 호스트 앱의 Firebase BOM 또는
  `firebase_messaging`과 최종 해석되는 버전, 푸시 전달 경로는 실제 앱에서 확인해야 한다.

계약 근거: [iOS API](https://developers.channel.io/en/articles/a403bd1c),
[iOS 모델](https://developers.channel.io/en/articles/c692396f),
[Android API](https://developers.channel.io/en/articles/ChannelIO-e9706bcd),
[Web API](https://developers.channel.io/en/articles/0b119290),
[Dart JS interop](https://dart.dev/blog/new-in-dart-3-3-extension-types-javascript-interop-and-more).

## 검증

- Flutter 3.19.6 및 3.44.1에서 정적 분석과 공개 API/MethodChannel 테스트 12개 통과.
- ChannelIOSDK 13.3.0 설치 및 Xcode 26.0.1 iOS 시뮬레이터 예제 빌드 통과.
- Flutter 3.19.6 및 3.44.1 + Chrome에서 Web 회귀 테스트 19개 통과.
- Android SDK 13.5.0의 실제 요청 본문 및 호출을 검증하는 네이티브 회귀 테스트
  10개 통과(부분 업데이트, 언어 처리, Activity 교체/분리, 초기화·푸시 오류).
- Android 예제 `assembleDebug` 통과. 의존성 메타데이터 검사와 manifest 병합도 통과했다.
  예제 AGP 8.1.0에서 compileSdk 35 및 tracing의 Kotlin 메타데이터 처리 관련 경고가
  남으므로 호스트 앱의 빌드 도구 갱신 시 함께 확인해야 한다.
- `git diff --check` 통과.
- 실제 Channel.io 계정의 상담 생성, 첨부, 로그인 전환, APNs/FCM 수신·클릭은
  이번 자동 검증에 포함하지 않았다.

재실행 명령(해당 Flutter 버전을 선택한 환경):

```sh
rtk proxy flutter analyze
rtk proxy flutter test test/channel_talk_flutter_test.dart test/channel_talk_flutter_method_channel_test.dart
rtk proxy flutter test --platform chrome test/channel_talk_flutter_web_test.dart
# example/android 디렉토리
rtk proxy ./gradlew :channel_talk_flutter:testDebugUnitTest :app:assembleDebug --no-daemon
# example 디렉토리
rtk proxy flutter build ios --simulator --debug --no-codesign
```
