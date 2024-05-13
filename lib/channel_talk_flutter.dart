import 'channel_talk_flutter_platform_interface.dart';

enum Appearance {
  system('system'),
  light('light'),
  dark('dark');

  const Appearance(this.value);

  final String value;
}

enum Language {
  english('en'),
  korean('ko'),
  japanese('ja'),
  device('device');

  const Language(this.value);

  final String value;
}

class ChannelTalk {
  static void setListener(ChannelTalkDelegate delegate) {
    return ChannelTalkFlutterPlatform.instance.setListener(delegate);
  }

  // Removes the callback listener if it exists
  static void removeListener() {
    return ChannelTalkFlutterPlatform.instance.removeListener();
  }

  static Future<bool?> boot({
    required String pluginKey,
    String? memberId,
    String? memberHash,
    String? email,
    String? name,
    String? mobileNumber,
    String? avatarUrl,
    Language? language,
    bool? unsubscribeEmail,
    bool? unsubscribeTexting,
    bool? trackDefaultEvent,
    bool? hidePopup,
    Appearance? appearance,
  }) {
    Map<String, dynamic> config = {
      'pluginKey': pluginKey,
      if (memberId != null) 'memberId': memberId,
      if (memberHash != null) 'memberHash': memberHash,
      if (email != null) 'email': email,
      if (name != null) 'name': name,
      if (mobileNumber != null) 'mobileNumber': mobileNumber,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (language != null) 'language': language.value,
      if (unsubscribeEmail != null) 'unsubscribeEmail': unsubscribeEmail,
      if (unsubscribeTexting != null) 'unsubscribeTexting': unsubscribeTexting,
      if (trackDefaultEvent != null) 'trackDefaultEvent': trackDefaultEvent,
      if (hidePopup != null) 'hidePopup': hidePopup,
      if (appearance != null) 'appearance': appearance.value,
    };

    return ChannelTalkFlutterPlatform.instance.boot(config);
  }

  static Future<bool?> bootForWeb({
    required String pluginKey,
    String? memberId,
    String? email,
    String? name,
    String? mobileNumber,
    String? avatarUrl,
    String? customLauncherSelector,
    bool? hideChannelButtonOnBoot,
    int? zIndex,
    Language? language,
    bool? trackDefaultEvent,
    bool? trackUtmSource,
    bool? unsubscribeEmail,
    bool? unsubscribeTexting,
    String? memberHash,
    bool? hidePopup,
    Appearance? appearance,
  }) {
    Map<String, dynamic> config = {
      'pluginKey': pluginKey,
      if (memberId != null) 'memberId': memberId,
      if (email != null) 'email': email,
      if (name != null) 'name': name,
      if (mobileNumber != null) 'mobileNumber': mobileNumber,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (customLauncherSelector != null)
        'customLauncherSelector': customLauncherSelector,
      if (hideChannelButtonOnBoot != null)
        'hideChannelButtonOnBoot': hideChannelButtonOnBoot,
      if (zIndex != null) 'zIndex': zIndex,
      if (language != null) 'language': language.value,
      if (trackDefaultEvent != null) 'trackDefaultEvent': trackDefaultEvent,
      if (trackUtmSource != null) 'trackUtmSource': trackUtmSource,
      if (unsubscribeEmail != null) 'unsubscribeEmail': unsubscribeEmail,
      if (unsubscribeTexting != null) 'unsubscribeTexting': unsubscribeTexting,
      if (memberHash != null) 'memberHash': memberHash,
      if (hidePopup != null) 'hidePopup': hidePopup,
      if (appearance != null) 'appearance': appearance.value,
    };

    return ChannelTalkFlutterPlatform.instance.boot(config);
  }

  static Future<bool?> sleep() {
    return ChannelTalkFlutterPlatform.instance.sleep();
  }

  static Future<bool?> shutdown() {
    return ChannelTalkFlutterPlatform.instance.shutdown();
  }

  static Future<bool?> showChannelButton() {
    return ChannelTalkFlutterPlatform.instance.showChannelButton();
  }

  static Future<bool?> hideChannelButton() {
    return ChannelTalkFlutterPlatform.instance.hideChannelButton();
  }

  static Future<bool?> showMessenger() {
    return ChannelTalkFlutterPlatform.instance.showMessenger();
  }

  static Future<bool?> hideMessenger() {
    return ChannelTalkFlutterPlatform.instance.hideMessenger();
  }

  static Future<bool?> openChat({
    String? chatId,
    String? message,
  }) {
    return ChannelTalkFlutterPlatform.instance.openChat(
      {
        'chatId': chatId,
        'message': message,
      },
    );
  }

  static Future<bool?> track({
    required String eventName,
    Map<String, dynamic>? properties,
  }) {
    Map<String, dynamic> data = {
      'eventName': eventName,
    };

    if (properties != null) {
      data['properties'] = properties;
    }

    return ChannelTalkFlutterPlatform.instance.track(data);
  }

  static Future<bool?> updateUser({
    String? name,
    String? email,
    String? mobileNumber,
    String? avatarUrl,
    bool? unsubscribeEmail,
    bool? unsubscribeTexting,
    List<String>? tags,
    Language? language,
  }) {
    return ChannelTalkFlutterPlatform.instance.updateUser(
      {
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (mobileNumber != null) 'mobileNumber': mobileNumber,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        if (unsubscribeEmail != null) 'unsubscribeEmail': unsubscribeEmail,
        if (unsubscribeTexting != null)
          'unsubscribeTexting': unsubscribeTexting,
        if (tags != null) 'tags': tags,
        if (language != null) 'language': language.value,
      },
    );
  }

  static Future<bool?> initPushToken({
    required String deviceToken,
  }) {
    return ChannelTalkFlutterPlatform.instance.initPushToken(deviceToken);
  }

  static Future<bool?> isChannelPushNotification({
    required Map<String, dynamic> content,
  }) {
    return ChannelTalkFlutterPlatform.instance
        .isChannelPushNotification(content);
  }

  static Future<bool?> receivePushNotification({
    required Map<String, dynamic> content,
  }) {
    return ChannelTalkFlutterPlatform.instance.receivePushNotification(content);
  }

  static Future<bool?> storePushNotification({
    required Map<String, dynamic> content,
  }) {
    return ChannelTalkFlutterPlatform.instance.storePushNotification(content);
  }

  static Future<bool?> hasStoredPushNotification() {
    return ChannelTalkFlutterPlatform.instance.hasStoredPushNotification();
  }

  static Future<bool?> openStoredPushNotification() {
    return ChannelTalkFlutterPlatform.instance.openStoredPushNotification();
  }

  static Future<bool?> isBooted() {
    return ChannelTalkFlutterPlatform.instance.isBooted();
  }

  static Future<bool?> setDebugMode({
    required bool flag,
  }) {
    return ChannelTalkFlutterPlatform.instance.setDebugMode(flag);
  }

  static Future<bool?> setPage({required page}) {
    return ChannelTalkFlutterPlatform.instance.setPage(page);
  }

  static Future<bool?> resetPage() {
    return ChannelTalkFlutterPlatform.instance.resetPage();
  }

  static Future<bool?> addTags({
    required List tags,
  }) {
    if (tags.length > 10) {
      return Future.value(false);
    }
    return ChannelTalkFlutterPlatform.instance.addTags(tags);
  }

  static Future<bool?> removeTags({
    required List tags,
  }) {
    return ChannelTalkFlutterPlatform.instance.removeTags(tags);
  }
}
