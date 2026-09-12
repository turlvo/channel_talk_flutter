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

/// The outcome of [ChannelTalk.bootWithStatus], mirroring the native ChannelIO
/// `BootStatus`.
///
/// [ChannelTalk.boot] collapses this to `success`; [ChannelTalk.bootWithStatus]
/// preserves the reason so callers can tell transient failures (e.g.
/// [networkTimeout], retryable) from permanent ones (e.g. [accessDenied]).
enum ChannelTalkBootStatus {
  success('success'),
  notInitialized('notInitialized'),
  networkTimeout('networkTimeout'),
  notAvailableVersion('notAvailableVersion'),
  serviceUnderConstruction('serviceUnderConstruction'),
  requirePayment('requirePayment'),
  accessDenied('accessDenied'),
  unknown('unknown');

  const ChannelTalkBootStatus(this.value);

  final String value;

  /// Maps a native status string to a [ChannelTalkBootStatus], defaulting to
  /// [unknown] for null or any unrecognized value.
  static ChannelTalkBootStatus fromNative(String? value) {
    for (final status in ChannelTalkBootStatus.values) {
      if (status.value == value) {
        return status;
      }
    }
    return ChannelTalkBootStatus.unknown;
  }
}

class ChannelTalk {
  static void setListener(ChannelTalkDelegate delegate) {
    return ChannelTalkFlutterPlatform.instance.setListener(delegate);
  }

  // Removes the callback listener if it exists
  static void removeListener() {
    return ChannelTalkFlutterPlatform.instance.removeListener();
  }

  static Map<String, dynamic> _buildBootConfig({
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
    return {
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
    return ChannelTalkFlutterPlatform.instance.boot(
      _buildBootConfig(
        pluginKey: pluginKey,
        memberId: memberId,
        memberHash: memberHash,
        email: email,
        name: name,
        mobileNumber: mobileNumber,
        avatarUrl: avatarUrl,
        language: language,
        unsubscribeEmail: unsubscribeEmail,
        unsubscribeTexting: unsubscribeTexting,
        trackDefaultEvent: trackDefaultEvent,
        hidePopup: hidePopup,
        appearance: appearance,
      ),
    );
  }

  /// Boots ChannelTalk like [boot], but resolves to the detailed
  /// [ChannelTalkBootStatus] instead of collapsing it to a bool.
  ///
  /// [boot] returns `true` only for [ChannelTalkBootStatus.success]; use this
  /// when you need to distinguish a transient failure (e.g.
  /// [ChannelTalkBootStatus.networkTimeout], retryable) from a permanent one
  /// (e.g. [ChannelTalkBootStatus.accessDenied]). On web, which does not surface
  /// a boot status, a completed boot resolves to [ChannelTalkBootStatus.success].
  static Future<ChannelTalkBootStatus> bootWithStatus({
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
    return ChannelTalkFlutterPlatform.instance.bootWithStatus(
      _buildBootConfig(
        pluginKey: pluginKey,
        memberId: memberId,
        memberHash: memberHash,
        email: email,
        name: name,
        mobileNumber: mobileNumber,
        avatarUrl: avatarUrl,
        language: language,
        unsubscribeEmail: unsubscribeEmail,
        unsubscribeTexting: unsubscribeTexting,
        trackDefaultEvent: trackDefaultEvent,
        hidePopup: hidePopup,
        appearance: appearance,
      ),
    );
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
      chatId: chatId,
      message: message,
    );
  }

  static Future<bool?> track({
    required String eventName,
    Map<String, dynamic>? properties,
  }) {
    return ChannelTalkFlutterPlatform.instance.track(
      eventName: eventName,
      properties: properties,
    );
  }

  static Future<bool?> updateUser(
      {String? name,
      String? email,
      String? mobileNumber,
      String? avatarUrl,
      bool? unsubscribeEmail,
      bool? unsubscribeTexting,
      List<String>? tags,
      Language? language,
      Map<String, dynamic>? customAttributes}) {
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
        if (customAttributes != null) 'customAttributes': customAttributes,
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

  static Future<bool?> setPage({required page, Map<String, dynamic>? profile}) {
    return ChannelTalkFlutterPlatform.instance.setPage(page, profile);
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

  static Future<bool?> openWorkflow({
    String? workflowId,
  }) {
    return ChannelTalkFlutterPlatform.instance.openWorkflow(
      workflowId: workflowId,
    );
  }

  static Future<bool?> setAppearance({
    required Appearance appearance,
  }) {
    return ChannelTalkFlutterPlatform.instance.setAppearance(appearance);
  }

  static Future<bool?> hidePopup() {
    return ChannelTalkFlutterPlatform.instance.hidePopup();
  }

  static Future<bool?> setPreventDefaultUrlClick({
    required bool prevent,
  }) {
    return ChannelTalkFlutterPlatform.instance
        .setPreventDefaultUrlClick(prevent);
  }
}
