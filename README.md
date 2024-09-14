# channel_talk_flutter
Flutter wrapper for Channel Talk Android and iOS projects.(Unofficial)<br><br>
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
  pod 'ChannelIOSDK', podspec: 'https://mobile-static.channel.io/ios/11.7.3/xcframework.podspec'

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


### Supported API

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
            <td>Mobile</td>
        </tr>
        <!-- removeListener -->
        <tr>
            <td>removeListener</td>
            <td>Remove the delegate allows the reception of event callbacks from the SDK.q

</td>
            <td></td>
            <td></td>
            <td></td>
            <td>Mobile</td>
        </tr>
        <!-- boot -->
        <tr>
            <td rowspan=13>boot</td>
            <td rowspan=13>Load the information necessary to use the SDK.</td>
            <td>pluginKey*</td>
            <td>String</td>
            <td>Plugin key of Channel.</td>
            <td rowspan=13>Mobile, Web</td>
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
        <!-- bootForWeb -->
        <tr>
            <td rowspan=17>bootForWeb</td>
            <td rowspan=17>Load the information necessary to use the SDK.</td>
            <td>pluginKey*</td>
            <td>String</td>
            <td>Plugin key of Channel.</td>
            <td rowspan=17>Web</td>
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
            <td rowspan=9>updateUser</td>
            <td rowspan=9>TraModifies user information.</td>
            <td>name</td>
            <td>String?</td>
            <td>A name of a user.</td>
            <td rowspan=9>Mobile, Web</td>
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
            <td>Map < String, dynamic >?</td>
            <td>A user's CustomAttributes</td>
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
            <td>Sets the name of the screen when the track is called.</td>
            <td>page*</td>
            <td>String</td>
            <td>This is the screen name when track is called.</td>
            <td>Mobile, Web</td>
        </tr>
        <!-- resetPage -->
        <tr>
            <td>resetPage</td>
            <td>Resets the name of the screen when track is called.</td>
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
            <td rowspan=2>openWorkflow</td>
            <td rowspan=2>Opens a user chat and starts the specified workflow.</td>
            <td>workflowId</td>
            <td>String?</td>
            <td>The ID of workflow to start with. An error page will be shown if such workflow does not exist.</td>
            <td rowspan=2>Mobile, Web</td>
        </tr>
        <tr>
            <td>message</td>
            <td>String?</td>
            <td>This message will be displayed in the input field after completing the support bot operation.</td>
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
            <td>Mobile</td>
        </tr>
    </tbody>
</table>
