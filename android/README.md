# Android 네이티브 브리지

Java 구현과 SDK 의존성, 네이티브 회귀 테스트를 담는 Android 라이브러리 모듈이다.
소스 패키지는 `com.kuku.channel_talk_flutter`다.

## 파일 역할

- [ChannelTalkFlutterPlugin.java][plugin]: 엔진 초기화, 요청 라우팅, 인자 변환,
  결과 응답과 Activity 수명주기.
- [ChannelTalkFlutterHandler.java][handler]: SDK 이벤트를 Dart 채널로 전달하고 URL 차단값 반환.
- [PushInterceptService.java][push]: FCM 토큰·메시지를 SDK 또는 로컬 브로드캐스트로 전달.
- [build.gradle](build.gradle): Channel.io·Firebase SDK, Android 컴파일 설정, JUnit·Mockito.
- [네이티브 테스트][tests]: SDK 호출을 mock하고 실제 SDK 요청 객체의 직렬화 등을 검증.

## 유지할 동작

- 엔진 연결 때 `ChannelIO.initialize`를 수행하고 실패는 후속 요청에 오류로 전달한다.
- Activity detach 때 참조를 비우고 reattach 때 새 Activity를 연결한다.
- updateUser에서 생략된 언어·태그·수신 설정을 Builder에 넣지 않는다.
- 결과 콜백의 오류와 성공을 중복 반환하지 않는다.
- 푸시 서비스는 [manifest](src/main/AndroidManifest.xml)에 자동 등록되어 있지 않다.
  실제 호스트 FCM 처리 경로와 함께 등록·검증해야 한다.

현재 Channel.io SDK는 13.5.0, Firebase Messaging은 20.1.0,
minSdk는 21, compileSdk는 35다. 버전 판단은 build.gradle을 기준으로 한다.
SDK Maven 저장소는 `io.channel` 그룹에 한정한다.

Flutter 엔진 의존성과 플러그인 등록이 필요한 검증은 [예제 호스트](../example/android/)를 사용한다.
실행 명령은 [테스트·빌드 가이드](../docs/TESTING.md), 계약은 [구조 문서](../docs/ARCHITECTURE.md)에 있다.

[plugin]: src/main/java/com/kuku/channel_talk_flutter/ChannelTalkFlutterPlugin.java
[handler]: src/main/java/com/kuku/channel_talk_flutter/ChannelTalkFlutterHandler.java
[push]: src/main/java/com/kuku/channel_talk_flutter/PushInterceptService.java
[tests]: src/test/java/com/kuku/channel_talk_flutter/ChannelTalkFlutterPluginTest.java
