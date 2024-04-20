# channel_talk_flutter

Flutter wrapper for Channel Talk Android and iOS projects.(Unofficial)

## Usage
```dart
import 'package:channel_talk_flutter/channel_talk_flutter.dart';

void main() async {
    await ChannelTalk.boot(
        pluginKey: 'pluginKey',
        memberId: 'memberId',
        email: 'email',
        name: 'name',
        memberHash: 'memberHash',
        mobileNumber: 'mobileNumber',
        trackDefaultEvent: false,
        hidePopup: false,
        language: 'english',
    );
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
  pod 'ChannelIOSDK', podspec: 'https://mobile-static.channel.io/ios/latest/xcframework.podspec'

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

