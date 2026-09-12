# 수동 API 실행 예제

상위 플러그인을 `path: ../`로 참조하는 Flutter 호스트 앱이다.
배포용 앱이 아니라 API 입력·결과·이벤트와 플랫폼 빌드 호환성을 확인하는 용도다.

## 구성

- [lib/main.dart](lib/main.dart): StatefulWidget 기반 API 버튼 목록.
  JSON 입력 다이얼로그에서 인자를 받아 ChannelTalk을 호출하고 toast로 결과를 표시한다.
  리스너 등록·해제 버튼과 이벤트 콘솔 출력이 있다.
- [android/](android/): Java·Kotlin·Gradle 호스트와 SDK keep 규칙.
- [iOS AppDelegate](ios/Runner/AppDelegate.swift): SDK 초기화.
- [web/index.html](web/index.html): 전역 ChannelIO 명령 큐·CDN 스크립트 로더.
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
앱 dispose는 입력 controller를 정리하지만 ChannelTalk 리스너를 자동 해제하지 않는다.

현재 widget 테스트는 이전 `Running on:` 텍스트를 기대하고,
iOS RunnerTests는 미구현 getPlatformVersion을 기대하므로 현 동작의 통과 기준이 아니다.
플랫폼별 검증 명령과 기존 테스트 범위는 [테스트 가이드](../docs/TESTING.md)를 참고한다.


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
