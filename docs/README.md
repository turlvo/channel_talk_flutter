# 문서

- [프로젝트 작업 지침](../AGENTS.md): 탐색 방법, 변경 시 유지할 계약, 검증·문서화 규칙.
- [프로젝트 구조와 플랫폼 계약](ARCHITECTURE.md): 파일 지도, 호출·이벤트 흐름,
  데이터 변환, 지원 API, 오류·수명주기 차이, 버전 설정.
- [테스트·빌드 가이드](TESTING.md): 테스트 범위, 실행 위치·명령, 실제 SDK 검증과의 구분.
- [SDK 호환성 점검](sdk_compatibility_audit.md): SDK 배포 버전, 발견한 문제, 수정 및 검증 범위.

## 폴더별 진입점

- [Dart API와 플랫폼 연결](../lib/README.md), [웹 JS 선언](../lib/web/README.md)
- [Android 브리지](../android/README.md), [iOS 브리지](../ios/README.md)
- [macOS 템플릿](../macos/README.md), [수동 실행 예제](../example/README.md)
- [Dart·웹 테스트](../test/README.md)

구조·계약 설명은 현재 소스 기준으로 유지하고, 점검 기록에는 검증 시점과 범위를 남긴다.
과거 점검 결과를 새 변경의 테스트 통과로 간주하지 않는다.
