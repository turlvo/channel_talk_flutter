# Channel.io JavaScript 선언

[channel_io_service.dart](channel_io_service.dart)의 external 함수는 모두 전역 `ChannelIO`를 호출한다.
첫 인자는 `boot`, `setPage` 같은 명령 문자열이고 뒤에 옵션·값·콜백을 전달한다.
이 파일은 SDK 로더나 Dart 상태 관리 계층이 아니다.

호스트의 [index.html 예시](../../example/web/index.html)가 SDK 스크립트를 준비하고,
[웹 어댑터](../channel_talk_flutter_web.dart)가 Map 변환과 리스너·완료 콜백을 관리한다.
주석 처리된 extension type 모델은 현재 실행 코드에서 사용하지 않는다.

JS 시그니처를 바꾸면 어댑터 호출과 [브라우저 테스트](../../docs/TESTING.md)를 함께 확인한다.
SDK 완료 콜백과 일반 이벤트 콜백은 서로 다른 경로다.
