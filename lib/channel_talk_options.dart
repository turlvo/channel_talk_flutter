/// 모바일 채널 버튼의 가로 배치 방향이다.
enum ChannelButtonPosition {
  left('left'),
  right('right');

  const ChannelButtonPosition(this.value);

  /// 네이티브 브리지에 전달하는 플랫폼 공통 값이다.
  final String value;
}

/// Android와 iOS SDK가 공통으로 제공하는 채널 버튼 아이콘이다.
enum ChannelButtonIcon {
  channel('channel'),
  chatBubbleFilled('chatBubbleFilled'),
  chatProgressFilled('chatProgressFilled'),
  chatQuestionFilled('chatQuestionFilled'),
  chatLightningFilled('chatLightningFilled'),
  chatBubbleAltFilled('chatBubbleAltFilled'),
  smsFilled('smsFilled'),
  commentFilled('commentFilled'),
  sendForwardFilled('sendForwardFilled'),
  helpFilled('helpFilled'),
  chatProgress('chatProgress'),
  chatQuestion('chatQuestion'),
  chatBubbleAlt('chatBubbleAlt'),
  sms('sms'),
  comment('comment'),
  sendForward('sendForward'),
  communication('communication'),
  headset('headset');

  const ChannelButtonIcon(this.value);

  /// 네이티브 enum의 구현 이름과 독립적인 채널 계약 값이다.
  final String value;
}

/// Android와 iOS 채널 버튼의 모양과 위치를 지정한다.
///
/// 이 옵션을 명시하면 양 플랫폼 모두 오른쪽, 여백 20을 기본값으로 사용한다.
/// 옵션 자체를 생략하면 기존 플랫폼별 배치를 유지한다. Web은 지원하지 않는다.
class ChannelButtonOption {
  /// 여백은 Android에서 dp, iOS에서 pt 단위로 해석된다.
  const ChannelButtonOption({
    this.icon = ChannelButtonIcon.channel,
    this.position = ChannelButtonPosition.right,
    this.xMargin = 20,
    this.yMargin = 20,
  });

  /// SDK가 제공하는 버튼 아이콘이다.
  final ChannelButtonIcon icon;

  /// 가로 여백의 기준이 되는 화면 가장자리다.
  final ChannelButtonPosition position;

  /// 화면 가장자리로부터의 가로 여백이다.
  final double xMargin;

  /// 화면 아래쪽으로부터의 세로 여백이다.
  final double yMargin;

  /// 네이티브 레이아웃에 전달할 수 없는 숫자를 거부하고 설정을 변환한다.
  Map<String, dynamic> toMap() {
    if (!xMargin.isFinite || !yMargin.isFinite) {
      throw ArgumentError('Channel button margins must be finite.');
    }
    return {
      'icon': icon.value,
      'position': position.value,
      'xMargin': xMargin,
      'yMargin': yMargin,
    };
  }
}

/// 모바일 알림·마케팅 팝업의 세로 배치 방향이다.
enum BubblePosition {
  top('top'),
  bottom('bottom');

  const BubblePosition(this.value);

  /// 네이티브 브리지에 전달하는 플랫폼 공통 값이다.
  final String value;
}

/// Android와 iOS 팝업의 위치와 여백을 지정한다. Web은 지원하지 않는다.
class BubbleOption {
  /// [yMargin] 생략 시 SDK의 기기별 기본 여백 계산을 유지한다.
  const BubbleOption({
    this.position = BubblePosition.top,
    this.yMargin,
  });

  /// 세로 여백의 기준이 되는 화면 가장자리다.
  final BubblePosition position;

  /// Android는 dp, iOS는 pt 단위이며 0과 생략은 구분된다.
  final double? yMargin;

  /// 생략한 여백을 null로 덮어쓰지 않고 SDK의 기본값에 맡긴다.
  Map<String, dynamic> toMap() {
    if (yMargin != null && !yMargin!.isFinite) {
      throw ArgumentError('Bubble margin must be finite.');
    }
    return {
      'position': position.value,
      if (yMargin != null) 'yMargin': yMargin,
    };
  }
}
