# macOS 템플릿

pubspec에 macOS 플랫폼이 등록되어 있지만 Channel Talk 기능은 구현되어 있지 않다.
[Plugin](Classes/ChannelTalkFlutterPlugin.swift)은 `getPlatformVersion`만 처리한다.
다른 메서드에는 `FlutterMethodNotImplemented`를 반환한다.
공개 Dart API에는 getPlatformVersion 래퍼도 없다.

[podspec](channel_talk_flutter.podspec)은 FlutterMacOS에만 의존하며,
버전 0.0.1과 macOS 10.11을 선언하는 초기 템플릿 상태다.
Channel.io SDK 의존성·이벤트 Handler·푸시 구현은 없다.

예제 macOS RunnerTests 통과는 플랫폼 문자열 테스트만 의미한다.
macOS 기능 지원 작업은 이 템플릿과 [플랫폼 계약](../docs/ARCHITECTURE.md)을 함께 검토해야 한다.
