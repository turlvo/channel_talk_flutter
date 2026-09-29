# iOS 이벤트 스레드 수정과 Web 미지원 API 설명

2026-09-29 전수 검증에서 발견한 `onChatCreated`의 비메인 스레드 전달을 수정했다.
수정 전에는 실제 SDK에서 3/3회 오류가 재현됐고, 수정 후 같은 흐름 3회에서는
이벤트가 매회 정확히 한 번 도착하며 플랫폼 채널 스레드 오류가 발생하지 않았다.

## 수정 내용과 유지한 동작

[Swift Handler][handler]의 모든 이벤트가 공통 `sendEvent`를 거치도록 했다.

- SDK 콜백이 메인 스레드이면 기존처럼 즉시 `invokeMethod`를 호출한다.
- 백그라운드 스레드이면 `DispatchQueue.main.async`로 넘겨 Flutter 채널을 호출한다.
- 상담·메신저·배지·프로필·URL·팝업 이벤트명과 payload는 그대로 전달한다.
- URL 기본 이동 차단 여부는 기존 저장값을 동기 반환한다. Dart 콜백 응답을 기다리지 않는다.
- 공개 API 반환형, bool/오류 처리, `shutdown` 응답 완료 시점은 변경하지 않았다.

같은 전달 경로를 쓰는 이벤트 전체에 적용해 SDK의 이벤트별 스레드 선택에 의존하지 않게 했다.
CocoaPods와 SPM은 수정한 Swift 파일을 공유한다. SDK 의존성 버전은 변경하지 않았다.

## 수정 후 실행 결과

| 검증 | 결과 | 범위 |
| --- | --- | --- |
| 실제 iOS SDK 재현 | 3/3회 통과 | 부팅→openChat 초안→이벤트 1회→종료 상태 확인 |
| iOS 네이티브 XCTest | 5개 통과 | 수정 전 백그라운드 스레드 검사 4개 실패를 확인한 뒤 수정 후 통과 |
| Dart 이벤트·전체 채널 계약 | 68개 통과 | 이벤트 종류·payload·리스너, 공개 응답·오류 보존 |
| 정적 분석 | 문제 없음 | 새 실제 SDK 검증 도구 포함 |

실제 실행은 iPhone 17 Pro Max **시뮬레이터**, iOS 26.2, Flutter 3.44.1,
Dart 3.12.1, ChannelIOSDK 13.3.0의 CocoaPods 경로를 사용했다.
원본 Handler와 임시 빌드에 사용한 파일의 SHA256이 같은지 확인했고,
최종 실제 실행에는 스레드 진단용 로그 코드를 추가하지 않았다.
새 Flutter 실행 로그에 `[ERROR:]` 및 `non-platform thread` 오류가 없었다.

[RunnerTests](../example/ios/RunnerTests/RunnerTests.swift)는 SDK 서버 연결 없이 실제
FlutterMethodChannel codec과 기록용 BinaryMessenger 경계에서 검사한다.
수정 전에는 백그라운드 전달 검사 4개가 메인 스레드 조건에서 실패하고 main 동기 전달 1개는
통과했다. 수정 후에는 동일한 5개가 모두 통과했다. 이벤트명·인자·순서·전달 횟수와
URL 차단 true/false 반환을 확인했다. SDK PopupData에 공개 생성자가 없어 팝업 객체를
임의로 만들어 네이티브 테스트에 넣지는 않았다.

수정 전 테스트는 4개 실패 결과가 기록된 뒤 xcodebuild의 정리가 멈춰 해당 프로세스를 종료했다.
수정 전 판정은 완료된 XCTest 로그를 근거로 하며 미완성 xcresult는 사용하지 않았다.
수정 후 xcodebuild는 정상 종료 코드 0이고 xcresult도 5개 통과를 확인했다.

`shutdown` 직후 상태가 잠시 true인 기존 동작은 유지했다.
재현 테스트는 종료를 요청한 뒤 상태가 false로 바뀔 때까지 최대 10초 대기한다.
이 대기는 테스트에만 있으며 패키지의 Future를 바꾸지 않는다.

실제 SDK 검증은 사용자 메시지를 전송하지 않았으나 상담 기록을 생성했다.
프로필·태그·track·마케팅 수신 설정은 변경하지 않았다.
이 수정으로 실제 푸시나 팝업 등 기존 미검증 항목까지 통과한 것은 아니다.

## Web 미지원 9개의 이유

이 9개는 공식 Web JavaScript SDK에 대응 API가 없는 항목이다.
Flutter 공통 인터페이스에는 존재하지만 Web 구현이 재정의하지 않아 `UnimplementedError`가 발생한다.
실행한 테스트는 이 예상 오류를 확인했으며, 네트워크 실패나 plugin key 권한 오류가 아니다.

| API | 이유 |
| --- | --- |
| `sleep` | 모바일에서 푸시·track만 유지하는 휴면 상태에 대응하는 Web 명령이 없음 |
| `isBooted` | Web SDK가 현재 부팅 상태를 조회하는 공식 명령을 제공하지 않음 |
| `setDebugMode` | Web SDK가 동일한 디버그 로그 설정 명령을 제공하지 않음 |
| `initPushToken` | 모바일 FCM/APNs 토큰 등록용, Web SDK 대응 명령 없음 |
| `isChannelPushNotification` | 모바일 수신 푸시 payload 판별용 |
| `receivePushNotification` | 모바일 호스트가 받은 푸시를 SDK에 전달하는 용도 |
| `storePushNotification` | 모바일 SDK에 수신 푸시를 보관하는 용도 |
| `hasStoredPushNotification` | 모바일 SDK의 저장 푸시 조회용 |
| `openStoredPushNotification` | 저장된 모바일 푸시로 상담을 여는 용도 |

2026-09-29에 [공식 Web API 문서](https://developers.channel.io/en/articles/0b119290)와
[공식 loader 소스](https://github.com/channel-io/channel-web-sdk-loader/blob/main/src/index.ts)를 대조했다.
이는 브라우저 자체의 Web Push 구현 가능성과는 별개다.
모바일의 sleep 의미는 [Android SDK 문서][android-sdk]에서도 확인할 수 있다.

Web 부팅 결과는 `boot`/`bootForWeb`/`bootWithStatus` 완료값으로 확인한다.
마지막 boot 성공을 로컬 변수에 저장하는 것은 SDK의 현재 상태를 조회하는 것과 다르며,
이 변경에서 이를 `isBooted`로 대신 제공하지 않았다.
`shutdown`은 모든 SDK 동작을 종료하므로 `sleep`과 같은 효과로 대체하지 않았다.

## 재현과 증거

- [실제 SDK 3회 검증 코드](../example/integration_test/ios_event_thread_qa_test.dart)
- [실행 안내](../example/integration_test/README.md)
- [수정 전 전수 검증](full_api_qa_2026_09_29.md)
- [네이티브 이벤트 회귀 테스트](../example/ios/RunnerTests/RunnerTests.swift)
- 로컬 [네이티브 회귀 실행 명령·로그](../build/qa/2026-09-29/ios_event_regression/README.md)
- 로컬 [수정 후 실제 SDK 보고서](../build/qa/2026-09-29/ios_event_thread_fix/report.md)와
  [회차별 결과](../build/qa/2026-09-29/ios_event_thread_fix/results.json)

[handler]:
  ../ios/channel_talk_flutter/Sources/channel_talk_flutter/ChannelTalkFlutterHandler.swift
[android-sdk]: https://developers.channel.io/en/articles/ChannelIO-e9706bcd
