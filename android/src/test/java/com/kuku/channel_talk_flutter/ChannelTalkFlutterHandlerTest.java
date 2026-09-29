package com.kuku.channel_talk_flutter;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.zoyi.channel.plugin.android.open.model.PopupData;

import java.util.Map;

import org.junit.Test;
import org.mockito.ArgumentCaptor;

import io.flutter.plugin.common.MethodChannel;

/** SDK 팝업 이벤트의 필드와 nullable 값을 플랫폼 채널에서 보존하는지 검사한다. */
public class ChannelTalkFlutterHandlerTest {
  /** 32비트를 넘는 타임스탬프와 null 메시지를 기존 팝업 필드와 함께 전달한다. */
  @Test
  public void popupPreservesTimestampAndNullableMessage() {
    MethodChannel channel = mock(MethodChannel.class);
    PopupData popup = mock(PopupData.class);
    when(popup.getChatId()).thenReturn("chat-id");
    when(popup.getAvatarUrl()).thenReturn("avatar-url");
    when(popup.getName()).thenReturn("Agent");
    when(popup.getMessage()).thenReturn(null);
    when(popup.getTimestamp()).thenReturn(1789170000123L);

    new ChannelTalkFlutterHandler(channel).onPopupDataReceived(popup);

    ArgumentCaptor<Map> arguments = ArgumentCaptor.forClass(Map.class);
    verify(channel).invokeMethod(eq("onPopupDataReceived"), arguments.capture());
    Map<?, ?> payload = arguments.getValue();
    assertEquals(5, payload.size());
    assertEquals("chat-id", payload.get("chatId"));
    assertEquals("avatar-url", payload.get("avatarUrl"));
    assertEquals("Agent", payload.get("name"));
    assertNull(payload.get("message"));
    assertEquals(1789170000123L, payload.get("timestamp"));
  }
}
