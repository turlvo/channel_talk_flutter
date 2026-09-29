## 4.3.0-rc.1

- 4.3.0 정식 배포 전 실제 앱 호환성을 확인하기 위한 RC입니다.
  Flutter 3.19 / Dart 3.3 이상이 필요하며, 커스텀 플랫폼의 `setPage` 재정의와
  Web 콜백 대기·실패 처리는 README의 Upgrade Notes를 확인하세요.

- Add `bootWithStatus()` returning detailed `ChannelTalkBootStatus` results
- `boot`, `bootWithStatus`, `bootForWeb`에 `customAttributes`를 추가했습니다.
  기본 프로필 뒤에 병합하며 중복 키는 커스텀 값이 우선하고 명시적인 null을 보존합니다.
- 모바일 `boot`와 `bootWithStatus`에 `ChannelButtonOption`과 `BubbleOption`을 추가했습니다.
  버튼은 18개 아이콘, 좌우 위치와 여백을 지원하고 팝업은 상하 위치와 선택적 여백을 지원합니다.
  옵션을 생략하면 기존 배치를 유지합니다. 버튼 옵션을 명시하면 기본값은 channel/right/20/20이고,
  팝업 yMargin을 생략하면 기기별 SDK 기본값을 유지합니다. Web은 비동기 UnsupportedError입니다.
- `updateUser`에 기존 값이 없는 프로필 필드만 채우는 `profileOnce`를 추가했습니다.
- Android `onPopupDataReceived`에 SDK 원본 `timestamp`를 추가했습니다. 단위는 정규화하지 않습니다.
- iOS SDK가 백그라운드에서 호출하는 `onChatCreated` 등 이벤트를 메인 스레드로 전달합니다.
  이벤트명·payload·URL 차단 반환값과 이미 메인 스레드에서 전달되던 이벤트의 즉시 호출은 유지합니다.
- 샘플 앱에 상세 부팅·새 옵션 JSON 입력·profileOnce 전달·팝업 timestamp 표시를 추가했습니다.
- Add iOS Swift Package Manager support using the same source tree as CocoaPods
- Preserve example SPM package resolution across checkout directory names
- Remove explicit `ChannelIOSDK` pods before enabling SPM to avoid duplicate frameworks
- Upgrade Android SDK to 13.5.0 and iOS SDK to 13.3.0
- Resolve Android SDK artifacts from Channel.io's official Maven repository
- Require Flutter 3.19 / Dart 3.3 for the Web JS interop implementation
- Fix iOS `setPage` to pass a non-null profile dictionary required by the SDK
- Preserve omitted user language, tags, and marketing preferences in native updates
- Fix Android Activity reattachment and propagate push token registration failures
- Wait for Web SDK callbacks in boot and user/tag updates; reject null Web pages
- Handle the Web SDK's argument-free `onChatCreated` callback
- Add `profile` support to `setPage` on Android, iOS, and Web
- Implement Web `setListener`, `removeListener`, and `hidePopup`
- Web URL 콜백이 기본 이동을 차단한다고 잘못 표현하던 동작을 수정했습니다.
  `onUrlClicked`는 관찰용 void 이벤트이며 `setPreventDefaultUrlClick(true)`는 비동기
  UnsupportedError입니다. false는 SDK 호출 없이 성공하며 기본 동작을 유지합니다.
- Expand regression coverage for configuration, events, callbacks, and boot status
- Compatibility: existing public `ChannelTalk.setPage(page: ...)` calls continue to work.
  Custom platform implementations must adopt the named `setPage` parameters.

## 4.2.1
- Upgrade iOS ChannelIOSDK version to 13.1.0
- Upgrade Android ChannelIOSDK version to 13.3.0
- Fix Android native result handling to avoid double replies
- Remove outdated Android `jcenter()` repository usage
- Restore Flutter test coverage for method channel and public API wrappers
- Compatibility: Android module now builds with `compileSdkVersion 35`
- Compatibility: this plugin still depends on
  `com.google.firebase:firebase-messaging:20.1.0`; apps that pin Firebase
  BOM or messaging versions should verify dependency resolution

## 4.2.0
- Upgrade iOS's ChannelIOSdk version to 13.0.2
- Upgrade Android's ChannelIOSdk version to 13.1.0
- Update Android `minSdkVersion` requirement to 21
- Compatibility: apps using Android `minSdkVersion` below 21 must raise their
  deployment target before upgrading

## 4.1.0
- Added 'setPreventDefaultUrlClick' API
 
## 4.0.0
- BREAKING: require iOS 15 and above
- Upgrade iOS's ChannelIOSdk version to 12.6.0
- Upgrade Android's ChannelIOSdk version to 12.6.0
- Compatibility: apps targeting iOS 14 or lower cannot upgrade without raising
  the iOS deployment target

## 3.3.0
- Fixed 'App not launching when tapping on Push Notification' in Android
- Upgrade iOS's ChannelIOSdk version to 12.2.1
- Upgrade Android's ChannelIOSdk version to 12.3.1
  
## 3.2.1
- Update compileSdkVersion to Resolve Android Build Error after Flutter 3.24 Upgrade

## 3.2.0
- Upgrade iOS's ChannelIOSdk version to 12.1.0
- Upgrade Android's ChannelIOSdk version to 12.2.0
- Added `hidePopup` API
- BREAKING: Removed `openSupportBot` and added `openWorkflow`

## 3.1.3
- BREAKING: Updated README for Android push notification guide
- Upgrade Android's ChannelIOSdk version from 11.6.1 to 11.6.2

## 3.1.2
- fixed `openSupportBot` wrong parameter processing for Android

## 3.1.1
- added `customAttributes` on `updateUser` API

## 3.1.0
- Removed not using package(js)
- Update iOS ChannelIOSDK to 11.7.3
- Update Android ChannelIOSDK to 11.6.1

## 3.0.0
- Changed to Federated plugins
- Support Web(bootForWeb)
- Changed `updateUser` API's parameters
- Added `openSupportBot`, `setAppearance` API

## 2.6.2
- Fixed iOS ChannelIOSdk version to 11.6.0
- Added iOS Privacy Manifest
- Added Android namespace

## 2.6.0
- Added ChannelPluginListener

## 2.5.2
- Update Android ChannelIOSDK to 11.6.0
- Upgrade gradle version for release build error

## 2.5.1
- Changed android `minSdkVersion` to 21

## 2.5.0
- Update Android ChannelIOSDK to 11.5.0
- Update README for latest ChannelIOSDK usage
- Update example source

## 2.4.0
- Update Android ChannelIOSDK to 10.0.5
- Removed memberHash from required fields.

## 2.3.1+1
- Fix android build gradle error

## 2.3.1
- Update Android ChannelIOSDK to 10.0.3
- Sync minor version with V1

## 2.2.0
- Update Android ChannelIOSDK to 10.0.1
- Changed toast package

## 2.1.1
- fix updateUser SDK error
- fix to broadcast received push message not for Channel Talk

## 2.1.0
- fix error for ChannelIO 9.1.2 version

## 2.0.1
- fix channel talk ios sdk import error

## 2.0.0
- Null safety support

## 1.1.0
- Update ChannelIOSDK
- Added methods
"setPage"
"resetPage"

## 1.0.0

This is a initial release of channel talk plugin(Unofficial).

- Added SDK
"boot"
"sleep"
"shutdown"
"showChannelButton"
"hideChannelButton"
"showMessenger"
"hideMessenger"
"openChat"
"track"
"updateUser"
"initPushToken"
"isChannelPushNotification"
"receivePushNotification"
"storePushNotification"
"hasStoredPushNotification"
"openStoredPushNotification"
"isBooted"
"setDebugMode"
