# Dart API와 플랫폼 연결

이 폴더는 공개 API와 Android·iOS·웹 연결 구현을 함께 포함한다.
상세 계약은 [구조 문서](../docs/ARCHITECTURE.md), 작업 규칙은 [AGENTS.md](../AGENTS.md)를 따른다.

| 파일 | 역할 |
| --- | --- |
| [공개 API](channel_talk_flutter.dart) | ChannelTalk 정적 API, 언어·테마·boot 상태 enum, 설정 Map |
| [플랫폼 인터페이스](channel_talk_flutter_platform_interface.dart) | instance, 계약, delegate·이벤트 |
| [MethodChannel](channel_talk_flutter_method_channel.dart) | 네이티브 요청과 수신 이벤트 매핑 |
| [웹 구현](channel_talk_flutter_web.dart) | JS 값 변환, 완료 콜백, 리스너 수명주기 |
| [JS 선언](web/channel_io_service.dart) | 전역 ChannelIO의 명령별 함수 시그니처 |

## 변경할 때

- 기본 instance는 MethodChannel 구현이며 웹 플러그인 등록 때 웹 구현으로 교체된다.
- 공개 메서드를 추가하면 인터페이스·해당 플랫폼 구현·테스트를 함께 갱신한다.
- 네이티브 메서드명·인자 키·이벤트명은 Java·Swift와 동일해야 한다.
- 선택 인자의 null 생략과 명시적 false·빈 목록 전달을 구분한다.
- `ChannelTalkEvent`를 이름으로 참조하는 앱은 플랫폼 인터페이스 파일도 import한다.
- 플랫폼별 미지원 API와 오류 방식이 다르므로 단순 bool 성공 모델로 통합하지 않는다.

`boot`와 `bootWithStatus`는 같은 설정 Map을 구성한다. `bootWithStatus`는
`ChannelTalkBootStatus`를 반환하며 MethodChannel의 네이티브 상태 문자열을 enum으로 변환한다.
상태는 `success`, `notInitialized`, `networkTimeout`, `notAvailableVersion`,
`serviceUnderConstruction`, `requirePayment`, `accessDenied`, `unknown`이다.
알 수 없는 문자열이나 null은 `unknown`이며 네이티브 성공 콜백에도 user가 없으면 `unknown`이다.
웹은 SDK 콜백을 기다려 성공이면 `success`, 오류이면 `unknown`을 반환하고 호출 예외는 전달한다.
iOS 연결 코드는 [공유 Swift 소스][ios]에 있으며 CocoaPods와 SPM이 함께 사용한다.

모바일과 웹은 [각 테스트](../test/README.md)로 검증한다.
일반 Dart VM 테스트만 실행하면 웹 JS interop은 검증되지 않는다.

[ios]: ../ios/channel_talk_flutter/Sources/channel_talk_flutter/ChannelTalkFlutterPlugin.swift
