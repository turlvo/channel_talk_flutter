


# channel_talk_flutter
Channel Talk Android·iOS·Web SDK를 연결하는 비공식 Flutter 플러그인입니다.<br><br>

## RC 버전 설치

`4.3.0-rc.1`은 SDK 호환성 변경을 실제 앱에서 확인하기 위한 사전 배포 버전입니다.
테스트할 앱의 `pubspec.yaml`에서 버전을 명시하세요.

```yaml
dependencies:
  channel_talk_flutter: 4.3.0-rc.1
```

설정 후 `flutter pub get`을 실행합니다. 필요한 환경 변경은 **Upgrade Notes**,
검증된 기능과 남은 범위는 **현재 SDK 대응 범위**를 확인하세요.

\*******************************************************************************************************
<br> [ANDROID] <br>
Please should change the bottom part when change version from v2.x.x to above of v3.0.0.

In `AndroidManifest.xml` file, <br>
AS-IS
```
    <service
        android:name="ai.deepnatural.channel_talk.PushInterceptService"
        ...
```
TO-BE
```
    <service
        android:name="com.kuku.channel_talk_flutter.PushInterceptService"
        ...
```
\*******************************************************************************************************

## Compatibility

- Flutter 3.19 / Dart 3.3 or later is required by the Web JS interop implementation.
- Bundled SDKs: Android 13.5.0 and iOS 13.3.0 (실제 SDK 연결 확인: 2026-09-29).
- Channel Talk APIs are implemented for Android, iOS, and Web. The registered
  macOS plugin is a placeholder and does not implement those APIs.
- iOS 15.0 or later is required.
- Android `minSdkVersion` 21 or later is required.
- The Android plugin module currently builds with `compileSdkVersion 35`.
- Android 13 (API 33) or later requires `POST_NOTIFICATIONS` permission for
  system push notifications.
- The Android plugin still depends on
  `com.google.firebase:firebase-messaging:20.1.0`. If your app pins Firebase
  BOM or messaging versions directly, verify the resolved dependency graph.

### 현재 SDK 대응 범위

현재 패키지는 위 SDK 버전의 기존 공개 API 호환성 유지에 초점을 맞춥니다.
각 SDK의 모든 기능을 Flutter API로 제공하는 것은 아닙니다. Web은 호스트가 로드한
Channel.io JavaScript SDK를 사용하며, 모바일과 지원 범위가 다릅니다.

iOS의 `onChatCreated` 등 SDK 이벤트는 메인 스레드에서 Flutter로 전달하도록 수정했습니다.
이미 메인 스레드에서 발생한 이벤트는 즉시 전달하며, 이벤트명·데이터와 URL 차단 반환값을
유지합니다. 이 수정에서 기존 `boot`·`updateUser` 등의 반환형·오류 처리나
`receivePushNotification`·`shutdown`의 응답 완료 시점은 변경하지 않았습니다.
이전 버전에서 올릴 때 필요한 변경은 아래 **Upgrade Notes**를 확인하세요.

다음 6개 확장은 현재 추가하지 않습니다. 기존 사용 방식은 유지하며,
해당 기능이 필요한 앱은 아래 제한을 확인해야 합니다.

| 확장 항목 | 현재 제공 범위와 제한 |
| --- | --- |
| 사용자 객체·상세 오류 반환 | bool 응답·`bootWithStatus` 상태 enum 유지. 사용자 객체·상세 오류를 함께 반환하는 API 없음. |
| 전체 프로필·Web 태그 초기화 | 전용 API 없음. 개별 필드 null 전달과 다르며 Web의 `tags: []` 초기화는 보장하지 않음. |
| Android 푸시 클릭 기본 동작 차단 | 클릭 이벤트는 제공하지만 차단 설정은 없습니다. SDK 기본 동작을 허용합니다. |
| Web 추가 언어 코드 | 기존 `Language` enum을 유지하며 Web 전용 추가 언어 코드는 노출하지 않습니다. |
| iOS 기본 테마 위임·푸시 완료 대기 | system/light/dark 유지. SDK 기본 테마 위임·푸시 처리 완료 대기 API 없음. |
| 네이티브 리스너 완전 해제 | 모바일 `removeListener()`는 Dart 콜백만 해제. SDK 네이티브 리스너 제거 기능 없음. |

### 검증 결과와 남은 범위

2026-09-29에 Android 에뮬레이터, iOS 시뮬레이터, Web에서 실제 SDK를 연결해 확인했습니다.
자동 회귀 266개가 통과했고, 후속 iOS 이벤트 수정에서는 네이티브 회귀 5개와 관련 Dart 검사
68개가 통과했습니다. 수정 후 실제 iOS 상담 생성도 3회 모두 이벤트가 한 번씩 도착했고
기존 플랫폼 채널 스레드 오류가 발생하지 않았습니다.

실제 푸시 수신·클릭, 정상 워크플로, 팝업·URL 차단 효과, 프로필·태그·track의 서버 반영은
미검증 범위가 남아 있습니다. API의 true 반환만으로 서버 작업 완료까지 보장하지 않습니다.

- [전체 API 검증 결과](docs/full_api_qa_2026_09_29.md): 플랫폼별 확인·부분 검증·미지원 항목.
- [iOS 이벤트 수정 결과](docs/ios_event_thread_fix_2026_09_29.md): 수정 후 재검증과 Web 미지원 이유.
- [테스트·빌드 가이드](docs/TESTING.md): 재현 명령과 자동 테스트 범위.

## Upgrade Notes

- `3.x -> 4.x`
  - Raise the iOS deployment target to 15.0 or later before upgrading.
- `4.1.x -> 4.2.x`
  - Raise Android `minSdkVersion` to 21 or later before upgrading.
  - If your project uses an older Android Gradle Plugin, verify it is
    compatible with `compileSdkVersion 35`.
- `4.2.x -> 4.3.0`
  - Raise Flutter to 3.19 / Dart to 3.3 or later.
  - `ChannelTalk.setPage(page: ...)` still works and now also accepts
    `profile`. Web requires a non-null page; use `resetPage()` to reset it.
  - Custom `ChannelTalkFlutterPlatform` implementations must change their
    `setPage` override to `setPage({String? page, Map<String, dynamic>? profile})`.
  - Web now supports `setListener`, `removeListener`, and `hidePopup`.
  - Web의 URL 클릭 콜백은 관찰용입니다. `setPreventDefaultUrlClick(true)`는
    비동기 `UnsupportedError`이며, `false`는 기본 동작을 유지하고 성공합니다.
  - Web `boot`, `updateUser`, `addTags`, and `removeTags` now wait for the
    SDK callback and return `false` on SDK failure. JS invocation errors complete
    the Future with an error.
  - Native `updateUser` preserves omitted language, tags, and marketing preferences.
  - `boot`와 `bootWithStatus`에 `customAttributes`, `channelButtonOption`,
    `bubbleOption`을 추가했습니다. 배치 옵션을 생략하면 기존 플랫폼별 배치를 유지합니다.
  - `bootForWeb`도 `customAttributes`를 지원하며, `updateUser`에 `profileOnce`를 추가했습니다.

See [SDK compatibility audit](docs/sdk_compatibility_audit.md) for findings and validation.

## 프로젝트 내부 문서

- [작업 지침](AGENTS.md): 코드 탐색, 변경 규칙, 유지해야 할 플랫폼 계약.
- [구조와 플랫폼 차이](docs/ARCHITECTURE.md): 파일 지도, 요청·이벤트 흐름, 데이터·오류 처리.
- [테스트·빌드 가이드](docs/TESTING.md): 검증 범위와 플랫폼별 실행 방법.
- [전체 문서 목록](docs/README.md): 폴더별 안내와 SDK 호환성 점검 기록.

## ⚡ Usage
```dart
import 'package:channel_talk_flutter/channel_talk_flutter.dart';

void main() async {
    await ChannelTalk.boot(
        pluginKey: 'pluginKey', // Required
        memberId: 'memberId',
        memberHash: 'memberHash',
        email: 'email',
        name: 'name',
        mobileNumber: 'mobileNumber',
        avatarUrl: 'avatarUrl',
        unsubscribeEmail: false,
        unsubscribeTexting: false,
        trackDefaultEvent: false,
        hidePopup: false,
        language: Language.korean,
        appearance: Appearance.dark,
    );

    ChannelTalk.setListener((event, arguments) {
      switch(event){
        case ChannelTalkEvent.onShowMessenger:
          print('ON_SHOW_MESSENGER');
          break;
        case ChannelTalkEvent.onHideMessenger:
          print('ON_HIDE_MESSENGER');
          break;
        case ChannelTalkEvent.onChatCreated:
          print('ON_CHAT_CREATED:\nchatId: $arguments');
          break;
        case ChannelTalkEvent.onBadgeChanged:
          print('ON_BADGE_CHANGED:\n$arguments');
          break;
        case ChannelTalkEvent.onFollowUpChanged:
          print('ON_FOLLOW_UP_CHANGED\ndata: $arguments');
          break;
        case ChannelTalkEvent.onUrlClicked:
          print('ON_URL_CLICKED\nurl: $arguments');
          break;
        case ChannelTalkEvent.onPopupDataReceived:
          print('ON_POPUP_DATA_RECEIVED\nevent: $arguments}');
          break;
        case ChannelTalkEvent.onPushNotificationClicked:
          print('ON_PUSH_NOTIFICATION_CLICKED\nevent: $arguments}');
        default:
          break;
      }
    });

    runApp(App());
}

class App extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return FlatButton(
            child: Text('Open Channel Talk'),
            onPressed: () async {
                await ChannelTalk.showMessenger();
            },
        );
    }
}

```

See Channel Talk Android and iOS package documentation for more information.

### Boot with status

`boot()` returns `true` only on success. To tell *why* a boot failed — e.g. to
retry a transient `networkTimeout` but give up on a permanent `accessDenied` —
use `bootWithStatus()`, which resolves to a `ChannelTalkBootStatus` (`success`,
`notInitialized`, `networkTimeout`, `notAvailableVersion`,
`serviceUnderConstruction`, `requirePayment`, `accessDenied`, `unknown`). It
takes the same arguments as `boot()` and shares the same native boot path. On
web, the SDK callback resolves to `success` when no error is reported, otherwise `unknown`.

```dart
final status = await ChannelTalk.bootWithStatus(pluginKey: 'pluginKey');
if (status != ChannelTalkBootStatus.success) {
  // inspect `status` and decide whether to retry
}
```

### 프로필과 모바일 배치 옵션

`boot`, `bootWithStatus`, `bootForWeb`의 `customAttributes`는 `name`, `email` 등 기본
프로필 뒤에 병합됩니다. 같은 키가 있으면 `customAttributes` 값이 우선하며, 프로필 안의
명시적인 `null`도 SDK로 전달됩니다. `updateUser`의 `profileOnce`는 일반 프로필과 별도로
전달되어 아직 값이 없는 필드만 채웁니다. 인자를 생략하면 해당 값을 변경하지 않습니다.

`channelButtonOption`과 `bubbleOption`은 Android/iOS의 `boot`와 `bootWithStatus`에서만
지원합니다. Web에서 두 옵션을 전달하면 SDK 호출 없이 비동기 `UnsupportedError`가 발생합니다.
`bootForWeb`은 이 두 옵션을 노출하지 않습니다.

| 옵션 | 필드와 기본값 |
| --- | --- |
| `ChannelButtonOption` | `icon`: `channel`, `position`: `right`, `xMargin`: 20, `yMargin`: 20 |
| `BubbleOption` | `position`: `top`, `yMargin`: 생략 시 기기별 SDK 기본 여백 유지 |

버튼 위치는 `ChannelButtonPosition.left`/`right`, 팝업 위치는 `BubblePosition.top`/`bottom`입니다.
여백 단위는 Android dp, iOS pt이며, `BubbleOption.yMargin: 0`은 생략과 다릅니다.
**옵션 객체 자체를 생략하면 기존 배치를 유지합니다.** 특히 iOS의 기존 버튼 배치는 왼쪽,
가로 여백 16, 세로 여백 23입니다. `const ChannelButtonOption()`을 명시하면 양 플랫폼 모두
`channel` 아이콘, 오른쪽, 가로·세로 여백 20을 적용합니다.

`ChannelButtonIcon`은 18개 아이콘을 제공합니다: `channel`, `chatBubbleFilled`,
`chatProgressFilled`, `chatQuestionFilled`, `chatLightningFilled`, `chatBubbleAltFilled`,
`smsFilled`, `commentFilled`, `sendForwardFilled`, `helpFilled`, `chatProgress`, `chatQuestion`,
`chatBubbleAlt`, `sms`, `comment`, `sendForward`, `communication`, `headset`.

다음은 Android/iOS에서 커스텀 프로필과 버튼·팝업 배치를 설정하는 예제입니다.

```dart
final status = await ChannelTalk.bootWithStatus(
  pluginKey: 'pluginKey',
  name: '기본 이름',
  customAttributes: {
    'name': '우선 적용할 이름',
    'plan': 'pro',
    'expiredAt': null,
  },
  channelButtonOption: const ChannelButtonOption(
    icon: ChannelButtonIcon.headset,
    position: ChannelButtonPosition.right,
    xMargin: 20,
    yMargin: 24,
  ),
  bubbleOption: const BubbleOption(position: BubblePosition.bottom),
);

if (status == ChannelTalkBootStatus.success) {
  await ChannelTalk.updateUser(profileOnce: {'signupSource': 'app'});
}
```

### iOS

Set the app's iOS deployment target to **15.0 or later** for both Swift Package Manager
and CocoaPods.

Update info.plist.
```xml
<key>NSCameraUsageDescription</key>
<string>Accessing to camera in order to provide better user experience</string>

<key>NSMicrophoneUsageDescription</key>
<string>Accessing to microphone to record voice for video</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>Accessing to photo library in order to save photos</string>
 
<key>NSPhotoLibraryUsageDescription</key>
<string>Accessing to photo library in order to provide better user experience</string>
```

#### Native dependencies

Both integrations currently use ChannelIOSDK 13.3.0.

The plugin installs `ChannelIOSDK` automatically through Swift Package Manager (SPM) or CocoaPods.
Remove any explicit `pod 'ChannelIOSDK', ...` entry from `ios/Podfile` when upgrading.
Keeping that entry with SPM causes a duplicate `ChannelIOFront.framework` build error.

**Swift Package Manager:** Flutter 3.44 and later enable SPM by default. To enable it for your app,
merge this setting into the existing `flutter` section of the app's `pubspec.yaml`:

```yaml
flutter:
  config:
    enable-swift-package-manager: true
```

Run `flutter pub get`, then build or run the app to let Flutter integrate the Swift package.
See the [Flutter SPM migration guide][flutter-spm] if your app has custom native integration.

**CocoaPods:** Existing CocoaPods apps can continue using the plugin's podspec. With Flutter 3.44
or later, set `enable-swift-package-manager: false` in the app configuration above to use CocoaPods.
Keep the Flutter installation call in `ios/Podfile`; no separate `ChannelIOSDK` pod entry is needed:

```ruby
platform :ios, '15.0'

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end
```

After changing the Podfile, run `flutter pub get` from the app directory, then `pod install`
from `ios/`. This also applies to SPM apps that retain CocoaPods for other dependencies.

[flutter-spm]:
  https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers

Add ChannelTalk initializing code to `[project]/ios/Runner/AppDelegate.swift`
```
import ChannelIOFront
...

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        ...
        ChannelIO.initialize(application)
        ...
    }
...

```


### Android

#### Requirements
- minSdkVersion 21 (Channel Talk Android SDK requires API 21+ for features to work)
- compileSdkVersion 35 is used by this plugin module
- Android 13 (API 33) or later requires `POST_NOTIFICATIONS` permission for
  system push notifications.

The plugin adds Channel.io's official Maven repository for `io.channel` artifacts.
If your app centrally manages repositories in `settings.gradle`, add it there too:

```groovy
dependencyResolutionManagement {
    repositories {
        google()
        mavenCentral()
        maven {
            url 'https://maven.channel.io/maven2'
            content { includeGroup 'io.channel' }
        }
    }
}
```

Android supports explicit Korean, Japanese, and English SDK languages.
`Language.device` uses the device language during boot; in `updateUser` it leaves
the current language unchanged because the Android SDK has no device-language enum.

Android의 `onPopupDataReceived` 데이터에는 `timestamp`가 포함됩니다. 이 값은 SDK가 전달한
원본 시간 값이며 패키지가 단위를 정규화하지 않습니다. 플랫폼 공통 밀리초·초 값으로 가정하지
말고, 시간을 변환할 때 해당 플랫폼 SDK의 계약을 확인하세요.

#### Push notifications in combination with FCM
This plugin works in combination with the [`firebase_messaging`](https://pub.dev/packages/firebase_messaging) plugin to receive Push Notifications. To set this up:

* First, implement [`firebase_messaging`](https://pub.dev/packages/firebase_messaging) and check if it works: https://pub.dev/packages/firebase_messaging#android-integration
* Configure Firebase credentials in Channel Talk using the current
  [FCM integration guide](https://developers.channel.io/en/articles/Push-Notification-3bbe60d1).
* If your app targets Android 13 or above, request notification permission before showing system pushes.
* Add the following to your  `AndroidManifest.xml` file, so incoming messages are handled by Channel Talk:

```
    <service
        android:name="com.kuku.channel_talk_flutter.PushInterceptService"
        android:enabled="true"
        android:exported="true">
        <intent-filter>
          <action android:name="com.google.firebase.MESSAGING_EVENT" />
        </intent-filter>
    </service>
```

just above the closing `</application>` tag.


### Web

The SDK script must be loaded before calling this package. Await `bootForWeb`
before calling APIs that need a booted user.

Web에서는 다음 9개 메서드에 대응하는 공식 JavaScript SDK API가 없어
현재 `UnimplementedError`가 발생합니다. 테스트 실패나 plugin key 권한 문제와 구분합니다.

| API | Web에서 지원하지 않는 이유 |
| --- | --- |
| `sleep` | 모바일의 푸시·track만 유지하는 휴면 모드에 대응하는 Web 명령이 없습니다. |
| `isBooted` | Web SDK에 부팅 상태 조회 API가 없습니다. 부팅 결과는 await한 결과로 확인합니다. |
| `setDebugMode` | Web SDK에 같은 디버그 로그 설정 API가 없습니다. |
| `initPushToken` | 모바일 FCM/APNs 토큰 등록용이며 Web SDK에는 대응 명령이 없습니다. |
| `isChannelPushNotification` | 모바일 호스트가 받은 푸시 payload 판별용입니다. |
| `receivePushNotification` | 모바일 호스트의 푸시 수신을 SDK에 전달하는 API입니다. |
| `storePushNotification` | 모바일에서 수신한 푸시를 SDK에 보관하는 API입니다. |
| `hasStoredPushNotification` | 모바일 SDK에 저장된 푸시를 조회하는 API입니다. |
| `openStoredPushNotification` | 모바일에 저장된 푸시로 상담을 여는 API입니다. |

공개 범위는 [공식 Web API 문서](https://developers.channel.io/en/articles/0b119290)와
[공식 loader 소스](https://github.com/channel-io/channel-web-sdk-loader/blob/main/src/index.ts)를
기준으로 확인했습니다. 브라우저 자체의 Web Push 구현 가능성과는 별개입니다.
`shutdown`은 모든 SDK 동작을 종료하므로 `sleep`의 동일한 대체 동작은 아닙니다.
로컬 변수로 마지막 boot 결과를 보관하는 것도 SDK의 현재 상태를 직접 조회하는 것과 다릅니다.

The Web `onChatCreated` event has no chat ID argument, so its listener payload is null.

Web의 `onUrlClicked`는 URL을 알려주는 이벤트입니다. SDK는 콜백 반환값으로 기본 이동을
취소하지 않으므로 `setPreventDefaultUrlClick(true)`는 비동기 `UnsupportedError`를 반환합니다.
`setPreventDefaultUrlClick(false)`는 SDK 호출 없이 `true`로 완료되어 기본 동작을 유지합니다.
자세한 콜백 계약은 [공식 Web SDK의 `UrlClickedCallback` 정의](https://github.com/channel-io/channel-web-sdk-loader/blob/main/src/index.ts)를 참고하세요.

`setPage` requires a non-null `page` on Web. Use `resetPage` to reset the page
and user chat profile. The listener APIs use the SDK's global `clearCallbacks`;
manage Channel.io callbacks through this package when using `setListener` or `removeListener`.

Insert the following script within the <body> tag of your HTML file(web/index.html):
```Html
<script>
  (function(){var w=window;if(w.ChannelIO){return w.console.error("ChannelIO script included twice.");}var ch=function(){ch.c(arguments);};ch.q=[];ch.c=function(args){ch.q.push(args);};w.ChannelIO=ch;function l(){if(w.ChannelIOInitialized){return;}w.ChannelIOInitialized=true;var s=document.createElement("script");s.type="text/javascript";s.async=true;s.src="https://cdn.channel.io/plugin/ch-plugin-web.js";var x=document.getElementsByTagName("script")[0];if(x.parentNode){x.parentNode.insertBefore(s,x);}}if(document.readyState==="complete"){l();}else{w.addEventListener("DOMContentLoaded",l);w.addEventListener("load",l);}})();
</script>
```

In case of Web platform, would better use `bootForWeb` API but we can also use `boot` API.
```dart
import 'package:channel_talk_flutter/channel_talk_flutter.dart';

void main() async {
    await ChannelTalk.bootForWeb(
        pluginKey: 'pluginKey', // Required
        memberId: 'memberId',
        memberHash: 'memberHash',
        email: 'email',
        name: 'name',
        mobileNumber: '0101231234',
        avatarUrl: 'avatarUrl',
        customLauncherSelector: 'customLauncherSelector',
        hideChannelButtonOnBoot: false,
        zIndex: 10000000,
        trackDefaultEvent: false,
        trackUtmSource: false,
        unsubscribeEmail: false,
        unsubscribeTexting: false,
        hidePopup: false,
        appearance: Appearance.light,
        language: Language.japanese,
    );
...
}
```


### 🔧 Supported API

<table>
    <thead>
        <tr>
            <th>API</th>
            <th>API Description</th>
            <th>Parameter</th>
            <th>Type</th>
            <th style="width:70%">Parameter Description</th>
            <th>Support platforms</th>
        </tr>
    </thead>
    <tbody>
        <!-- setListener -->
        <tr>
            <td>setListener</td>
            <td>Set the delegate allows the reception of event callbacks from the SDK.

</td>
            <td>delegate*</td>
            <td>ChannelTalkDelegate</td>
            <td>Support onShowMessenger/onHideMessenger/onChatCreated/onBadgeChanged/onFollowUpChanged/onUrlClicked/onPopupDataReceived</td>
            <td>Mobile, Web</td>
        </tr>
        <!-- removeListener -->
        <tr>
            <td>removeListener</td>
            <td>Remove the delegate allows the reception of event callbacks from the SDK.q

</td>
            <td></td>
            <td></td>
            <td></td>
            <td>Mobile, Web</td>
        </tr>
        <!-- boot -->
        <tr>
            <td rowspan=16>boot</td>
            <td rowspan=16>Load the information necessary to use the SDK.</td>
            <td>pluginKey*</td>
            <td>String</td>
            <td>Plugin key of Channel.</td>
            <td rowspan=16>Mobile, Web<br>배치 옵션은 Android/iOS 전용</td>
        </tr>
        <tr>
            <td>memberId</td>
            <td>String?</td>
            <td>An identifier to distinguish each member user.</td>
        </tr>
        <tr>
            <td>memberHash</td>
            <td>String?</td>
            <td>A HMAC-SHA256 value of memberId.</td>
        </tr>
        <tr>
            <td>email</td>
            <td>String?</td>
            <td>An email of a user.</td>
        </tr>
        <tr>
            <td>name</td>
            <td>String?</td>
            <td>A name of a user.</td>
        </tr>
        <tr>
            <td>mobileNumber</td>
            <td>String?</td>
            <td>A mobile number of a user.</td>
        </tr>
        <tr>
            <td>avatarUrl</td>
            <td>String?</td>
            <td>An avatar URL of a user.</td>
        </tr>
        <tr>
            <td>language</td>
            <td>Language?</td>
            <td>A user’s language.
It is valid when creating a new user. The language of the user that already exists will not change.</td>
        </tr>
        <tr>
            <td>unsubscribeEmail</td>
            <td>bool?</td>
            <td>Sets whether to receive marketing messages via email.</td>
        </tr>
        <tr>
            <td>unsubscribeTexting</td>
            <td>bool?</td>
            <td>Sets whether to receive marketing messages via texting (SMS, LMS)</td>
        </tr>
        <tr>
            <td>trackDefaultEvent</td>
            <td>bool?</td>
            <td>Sets whether to track the default event, such as PageView.</td>
        </tr>
        <tr>
            <td>hidePopup</td>
            <td>bool?</td>
            <td>Sets whether to hide popups such as marketing popup and in-app notifications.</td>
        </tr>
        <tr>
            <td>appearance</td>
            <td>Appearance?</td>
            <td>Sets the appearance of SDK.</td>
        </tr>
        <tr>
            <td>customAttributes</td>
            <td>Map&lt;String, dynamic&gt;?</td>
            <td>기본 프로필 뒤에 병합합니다. 중복 키는 이 값이 우선하며 null도 전달합니다.</td>
        </tr>
        <tr>
            <td>channelButtonOption</td>
            <td>ChannelButtonOption?</td>
            <td>Android/iOS 버튼 아이콘과 위치·여백입니다. 생략 시 기존 배치를 유지합니다. Web은 비동기 UnsupportedError입니다.</td>
        </tr>
        <tr>
            <td>bubbleOption</td>
            <td>BubbleOption?</td>
            <td>Android/iOS 팝업 위치·여백입니다. yMargin 생략 시 SDK 기본값을 유지합니다. Web은 비동기 UnsupportedError입니다.</td>
        </tr>
        <!-- bootWithStatus -->
        <tr>
            <td>bootWithStatus</td>
            <td>부팅 결과를 ChannelTalkBootStatus로 반환합니다.</td>
            <td>boot와 동일</td>
            <td>boot와 동일</td>
            <td>customAttributes와 두 모바일 배치 옵션을 포함합니다. Web SDK 콜백 결과는 success 또는 unknown이며 호출 예외는 Future 오류입니다.</td>
            <td>Mobile, Web<br>배치 옵션은 Android/iOS 전용</td>
        </tr>
        <!-- bootForWeb -->
        <tr>
            <td rowspan=18>bootForWeb</td>
            <td rowspan=18>Load the information necessary to use the SDK.</td>
            <td>pluginKey*</td>
            <td>String</td>
            <td>Plugin key of Channel.</td>
            <td rowspan=18>Web</td>
        </tr>
        <tr>
            <td>memberId</td>
            <td>String?</td>
            <td>An identifier to distinguish each member user.</td>
        </tr>
        <tr>
            <td>memberHash</td>
            <td>String?</td>
            <td>A HMAC-SHA256 value of memberId.</td>
        </tr>
        <tr>
            <td>email</td>
            <td>String?</td>
            <td>An email of a user.</td>
        </tr>
        <tr>
            <td>name</td>
            <td>String?</td>
            <td>A name of a user.</td>
        </tr>
        <tr>
            <td>mobileNumber</td>
            <td>String?</td>
            <td>A mobile number of a user.</td>
        </tr>
        <tr>
            <td>avatarUrl</td>
            <td>String?</td>
            <td>An avatar URL of a user.</td>
        </tr>
        <tr>
            <td>language</td>
            <td>Language?</td>
            <td>A user’s language.
It is valid when creating a new user. The language of the user that already exists will not change.</td>
        </tr>
        <tr>
            <td>unsubscribeEmail</td>
            <td>bool?</td>
            <td>Sets whether to receive marketing messages via email.</td>
        </tr>
        <tr>
            <td>unsubscribeTexting</td>
            <td>bool?</td>
            <td>Sets whether to receive marketing messages via texting (SMS, LMS)</td>
        </tr>
        <tr>
            <td>trackDefaultEvent</td>
            <td>bool?</td>
            <td>Sets whether to track the default event, such as PageView.</td>
        </tr>
        <tr>
            <td>hidePopup</td>
            <td>bool?</td>
            <td>Sets whether to hide popups such as marketing popup and in-app notifications.</td>
        </tr>
        <tr>
            <td>appearance</td>
            <td>Appearance?</td>
            <td>Sets the appearance of SDK.</td>
        </tr>
        <tr>
            <td>customLauncherSelector</td>
            <td>String?</td>
            <td>The CSS Selector to select a custom launcher.
Use this option to customize the default chat button.</td>
        </tr>
        <tr>
            <td>hideChannelButtonOnBoot</td>
            <td>bool?</td>
            <td>Determines whether to hide the default chat button on boot.
The default value is false.</td>
        </tr>
        <tr>
            <td>zIndex</td>
            <td>int?</td>
            <td>Sets the z-index for SDK elements, such as the chat button, messenger, and marketing pop-ups.
The default value is 10000000.</td>
        </tr>
        <tr>
            <td>trackUtmSource</td>
            <td>bool?</td>
            <td>Determines whether to track the UTM source and referrer.
The default value is true.</td>
        </tr>
        <tr>
            <td>customAttributes</td>
            <td>Map&lt;String, dynamic&gt;?</td>
            <td>기본 프로필 뒤에 병합합니다. 중복 키는 이 값이 우선하며 null도 전달합니다.</td>
        </tr>
        <!-- sleep -->
        <tr>
            <td>sleep</td>
            <td>Disables all features except for receiving system push notifications and using the Track.</td>
            <td></td>
            <td></td>
            <td></td>
            <td>Mobile</td>
        </tr>
        <!-- shutdown -->
        <tr>
            <td>shutdown</td>
            <td>Disconnects the SDK from the channel.</td>
            <td></td>
            <td></td>
            <td></td>
            <td>Mobile, Web</td>
        </tr>
        <!-- showChannelButton -->
        <tr>
            <td>showChannelButton</td>
            <td>Displays the Channel button on the global screen.</td>
            <td></td>
            <td></td>
            <td></td>
            <td>Mobile, Web</td>
        </tr>
        <!-- hideChannelButton -->
        <tr>
            <td>hideChannelButton</td>
            <td>Hides the Channel button on the global screen.</td>
            <td></td>
            <td></td>
            <td></td>
            <td>Mobile, Web</td>
        </tr>
        <!-- showMessenger -->
        <tr>
            <td>showMessenger</td>
            <td>Displays the messenger.</td>
            <td></td>
            <td></td>
            <td></td>
            <td>Mobile, Web</td>
        </tr>
        <!-- hideMessenger -->
        <tr>
            <td>hideMessenger</td>
            <td>Hides the messenger.</td>
            <td></td>
            <td></td>
            <td></td>
            <td>Mobile, Web</td>
        </tr>
        <!-- openChat -->
        <tr>
            <td rowspan=2>openChat</td>
            <td rowspan=2>Opens User chat.</td>
            <td>chatId</td>
            <td>String?</td>
            <td>This is the chat ID. If the chatId is invalid or nil, a new user chat is opened.</td>
            <td rowspan=2>Mobile, Web</td>
        </tr>
        <tr>
            <td>message</td>
            <td>String?</td>
            <td>This is the pre-filled message in the message input field when opening a new chat. It is valid when chatId is nil.</td>
        </tr>
        <!-- track -->
        <tr>
            <td rowspan=2>track</td>
            <td rowspan=2>Tracks the user's events.</td>
            <td>eventName*</td>
            <td>String</td>
            <td>This is the name of the event to track, with a maximum length of 30 characters.</td>
            <td rowspan=2>Mobile, Web</td>
        </tr>
        <tr>
            <td>properties</td>
            <td>Map?</td>
            <td>This is additional information about the event.</td>
        </tr>
        <!-- updateUser -->
        <tr>
            <td rowspan=10>updateUser</td>
            <td rowspan=10>Modifies user information.</td>
            <td>name</td>
            <td>String?</td>
            <td>A name of a user.</td>
            <td rowspan=10>Mobile, Web</td>
        </tr>
        <tr>
            <td>email</td>
            <td>String?</td>
            <td>An email of a user.</td>
        </tr>
        <tr>
            <td>mobileNumber</td>
            <td>String?</td>
            <td>A mobile number of a user.</td>
        </tr>
        <tr>
            <td>avatarUrl</td>
            <td>String?</td>
            <td>An avatar URL of a user.</td>
        </tr>
        <tr>
            <td>language</td>
            <td>Language?</td>
            <td>A user’s language.
It is valid when creating a new user. The language of the user that already exists will not change.</td>
        </tr>
        <tr>
            <td>unsubscribeEmail</td>
            <td>bool?</td>
            <td>Sets whether to receive marketing messages via email.</td>
        </tr>
        <tr>
            <td>unsubscribeTexting</td>
            <td>bool?</td>
            <td>Sets whether to receive marketing messages via texting (SMS, LMS)</td>
        </tr>
        <tr>
            <td>tags</td>
            <td>List[String]?</td>
            <td>A tag list of the user.</td>
        </tr>
        <tr>
            <td>customAttributes</td>
            <td>Map&lt;String, dynamic&gt;?</td>
            <td>기본 프로필 뒤에 병합합니다. 중복 키는 이 값이 우선하며 null도 전달합니다.</td>
        </tr>
        <tr>
            <td>profileOnce</td>
            <td>Map&lt;String, dynamic&gt;?</td>
            <td>아직 값이 없는 프로필 필드만 채웁니다. customAttributes와 별도로 전달되며 생략 시 전송하지 않습니다.</td>
        </tr>
        <!-- initPushToken -->
        <tr>
            <td >initPushToken</td>
            <td>Informs ChannelTalk about updates to the device token.</td>
            <td>deviceToken*</td>
            <td>String</td>
            <td>This is additional information about the event.</td>
            <td>Mobile</td>
        </tr>
        <!-- isChannelPushNotification -->
        <tr>
            <td>isChannelPushNotification</td>
            <td>It checks if the push data should be processed by the SDK.</td>
            <td>content*</td>
            <td>Map</td>
            <td>This is the `userInfo object received through push notifications.</td>
            <td>Mobile</td>
        </tr>
        <!-- receivePushNotification -->
        <tr>
            <td>receivePushNotification</td>
            <td>Notifies Channel Talk that the user has received a push notification.</td>
            <td>content*</td>
            <td>Map</td>
            <td>This is the `userInfo object received through push notifications.</td>
            <td>Mobile</td>
        </tr>
        <!-- storePushNotification -->
        <tr>
            <td>storePushNotification</td>
            <td>Stores push information on the device.</td>
            <td>content*</td>
            <td>Map</td>
            <td>This is the `userInfo object received through push notifications.</td>
            <td>Mobile</td>
        </tr>
        <!-- hasStoredPushNotification -->
        <tr>
            <td>hasStoredPushNotification</td>
            <td>Check for any saved push notifications from the Channel.</td>
            <td></td>
            <td></td>
            <td></td>
            <td>Mobile</td>
        </tr>
        <!-- openStoredPushNotification -->
        <tr>
            <td>openStoredPushNotification</td>
            <td>Opens a user chat using the stored push information on the device through storePushNotification.</td>
            <td></td>
            <td></td>
            <td></td>
            <td>Mobile</td>
        </tr>
        <!-- isBooted -->
        <tr>
            <td>isBooted</td>
            <td>Verify that the SDK is in a Boot state.</td>
            <td></td>
            <td></td>
            <td></td>
            <td>Mobile</td>
        </tr>
        <!-- setDebugMode -->
        <tr>
            <td>setDebugMode</td>
            <td>Sets the debug mode.</td>
            <td>flag*</td>
            <td>String</td>
            <td>debug mode</td>
            <td>Mobile</td>
        </tr>
        <!-- setPage -->
        <tr>
            <td>setPage</td>
            <td>Sets the page and user chat profile used by track and new chats.</td>
            <td>page, profile</td>
            <td>String?, Map&lt;String, dynamic&gt;?</td>
            <td>page is the tracked screen name and is required on Web. profile sets user chat profile fields. Both parameters are optional on Android and iOS.</td>
            <td>Mobile, Web</td>
        </tr>
        <!-- resetPage -->
        <tr>
            <td>resetPage</td>
            <td>Resets the tracked screen name and user chat profile.</td>
            <td></td>
            <td></td>
            <td></td>
            <td>Mobile, Web</td>
        </tr>
        <!-- addTags -->
        <tr>
            <td>addTags</td>
            <td>Adds tags to the user.</td>
            <td>tags*</td>
            <td>List[String]</td>
            <td>• The maximum number of tags that can be added is 10.<br>
• Tags are stored in lowercase.<br>
• Any tags that have already been added will be ignored.<br>
• nil, empty strings, or lists containing them are not allowed.</td>
            <td>Mobile, Web</td>
        </tr>
        <!-- removeTags -->
        <tr>
            <td>removeTags</td>
            <td>Removes tags from the user, ignoring any tags that do not exist.

</td>
            <td>tags*</td>
            <td>List[String]</td>
            <td>These are the tags to be removed. Null, empty strings, or lists containing them are not allowed.</td>
            <td>Mobile, Web</td>
        </tr>
        <!-- openWorkflow -->
        <tr>
            <td>openWorkflow</td>
            <td>Opens a user chat and starts the specified workflow.</td>
            <td>workflowId</td>
            <td>String?</td>
            <td>The ID of workflow to start with. An error page will be shown if such workflow does not exist.</td>
            <td>Mobile, Web</td>
        </tr>
        <!-- setAppearance -->
        <tr>
            <td>setAppearance</td>
            <td>Configures the SDK's theme.</td>
            <td>appearance*</td>
            <td>Appearance</td>
            <td>If specified as .light or .dark, it locks the theme to the respective mode. If specified as .system, it follows the device's system theme.</td>
            <td>Mobile, Web</td>
        </tr>
        <!-- hidePopup -->
        <tr>
            <td>hidePopup</td>
            <td>Hides the Channel popup on the global screen.</td>
            <td></td>
            <td></td>
            <td></td>
            <td>Mobile, Web</td>
        </tr>
        <!-- setPreventDefaultUrlClick -->
        <tr>
            <td>setPreventDefaultUrlClick</td>
            <td>
                Android/iOS에서 기본 URL 이동을 차단하고 onUrlClicked 이벤트로 앱이 처리하도록 설정합니다.
            </td>
            <td>prevent*</td>
            <td>bool</td>
            <td>
                Web의 true는 비동기 UnsupportedError입니다. false는 SDK 호출 없이 true로 완료되며 기본 이동을 유지합니다. Web onUrlClicked는 URL 관찰만 지원합니다.
            </td>
            <td>Android, iOS<br>Web은 false만 허용</td>
        </tr>
    </tbody>
</table>

## 🤗 Contributing

Contributions are welcome! Feel free to [open an issue](https://github.com/turlvo/channel_talk_flutter/issues/new) or submit a [pull request](https://github.com/turlvo/channel_talk_flutter/compare) if you have a way to improve this project.

Make sure your request is meaningful and you have tested the app locally before submitting a pull request.


## 🙋‍♂️ Support

💙 If you like this project, give it a ⭐ and share it with friends!

<a href="https://www.buymeacoffee.com/turlvo" target="_blank" title="buymeacoffee">
  <img src="https://iili.io/JoQ1HUQ.md.png"  alt="buymeacoffee-violet-badge" style="width: 130px;">
</a>
