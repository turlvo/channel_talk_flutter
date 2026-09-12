package com.kuku.channel_talk_flutter;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.zoyi.channel.plugin.android.ChannelIO;
import com.zoyi.channel.plugin.android.open.callback.BootCallback;
import com.zoyi.channel.plugin.android.open.config.BootConfig;
import com.zoyi.channel.plugin.android.open.enumerate.BootStatus;
import com.zoyi.channel.plugin.android.open.model.Profile;
import com.zoyi.channel.plugin.android.open.model.User;
import com.zoyi.channel.plugin.android.open.model.UserData;
import com.zoyi.channel.plugin.android.open.option.Language;
import io.channel.plugin.android.open.model.Appearance;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** ChannelTalkFlutterPlugin */
public class ChannelTalkFlutterPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
  private static final String LOG_TAG = "ChannelTalkFlutter";
  /// The MethodChannel that will the communication between Flutter and native
  /// Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine
  /// and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private static Context context;
  private Activity activity;
  private ChannelTalkFlutterHandler channelTalkEventHandler;
  private boolean initializationFailed;

  public static void registerWith(Application application) {
  }

  /** Initializes the SDK and retains failures for the first call from Dart. */
  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "channel_talk_flutter");
    channel.setMethodCallHandler(this);

    context = flutterPluginBinding.getApplicationContext();
    channelTalkEventHandler = new ChannelTalkFlutterHandler(channel);

    initializationFailed = false;
    try {
      ChannelIO.initialize((Application) context);
    } catch (Exception e) {
      initializationFailed = true;
      Log.e(LOG_TAG, "Channel Talk initialization failed");
    }
  }

  /** Routes Dart calls, reporting initialization failures before invoking the SDK. */
  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull final Result result) {
    if (initializationFailed) {
      result.error("INITIALIZATION_FAILED", "Channel Talk initialization failed", null);
      return;
    }

    if (call.method.equals("boot")) {
      boot(call, result);
    } else if (call.method.equals("bootWithStatus")) {
      bootWithStatus(call, result);
    } else if (call.method.equals("sleep")) {
      sleep(call, result);
    } else if (call.method.equals("shutdown")) {
      shutdown(call, result);
    } else if (call.method.equals("showChannelButton")) {
      showChannelButton(call, result);
    } else if (call.method.equals("hideChannelButton")) {
      hideChannelButton(call, result);
    } else if (call.method.equals("showMessenger")) {
      showMessenger(call, result);
    } else if (call.method.equals("hideMessenger")) {
      hideMessenger(call, result);
    } else if (call.method.equals("openChat")) {
      openChat(call, result);
    } else if (call.method.equals("track")) {
      track(call, result);
    } else if (call.method.equals("updateUser")) {
      updateUser(call, result);
    } else if (call.method.equals("initPushToken")) {
      initPushToken(call, result);
    } else if (call.method.equals("isChannelPushNotification")) {
      isChannelPushNotification(call, result);
    } else if (call.method.equals("receivePushNotification")) {
      receivePushNotification(call, result);
    } else if (call.method.equals("storePushNotification")) {
      result.error("UNAVAILABLE", "There is no API in Android", null);
    } else if (call.method.equals("hasStoredPushNotification")) {
      hasStoredPushNotification(call, result);
    } else if (call.method.equals("openStoredPushNotification")) {
      openStoredPushNotification(call, result);
    } else if (call.method.equals("isBooted")) {
      isBooted(call, result);
    } else if (call.method.equals("setDebugMode")) {
      setDebugMode(call, result);
    } else if (call.method.equals("setPage")) {
      setPage(call, result);
    } else if (call.method.equals("resetPage")) {
      resetPage(call, result);
    } else if (call.method.equals("addTags")) {
      addTags(call, result);
    } else if (call.method.equals("removeTags")) {
      removeTags(call, result);
    } else if (call.method.equals("openWorkflow")) {
      openWorkflow(call, result);
    } else if (call.method.equals("setAppearance")) {
      setAppearance(call, result);
    } else if (call.method.equals("hidePopup")) {
      hidePopup(call, result);
    } else if (call.method.equals("setPreventDefaultUrlClick")) {
      setPreventDefaultUrlClick(call, result);
    } else {
      result.notImplemented();
    }
  }

  /** Stops accepting calls and releases the Activity when the engine detaches. */
  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    activity = null;
  }

  /** Retains the currently attached Activity for SDK methods that display UI. */
  @Override
  public void onAttachedToActivity(ActivityPluginBinding activityPluginBinding) {
    activity = activityPluginBinding.getActivity();
  }

  /** Releases the old Activity before Android recreates it after a configuration change. */
  @Override
  public void onDetachedFromActivityForConfigChanges() {
    activity = null;
  }

  /** Replaces the Activity reference after a configuration change. */
  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding activityPluginBinding) {
    onAttachedToActivity(activityPluginBinding);
  }

  /** Releases the Activity when the plugin is no longer attached to it. */
  @Override
  public void onDetachedFromActivity() {
    activity = null;
  }

  private interface OnBootStatus {
    void onStatus(String status);
  }

  public void boot(@NonNull MethodCall call, @NonNull final Result result) {
    performBoot(call, result, status -> {
      if ("success".equals(status)) {
        result.success(true);
      } else {
        result.error("ERROR", "Execution failed(boot)", null);
      }
    });
  }

  public void bootWithStatus(@NonNull MethodCall call, @NonNull final Result result) {
    performBoot(call, result, status -> result.success(status));
  }

  private void performBoot(@NonNull MethodCall call, @NonNull final Result result,
      @NonNull final OnBootStatus onStatus) {
    String pluginKey = call.argument("pluginKey");
    if (pluginKey == null || pluginKey.isEmpty()) {
      result.error("UNAVAILABLE", "Missing argument(pluginKey)", null);
      return;
    }

    Profile profile = Profile.create();
    if (call.argument("email") != null) {
      profile.setEmail(call.argument("email"));
    }
    if (call.argument("name") != null) {
      profile.setName(call.argument("name"));
    }
    if (call.argument("mobileNumber") != null) {
      profile.setMobileNumber(call.argument("mobileNumber"));
    }
    if (call.argument("avatarUrl") != null) {
      profile.setAvatarUrl(call.argument("avatarUrl"));
    }

    BootConfig bootConfig = BootConfig.create(pluginKey)
        .setProfile(profile);
    if (call.argument("memberHash") != null) {
      bootConfig.setMemberHash(call.argument("memberHash"));
    }
    if (call.argument("memberId") != null) {
      bootConfig.setMemberId(call.argument("memberId"));
    }
    if (call.argument("language") != null) {
      bootConfig.setLanguage(getLanguage(call.argument("language")));
    }
    if (call.argument("unsubscribeEmail") != null) {
      bootConfig.setUnsubscribeEmail(call.argument("unsubscribeEmail"));
    }
    if (call.argument("unsubscribeTexting") != null) {
      bootConfig.setUnsubscribeTexting(call.argument("unsubscribeTexting"));
    }
    if (call.argument("trackDefaultEvent") != null) {
      bootConfig.setTrackDefaultEvent(call.argument("trackDefaultEvent"));
    }
    if (call.argument("hidePopup") != null) {
      bootConfig.setHidePopup(call.argument("hidePopup"));
    }
    if (call.argument("appearance") != null) {
      bootConfig.setAppearance(getAppearance(call.argument("appearance")));
    }

    ChannelIO.boot(bootConfig, new BootCallback() {
      @Override
      public void onComplete(BootStatus bootStatus, @Nullable User user) {
        if (bootStatus == BootStatus.SUCCESS && user != null) {
          ChannelIO.setListener(channelTalkEventHandler);
        }
        onStatus.onStatus(bootStatusString(bootStatus, user));
      }
    });
  }

  private String bootStatusString(BootStatus status, @Nullable User user) {
    if (status == BootStatus.SUCCESS) {
      return user != null ? "success" : "unknown";
    } else if (status == BootStatus.NOT_INITIALIZED) {
      return "notInitialized";
    } else if (status == BootStatus.NETWORK_TIMEOUT) {
      return "networkTimeout";
    } else if (status == BootStatus.NOT_AVAILABLE_VERSION) {
      return "notAvailableVersion";
    } else if (status == BootStatus.SERVICE_UNDER_CONSTRUCTION) {
      return "serviceUnderConstruction";
    } else if (status == BootStatus.REQUIRE_PAYMENT) {
      return "requirePayment";
    } else if (status == BootStatus.ACCESS_DENIED) {
      return "accessDenied";
    } else {
      return "unknown";
    }
  }

  public void sleep(@NonNull MethodCall call, @NonNull final Result result) {
    ChannelIO.sleep();
    result.success(true);
  }

  public void shutdown(@NonNull MethodCall call, @NonNull final Result result) {
    ChannelIO.shutdown();
    result.success(true);
  }

  public void showChannelButton(@NonNull MethodCall call, @NonNull final Result result) {
    ChannelIO.showChannelButton();
    result.success(true);
  }

  public void hideChannelButton(@NonNull MethodCall call, @NonNull final Result result) {
    ChannelIO.hideChannelButton();
    result.success(true);
  }

  public void showMessenger(@NonNull MethodCall call, @NonNull final Result result) {
    if (!ensureActivity(result)) {
      return;
    }

    ChannelIO.showMessenger(this.activity);
    result.success(true);
  }

  public void hideMessenger(@NonNull MethodCall call, @NonNull final Result result) {
    ChannelIO.hideMessenger();
    result.success(true);
  }

  public void openChat(@NonNull MethodCall call, @NonNull final Result result) {
    if (!ensureActivity(result)) {
      return;
    }

    String chatId = call.argument("chatId");
    String message = call.argument("message");

    ChannelIO.openChat(this.activity, chatId, message);
    result.success(true);
  }

  public void track(@NonNull MethodCall call, @NonNull final Result result) {
    String eventName = call.argument("eventName");
    if (eventName == null || eventName.isEmpty()) {
      result.error("UNAVAILABLE", "Missing argument(EventName)", null);
      return;
    }
    Map<String, Object> properties = call.argument("properties");

    ChannelIO.track(eventName, properties);
    result.success(true);
  }

  /** Updates only supplied user fields so omitted settings keep their existing values. */
  public void updateUser(@NonNull MethodCall call, @NonNull final Result result) {
    if (!ensureBooted(result)) {
      return;
    }

    Map<String, Object> profileMap = new HashMap<>();
    if (call.argument("name") != null) {
      profileMap.put("name", call.argument("name"));
    }
    if (call.argument("mobileNumber") != null) {
      profileMap.put("mobileNumber", call.argument("mobileNumber"));
    }
    if (call.argument("email") != null) {
      profileMap.put("email", call.argument("email"));
    }
    if (call.argument("avatarUrl") != null) {
      profileMap.put("avatarUrl", call.argument("avatarUrl"));
    }
    if (call.argument("customAttributes") != null) {
      Map<String, Object> customAttributes = call.argument("customAttributes");
      for (Map.Entry<String, Object> entry : customAttributes.entrySet()) {
        profileMap.put(entry.getKey(), entry.getValue());
      }
    }

    UserData.Builder userDataBuilder = new UserData.Builder();
    // Omitted fields must stay unset so a partial update preserves existing user settings.
    if (!profileMap.isEmpty()) {
      userDataBuilder.setProfileMap(profileMap);
    }
    Language language = getLanguage(call.argument("language"));
    if (language != null) {
      userDataBuilder.setLanguage(language);
    }
    if (call.argument("tags") != null) {
      userDataBuilder.setTags(call.argument("tags"));
    }
    if (call.argument("unsubscribeEmail") != null) {
      userDataBuilder.setUnsubscribeEmail(call.argument("unsubscribeEmail"));
    }
    if (call.argument("unsubscribeTexting") != null) {
      userDataBuilder.setUnsubscribeTexting(call.argument("unsubscribeTexting"));
    }

    UserData userData = userDataBuilder.build();

    ChannelIO.updateUser(userData, (e, user) -> {
      if (e != null) {
        result.error("ERROR", "Execution failed(updateUser)", null);
        return;
      }

      result.success(user != null);
    });
  }

  /** Registers a push token and reports SDK failures to Dart. */
  public void initPushToken(@NonNull MethodCall call, @NonNull final Result result) {
    String deviceToken = call.argument("deviceToken");
    if (deviceToken == null || deviceToken.isEmpty()) {
      result.error("UNAVAILABLE", "Missing argument(deviceToken)", null);
      return;
    }

    try {
      ChannelIO.initPushToken(deviceToken);
    } catch (Exception e) {
      result.error("ERROR", "Execution failed(initPushToken)", null);
      return;
    }
    result.success(true);
  }

  public void isChannelPushNotification(@NonNull MethodCall call, @NonNull final Result result) {
    Map<String, String> content = call.argument("content");
    if (content == null || content.isEmpty()) {
      result.error("UNAVAILABLE", "Missing argument(content)", null);
      return;
    }
    Boolean res = ChannelIO.isChannelPushNotification(content);
    result.success(res);
  }

  public void receivePushNotification(@NonNull MethodCall call, @NonNull final Result result) {
    Map<String, String> content = call.argument("content");
    if (content == null || content.isEmpty()) {
      result.error("UNAVAILABLE", "Missing argument(content)", null);
      return;
    }
    ChannelIO.receivePushNotification(context, content);
    result.success(true);
  }

  public void hasStoredPushNotification(@NonNull MethodCall call, @NonNull final Result result) {
    if (!ensureActivity(result)) {
      return;
    }

    Boolean res = ChannelIO.hasStoredPushNotification(this.activity);
    result.success(res);
  }

  public void openStoredPushNotification(@NonNull MethodCall call, @NonNull final Result result) {
    if (!ensureActivity(result)) {
      return;
    }

    ChannelIO.openStoredPushNotification(this.activity);
    result.success(true);
  }

  public void isBooted(@NonNull MethodCall call, @NonNull final Result result) {
    result.success(ChannelIO.isBooted());
  }

  public void setDebugMode(@NonNull MethodCall call, @NonNull final Result result) {
    Boolean flag = call.argument("flag");
    if (flag == null) {
      result.error("UNAVAILABLE", "Missing argument(flag)", null);
      return;
    }
    ChannelIO.setDebugMode(flag);
    result.success(true);
  }

  public void setPage(@NonNull MethodCall call, @NonNull final Result result) {
    String page = call.argument("page");
    Map<?, ?> rawProfile = call.argument("profile");
    Map<String, Object> profile = null;

    if (rawProfile != null) {
      profile = new HashMap<>();

      for (Map.Entry<?, ?> entry : rawProfile.entrySet()) {
        if (entry.getKey() instanceof String) {
          profile.put((String) entry.getKey(), entry.getValue());
        }
      }
    }

    ChannelIO.setPage(page, profile);
    result.success(true);
  }

  public void resetPage(@NonNull MethodCall call, @NonNull final Result result) {
    ChannelIO.resetPage();
    result.success(true);
  }

  public void addTags(@NonNull MethodCall call, @NonNull final Result result) {
    List<String> tags = new ArrayList<String>();
    if (call.argument("tags") != null) {
      tags = call.argument("tags");
    }
    if (tags == null || tags.isEmpty()) {
      result.error("UNAVAILABLE", "Missing argument(tags)", null);
      return;
    }
    ChannelIO.addTags(tags, (e, user) -> {
      if (e != null) {
        result.error("ERROR", "Execution failed(addTags)", null);
        return;
      }

      result.success(user != null);
    });
  }

  public void removeTags(@NonNull MethodCall call, @NonNull final Result result) {
    List<String> tags = new ArrayList<String>();
    if (call.argument("tags") != null) {
      tags = call.argument("tags");
    }
    if (tags == null || tags.isEmpty()) {
      result.error("UNAVAILABLE", "Missing argument(tags)", null);
      return;
    }
    ChannelIO.removeTags(tags, (e, user) -> {
      if (e != null) {
        result.error("ERROR", "Execution failed(removeTags)", null);
        return;
      }

      result.success(user != null);
    });
  }

  public void openWorkflow(@NonNull MethodCall call, @NonNull final Result result) {
    if (!ensureActivity(result)) {
      return;
    }

    String workflowId = call.argument("workflowId");

    ChannelIO.openWorkflow(this.activity, workflowId);
    result.success(true);
  }

  public void setAppearance(@NonNull MethodCall call, @NonNull final Result result) {
    if (!ensureBooted(result)) {
      return;
    }

    ChannelIO.setAppearance(getAppearance(call.argument("appearance")));
    result.success(true);
  }

  public void hidePopup(@NonNull MethodCall call, @NonNull final Result result) {
    ChannelIO.hidePopup();
    result.success(true);
  }
  
  public void setPreventDefaultUrlClick(@NonNull MethodCall call, @NonNull final Result result) {
    Boolean prevent = call.argument("prevent");
    if (prevent == null) {
      result.error("UNAVAILABLE", "Missing argument(prevent)", null);
      return;
    }
    
    channelTalkEventHandler.setPreventDefaultUrlClick(prevent);
    result.success(true);
  }

  private boolean ensureActivity(@NonNull Result result) {
    if (activity == null) {
      result.error("UNAVAILABLE", "Activity is not attached", null);
      return false;
    }

    return true;
  }

  private boolean ensureBooted(@NonNull Result result) {
    if (!ChannelIO.isBooted()) {
      result.error("UNAVAILABLE", "Channel Talk is not booted", null);
      return false;
    }

    return true;
  }

  /** Leaves device-language handling to the SDK instead of forcing Korean. */
  @Nullable
  private Language getLanguage(@Nullable String lang) {
    if (lang == null) {
      return null;
    }

    switch (lang) {
      case "en":
        return Language.ENGLISH;
      case "ko":
        return Language.KOREAN;
      case "ja":
        return Language.JAPANESE;
      default:
        return null;
    }
  }

  private Appearance getAppearance(String appearance) {
    switch (appearance) {
      case "system":
        return Appearance.SYSTEM;
      case "light":
        return Appearance.LIGHT;
      case "dark":
        return Appearance.DARK;
      default:
        return Appearance.SYSTEM;
    }
  }

}
