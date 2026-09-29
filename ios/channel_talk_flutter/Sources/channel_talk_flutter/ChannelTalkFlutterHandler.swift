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

    /// SDK 콜백의 스레드와 무관하게 Flutter 채널을 메인 스레드에서 호출한다.
    /// 이미 메인 스레드라면 기존 이벤트의 동기 전달 시점을 유지한다.
    private func sendEvent(_ method: String, arguments: Any?) {
        if Thread.isMainThread {
            channel.invokeMethod(method, arguments: arguments)
        } else {
            DispatchQueue.main.async { [channel] in
                channel.invokeMethod(method, arguments: arguments)
            }
        }
    }

    public func onShowMessenger() {
        sendEvent("onShowMessenger", arguments: nil)
    }

    public func onHideMessenger() {
        sendEvent("onHideMessenger", arguments: nil)
    }

    public func onChatCreated(chatId: String) {
        sendEvent("onChatCreated", arguments: chatId)
    }

    public func onBadgeChanged(unread: Int, alert: Int) {
        var args = [String: Any]()
        args["unread"] = unread
        args["alert"] = alert

        sendEvent("onBadgeChanged", arguments: args)
    }

    public func onFollowUpChanged(data: [String : Any]) {
        sendEvent("onFollowUpChanged", arguments: data)
    }

    public func onUrlClicked(url: URL) -> Bool {
        sendEvent("onUrlClicked", arguments: url.absoluteString)
        return preventDefaultUrlClick
    }

    public func onPopupDataReceived(event: PopupData) {
        sendEvent("onPopupDataReceived", arguments: event.toJson())
    }

}
