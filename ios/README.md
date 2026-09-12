# iOS 네이티브 브리지

Swift로 MethodChannel 요청을 `ChannelIOFront` 모듈에 연결한다.

| 파일 | 역할 |
| --- | --- |
| [Plugin][plugin] | 메서드 라우팅·설정 변환·SDK 호출·결과 반환 |
| [Handler][handler] | SDK delegate 이벤트를 Flutter 채널로 전달 |
| [podspec](channel_talk_flutter.podspec) | ChannelIOSDK 버전, 최소 OS, privacy 리소스 번들 |
| [Package.swift](channel_talk_flutter/Package.swift) | SPM 의존성, 최소 OS, 공유 소스·리소스 |
| [PrivacyInfo][privacy] | 플러그인 privacy manifest |

CocoaPods와 SPM은 `channel_talk_flutter/Sources/channel_talk_flutter/`의 동일한 Swift 소스를
사용한다. privacy manifest도 같은 파일을 CocoaPods resource bundle과 SPM process 리소스에
각각 포함한다.

## 호스트 연동과 유지할 계약

- SDK 초기화는 호스트 AppDelegate의 `ChannelIO.initialize(application)` 호출로 수행한다.
  [예제 AppDelegate](../example/ios/Runner/AppDelegate.swift)가 실제 연동 위치다.
- `boot`·`bootWithStatus`는 같은 설정과 SDK 호출을 사용한다. SDK 성공 상태와 user 존재를
  함께 확인한 경우에만 SDK delegate에 플러그인의 이벤트 Handler를 연결한다.
- `bootWithStatus`는 상세 상태 문자열을 반환하고 Dart에서 `ChannelTalkBootStatus`로 변환한다.
  SDK가 성공을 보고해도 user가 없으면 `unknown`이며, 인자 오류는 `FlutterError`로 반환한다.
- updateUser에서 생략된 언어·태그·수신 설정을 기존 값으로 유지한다.
- SDK 콜백은 user와 error가 모두 nil인 경우도 결과를 한 번 반환해야 한다.
- setPage의 profile 생략은 SDK에 빈 사전으로 전달한다.
- boot·태그 작업 실패의 bool 반환과 updateUser의 FlutterError 반환 차이가 있다.

podspec과 Package.swift는 모두 ChannelIOSDK 13.3.0, iOS 15.0을 선언한다.
CocoaPods의 Swift 버전은 5.0, SPM manifest의 Swift tools 버전은 5.9다.
호스트가 SDK pod를 직접 추가하면 플러그인의 버전과 맞춰야 한다.
APNs·권한·Capabilities와 호스트 앱의 개인정보 설정은 이 브리지 밖에서 관리한다.

[예제 Podfile](../example/ios/Podfile)과 시뮬레이터 빌드로 컴파일 호환성을 확인한다.
예제 RunnerTests의 getPlatformVersion 검증은 현 iOS 구현과 맞지 않는 템플릿이다.
상세 내용은 [구조 문서](../docs/ARCHITECTURE.md), [테스트 가이드](../docs/TESTING.md)를 참고한다.

[plugin]: channel_talk_flutter/Sources/channel_talk_flutter/ChannelTalkFlutterPlugin.swift
[handler]: channel_talk_flutter/Sources/channel_talk_flutter/ChannelTalkFlutterHandler.swift
[privacy]: channel_talk_flutter/Sources/channel_talk_flutter/PrivacyInfo.xcprivacy
