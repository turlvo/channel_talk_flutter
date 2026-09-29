# 수동 API 실행 예제

상위 플러그인을 `path: ../`로 참조하는 Flutter 호스트 앱이다.
배포용 앱이 아니라 API 입력·결과·이벤트와 플랫폼 빌드 호환성을 확인하는 용도다.

## 구성

- [lib/main.dart](lib/main.dart): StatefulWidget 기반 API 버튼 목록.
  `boot`·`bootWithStatus`·`bootForWeb` 버튼별 JSON 입력 다이얼로그와 결과 toast를 제공한다.
  리스너 등록·해제 버튼과 최근 팝업 timestamp 표시가 있다.
- [lib/sample_boot.dart](lib/sample_boot.dart): JSON을 공개 API 인자로 변환한다.
  모바일 버튼·팝업 옵션을 타입 모델로 파싱하고 선택한 부팅 함수를 호출한다.
- [android/](android/): Java·Kotlin·Gradle 호스트와 SDK keep 규칙.
- [iOS AppDelegate](ios/Runner/AppDelegate.swift): SDK 초기화.
- [web/index.html](web/index.html): 전역 ChannelIO 명령 큐·CDN 스크립트 로더.
- [integration_test/](integration_test/README.md): Android·iOS·Web 실제 SDK 공개 API 검증 도구.
- [macos/](macos/): 플러그인 템플릿 확인용 호스트, Channel Talk 기능 미구현.

## 실행

작업 디렉터리: `example/`. Chrome 실행은 실제 웹 SDK를 로드한다.

```sh
rtk proxy flutter pub get
rtk proxy flutter run -d chrome
```

모바일은 준비된 기기를 선택해 실행한다. `.flutter-version`은 3.19.6을 표기하며
실제 최소 SDK 요구사항은 상위 [pubspec](../pubspec.yaml)을 따른다.
상담 기능에는 테스트용 Channel.io 채널 설정이 필요하다. 입력값을 소스에 저장하지 않는다.
예제의 이벤트 출력에는 사용자 데이터가 포함될 수 있으므로 테스트 데이터로 확인한다.

Android 예제의 알림 permission 선언만으로 FCM 설정과 서비스 등록이 완료되지는 않는다.
release 빌드는 debug 서명 설정을 사용한다.
앱 dispose는 입력 controller를 정리하고 ChannelTalk 리스너도 해제한다.

예제 widget 테스트는 새 UI와 API 입력 흐름을 검증한다.
iOS RunnerTests는 이벤트의 메인 스레드 전달·payload·URL 차단 반환값을 검증한다.
플랫폼별 검증 명령과 테스트 범위는 [테스트 가이드](../docs/TESTING.md)를 참고한다.

## 부팅 입력 예제

아래는 Android/iOS의 `boot`·`bootWithStatus` 기본 입력이다.
`pluginKey` 값을 자체 테스트 채널의 plugin key로 바꾼다.

```json
{
  "pluginKey": "pluginKey",
  "language": "ko",
  "appearance": "dark",
  "customAttributes": {
    "samplePlan": "pro",
    "obsoleteField": null
  },
  "channelButtonOption": {
    "icon": "headset",
    "position": "right",
    "xMargin": 20,
    "yMargin": 24
  },
  "bubbleOption": {
    "position": "bottom"
  }
}
```

`customAttributes`는 기본 프로필과 함께 전달하며 중복 키는 커스텀 값이 우선한다.
명시적인 `null`도 유지한다. `bubbleOption.yMargin`을 생략하면 SDK 기본 여백을 사용한다.

Web에서 여는 부팅 다이얼로그에는 모바일 전용 `channelButtonOption`·`bubbleOption`이
기본 입력에 포함되지 않는다. 위 JSON을 Web에 붙여 넣을 때는 두 옵션을 제거한다.
`bootForWeb`은 웹 전용 부팅 API이며 기본 입력에 `hideChannelButtonOnBoot: false`가 있다.

`updateUser` 다이얼로그에는 `customAttributes`와 함께
`profileOnce`의 `signupSource: "sample-app"`, `firstVisit: true` 예제가 포함되어 있다.
입력한 `profileOnce` 사전을 그대로 공개 `updateUser` API에 전달한다.

## 수동 확인 순서

1. 준비된 Android/iOS 기기나 Chrome에서 예제를 실행한다.
2. 상단 `bootWithStatus`를 누르고 테스트용 plugin key를 입력한 뒤 `OK`를 누른다.
   toast의 `Result: success`를 확인한다. `boot`는 성공 여부를 반환하며,
   Chrome에서는 `bootForWeb`으로 웹 전용 옵션도 실행할 수 있다.
3. `register listener`를 눌러 이벤트를 등록한다.
4. 테스트 채널에서 현재 테스트 사용자를 대상으로 팝업을 발생시킨다.
   화면의 `최근 팝업 timestamp:`가 바뀌는지 확인한다.
   SDK가 timestamp를 제공하지 않으면 `SDK에서 제공하지 않음`으로 표시한다.
5. `updateUser`에서 커스텀 속성과 `profileOnce`를 입력해 결과를 확인하고,
   끝나면 `unregister listener`로 리스너를 해제한다.

팝업 메시지 본문은 출력하지 않는다. 다른 이벤트의 기존 콘솔 출력은 유지되므로
콘솔 확인에도 테스트 데이터를 사용한다. 팝업 발생과 서버 반영은 실제 채널 설정에 의존한다.

## iOS SPM과 CocoaPods

원격에서 추가된 SPM과 CocoaPods는 같은 플러그인 소스를 사용한다.
[루트 iOS 안내](../README.md#ios)에 따라 호스트를 구성한 뒤 `example/`에서 실행한다.

```sh
rtk proxy flutter pub get
rtk proxy flutter build ios --debug --simulator
```

SPM을 지원하는 Flutter에서는 예제 pubspec의 기존 flutter 섹션에 아래 설정을 합친다.
CocoaPods 경로를 검증할 때는 같은 설정을 false로 바꾸고 의존성을 갱신한다.

```yaml
flutter:
  config:
    enable-swift-package-manager: true
```

두 경로 모두 Podfile에 ChannelIOSDK를 직접 추가할 필요가 없다.
SPM과 명시적 SDK pod를 동시에 설치하면 프레임워크 중복 문제가 생길 수 있다.
Xcode 프로젝트는 `FlutterGeneratedPluginSwiftPackage`를 통해 연결한다.
Flutter가 진단용으로 생성한 channel_talk_flutter·FlutterFramework 직접 경로 override는
체크아웃 폴더명에 따라 package identity 충돌을 만들 수 있으므로 커밋하지 않는다.
