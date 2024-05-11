# channel_talk_flutter

Flutter wrapper for Channel Talk Android and iOS projects.(Unofficial)

## Usage
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

### iOS

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

Add pod installation to `ios/Podfile`.
(Because there is no latest `ChannelIOSDK` pod in Cocopod, can not add dependecy to plugin podspec properly.)
```
target 'Runner' do
  use_frameworks!
  use_modular_headers!
  # Add below line
  pod 'ChannelIOSDK', podspec: 'https://mobile-static.channel.io/ios/11.6.0/xcframework.podspec'

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end
```

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

#### Push notifications in combination with FCM
This plugin works in combination with the [`firebase_messaging`](https://pub.dev/packages/firebase_messaging) plugin to receive Push Notifications. To set this up:

* First, implement [`firebase_messaging`](https://pub.dev/packages/firebase_messaging) and check if it works: https://pub.dev/packages/firebase_messaging#android-integration
* Then, add the Firebase server key to Channel Talk, as described here: https://developers.channel.io/docs/android-push-notification
* Add the following to your  `AndroidManifest.xml` file, so incoming messages are handled by Channel Talk:

```
    <service
        android:name="ai.deepnatural.channel_talk.PushInterceptService"
        android:enabled="true"
        android:exported="true">
        <intent-filter>
          <action android:name="com.google.firebase.MESSAGING_EVENT" />
        </intent-filter>
    </service>
```

just above the closing `</application>` tag.


### Web

Insert the following script within the <body> tag of your HTML file(web/index.html):
```Html
<script>
  (function(){var w=window;if(w.ChannelIO){return w.console.error("ChannelIO script included twice.");}var ch=function(){ch.c(arguments);};ch.q=[];ch.c=function(args){ch.q.push(args);};w.ChannelIO=ch;function l(){if(w.ChannelIOInitialized){return;}w.ChannelIOInitialized=true;var s=document.createElement("script");s.type="text/javascript";s.async=true;s.src="https://cdn.channel.io/plugin/ch-plugin-web.js";var x=document.getElementsByTagName("script")[0];if(x.parentNode){x.parentNode.insertBefore(s,x);}}if(document.readyState==="complete"){l();}else{w.addEventListener("DOMContentLoaded",l);w.addEventListener("load",l);}})();
</script>
```

In case of Web platform, use `bootForWeb` API
```dart
import 'package:channel_talk_flutter/channel_talk_flutter.dart';

void main() async {
    await ChannelTalk.bootForWeb(
        pluginKey: 'pluginKey', // Required
        memberId: 'memberId',
        memberHash: 'memberHash',
        customLauncherSelector: 'customLauncherSelector',
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