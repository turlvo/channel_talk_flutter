package com.kuku.channel_talk_flutter;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.clearInvocations;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockStatic;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoMoreInteractions;

import com.zoyi.channel.plugin.android.ChannelIO;
import com.zoyi.channel.plugin.android.open.config.BootConfig;
import com.zoyi.channel.plugin.android.open.enumerate.ChannelButtonPosition;
import com.zoyi.channel.plugin.android.open.model.UserData;
import com.zoyi.channel.plugin.android.open.option.ChannelButtonOption;
import com.zoyi.okio.Buffer;

import java.io.IOException;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.MockedStatic;

import io.channel.com.google.gson.JsonObject;
import io.channel.com.google.gson.JsonParser;
import io.channel.plugin.android.enumerate.BubblePosition;
import io.channel.plugin.android.open.enumerate.ChannelButtonIcon;
import io.channel.plugin.android.open.option.BubbleOption;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.Result;

/** 실제 SDK 설정 및 요청 객체로 추가 옵션의 데이터 손실과 기본값 변경을 검출한다. */
public class ChannelTalkFlutterOptionsTest {
  private ChannelTalkFlutterPlugin plugin;
  private MockedStatic<ChannelIO> channelIo;
  private Result result;

  /** 서버 호출 없이 실제 SDK 설정 객체를 검사할 수 있도록 외부 호출만 격리한다. */
  @Before
  public void setUp() {
    plugin = new ChannelTalkFlutterPlugin();
    channelIo = mockStatic(ChannelIO.class);
    channelIo.when(ChannelIO::isBooted).thenReturn(true);
    result = mock(Result.class);
  }

  /** 다음 테스트에 static mock이 남지 않게 해제한다. */
  @After
  public void tearDown() {
    channelIo.close();
  }

  /** 두 부팅 API 모두 사용자 지정 값이 기본 필드를 덮고 null과 복합 값을 보존한다. */
  @Test
  public void bootProfilesMergeCustomAttributesWithoutLosingNulls() {
    Map<String, Object> custom = new HashMap<>();
    custom.put("name", "Custom name");
    custom.put("email", null);
    custom.put("vip", true);
    custom.put("plan", Collections.singletonMap("tier", "pro"));
    Map<String, Object> arguments = new HashMap<>();
    arguments.put("name", "Base name");
    arguments.put("email", "base@example.com");
    arguments.put("mobileNumber", "+1234567");
    arguments.put("customAttributes", custom);

    for (String method : Arrays.asList("boot", "bootWithStatus")) {
      JsonObject profile = JsonParser.parseString(bootConfig(method, arguments).getProfile())
          .getAsJsonObject();
      assertEquals("Custom name", profile.get("name").getAsString());
      assertTrue(profile.get("email").isJsonNull());
      assertTrue(profile.get("vip").getAsBoolean());
      assertEquals("pro", profile.getAsJsonObject("plan").get("tier").getAsString());
      assertEquals("+1234567", profile.get("mobileNumber").getAsString());
    }
  }

  /** 옵션 생략은 SDK 기본 버튼과 말풍선 설정을 덮어쓰지 않는다. */
  @Test
  public void omittedOptionsStayUnset() {
    BootConfig config = bootConfig("boot", Collections.emptyMap());
    assertNull(config.getChannelButtonOption());
    assertNull(config.getBubbleOption());
  }

  /** 빈 옵션 맵은 Dart 모델의 기본값을 적용하되 말풍선 여백은 SDK에 위임한다. */
  @Test
  public void partialOptionsUseSafeDefaults() {
    Map<String, Object> arguments = new HashMap<>();
    arguments.put("channelButtonOption", Collections.emptyMap());
    arguments.put("bubbleOption", Collections.emptyMap());
    BootConfig config = bootConfig("boot", arguments);
    ChannelButtonOption button = config.getChannelButtonOption();

    assertEquals(ChannelButtonIcon.Channel, button.getIcon());
    assertEquals(ChannelButtonPosition.RIGHT, button.getPosition());
    assertEquals(20.0f, button.getXMargin(), 0.0f);
    assertEquals(20.0f, button.getYMargin(), 0.0f);
    assertEquals(new BubbleOption(BubblePosition.TOP, null), config.getBubbleOption());
  }

  /** 플랫폼 채널이 전달하는 int와 double 여백을 모두 float로 변환한다. */
  @Test
  public void optionsForwardIconsPositionsAndMixedNumericMargins() {
    Map<String, Object> button = new HashMap<>();
    button.put("icon", "chatBubbleFilled");
    button.put("position", "left");
    button.put("xMargin", 12);
    button.put("yMargin", 34.5);
    Map<String, Object> bubble = new HashMap<>();
    bubble.put("position", "bottom");
    bubble.put("yMargin", 48);
    Map<String, Object> arguments = new HashMap<>();
    arguments.put("channelButtonOption", button);
    arguments.put("bubbleOption", bubble);
    BootConfig config = bootConfig("bootWithStatus", arguments);

    assertEquals(ChannelButtonIcon.ChatBubbleFilled, config.getChannelButtonOption().getIcon());
    assertEquals(ChannelButtonPosition.LEFT, config.getChannelButtonOption().getPosition());
    assertEquals(12.0f, config.getChannelButtonOption().getXMargin(), 0.0f);
    assertEquals(34.5f, config.getChannelButtonOption().getYMargin(), 0.0f);
    assertEquals(new BubbleOption(BubblePosition.BOTTOM, 48.0f), config.getBubbleOption());
  }

  /** 공개 Dart 아이콘 18개가 서로 다른 실제 SDK enum 값으로 연결된다. */
  @Test
  public void allPublicIconsMatchSdkEnums() {
    String[] icons = {"channel", "chatBubbleFilled", "chatProgressFilled", "chatQuestionFilled",
        "chatLightningFilled", "chatBubbleAltFilled", "smsFilled", "commentFilled",
        "sendForwardFilled", "helpFilled", "chatProgress", "chatQuestion", "chatBubbleAlt",
        "sms", "comment", "sendForward", "communication", "headset"};
    assertEquals(18, ChannelButtonIcon.values().length);
    for (int index = 0; index < icons.length; index++) {
      BootConfig config = bootConfig("boot", Collections.singletonMap("channelButtonOption",
          Collections.singletonMap("icon", icons[index])));
      assertEquals(ChannelButtonIcon.values()[index], config.getChannelButtonOption().getIcon());
    }
  }

  /** 잘못된 필드명, enum, 숫자 및 맵 타입은 SDK 호출 없이 고정 오류로 완료한다. */
  @Test
  public void invalidBootOptionsAreRejected() {
    for (Object invalid : Arrays.asList("invalid-map",
        Collections.singletonMap("icon", "invalid-icon"),
        Collections.singletonMap("position", "top"),
        Collections.singletonMap("xMargin", "20"),
        Collections.singletonMap("yMargin", Double.NaN),
        Collections.singletonMap("xMargin", Double.POSITIVE_INFINITY),
        Collections.singletonMap("xMargins", 20))) {
      assertInvalidBootOption("channelButtonOption", invalid);
    }
    assertInvalidBootOption("bubbleOption", Collections.singletonMap("position", "left"));
    assertInvalidBootOption("bubbleOption", Collections.singletonMap("margin", 20));
    assertInvalidBootOption("customAttributes", Arrays.asList("invalid-map"));
  }

  /** 최초 설정 프로필과 현재 프로필을 별도 SDK 요청 키로 전달한다. */
  @Test
  public void profileOnceRemainsSeparateFromCurrentProfile() throws IOException {
    Map<String, Object> arguments = new HashMap<>();
    arguments.put("name", "Current name");
    arguments.put("profileOnce", Collections.singletonMap("name", "First name"));
    JsonObject payload = updatePayload(arguments);

    assertEquals("Current name", payload.getAsJsonObject("profile").get("name").getAsString());
    assertEquals("First name", payload.getAsJsonObject("profileOnce").get("name").getAsString());
  }

  /** 빈 최초 프로필은 명시적으로 전달하고 생략한 프로필은 요청에 넣지 않는다. */
  @Test
  public void profileOncePreservesExplicitEmptyMapAndOmission() throws IOException {
    assertEquals("{\"profileOnce\":{}}",
        updatePayload(Collections.singletonMap("profileOnce", Collections.emptyMap())).toString());
    assertEquals("{\"profile\":{\"name\":\"Ada\"}}",
        updatePayload(Collections.singletonMap("name", "Ada")).toString());
  }

  /** 잘못된 최초 프로필 타입은 사용자 업데이트를 보내지 않는다. */
  @Test
  public void invalidProfileOnceIsRejected() {
    plugin.updateUser(new MethodCall("updateUser",
        Collections.singletonMap("profileOnce", "invalid-map")), result);

    channelIo.verify(() -> ChannelIO.updateUser(any(), any()), never());
    verify(result).error("INVALID_ARGUMENT", "Invalid profileOnce", null);
    verifyNoMoreInteractions(result);
  }

  /** 실제 공통 부팅 경로에서 SDK에 전달된 설정을 캡처한다. */
  private BootConfig bootConfig(String method, Map<String, Object> options) {
    channelIo.clearInvocations();
    Map<String, Object> arguments = new HashMap<>(options);
    arguments.put("pluginKey", "test-plugin-key");
    plugin.onMethodCall(new MethodCall(method, arguments), result);
    ArgumentCaptor<BootConfig> config = ArgumentCaptor.forClass(BootConfig.class);
    channelIo.verify(() -> ChannelIO.boot(config.capture(), any()));
    return config.getValue();
  }

  /** 옵션 오류가 정확히 한 번 전달되고 SDK를 호출하지 않는지 확인한다. */
  private void assertInvalidBootOption(String option, Object value) {
    channelIo.clearInvocations();
    clearInvocations(result);
    Map<String, Object> arguments = new HashMap<>();
    arguments.put("pluginKey", "test-plugin-key");
    arguments.put(option, value);
    plugin.onMethodCall(new MethodCall("bootWithStatus", arguments), result);
    channelIo.verify(() -> ChannelIO.boot(any(), any()), never());
    verify(result).error("INVALID_ARGUMENT", "Invalid boot options", null);
    verifyNoMoreInteractions(result);
  }

  /** 실제 SDK 요청 직렬화를 검사해 profileOnce 키의 전달을 확인한다. */
  private JsonObject updatePayload(Map<String, Object> arguments) throws IOException {
    channelIo.clearInvocations();
    plugin.updateUser(new MethodCall("updateUser", arguments), result);
    ArgumentCaptor<UserData> userData = ArgumentCaptor.forClass(UserData.class);
    channelIo.verify(() -> ChannelIO.updateUser(userData.capture(), any()));
    Buffer buffer = new Buffer();
    userData.getValue().getRequestBody().writeTo(buffer);
    return JsonParser.parseString(buffer.readUtf8()).getAsJsonObject();
  }
}
