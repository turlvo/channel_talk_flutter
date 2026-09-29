# Channel.io SDK 호환성 점검

점검일: 2026-09-12. 작업 시작 시 존재하던 미커밋 변경을 포함한 상태를 기준으로 점검했다.
기존 `setPage(profile)`와 Web 이벤트 구현을 보존하면서 아래 문제를 수정했다.
같은 날 진행한 누락 옵션 추가 및 Web URL 계약 정정은 문서 마지막의 후속 기록을 참고한다.

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

## 추가 SDK 옵션 대응

2026-09-12 후속 점검에서 SDK가 제공하지만 공개 Flutter API에 노출되지 않은 항목을 연결했다.
Android 13.5.0·iOS 13.3.0 의존성 버전은 변경하지 않았다.
이 항목들이 해당 SDK 릴리스에서 처음 추가되었다고 해석하지 않는다.

| 항목 | 반영 범위 |
| --- | --- |
| 부팅 customAttributes | boot·bootWithStatus·bootForWeb에서 기본 profile 뒤에 병합 |
| updateUser.profileOnce | Android·iOS·Web에 일반 profile과 구분해 전달 |
| ChannelButtonOption | 모바일 버튼 아이콘 18개, left/right, xMargin/yMargin |
| BubbleOption | 모바일 팝업 top/bottom 및 선택적 yMargin |
| Android PopupData.timestamp | 기존 4개 필드와 nullable message를 유지하고 SDK long 값 추가 |

모바일 배치 옵션은 공개 API → Map → 네이티브 SDK 객체로 변환한다.
두 부팅 API가 같은 경로를 사용하고, iOS CocoaPods·SPM도 같은 Swift 소스를 사용한다.
옵션 자체를 생략하면 기존 동작을 유지한다. 새 버튼 옵션을 명시할 때의 기본값만
channel/right/20/20이며 팝업 여백 생략은 SDK 계산에 맡긴다.
네이티브 SDK의 실제 타입·생성자와 [iOS 모델 문서][ios-models]를 함께 확인했다.

### Web URL 계약 정정

기존 Web 구현은 URL 이벤트 콜백에서 bool을 반환해 기본 동작이 차단된다고 가정했다.
하지만 [공식 loader의 UrlClickedCallback][web-loader]은 void이고,
[점검 시 배포된 SDK 코드][web-core]도 콜백 반환값을 사용하지 않는다.
이전 mock은 반환값을 검사했으므로 그 테스트 통과가 실제 URL 차단을 입증하지 못했다.

Web의 `onUrlClicked`는 관찰 이벤트로 유지한다.
`setPreventDefaultUrlClick(true)`는 비동기 `UnsupportedError`를 발생시키고,
false는 SDK 호출 없이 성공한다. 모바일은 기존 별도 차단 플래그를 유지한다.
Web에 모바일 버튼·팝업 옵션을 주어도 SDK 호출 전 비동기 미지원 오류로 완료한다.
호스트 앱은 Web에서 위 차단 API를 호출하지 않도록 분기해야 한다.

후속 실행 결과와 재실행 명령은 [최신 테스트 가이드](TESTING.md)에 기록한다.
실제 계정의 서버 반영·상담 UI·푸시 수신은 자동 테스트 범위 밖이다.

[ios-models]: https://developers.channel.io/en/articles/c692396f
[web-loader]: https://github.com/channel-io/channel-web-sdk-loader/blob/main/src/index.ts
[web-core]: https://cdn.channel.io/plugin/ch-plugin-core-20260910202327.js

## 공개 API 전체 대조: 2026-09-15

공식 배포 정보를 다시 확인한 최신 버전은 Android 13.5.0, iOS 13.3.0이다.
이번에 추가한 customAttributes·profileOnce·모바일 배치 옵션·팝업 timestamp와
bootWithStatus는 공개 API와 샘플 입력 경로에 연결되어 있다.
다만 이것이 SDK의 모든 반환 데이터와 선택 동작까지 동일하게 지원한다는 뜻은 아니다.

### 대조 범위와 신규 메서드 여부

- Android 공식 13.1.0·13.3.0·13.5.0 AAR의 공개 메서드 이름과 JVM descriptor를 비교했다.
  ChannelIO, BootConfig, UserData.Builder, BootCallback, UserUpdateCallback,
  ChannelPluginListener, User, PopupData, ChannelButtonOption, BubbleOption의
  10개 클래스는 추가·삭제 없이 동일했다. 아래 차이를 13.5.0의 신규 메서드 누락으로 보지 않는다.
- iOS 13.3.0 swiftinterface의 일반 실행 메서드와 현재 delegate 이벤트 7종은 연결되어 있다.
  initialize·initializeWindow, Data 형식 푸시 토큰과 Objective-C 호환 overload는
  Dart 메서드를 하나씩 추가할 대상이 아니라 호스트 통합 또는 기존 브리지에서 처리하는 항목이다.
- Web 공식 loader의 함수 23개 중 22개는 JS 브리지의 실행 함수·리스너에 연결된다.
  loadScript는 예제 HTML의 호스트 로더가 맡는다. loader에 없는 hidePopup과
  onPopupDataReceived는 공식 Web API 문서를 기준으로 구현되어 있다.
- 구형 unsubscribe 옵션은 공식 문서가 개별 unsubscribeEmail·unsubscribeTexting으로
  대체하도록 안내하므로 추가 대상에서 제외했다. Web 네이티브 푸시·sleep·isBooted 역시
  현재 Web SDK의 대응 함수가 없어 모바일과 동일하게 구현할 수 있는 항목이 아니다.

근거: [Android Maven 메타데이터][android-metadata], [iOS 최신 podspec][ios-latest],
[iOS 13.3.0 릴리스][ios-release], [공식 Web loader][web-loader],
[Web API][web-api], [Web 부팅 옵션][web-boot].

### 남은 기능·데이터 차이

| 항목 | 현재 상태와 영향 |
| --- | --- |
| SDK 콜백의 User 반환 | boot·updateUser·태그 작업의 User를 반환하지 않고 bool/상태로 축약한다. |
| SDK 오류 상세 | Web의 오류 콜백은 false/unknown으로 축약되며 원본 오류 결과 API가 없다. |
| 전체 프로필 초기화 | updateUser의 profile=null을 표현할 수 없다. 개별 속성 null은 가능하다. |
| Web 태그 초기화 | SDK는 tags=null을 요구하고 []를 금지하지만, 현재 null은 생략하고 []는 전송한다. |
| Web 언어 코드 | 공개 enum은 en·ko·ja·device만 가능해 그 외 사용자 번역 언어 코드를 지정할 수 없다. |
| Android 푸시 클릭 | 이벤트는 전달하지만 native 반환은 항상 false라 SDK 기본 이동을 막을 수 없다. |
| iOS appearance | nil 대신 system을 넣어 SDK 기본값에 위임할 수 없다. nil의 테마 의미는 미확인이다. |
| iOS 푸시 완료 | receivePushNotification의 Future는 SDK completion을 기다리지 않는다. |
| 모바일 리스너 해제 | removeListener는 Dart 콜백을 지우지만 SDK의 native 리스너는 유지한다. |

이 중 User·오류 결과, profile=null 및 언어 범위는 SDK 모델·콜백 계약과 공개 API를 대조했다.
Web tags 규칙은 [공식 updateUser 문서][web-api]와의 불일치다. 실제 서버에서의 초기화 동작은
이번 읽기 전용 점검에서 실행하지 않았다. iOS stage와 CrossPlatformUtils.openBrowser는
바이너리 public이지만 일반 앱용 공식 문서가 확인되지 않아 별도 검토 대상으로 남긴다.
SDK 내부 API라고 단정하거나 필수 Flutter 기능으로 자동 분류하지 않는다.
Android의 isInitialized·isDebugMode·isAttachChannelView·getAppContext·getListener도
바이너리 public인 진단·호스트 접근 항목이며 Dart에는 없다. initialize의 attachView는
플러그인 기본값을 사용한다. Activity/Context 인자와 callback 없는 overload는 별도 기능으로
세지 않았다. Web의 32개 언어 설명은 번역·사용자 언어에 관한 것이며 UI 언어 수가 아니다.

이번 대조에서는 런타임 코드와 SDK 버전을 바꾸지 않았고 빌드·테스트를 다시 실행하지 않았다.
샘플 입력·옵션 변환 테스트 31개와 앞선 플러그인 검증은 [테스트 기록](TESTING.md)을 참고한다.

[android-metadata]: https://maven.channel.io/maven2/io/channel/plugin-android/maven-metadata.xml
[ios-latest]: https://mobile-static.channel.io/ios/latest/xcframework.podspec
[ios-release]: https://github.com/channel-io/channel-talk-ios-framework/releases/tag/13.3.0
[web-api]: https://developers.channel.io/en/articles/0b119290
[web-boot]: https://developers.channel.io/en/articles/7f1c7aed
