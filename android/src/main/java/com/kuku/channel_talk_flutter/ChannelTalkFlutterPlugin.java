package com.kuku.channel_talk_flutter;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.os.Handler;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.zoyi.channel.plugin.android.ChannelIO;
import com.zoyi.channel.plugin.android.open.callback.BootCallback;
import com.zoyi.channel.plugin.android.open.config.BootConfig;
import com.zoyi.channel.plugin.android.open.enumerate.BootStatus;
import com.zoyi.channel.plugin.android.open.enumerate.ChannelButtonPosition;
import com.zoyi.channel.plugin.android.open.model.Profile;
import com.zoyi.channel.plugin.android.open.model.User;
import com.zoyi.channel.plugin.android.open.model.UserData;
import com.zoyi.channel.plugin.android.open.option.ChannelButtonOption;
import com.zoyi.channel.plugin.android.open.option.Language;
import io.channel.plugin.android.open.model.Appearance;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ScheduledThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** ChannelTalkFlutterPlugin */
public class ChannelTalkFlutterPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
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

  public static void registerWith(Application application) {
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "channel_talk_flutter");
    channel.setMethodCallHandler(this);

    context = flutterPluginBinding.getApplicationContext();
    channelTalkEventHandler = new ChannelTalkFlutterHandler(channel);

    try {
      ChannelIO.initialize((Application) context);
    } catch (Exception e) {
    }
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull final Result result) {
    if (call.method.equals("boot")) {
      boot(call, result);
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
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  @Override
  public void onAttachedToActivity(ActivityPluginBinding activityPluginBinding) {
    activity = activityPluginBinding.getActivity();

    // if (ChannelIO.hasStoredPushNotification(activity)) {
    // Handler delayHandler = new Handler();
    // delayHandler.postDelayed(new Runnable() {
    // @Override
    // public void run() {
    // ChannelIO.openStoredPushNotification(activity);
    // }
    // }, 5000);
    // }
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    // destroyed to change configuration.
    // This call will be followed by onReattachedToActivityForConfigChanges().
  }

  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding activityPluginBinding) {
    // after a configuration change.

  }

  @Override
  public void onDetachedFromActivity() {
    // Clean up references.
  }

  public void boot(@NonNull MethodCall call, @NonNull final Result result) {
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

    ChannelButtonOption buttonOption = new ChannelButtonOption(
        ChannelButtonPosition.LEFT,
        16,
        23);

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
          result.success(true);
        } else {
          result.error("ERROR", "Execution failed(boot)", null);
        }
      }
    });
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
    if (!ChannelIO.isBooted()) {
      result.error("UNAVAILABLE", "Channel Talk is not booted", null);
    }

    ChannelIO.showChannelButton();
    result.success(true);
  }

  public void hideChannelButton(@NonNull MethodCall call, @NonNull final Result result) {
    if (!ChannelIO.isBooted()) {
      result.error("UNAVAILABLE", "Channel Talk is not booted", null);
    }

    ChannelIO.hideChannelButton();
    result.success(true);
  }

  public void showMessenger(@NonNull MethodCall call, @NonNull final Result result) {
    if (!ChannelIO.isBooted()) {
      result.error("UNAVAILABLE", "Channel Talk is not booted", null);
    }

    ChannelIO.showMessenger(this.activity);
    result.success(true);
  }

  public void hideMessenger(@NonNull MethodCall call, @NonNull final Result result) {
    if (!ChannelIO.isBooted()) {
      result.error("UNAVAILABLE", "Channel Talk is not booted", null);
    }

    ChannelIO.hideMessenger();
    result.success(true);
  }

  public void openChat(@NonNull MethodCall call, @NonNull final Result result) {
    if (!ChannelIO.isBooted()) {
      result.error("UNAVAILABLE", "Channel Talk is not booted", null);
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

  public void updateUser(@NonNull MethodCall call, @NonNull final Result result) {
    if (!ChannelIO.isBooted()) {
      result.error("UNAVAILABLE", "Channel Talk is not booted", null);
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

    Language enumLanguage = Language.KOREAN;
    if (call.argument("language") != null) {
      enumLanguage = getLanguage(call.argument("language"));
    }

    List<String> tags = new ArrayList<String>();
    if (call.argument("tags") != null) {
      tags = call.argument("tags");
    }

    UserData userData = new UserData.Builder()
        .setLanguage(enumLanguage)
        .setProfileMap(profileMap)
        .setTags(tags)
        .setUnsubscribeEmail(call.argument(
            "unsubscribeEmail"))
        .setUnsubscribeTexting(call.argument(
            "unsubscribeTexting"))

        .build();

    ChannelIO.updateUser(userData, (e, user) -> {
      if (e == null && user != null) {
        result.success(true);
      } else if (e != null) {
        result.error("ERROR", "Execution failed(updateUser)", null);
      }
    });
  }

  public void initPushToken(@NonNull MethodCall call, @NonNull final Result result) {
    String deviceToken = call.argument("deviceToken");
    if (deviceToken == null || deviceToken.isEmpty()) {
      result.error("UNAVAILABLE", "Missing argument(deviceToken)", null);
      return;
    }

    try {
      ChannelIO.initPushToken(deviceToken);
    } catch (Exception e) {
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
    Boolean res = ChannelIO.hasStoredPushNotification(this.activity);
    result.success(res);
  }

  public void openStoredPushNotification(@NonNull MethodCall call, @NonNull final Result result) {
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
    if (page == null) {
      result.error("UNAVAILABLE", "Missing argument(page)", null);
      return;
    }
    ChannelIO.setPage(page);
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
      if (user != null) {
        result.success(true);
      } else if (e != null) {
        result.error("ERROR", "Execution failed(addTags)", null);
      }
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
      if (user != null) {
        result.success(true);
      } else if (e != null) {
        result.error("ERROR", "Execution failed(removeTags)", null);
      }
    });
  }

  public void openWorkflow(@NonNull MethodCall call, @NonNull final Result result) {
    if (!ChannelIO.isBooted()) {
      result.error("UNAVAILABLE", "Channel Talk is not booted", null);
    }

    String workflowId = call.argument("workflowId");

    ChannelIO.openWorkflow(this.activity, workflowId);
    result.success(true);
  }

  public void setAppearance(@NonNull MethodCall call, @NonNull final Result result) {
    if (!ChannelIO.isBooted()) {
      result.error("UNAVAILABLE", "Channel Talk is not booted", null);
    }

    ChannelIO.setAppearance(getAppearance(call.argument("appearance")));
    result.success(true);
  }

  public void hidePopup(@NonNull MethodCall call, @NonNull final Result result) {
    ChannelIO.hidePopup();
    result.success(true);
  }

  private Language getLanguage(String lang) {
    switch (lang) {
      case "en":
        return Language.ENGLISH;
      case "ko":
        return Language.KOREAN;
      case "ja":
        return Language.JAPANESE;
      default:
        return Language.KOREAN;
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
