package com.kuku.channel_talk_flutter;

import com.zoyi.channel.plugin.android.open.listener.ChannelPluginListener;
import com.zoyi.channel.plugin.android.open.model.PopupData;

import io.flutter.plugin.common.MethodChannel;

import java.util.HashMap;
import java.util.Map;

class ChannelTalkFlutterHandler implements ChannelPluginListener {
    private MethodChannel channel;

    public ChannelTalkFlutterHandler(MethodChannel methodChannel) {
        channel = methodChannel;
    }

    @Override
    public void onShowMessenger() {
        channel.invokeMethod("onShowMessenger", "");
    }

    @Override
    public void onHideMessenger() {
        channel.invokeMethod("onHideMessenger", "");
    }

    @Override
    public void onChatCreated(String chatId) {
        channel.invokeMethod("onChatCreated", chatId);
    }

    @Override
    public void onBadgeChanged(int i) {
    }

    @Override
    public void onBadgeChanged(int unread, int alert) {
        Map<String, Object> args = new HashMap<>();
        args.put("unread", unread);
        args.put("alert", alert);

        channel.invokeMethod("onBadgeChanged", args);
    }

    @Override
    public void onFollowUpChanged(Map<String, String> data) {
        channel.invokeMethod("onFollowUpChanged", data);
    }

    @Override
    public boolean onUrlClicked(String url) {
        channel.invokeMethod("onUrlClicked", url);
        return false;
    }

    @Override
    public void onPopupDataReceived(PopupData event) {
        Map<String, Object> args = new HashMap<>();
        args.put("chatId", event.getChatId());
        args.put("avatarUrl", event.getAvatarUrl());
        args.put("name", event.getName());
        args.put("message", event.getMessage());
        channel.invokeMethod("onPopupDataReceived", args);
    }

    @Override
    public boolean onPushNotificationClicked(String chatId) {
        if (chatId == null) {
            return false;
        }
        channel.invokeMethod("onPushNotificationClicked", chatId);
        return true;
    }

}