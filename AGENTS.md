# AGENTS.md — channel_talk_flutter 작업 지침

## 대화와 작업 원칙

- 사용자 응답과 새 내부 문서는 한국어로 작성한다.
- 가독성, 기존 패턴과의 일관성, 의도를 드러내는 이름을 우선한다.
- 작업 전 `rtk git status --short`로 사용자 변경을 확인하고 보존한다.
- 요청 범위 밖 리팩터링, SDK 업그레이드, 커밋, 배포를 함께 수행하지 않는다.
- 사용자가 명시적으로 요청하지 않으면 `using-git-worktrees` 스킬을 사용하지 않는다.
- 셸 명령은 `rtk`로 시작한다. 전용 지원이 없는 명령은 `rtk proxy`를 사용한다.
- 비밀키와 토큰은 `.env` 또는 Secret Manager에서 관리한다.
  사용자 프로필, 푸시 토큰, 메시지 본문을 로그나 테스트 픽스처에 넣지 않는다.
  테스트에는 가상 값을 사용한다.

## 먼저 읽을 문서

- [구조와 플랫폼 계약](docs/ARCHITECTURE.md)
- [테스트·빌드 가이드](docs/TESTING.md)
- [SDK 호환성 점검 기록](docs/sdk_compatibility_audit.md)
- [사용자 설치·API 안내](README.md), [릴리스 이력](CHANGELOG.md)

구조 문서는 현재 코드의 설명이고 호환성 점검 문서는 특정 시점의 검증 기록이다.
버전과 동작은 해당 소스·설정 파일을 기준으로 판단한다.

## 프로젝트 성격과 수정 위치

이 저장소는 Channel.io SDK를 연결하는 비공식 Flutter 플러그인이다.
하나의 패키지 안에 공개 API, 플랫폼 인터페이스, 모바일·웹 구현이 들어 있다.
독립된 앱이나 플랫폼별로 분리 배포하는 여러 패키지 구조가 아니다.

| 변경 대상 | 시작할 파일 또는 폴더 |
| --- | --- |
| 공개 API, 설정 Map, enum | `lib/channel_talk_flutter.dart` |
| 플랫폼 계약, 이벤트, 기본 구현 선택 | `lib/channel_talk_flutter_platform_interface.dart` |
| 네이티브 메서드명·인자·이벤트 매핑 | `lib/channel_talk_flutter_method_channel.dart` |
| 웹 데이터 변환·콜백·리스너 | `lib/channel_talk_flutter_web.dart` |
| JavaScript 함수 시그니처 | `lib/web/channel_io_service.dart` |
| Android 메서드·이벤트·FCM 서비스 | `android/src/main/java/com/kuku/channel_talk_flutter/` |
| iOS 메서드·이벤트·privacy manifest | `ios/channel_talk_flutter/Sources/channel_talk_flutter/` |
| iOS 의존성 | `ios/channel_talk_flutter.podspec`, `ios/channel_talk_flutter/Package.swift` |
| 수동 실행용 앱과 플랫폼 호스트 | `example/` |
| Dart·브라우저 회귀 테스트 | `test/` |
| Android 네이티브 회귀 테스트 | `android/src/test/` |

`macos/`는 현재 `getPlatformVersion`만 처리하는 템플릿이다.
pubspec에 등록되어 있다는 이유로 Channel Talk 기능 지원을 가정하지 않는다.
Windows와 Linux 구현은 없다.

## 코드 탐색

- 심볼, 호출 관계, 변경 영향, 파일 구조는 CodeGraph를 우선한다.
- 구조 파악은 `codegraph_context` 후 필요하면 `codegraph_explore` 한 번으로 좁힌다.
- 심볼 검색은 `codegraph_search`, 호출자는 `codegraph_callers`, 영향은 `codegraph_impact`다.
- 파일 목록은 `codegraph_files`, 인덱스 상태는 `codegraph_status`로 확인한다.
- 문자열·주석·설정값 검색은 `rtk proxy rg`를 사용한다.
  이미 특정한 파일의 전문이나 인덱스에 없는 자료는 직접 읽어도 된다.
- CodeGraph 결과를 동일한 grep 탐색으로 반복 검증하지 않는다.
  수정 직후에는 파일 감시기의 반영 시간을 고려한다.
- 인덱스가 초기화되지 않았다는 응답이면 사용자에게
  `rtk proxy codegraph init -i` 실행 여부를 확인한다.

## 반드시 유지할 계약

1. 공개 API → 플랫폼 인터페이스 → 모바일 채널 또는 웹 구현 흐름을 유지한다.
   새 API는 관련 계층, 네이티브 라우터, 테스트, 사용자 문서를 함께 검토한다.
2. MethodChannel 이름은 `channel_talk_flutter`다. 메서드명·Map 키·이벤트명은
   Dart, Java, Swift 사이의 계약이므로 한쪽에서만 변경하지 않는다.
3. 선택 인자 생략과 명시적 `false`·빈 태그 목록을 구분한다.
   `updateUser(name: ...)`가 기존 언어·태그·수신 설정을 덮어쓰지 않게 한다.
4. 네이티브 결과는 호출마다 정확히 한 번 완료한다.
   `result.error` 후 성공을 다시 반환하거나 콜백 분기에 결과를 누락하지 않는다.
5. Android의 Activity detach·reattach 처리를 보존한다.
   UI API의 `ensureActivity`, 사용자 갱신 등의 `ensureBooted` 검사를 제거하지 않는다.
6. 웹 `boot`, `updateUser`, `addTags`, `removeTags`는 SDK 콜백을 기다린다.
   SDK 오류 콜백의 `false`와 호출 자체의 예외를 임의로 성공 처리하지 않는다.
7. 웹 리스너 세대 번호는 교체·삭제된 콜백을 차단한다.
   `clearCallbacks`는 SDK 전역 콜백에 영향을 준다.
8. URL 기본 동작 차단은 별도 설정이다. Dart 리스너 반환값으로 대체하지 않는다.
9. `setPage`는 모바일에서 page 생략을 허용하고 웹에서는 `ArgumentError`로 거부한다.
   iOS에서 profile 생략은 빈 사전으로 변환한다.
10. iOS SDK 초기화는 호스트 AppDelegate가 맡는다. 웹 SDK 스크립트도 호스트가 로드한다.
    Android 푸시 서비스는 플러그인 manifest가 자동 등록하지 않는다.
11. `bootWithStatus`는 네이티브 상태 문자열을 `ChannelTalkBootStatus`로 변환한다.
    네이티브 성공 상태라도 user가 없으면 `unknown`이다. 웹은 SDK 콜백 성공을 `success`,
    오류를 `unknown`으로 변환하며 호출 예외를 그대로 전달한다.
12. iOS CocoaPods와 SPM은 같은 Swift 소스와 `PrivacyInfo.xcprivacy`를 공유한다.
    SDK 버전은 podspec과 Package.swift에 함께 맞춘다. 현재 두 경로 모두 13.3.0이다.

지원하지 않는 웹 메서드는 인터페이스 기본 구현의 `UnimplementedError`를 발생시킨다.
모든 플랫폼의 실패 방식이 같거나 모든 `true`가 서버 처리 완료를 뜻한다고 가정하지 않는다.
구체적인 차이는 구조 문서의 지원·결과 표를 확인한다.

## 구현 스타일

- 클래스·타입은 PascalCase, 변수·함수는 camelCase, 새 상수는 UPPER_SNAKE_CASE다.
- Dart 파일은 snake_case다. 기존 Java·Swift 클래스 파일명과 플랫폼 생성 파일은 유지한다.
- 100자 이내 줄 길이, 명확한 nullable·비동기 반환형을 사용한다.
- 파라미터가 3개 이상이면 줄바꿈과 언어가 지원하는 trailing comma를 사용한다.
- Dart import는 dart → Flutter → 외부 패키지 → 프로젝트 내부 순서로 그룹을 나눈다.
- 새 함수에는 dartdoc·Javadoc·Swift 문서 주석을 작성한다.
  주석은 구현을 반복하기보다 이유와 계약을 설명한다.
- 현재 런타임 코드에는 Riverpod, Freezed, 코드 생성이 없다.
  기존 플러그인 변경과 무관하게 앱용 상태 관리나 `features/` 계층을 도입하지 않는다.
- 예제는 큰 StatefulWidget 한 파일에 모여 있다. 새 UI를 분리할 때는 Widget 파일을
  200줄 이하로 유지하고 build 안에서 비동기 작업을 시작하지 않는다.
- 예외 처리와 필요한 로그를 누락하지 않되 개인정보는 로그에 남기지 않는다.

## 검증과 문서 갱신

- 실행 명령과 환경 준비는 [테스트 가이드](docs/TESTING.md)를 따른다.
  Dart VM, Chrome 브라우저, Android JVM, 실제 SDK 검증을 구분한다.
- 웹 테스트는 `@TestOn('browser')`이므로 VM 테스트 통과만으로 검증되지 않는다.
- iOS SDK 변경은 예제 시뮬레이터 빌드로 확인한다.
  기존 iOS RunnerTests는 현 API와 맞지 않는 템플릿이다.
- 변경에 맞는 회귀 테스트와 정적 분석을 수행한다.
  문서만 바꾼 경우 링크·경로·소스와의 일치를 확인하고 실행하지 않은 테스트는 구분한다.
- 아키텍처·지원 범위 변경은 `docs/ARCHITECTURE.md`, 실행 방법은 `docs/TESTING.md`,
  공개 사용법은 루트 README, 배포 변경은 CHANGELOG에 반영한다.
- 주요 폴더 README는 해당 폴더의 역할과 상세 문서 진입점을 유지한다.
- SDK 업그레이드 시 pubspec 최소 버전, Android Gradle, iOS podspec·Package.swift, 예제 호스트,
  README·CHANGELOG·호환성 기록을 함께 점검한다.
- 생성된 `.dart_tool/`, `build/`, `Pods/`, `.symlinks/`, 등록 코드와 로컬 SDK 경로는
  수동 수정 대상으로 삼지 않는다. `.metadata`는 Flutter 도구 관리 파일이다.
- 커밋을 요청받으면 `feat:`, `fix:`, `refactor:`, `chore:`, `docs:`, `style:`를 사용한다.
  PR은 300줄 이내로 작성하며, UI 변경에는 스크린샷과 관련 검증 결과를 첨부한다.
