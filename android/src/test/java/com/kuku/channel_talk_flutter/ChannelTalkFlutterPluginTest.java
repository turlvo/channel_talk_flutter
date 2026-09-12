package com.kuku.channel_talk_flutter;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockStatic;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.verifyNoMoreInteractions;
import static org.mockito.Mockito.when;

import android.app.Activity;
import android.app.Application;
import android.util.Log;

import com.zoyi.channel.plugin.android.ChannelIO;
import com.zoyi.channel.plugin.android.open.callback.BootCallback;
import com.zoyi.channel.plugin.android.open.callback.UserUpdateCallback;
import com.zoyi.channel.plugin.android.open.config.BootConfig;
import com.zoyi.channel.plugin.android.open.enumerate.BootStatus;
import com.zoyi.channel.plugin.android.open.model.User;
import com.zoyi.channel.plugin.android.open.model.UserData;
import com.zoyi.channel.plugin.android.util.DeviceUtils;
import com.zoyi.okio.Buffer;

import java.io.IOException;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.MockedStatic;

import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.Result;

/** Verifies native bridge behavior without booting a real Channel Talk session. */
public class ChannelTalkFlutterPluginTest {
  private ChannelTalkFlutterPlugin plugin;
  private MockedStatic<ChannelIO> channelIo;
  private Result result;

  /** Isolates SDK calls so tests cannot contact Channel Talk. */
  @Before
  public void setUp() {
    plugin = new ChannelTalkFlutterPlugin();
    channelIo = mockStatic(ChannelIO.class);
    channelIo.when(ChannelIO::isBooted).thenReturn(true);
    result = mock(Result.class);
  }

  /** Releases the static mock after each test. */
  @After
  public void tearDown() {
    channelIo.close();
  }

  /** A profile-only update must not change language, tags, or marketing preferences. */
  @Test
  public void updateUserPreservesOmittedSettings() throws IOException {
    assertEquals("{\"profile\":{\"name\":\"Ada\"}}",
        updateRequest(Collections.singletonMap("name", "Ada")));
  }

  /** Dart's explicit null entries must have the same effect as omitted options. */
  @Test
  public void updateUserPreservesNullSettings() throws IOException {
    Map<String, Object> arguments = new HashMap<>();
    arguments.put("name", "Ada");
    arguments.put("language", null);
    arguments.put("tags", null);
    arguments.put("unsubscribeEmail", null);
    arguments.put("unsubscribeTexting", null);

    assertEquals("{\"profile\":{\"name\":\"Ada\"}}", updateRequest(arguments));
  }

  /** An explicit empty list remains a request to clear existing tags. */
  @Test
  public void updateUserAllowsClearingTags() throws IOException {
    assertEquals("{\"tags\":[]}",
        updateRequest(Collections.singletonMap("tags", Collections.emptyList())));
  }

  /** False must remain a supplied marketing preference instead of an omitted value. */
  @Test
  public void updateUserKeepsExplicitFalse() throws IOException {
    assertEquals("{\"unsubscribeEmail\":false}",
        updateRequest(Collections.singletonMap("unsubscribeEmail", false)));
  }

  /** The device option must defer to the SDK's device-language default during boot. */
  @Test
  public void bootWithDeviceLanguageDoesNotForceKorean() {
    Map<String, Object> arguments = new HashMap<>();
    arguments.put("pluginKey", "test");
    arguments.put("language", "device");
    plugin.boot(new MethodCall("boot", arguments), result);
    ArgumentCaptor<BootConfig> config = ArgumentCaptor.forClass(BootConfig.class);
    channelIo.verify(() -> ChannelIO.boot(config.capture(), any()));

    try (MockedStatic<DeviceUtils> deviceUtils = mockStatic(DeviceUtils.class)) {
      deviceUtils.when(DeviceUtils::getDeviceLanguage).thenReturn("en");
      assertEquals("en", config.getValue().getLanguage());
    }
  }

  /** Android has no device language enum for updates, so it must preserve existing language. */
  @Test
  public void updateUserWithDeviceLanguagePreservesExistingLanguage() throws IOException {
    Map<String, Object> arguments = new HashMap<>();
    arguments.put("name", "Ada");
    arguments.put("language", "device");

    assertEquals("{\"profile\":{\"name\":\"Ada\"}}", updateRequest(arguments));
  }

  /** SDK UI methods must use the replacement Activity after a configuration change. */
  @Test
  public void configurationChangeReplacesActivity() {
    Activity originalActivity = mock(Activity.class);
    plugin.onAttachedToActivity(activityBinding(originalActivity));
    plugin.onDetachedFromActivityForConfigChanges();
    plugin.showMessenger(new MethodCall("showMessenger", null), result);
    verify(result).error("UNAVAILABLE", "Activity is not attached", null);
    channelIo.verify(() -> ChannelIO.showMessenger(originalActivity), never());

    Activity replacementActivity = mock(Activity.class);
    plugin.onReattachedToActivityForConfigChanges(activityBinding(replacementActivity));
    plugin.showMessenger(new MethodCall("showMessenger", null), result);
    channelIo.verify(() -> ChannelIO.showMessenger(replacementActivity));
  }

  /** A detached plugin must reject UI calls instead of retaining a destroyed Activity. */
  @Test
  public void detachReleasesActivity() {
    plugin.onAttachedToActivity(activityBinding(mock(Activity.class)));
    plugin.onDetachedFromActivity();
    plugin.openChat(new MethodCall("openChat", null), result);

    verify(result).error("UNAVAILABLE", "Activity is not attached", null);
    channelIo.verify(() -> ChannelIO.openChat(any(), any(), any()), never());
  }

  /** Push token failures must reach Dart without a contradictory success response. */
  @Test
  public void initPushTokenReportsSdkFailure() {
    channelIo.when(() -> ChannelIO.initPushToken("test-token"))
        .thenThrow(new IllegalStateException("SDK unavailable"));
    plugin.initPushToken(new MethodCall("initPushToken",
        Collections.singletonMap("deviceToken", "test-token")), result);

    verify(result).error("ERROR", "Execution failed(initPushToken)", null);
    verify(result, never()).success(any());
  }

  /** Initialization failures must be observable before any later SDK call executes. */
  @Test
  public void initializationFailureIsReportedToDart() {
    Application application = mock(Application.class);
    FlutterPluginBinding binding = mock(FlutterPluginBinding.class);
    when(binding.getApplicationContext()).thenReturn(application);
    when(binding.getBinaryMessenger()).thenReturn(mock(BinaryMessenger.class));
    channelIo.when(() -> ChannelIO.initialize(application))
        .thenThrow(new IllegalStateException("SDK unavailable"));

    try (MockedStatic<Log> log = mockStatic(Log.class)) {
      plugin.onAttachedToEngine(binding);
      plugin.onMethodCall(new MethodCall("boot", Collections.singletonMap("pluginKey", "test")),
          result);

      verify(result).error("INITIALIZATION_FAILED", "Channel Talk initialization failed", null);
      channelIo.verify(() -> ChannelIO.boot(any(), any()), never());
      log.verify(() -> Log.e("ChannelTalkFlutter", "Channel Talk initialization failed"));
    }
  }

  /** 성공 콜백을 받은 뒤에만 이벤트 리스너를 등록하고 Dart 호출을 완료한다. */
  @Test
  public void bootWaitsForSuccessBeforeRegisteringListener() {
    BootCallback callback = pendingBootCallback();

    callback.onComplete(BootStatus.SUCCESS, mock(User.class));

    channelIo.verify(() -> ChannelIO.setListener(any(ChannelTalkFlutterHandler.class)));
    verify(result).success(true);
    verifyNoMoreInteractions(result);
  }

  /** 사용자가 함께 반환되더라도 실패 상태는 성공 응답이나 리스너 등록으로 이어지지 않는다. */
  @Test
  public void bootFailureDoesNotRegisterListener() {
    BootCallback callback = pendingBootCallback();

    callback.onComplete(BootStatus.NETWORK_TIMEOUT, mock(User.class));

    channelIo.verify(() -> ChannelIO.setListener(any()), never());
    verify(result).error("ERROR", "Execution failed(boot)", null);
    verifyNoMoreInteractions(result);
  }

  /** SDK가 성공 상태만 반환하고 사용자를 누락한 경우 세션 성공으로 처리하지 않는다. */
  @Test
  public void bootWithoutUserReportsFailure() {
    BootCallback callback = pendingBootCallback();

    callback.onComplete(BootStatus.SUCCESS, null);

    channelIo.verify(() -> ChannelIO.setListener(any()), never());
    verify(result).error("ERROR", "Execution failed(boot)", null);
    verifyNoMoreInteractions(result);
  }

  /** 상태 반환 부팅은 SDK의 네트워크 실패 원인을 유지하고 리스너를 등록하지 않는다. */
  @Test
  public void bootWithStatusPreservesNetworkTimeout() {
    BootCallback callback = pendingBootCallback("bootWithStatus");

    callback.onComplete(BootStatus.NETWORK_TIMEOUT, mock(User.class));

    channelIo.verify(() -> ChannelIO.setListener(any()), never());
    verify(result).success("networkTimeout");
    verifyNoMoreInteractions(result);
  }

  /** 상태 반환 부팅도 사용자와 성공 상태가 확인된 뒤 리스너와 결과를 한 번만 전달한다. */
  @Test
  public void bootWithStatusRegistersListenerAndCompletesSuccessExactlyOnce() {
    BootCallback callback = pendingBootCallback("bootWithStatus");

    callback.onComplete(BootStatus.SUCCESS, mock(User.class));

    channelIo.verify(() -> ChannelIO.setListener(any(ChannelTalkFlutterHandler.class)));
    verify(result).success("success");
    verifyNoMoreInteractions(result);
  }

  /** 부팅 전 사용자 갱신은 SDK에 도달하지 않고 한 번의 오류 응답으로 완료한다. */
  @Test
  public void updateUserBeforeBootIsRejected() {
    channelIo.when(ChannelIO::isBooted).thenReturn(false);

    plugin.onMethodCall(new MethodCall("updateUser", Collections.emptyMap()), result);

    channelIo.verify(() -> ChannelIO.updateUser(any(), any()), never());
    verify(result).error("UNAVAILABLE", "Channel Talk is not booted", null);
    verifyNoMoreInteractions(result);
  }

  /** 오류와 사용자가 함께 반환되어도 갱신 실패 뒤에 성공 응답을 중복 전송하지 않는다. */
  @Test
  public void updateUserReportsSdkErrorExactlyOnce() {
    UserUpdateCallback callback = pendingUserCallback("updateUser");

    callback.onComplete(new IllegalStateException("Test SDK failure"), mock(User.class));

    verify(result).error("ERROR", "Execution failed(updateUser)", null);
    verifyNoMoreInteractions(result);
  }

  /** 갱신 콜백의 오류와 사용자가 모두 없더라도 Dart Future를 false로 완료한다. */
  @Test
  public void updateUserWithoutUserCompletesFalse() {
    UserUpdateCallback callback = pendingUserCallback("updateUser");

    callback.onComplete(null, null);

    verify(result).success(false);
    verifyNoMoreInteractions(result);
  }

  /** 태그 추가 오류는 사용자가 함께 반환되어도 한 번의 오류 응답으로 완료한다. */
  @Test
  public void addTagsReportsSdkErrorExactlyOnce() {
    UserUpdateCallback callback = pendingUserCallback("addTags");

    callback.onComplete(new IllegalStateException("Test SDK failure"), mock(User.class));

    verify(result).error("ERROR", "Execution failed(addTags)", null);
    verifyNoMoreInteractions(result);
  }

  /** 태그 추가 콜백의 빈 결과로 Dart Future가 미완료 상태에 남지 않아야 한다. */
  @Test
  public void addTagsWithoutUserCompletesFalse() {
    UserUpdateCallback callback = pendingUserCallback("addTags");

    callback.onComplete(null, null);

    verify(result).success(false);
    verifyNoMoreInteractions(result);
  }

  /** 태그 삭제 오류는 사용자가 함께 반환되어도 한 번의 오류 응답으로 완료한다. */
  @Test
  public void removeTagsReportsSdkErrorExactlyOnce() {
    UserUpdateCallback callback = pendingUserCallback("removeTags");

    callback.onComplete(new IllegalStateException("Test SDK failure"), mock(User.class));

    verify(result).error("ERROR", "Execution failed(removeTags)", null);
    verifyNoMoreInteractions(result);
  }

  /** 태그 삭제 콜백의 빈 결과로 Dart Future가 미완료 상태에 남지 않아야 한다. */
  @Test
  public void removeTagsWithoutUserCompletesFalse() {
    UserUpdateCallback callback = pendingUserCallback("removeTags");

    callback.onComplete(null, null);

    verify(result).success(false);
    verifyNoMoreInteractions(result);
  }

  /** 기존 boolean 부팅 테스트가 공유 SDK 콜백 준비 경로를 사용하도록 한다. */
  private BootCallback pendingBootCallback() {
    return pendingBootCallback("boot");
  }

  /** 실제 엔진 연결 경로로 리스너를 준비하고 SDK 콜백 전 조기 완료를 검출한다. */
  private BootCallback pendingBootCallback(String method) {
    FlutterPluginBinding binding = mock(FlutterPluginBinding.class);
    when(binding.getApplicationContext()).thenReturn(mock(Application.class));
    when(binding.getBinaryMessenger()).thenReturn(mock(BinaryMessenger.class));
    plugin.onAttachedToEngine(binding);
    plugin.onMethodCall(
        new MethodCall(method, Collections.singletonMap("pluginKey", "test-plugin-key")), result);

    ArgumentCaptor<BootCallback> callback = ArgumentCaptor.forClass(BootCallback.class);
    channelIo.verify(() -> ChannelIO.boot(any(), callback.capture()));
    channelIo.verify(() -> ChannelIO.setListener(any()), never());
    verifyNoInteractions(result);
    return callback.getValue();
  }

  /** SDK 응답을 보류해 사용자·태그 갱신이 실제 콜백까지 Dart 결과를 기다리는지 확인한다. */
  private UserUpdateCallback pendingUserCallback(String method) {
    Map<String, Object> arguments = method.equals("updateUser")
        ? Collections.emptyMap()
        : Collections.singletonMap("tags", Collections.singletonList("test-tag"));
    plugin.onMethodCall(new MethodCall(method, arguments), result);

    ArgumentCaptor<UserUpdateCallback> callback = ArgumentCaptor.forClass(UserUpdateCallback.class);
    switch (method) {
      case "updateUser":
        channelIo.verify(() -> ChannelIO.updateUser(any(), callback.capture()));
        break;
      case "addTags":
        channelIo.verify(() -> ChannelIO.addTags(any(), callback.capture()));
        break;
      case "removeTags":
        channelIo.verify(() -> ChannelIO.removeTags(any(), callback.capture()));
        break;
      default:
        throw new IllegalArgumentException("Unsupported test method: " + method);
    }
    verifyNoInteractions(result);
    return callback.getValue();
  }

  /** Captures the actual SDK payload to detect unintended updates to persisted user data. */
  private String updateRequest(Map<String, Object> arguments) throws IOException {
    plugin.updateUser(new MethodCall("updateUser", arguments), result);
    ArgumentCaptor<UserData> userData = ArgumentCaptor.forClass(UserData.class);
    channelIo.verify(() -> ChannelIO.updateUser(userData.capture(), any()));
    Buffer buffer = new Buffer();
    userData.getValue().getRequestBody().writeTo(buffer);
    return buffer.readUtf8();
  }

  /** Creates a binding that exposes a particular Activity. */
  private ActivityPluginBinding activityBinding(Activity activity) {
    ActivityPluginBinding binding = mock(ActivityPluginBinding.class);
    when(binding.getActivity()).thenReturn(activity);
    return binding;
  }
}
