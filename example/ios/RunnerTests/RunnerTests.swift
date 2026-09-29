import Flutter
import XCTest

@testable import channel_talk_flutter

final class RunnerTests: XCTestCase {
  /// 실제 codec과 messenger 경계에서 SDK의 백그라운드 콜백 전달을 검증한다.
  func testBackgroundChatCreatedArrivesOnMainThreadExactlyOnce() {
    let messenger = RecordingMessenger()
    let handler = makeHandler(messenger)
    let delivered = expectation(description: "상담 생성 이벤트 전달")
    let drained = expectation(description: "예약된 main 작업 완료")
    messenger.onSend = { delivered.fulfill() }

    DispatchQueue.global().async {
      XCTAssertFalse(Thread.isMainThread)
      handler.onChatCreated(chatId: "synthetic-chat-id")
      DispatchQueue.main.async { drained.fulfill() }
    }

    wait(for: [delivered, drained], timeout: 5)
    let messages = messenger.messages
    XCTAssertEqual(messages.count, 1)
    XCTAssertEqual(messages.first?.channel, "channel_talk_flutter")
    XCTAssertEqual(messages.first?.call.method, "onChatCreated")
    XCTAssertEqual(messages.first?.call.arguments as? String, "synthetic-chat-id")
    XCTAssertEqual(messages.first?.wasMainThread, true)
  }

  /// 기존 main 콜백에 불필요한 비동기 지연이나 중복 전달을 추가하지 않는다.
  func testMainThreadChatCreatedIsDeliveredSynchronously() {
    let messenger = RecordingMessenger()
    let handler = makeHandler(messenger)
    let checked = expectation(description: "main 동기 전달 검사")

    DispatchQueue.main.async {
      handler.onChatCreated(chatId: "synthetic-main-chat")
      XCTAssertEqual(messenger.messages.count, 1)
      XCTAssertEqual(messenger.messages.first?.wasMainThread, true)
      XCTAssertEqual(messenger.messages.first?.call.arguments as? String, "synthetic-main-chat")
      checked.fulfill()
    }

    wait(for: [checked], timeout: 5)
  }

  /// SDK가 같은 백그라운드 큐에서 보낸 이벤트의 순서와 payload를 보존한다.
  func testBackgroundDelegatesPreserveNamesOrderAndArguments() {
    let messenger = RecordingMessenger()
    let handler = makeHandler(messenger)
    let delivered = expectation(description: "네 이벤트 전달")
    delivered.expectedFulfillmentCount = 4
    let drained = expectation(description: "예약된 main 작업 완료")
    messenger.onSend = { delivered.fulfill() }

    DispatchQueue.global().async {
      handler.onShowMessenger()
      handler.onHideMessenger()
      handler.onBadgeChanged(unread: 7, alert: 2)
      handler.onFollowUpChanged(data: ["synthetic": "value", "enabled": true])
      DispatchQueue.main.async { drained.fulfill() }
    }

    wait(for: [delivered, drained], timeout: 5)
    let messages = messenger.messages
    XCTAssertEqual(messages.map { $0.call.method }, [
      "onShowMessenger", "onHideMessenger", "onBadgeChanged", "onFollowUpChanged",
    ])
    XCTAssertTrue(messages.allSatisfy { $0.wasMainThread })
    XCTAssertTrue(messages.allSatisfy { $0.channel == "channel_talk_flutter" })
    guard messages.count == 4 else { return }
    XCTAssertNil(messages[0].call.arguments)
    XCTAssertNil(messages[1].call.arguments)
    XCTAssertEqual(messages[2].call.arguments as? [String: Int], ["unread": 7, "alert": 2])
    let followUp = messages[3].call.arguments as? [String: Any]
    XCTAssertEqual(followUp?["synthetic"] as? String, "value")
    XCTAssertEqual(followUp?["enabled"] as? Bool, true)
  }

  /// 기본 URL 동작을 허용하는 기존 false 반환과 URL payload를 보존한다.
  func testBackgroundUrlClickPreservesDefaultBehavior() {
    assertBackgroundUrlClick(preventDefault: false)
  }

  /// 기본 URL 동작 차단은 main 이벤트 전달 완료를 기다리지 않고 true를 반환한다.
  func testBackgroundUrlClickPreservesPreventDefaultBehavior() {
    assertBackgroundUrlClick(preventDefault: true)
  }

  /// URL의 동기 반환 계약과 Flutter 이벤트 스레드 계약을 독립적으로 검사한다.
  private func assertBackgroundUrlClick(preventDefault: Bool) {
    let messenger = RecordingMessenger()
    let handler = makeHandler(messenger)
    handler.setPreventDefaultUrlClick(preventDefault)
    let delivered = expectation(description: "URL 이벤트 전달")
    let returned = expectation(description: "URL 기본 동작 반환")
    messenger.onSend = { delivered.fulfill() }
    let url = URL(string: "https://example.invalid/qa?value=synthetic")!

    DispatchQueue.global().async {
      XCTAssertFalse(Thread.isMainThread)
      XCTAssertEqual(handler.onUrlClicked(url: url), preventDefault)
      returned.fulfill()
    }

    wait(for: [returned, delivered], timeout: 5)
    XCTAssertEqual(messenger.messages.count, 1)
    XCTAssertEqual(messenger.messages.first?.call.method, "onUrlClicked")
    XCTAssertEqual(messenger.messages.first?.call.arguments as? String, url.absoluteString)
    XCTAssertEqual(messenger.messages.first?.wasMainThread, true)
  }

  /// 플랫폼에서 사용하는 채널명과 실제 Flutter codec을 그대로 사용한다.
  private func makeHandler(_ messenger: RecordingMessenger) -> ChannelTalkFlutterHandler {
    ChannelTalkFlutterHandler(channel: FlutterMethodChannel(
      name: "channel_talk_flutter",
      binaryMessenger: messenger
    ))
  }
}

private final class RecordingMessenger: NSObject, FlutterBinaryMessenger {
  struct Message {
    let channel: String
    let call: FlutterMethodCall
    let wasMainThread: Bool
  }

  private let lock = NSLock()
  private var recordedMessages: [Message] = []
  var onSend: (() -> Void)?

  var messages: [Message] {
    lock.lock()
    defer { lock.unlock() }
    return recordedMessages
  }

  /// 비동기 결과가 없는 실제 MethodChannel 전송을 기록한다.
  func send(onChannel channel: String, message: Data?) {
    record(channel: channel, message: message)
  }

  /// MethodChannel이 reply overload를 선택해도 같은 경계에서 기록한다.
  func send(onChannel channel: String, message: Data?, binaryReply: FlutterBinaryReply?) {
    record(channel: channel, message: message)
    binaryReply?(nil)
  }

  /// 이 테스트는 native에서 Dart로 보내는 이벤트만 검사한다.
  func setMessageHandlerOnChannel(
    _ channel: String,
    binaryMessageHandler handler: FlutterBinaryMessageHandler?
  ) -> FlutterBinaryMessengerConnection {
    0
  }

  /// 수신 핸들러를 등록하지 않으므로 해제할 연결도 없다.
  func cleanUpConnection(_ connection: FlutterBinaryMessengerConnection) {}

  /// 실제 wire payload를 decode해 호출 스레드와 함께 보관한다.
  private func record(channel: String, message: Data?) {
    guard let message = message else {
      XCTFail("이벤트 MethodCall payload가 없습니다.")
      return
    }
    let call = FlutterStandardMethodCodec.sharedInstance().decodeMethodCall(message)
    let recorded = Message(channel: channel, call: call, wasMainThread: Thread.isMainThread)
    lock.lock()
    recordedMessages.append(recorded)
    lock.unlock()
    onSend?()
  }
}
