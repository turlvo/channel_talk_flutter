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
