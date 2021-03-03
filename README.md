# channel_talk

Flutter wrapper for Channel Talk Android and iOS projects.(Unofficial)

## Usage
```
import 'package:channel_talk/channel_talk.dart';

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
        language: 'english,
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
```
<key>NSCameraUsageDescription</key>
<string>Accessing to camera in order to provide better user experience</string>
<key>NSMicrophoneUsageDescription</key>
<string>Accessing to microphone to record voice for video</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Accessing to photo library in order to save photos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Accessing to photo library in order to provide better user experience</string>
```

Add pod installation to 'Podfile'.
(Because there is no latest 'ChannelIOSDK' pod in Cocopod, can not add dependecy to plugin podspec properly.)
```
target 'Runner' do
  use_frameworks!
  use_modular_headers!
  # Add below 'pod 'ChannelIOSDK'
  pod 'ChannelIOSDK', podspec: 'https://mobile-static.channel.io/ios/latest/xcframework.podspec'

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end


### Android

#### Push notifications in combination with FCM
This plugin works in combination with the [`firebase_messaging`](https://pub.dev/packages/firebase_messaging) plugin to receive Push Notifications. To set this up:

* First, implement [`firebase_messaging`](https://pub.dev/packages/firebase_messaging) and check if it works: https://pub.dev/packages/firebase_messaging#android-integration
* Then, add the Firebase server key to Intercom, as described here: https://developers.channel.io/docs/android-push-notification
* Add the following to your  `AndroidManifest.xml` file, so incoming messages are handled by Intercom:

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
_just above the closing `</application>` tag._

* Ask FireBaseMessaging for the FCM token that we need to send to Intercom, and give it to Intercom (so Intercam can send push messages to the correct device):

```dart
final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
token = await _firebaseMessaging.getToken();

Intercom.sendTokenToIntercom(token);
```
