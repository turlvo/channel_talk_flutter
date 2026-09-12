import Flutter
import UIKit
import ChannelIOFront

public class ChannelTalkFlutterHandler: NSObject, ChannelPluginDelegate {
    var channel : FlutterMethodChannel
    private var preventDefaultUrlClick: Bool = false

    init (channel: FlutterMethodChannel) {
        self.channel = channel
    }

    public func setPreventDefaultUrlClick(_ prevent: Bool) {
        self.preventDefaultUrlClick = prevent
    }


    public func onShowMessenger() {
        channel.invokeMethod("onShowMessenger", arguments: nil)
    }

    public func onHideMessenger() {
        channel.invokeMethod("onHideMessenger", arguments: nil)
    }

    public func onChatCreated(chatId: String) {
        channel.invokeMethod("onChatCreated", arguments: chatId)
    }

    public func onBadgeChanged(unread: Int, alert: Int) {
        var args = [String: Any]()
        args["unread"] = unread
        args["alert"] = alert

        channel.invokeMethod("onBadgeChanged", arguments: args)
    }

    public func onFollowUpChanged(data: [String : Any]) {
        channel.invokeMethod("onFollowUpChanged", arguments:data)
    }

    public func onUrlClicked(url: URL) -> Bool {
        channel.invokeMethod("onUrlClicked", arguments: url.absoluteString)
        return preventDefaultUrlClick
    }

    public func onPopupDataReceived(event: PopupData) {
        channel.invokeMethod("onPopupDataReceived", arguments: event.toJson())
    }

}
