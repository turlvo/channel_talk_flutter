# Android·iOS·Web 공개 API 검증 결과

> 후속 수정: 이 문서는 최초 전수 검사 당시의 기록이다. 같은 날 iOS 이벤트 스레드 결함을
> 수정했으며 [수정 후 검증](ios_event_thread_fix_2026_09_29.md)을 별도로 기록했다.
> 아래 결함 재현 횟수와 표는 수정 전 결과를 보존한다.

실행일: 2026-09-29. 현재 패키지의 공개 메서드 30개와 이벤트 8개를 기준으로 점검했다.
자동 회귀 검증과 실제 SDK 실행을 함께 수행했지만 **모든 실제 기능이 통과한 상태는 아니다.**
iOS 이벤트 전달 결함을 재현했으며, 서버 쓰기·실제 푸시·유효 워크플로 등은 검증 조건이 남았다.
이번 검증에서는 플러그인 런타임, SDK 버전, 기존 반환형과 응답 완료 시점을 변경하지 않았다.

## 환경과 자동 회귀 결과

| 범위 | 환경 | 결과 |
| --- | --- | --- |
| Dart·MethodChannel | Flutter 3.19.6 / Dart 3.3.4 | 123개 통과 |
| Chrome mock SDK | Chrome 154.0.8037.58 / Flutter 3.19.6 | 80개 통과 |
| Android JVM | Gradle 8.10.2 / Java 17.0.18 | 32개 통과, 실패·오류·skip 0 |
| 샘플 widget·부팅 입력 | Flutter 3.19.6 / Dart 3.3.4 | 31개 통과 |
| 실제 Android | Android 15/API 35 arm64 에뮬레이터 / SDK 13.5.0 | 개별 검사 44개 통과, 쓰기 6개 보류 |
| 실제 iOS SDK | iOS 26.2 시뮬레이터 / SDK 13.3.0 | 44개 기대 일치, 즉시 종료 상태 1개 불일치, 쓰기 6개 보류 |
| 실제 Web | 샘플 Web 호스트 / 실제 CDN SDK / Chrome 154 | 공개 진입점 27종을 45회 호출, 아래 범위 확인 |

자동 회귀는 **합계 266개**다. 이 가운데 98개를 이번 작업에서 추가했다.
실제 SDK 검사의 횟수는 API 개수와 다르며 자동 회귀 합계에 더하지 않는다.
Chrome 회귀의 가짜 SDK와 실제 CDN SDK를 사용한 Web 실행을 구분했다.
전체 정적 분석은 문제 없이 통과했다.

모바일은 현재 작업 트리를 임시 폴더에 복사해 샘플의 정상 `main()`을 시작했다.
iOS는 iPhone 17 Pro Max 시뮬레이터에서 Flutter 3.44.1 / Dart 3.12.1의 CocoaPods로 실행했다.
Web도 기존 `main()`과 `web/index.html`을 유지하고 공개 Dart API를 호출했다.
사용자 제공 키는 소스·보고서에 저장하지 않았고, 이벤트 payload도 결과에서 제외했다.

## 발견한 문제와 응답의 한계

### iOS 상담 생성 이벤트가 비메인 스레드에서 전달됨

`openChat` 뒤 `onChatCreated`에서 Flutter가 다음 오류를 출력했다.

```text
channel_talk_flutter ... sent a message from native to Flutter on a non-platform thread
```

원본 실행, 전수 재실행, 임시 복사본의 좁은 진단에서 **3/3회 재현**했다.
진단은 이벤트명과 스레드 여부만 기록했으며 `onChatCreated main=false`를 확인했다.
같은 실행의 메신저 표시/숨김 이벤트는 main=true였다.
[Swift Handler][ios-handler]의
`onChatCreated`가 `channel.invokeMethod`를 바로 호출하는 부분이 수정 대상이다.
이 실행에서는 Dart에 이벤트가 도착했지만, 정상적인 플랫폼 채널 전달로 판정하지 않는다.
Android의 해당 실행 로그에서는 같은 스레드 오류나 치명적 예외를 관찰하지 못했다.

[ios-handler]:
  ../ios/channel_talk_flutter/Sources/channel_talk_flutter/ChannelTalkFlutterHandler.swift

### iOS shutdown 응답과 종료 상태 반영에 시간 차이가 있음

두 번의 전수 실행에서 `await shutdown()`은 true였지만 직후 `isBooted()`도 true였다.
후속 확인에서 500ms와 2.5초 뒤에는 false였다. 종료가 계속 실패한 것이 아니라,
현재 Future가 SDK 종료 완료까지 기다리지 않는다는 의미다.
즉시 false를 기대한 검사는 불일치로 남겼으며 기존 응답 처리를 변경하지 않았다.

### 잘못된 Web 키의 콜백 누락과 명령 성공의 의미

같은 날 앞선 [Web 검증](web_sdk_qa_2026_09_29.md)에서 가상 잘못된 키는 HTTP 422 이후
약 147초 동안 SDK 콜백이 없어 Dart Future가 대기했다. 정상 키 재부팅으로 복구됐다.
이번 45회 호출에 이 장시간 부정 검사를 다시 포함하지는 않았다.
QA 도구의 20초 대기 한도는 관찰용이며 패키지에 timeout을 추가한 것이 아니다.

Android의 ID 없는 `openWorkflow`, Web의 잘못된 ID 호출은 true를 반환해도
SDK에 오류 화면이 표시됐다. Web의 잘못된 ID 요청은 HTTP 422였다.
유효 workflow ID가 없으므로 정상 워크플로 실행 결과는 미검증이다.
호출 즉시 true를 반환하는 API는 서버 반영이나 정상 화면 전환까지 보장하지 않는다.

## 공개 메서드 30개 대조표

- **확인:** 표에 기재한 실제 동작과 결과를 확인했다. 모든 선택 인자의 조합을 뜻하지 않는다.
- **호출만:** 반환값을 확인했으나 서버/OS/외부 이벤트 효과까지 확인하지 못했다.
- **부분:** 부정 입력이나 빈 상태 등 일부 경로를 확인했다.
- **보류:** 실제 프로필·태그·이벤트 서버 쓰기는 실행하지 않았다.
- **미지원 확인:** 현재 플랫폼의 미지원 오류가 예상대로 발생했다.

| API | Android | iOS | Web |
| --- | --- | --- | --- |
| `setListener` | 실제 이벤트 수신·재등록 확인 | 수신·재등록 확인, 상담 이벤트 스레드 결함 | 4종 수신·중복 등록 시 중복 없음 |
| `removeListener` | Dart 수신 중단 확인 | Dart 수신 중단 확인 | 수신 중단·재등록 복구 확인 |
| `boot` | true·isBooted 확인 | true·isBooted 확인 | SDK 콜백 후 true 확인 |
| `bootWithStatus` | success 확인 | success 확인 | SDK 콜백 후 success 확인 |
| `bootForWeb` | 공통 boot 위임 확인 | 공통 boot 위임 확인 | SDK 콜백 후 true 확인 |
| `sleep` | true·재부팅 복구 확인 | 호출만 | 미지원 확인 |
| `shutdown` | true·isBooted=false 확인 | 직후 true 상태, 500ms 후 false | true·메신저/버튼 숨김 확인 |
| `showChannelButton` | 실제 표시 확인 | 실제 표시 확인 | 실제 표시 확인 |
| `hideChannelButton` | 실제 숨김 확인 | 실제 숨김 확인 | 실제 숨김 확인 |
| `showMessenger` | UI·이벤트 확인 | UI·이벤트 확인 | UI·이벤트 확인 |
| `hideMessenger` | UI·이벤트 확인 | UI·이벤트 확인 | UI·이벤트 확인 |
| `openChat` | 초안·상담 생성 이벤트 확인 | 초안 확인, 이벤트 스레드 결함 | 초안·상담 생성 이벤트 확인 |
| `track` | 빈 이름 오류 확인, 정상 쓰기 보류 | 보류 | 보류 |
| `updateUser` | boot 전 오류 확인, 정상 쓰기 보류 | boot 전 오류 확인, 정상 쓰기 보류 | 보류 |
| `initPushToken` | 빈 토큰 오류, 유효 FCM 미검증 | 빈 토큰 true, 유효 APNs 미검증 | 미지원 확인 |
| `isChannelPushNotification` | 비채널 payload=false | 빈 payload=false | 미지원 확인 |
| `receivePushNotification` | 비채널 true·빈 payload 오류 | 빈 payload=true | 미지원 확인 |
| `storePushNotification` | 미지원 오류 확인 | 빈 payload=true·저장 없음 | 미지원 확인 |
| `hasStoredPushNotification` | 빈 상태 false | 빈 상태 false | 미지원 확인 |
| `openStoredPushNotification` | 빈 상태 true | 빈 상태 true | 미지원 확인 |
| `isBooted` | 전/후/종료 상태 확인 | 상태 확인, 종료 반영 지연 별도 | 미지원 확인 |
| `setDebugMode` | true/false 호출 확인 | false 호출만 | 미지원 확인 |
| `setPage` | page+profile·page 생략 호출만 | page+profile·page 생략 호출만 | page 호출·생략 시 ArgumentError |
| `resetPage` | 호출만 | 호출만 | 호출만 |
| `addTags` | 11개·빈 목록 거절, 정상 쓰기 보류 | 보류 | 11개 로컬 거절, 정상 쓰기 보류 |
| `removeTags` | 빈 목록 오류, 정상 쓰기 보류 | 보류 | 보류 |
| `openWorkflow` | ID 생략 시 true+오류 UI | null/잘못된 ID 호출만 | 잘못된 ID true+오류 UI |
| `setAppearance` | 3종 호출·다크 UI 확인 | 3종 호출·네이티브 다크 캡처 확인 | 3종 호출·다크/라이트 UI 확인 |
| `hidePopup` | 팝업 없는 상태 호출만 | 팝업 없는 상태 호출만 | 팝업 없는 상태 호출만 |
| `setPreventDefaultUrlClick` | 설정만, 클릭 미검증 | 설정만, 클릭 미검증 | false=true, true=UnsupportedError |

Web의 미지원 9개는 `UnimplementedError`를 확인했다. 이를 구현된 기능의 성공으로 세지 않는다.
모바일 `bootForWeb` 확인은 공통 boot 위임만 뜻하며 Web 전용 옵션 지원을 보장하지 않는다.
모바일 리스너 확인은 Dart 콜백 중단이다. SDK delegate 자체의 완전 해제 확인과 다르다.
`setPage`/`resetPage`는 실제 상담 서버 메타데이터를 조회해 대조하지 않았다.
Web `addTags` 11개는 공개 Dart API의 상한 검사에서 false가 되며 SDK 호출이 없었다.

## 이벤트 8개

| 이벤트 | Android | iOS | Web |
| --- | --- | --- | --- |
| `onShowMessenger` | 4회 | 4회 | 4회 |
| `onHideMessenger` | 6회 | 7회 | 4회 |
| `onChatCreated` | 1회 | 1회, 스레드 오류 | 1회 |
| `onBadgeChanged` | 3회 | 미검증 | 1회 |
| `onFollowUpChanged` | 미검증 | 미검증 | 미검증 |
| `onUrlClicked` | 미검증 | 미검증 | 미검증 |
| `onPopupDataReceived` | 미검증 | 미검증 | 미검증 |
| `onPushNotificationClicked` | 실제 FCM 조건 없어 미검증 | 적용 제외 | 적용 제외 |

횟수는 대표 전수 실행에서 수신한 값이다. 후속 iOS 진단 횟수를 합산하지 않았다.
배지 이벤트 수신은 실제 새 메시지의 unread/alert 값 변화까지 검증한 것이 아니다.
사용자 메시지 전송 버튼은 누르지 않았지만, `openChat`으로 테스트 상담 기록은 생성됐다.
패키지에 상담 삭제 API가 없으므로 해당 기록을 삭제했다고 주장하지 않는다.

## 남은 검증 조건

1. 새 테스트 사용자의 프로필·profileOnce·태그 추가/삭제/초기화와 QA track 기록 승인.
   자동 승인 검토가 구체적인 서버 데이터 변경 승인 부족을 이유로 해당 실행을 거부했다.
   별도 승인 질문을 전달했으며, 응답 전에는 정상 쓰기 경로를 수행하지 않았다.
2. 정상 실행할 workflow ID와 채널의 워크플로 설정.
3. FCM/APNs를 구성한 호스트와 유효 토큰, 실제 푸시 발송·수신·클릭 조건.
4. 테스트 팝업과 URL이 포함된 상담 등 외부 이벤트 조건.

자동 계약 테스트는 위 미실행 기능의 인자·응답·오류 전달을 확인한다.
그 결과로 서버 저장, 푸시 전달, 네이티브 이벤트의 정상 스레드 실행을 대신 입증하지 않는다.
전체 프로필 초기화, Web 빈 태그 초기화 등 앞서 논의한 신규 API 확장은 이번 검증에서 추가하지 않았다.

## 재현 파일과 증거

- [통합 테스트 실행 안내](../example/integration_test/README.md)
- [자동 회귀 명령](TESTING.md)
- [전체 모바일 계약 테스트](../test/channel_talk_all_api_contract_test.dart)
- [전체 Web 계약 테스트](../test/channel_talk_web_all_api_contract_test.dart)

다음은 로컬 실행 산출물로 Git 추적 대상이 아니다.

- [Android 상세 보고서](../build/qa/2026-09-29/android/android_report.md)와
  [결과 JSON](../build/qa/2026-09-29/android/results.json)
- [iOS 상세 보고서](../build/qa/2026-09-29/ios_report.md)와
  [결과 JSON](../build/qa/2026-09-29/ios/api_results.json)
- [Web 결과 JSON](../build/qa/2026-09-29/web_api_results.json)
- [자동 회귀 상세](../build/qa/2026-09-29/regression_report.md)
- 실제 UI: [Android 다크](../build/qa/2026-09-29/android/messenger_dark.png),
  [iOS 다크](../build/qa/2026-09-29/ios/ios_native_dark.png),
  [Web 다크](../example/build/qa/2026-09-29/web_full_dark.png),
  [Web 라이트](../example/build/qa/2026-09-29/web_full_light.png)

실행 후 SDK 종료·리스너 해제, Web 브라우저와 서버 종료, 전용 Android AVD 종료를 완료했다.
다른 작업의 시뮬레이터나 앱 데이터는 초기화하지 않았다.
