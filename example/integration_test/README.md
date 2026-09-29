# 실제 SDK 공개 API 검증

샘플의 정상 `main()`에서 공개 `ChannelTalk` API를 실행한다.
가짜 SDK를 사용하는 `test/` 회귀와 구분하며, 유효 키와 각 플랫폼 실행 환경이 필요하다.
원격 서버 응답·네이티브 화면·이벤트를 확인한 범위는
[2026-09-29 결과](../../docs/full_api_qa_2026_09_29.md)에 기록했다.

| 파일 | 대상 | 동작 |
| --- | --- | --- |
| [android_api_qa_test.dart](android_api_qa_test.dart) | Android | 실제 응답·이벤트·화면과 입력 거절 확인 |
| [ios_api_qa_test.dart](ios_api_qa_test.dart) | iOS | 실제 응답·이벤트·화면 및 종료 상태 확인 |
| [ios_event_thread_qa_test.dart](ios_event_thread_qa_test.dart) | iOS | 상담 생성 이벤트 수신·종료를 3회 반복 |
| [web_api_qa.dart](web_api_qa.dart) | Web | 브라우저에서 공개 Dart API를 호출하는 QA 진입점 |

키는 Git 밖의 `.env` 파일에 `CHANNEL_TALK_PLUGIN_KEY`로 제공한다.
출력에는 키·푸시 토큰·이벤트 payload를 넣지 않는다. 테스트 앱을 실행하면 익명 방문자가
생성되며, `openChat`은 전송 버튼을 누르지 않아도 상담 기록을 생성할 수 있다.

## Android와 iOS

`example/`에서 실행한다. Flutter 버전별 생성 파일 변경을 피하려면 임시 복사본을 사용한다.

```sh
rtk proxy flutter pub get
rtk proxy flutter test integration_test/android_api_qa_test.dart \
  -d <QA_ANDROID_DEVICE_ID> --no-pub --reporter expanded \
  --dart-define-from-file=<PRIVATE_ENV_PATH>

rtk proxy flutter drive --driver=test_driver/ios_qa_driver.dart \
  --target=integration_test/ios_api_qa_test.dart \
  -d <QA_IOS_DEVICE_ID> --no-pub --dart-define-from-file=<PRIVATE_ENV_PATH>
```

iOS 드라이버는 [ios_qa_driver.dart](../test_driver/ios_qa_driver.dart)다.
이번 실제 실행은 Android Flutter 3.19.6, iOS Flutter 3.44.1을 사용했다.
기본값에서는 프로필·태그·track 서버 쓰기를 건너뛴다.
명시적으로 승인된 테스트 채널에서만 다음 환경 값을 추가한다.

- Android: `QA_ALLOW_SERVER_MUTATIONS=true`.
- iOS: `CHANNEL_TALK_ALLOW_DATA_WRITES=true`, 새 `CHANNEL_TALK_QA_MEMBER_ID`.

iOS 테스트는 현재 알려진 `shutdown` 직후 상태 불일치를 실패로 기록한다.
`onChatCreated`의 비메인 스레드 오류는 개별 bool 응답 검사 외에 런타임 로그도 확인해야 한다.
성공 bool만으로 서버 데이터 저장과 실제 푸시 수신까지 통과로 판정하지 않는다.

상담 생성 이벤트의 스레드 수정만 확인하려면 위 iOS 명령의 target을
`integration_test/ios_event_thread_qa_test.dart`로 바꾼다.
이 테스트는 매회 이벤트가 한 번 도착하는지 확인하고 SDK 종료 상태 반영을 기다린다.
실제 플랫폼 채널 스레드 오류는 테스트 결과와 함께 Flutter 실행 로그에서 확인한다.

## Web

```sh
rtk proxy flutter run -d web-server --web-hostname 127.0.0.1 \
  --web-port 8765 --no-pub -t integration_test/web_api_qa.dart
```

로컬 브라우저를 열면 기존 샘플 UI와 실제 CDN SDK가 실행된다.
QA 페이지는 `window.channelTalkQa(method, jsonArguments)`를 노출한다.
브라우저에서 다음처럼 실행하면 공개 Dart API의 결과를 JSON 문자열로 받는다.
키는 부팅 시에만 실행 입력으로 전달하고 코드·로그에 저장하지 않는다.

```js
JSON.parse(await window.channelTalkQa('showMessenger', '{}'));
JSON.parse(window.channelTalkQaEvents());
```

테스트용 20초 timeout은 QA 응답에만 적용된다. 원래 SDK 작업을 취소하거나
패키지의 Future 완료 방식·반환형을 바꾸지 않는다.
부팅을 제외한 서버 쓰기는 승인된 테스트 데이터로 별도 수행해야 한다.
끝나면 `removeListener`, `shutdown`을 호출하고 브라우저와 개발 서버를 종료한다.
