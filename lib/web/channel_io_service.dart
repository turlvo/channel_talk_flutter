@JS()
library channel;

import 'dart:js_interop';

// extension type BootOption._(JSObject _) implements JSObject {
//   external String get pluginKey;
//   external String? get memberId;
//   external String? get customLauncherSelector;
//   external bool? get hideChannelButtonOnBoot;
//   external int? get zIndex;
//   external String? get language;
//   external bool? get trackDefaultEvent;
//   external bool? get trackUtmSource;
//   external Profile? get profile;
//   external bool? get unsubscribeEmail;
//   external bool? get unsubscribeTexting;
//   external String? get memberHash;
//   external bool? get hidePopup;
//   external String? get appearance;

//   external factory BootOption({
//     String pluginKey,
//     String? memberId,
//     String? customLauncherSelector,
//     bool? hideChannelButtonOnBoot,
//     int? zIndex,
//     String? language,
//     bool? trackDefaultEvent,
//     bool? trackUtmSource,
//     Profile? profile,
//     bool? unsubscribeEmail,
//     bool? unsubscribeTexting,
//     String? memberHash,
//     bool? hidePopup,
//     String? appearance,
//   });
// }

// extension type UserObject._(JSObject _) implements JSObject {
//   external Profile? get profile;
//   external JSAny? get profileOnce;
//   external bool? get unsubscribeEmail;
//   external bool? get unsubscribeTexting;
//   external JSArray? get tags;
//   external String? get language;

//   external factory UserObject({
//     Profile? profile,
//     JSAny? profileOnce,
//     bool? unsubscribeEmail,
//     bool? unsubscribeTexting,
//     JSArray? tags,
//     String? language,
//   });
// }

// extension type Profile._(JSObject _) implements JSObject {
//   external String? get email;
//   external String? get mobileNumber;
//   external String? get name;
//   external String? get avatarUrl;

//   external factory Profile({
//     String? email,
//     String? mobileNumber,
//     String? name,
//     String? avatarUrl,
//   });
// }

@JS('ChannelIO')
@anonymous
external void boot(
  String command,
  JSAny? bootOption,
);

@JS('ChannelIO')
external void shutdown(String command);

@JS('ChannelIO')
external void showChannelButton(String command);

@JS('ChannelIO')
external void hideChannelButton(String command);

@JS('ChannelIO')
external void showMessenger(String command);

@JS('ChannelIO')
external void hideMessenger(String command);

@JS('ChannelIO')
external void openChat(
  String command,
  String? chatId,
  String? message,
);

@JS('ChannelIO')
external void track(
  String command,
  String eventName,
  JSAny? eventProperty,
);

@JS('ChannelIO')
external void updateUser(
  String command,
  JSAny? userObject,
);

@JS('ChannelIO')
external void setPage(String command, String page);

@JS('ChannelIO')
external void resetPage(String command);

@JS('ChannelIO')
external void addTags(
  String command,
  JSAny? tags,
);

@JS('ChannelIO')
external void removeTags(
  String command,
  JSAny? tags,
);

@JS('ChannelIO')
external void openSupportBot(String command, String supportBotId,
    [String? message]);

@JS('ChannelIO')
external void setAppearance(String command, String appearance);
