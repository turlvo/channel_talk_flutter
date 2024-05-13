@JS()
library channel;

import 'package:js/js.dart';

@JS()
@anonymous
class BootOption {
  external String get pluginKey;
  external String? get memberId;
  external String? get customLauncherSelector;
  external bool? get hideChannelButtonOnBoot;
  external int? get zIndex;
  external String? get language;
  external bool? get trackDefaultEvent;
  external bool? get trackUtmSource;
  external Profile? get profile;
  external bool? get unsubscribeEmail;
  external bool? get unsubscribeTexting;
  external String? get memberHash;
  external bool? get hidePopup;
  external String? get appearance;

  external factory BootOption({
    String pluginKey,
    String? memberId,
    String? customLauncherSelector,
    bool? hideChannelButtonOnBoot,
    int? zIndex,
    String? language,
    bool? trackDefaultEvent,
    bool? trackUtmSource,
    Profile? profile,
    bool? unsubscribeEmail,
    bool? unsubscribeTexting,
    String? memberHash,
    bool? hidePopup,
    String? appearance,
  });
}

@JS()
@anonymous
class UserObject {
  external Profile? get profile;
  external Object? get profileOnce;
  external bool? get unsubscribeEmail;
  external bool? get unsubscribeTexting;
  external List? get tags;
  external String? get language;

  external factory UserObject({
    Profile? profile,
    Object? profileOnce,
    bool? unsubscribeEmail,
    bool? unsubscribeTexting,
    List? tags,
    String? language,
  });
}

@JS()
@anonymous
class Profile {
  external String? get email;
  external String? get mobileNumber;
  external String? get name;
  external String? get avatarUrl;

  external factory Profile({
    String? email,
    String? mobileNumber,
    String? name,
    String? avatarUrl,
  });
}

@JS('ChannelIO')
@anonymous
external Future<void> boot(
  String command,
  BootOption bootOption,
  Function callback,
);

@JS('ChannelIO')
external Future<void> shutdown(String command);

@JS('ChannelIO')
external Future<void> showChannelButton(String command);

@JS('ChannelIO')
external Future<void> hideChannelButton(String command);

@JS('ChannelIO')
external Future<void> showMessenger(String command);

@JS('ChannelIO')
external Future<void> hideMessenger(String command);

@JS('ChannelIO')
external Future<void> openChat(String command, Map<String, dynamic> data);

@JS('ChannelIO')
external Future<void> track(String command, Map<String, dynamic> data);

@JS('ChannelIO')
external Future<void> updateUser(
  String command,
  UserObject userObject,
  Function callback,
);

@JS('ChannelIO')
external Future<void> setPage(String command, String page);

@JS('ChannelIO')
external Future<void> resetPage(String command);

@JS('ChannelIO')
external Future<void> addTags(
  String command,
  List tags,
  Function callback,
);

@JS('ChannelIO')
external Future<void> removeTags(
  String command,
  List tags,
  Function callback,
);
