package ai.deepnatural.channel_talk;

import com.google.firebase.messaging.*;
import com.zoyi.channel.plugin.android.ChannelIO;

import android.util.Log;
import java.util.Map;

public class PushInterceptService extends FirebaseMessagingService {
    private static final String TAG = "PushInterceptService";

    @Override
    public void onNewToken(String refreshedToken) {
        ChannelIO.initPushToken(refreshedToken);
        // Enter your code
    }

    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {
        super.onMessageReceived(remoteMessage);

        Map message = remoteMessage.getData();

        if (ChannelIO.isChannelPushNotification(message)) {
            Log.d(TAG, "Channel Talk message received");
            ChannelIO.receivePushNotification(getApplication(), message);
        } else {
            Log.d(TAG, "Push message received, not for Channel Talk");
        }
    }
}
