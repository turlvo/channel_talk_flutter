package ai.deepnatural.channel_talk;

import com.google.firebase.messaging.*;
import com.zoyi.channel.plugin.android.ChannelIO;

import android.content.Intent;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;
import android.util.Log;
import java.util.Map;

public class PushInterceptService extends FirebaseMessagingService {
    private static final String TAG = "PushInterceptService";
    public static final String ACTION_REMOTE_MESSAGE = "io.flutter.plugins.firebasemessaging.NOTIFICATION";
    public static final String EXTRA_REMOTE_MESSAGE = "notification";

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
            Intent intent = new Intent(ACTION_REMOTE_MESSAGE);
            intent.putExtra(EXTRA_REMOTE_MESSAGE, remoteMessage);
            LocalBroadcastManager.getInstance(this).sendBroadcast(intent);
            Log.d(TAG, "Push message received, not for Channel Talk");
        }
    }
}
