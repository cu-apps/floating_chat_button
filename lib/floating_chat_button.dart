import 'dart:async';

import 'floating_chat_icon.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class FloatingChatButton extends StatefulWidget {
  /// Must give the constraints that the chat widget is built under
  final BoxConstraints constraints;

  /// Function called when the chat icon (not the message) is tapped
  final Function(BuildContext) onTap;

  /// If true, the chat icon widget will be clipped to be a circle with a
  /// border around it
  final bool shouldPutWidgetInCircle;

  /// Used to specify custom chat icon widget. If not specified, the material chat icon
  /// widget will be used
  final Widget? chatIconWidget;

  final Color? chatIconColor;
  final Color? chatIconBackgroundColor;
  final double? chatIconSize;
  final double? chatIconWidgetHeight;
  final double? chatIconWidgetWidth;

  /// If shouldPutWidgetInCircle is true, this specifies the border colour around
  /// the circle
  final Color chatIconBorderColor;

  /// If shouldPutWidgetInCircle is true, this specifies the border width around
  /// the circle
  final double chatIconBorderWidth;

  /// The duration over which the message appears and disappears (if it isn't
  /// permanently shown or unshown
  final Duration? messageCrossFadeTime;

  /// Vertical spacing between the message and the chat icon
  final double messageVerticalSpacing;

  /// This fully replaces the default message widget
  final Widget? messageWidget;

  /// When messageWidget is not set, this sets the color for the default message
  /// background
  final Color? messageBackgroundColor;

  /// When messageWidget and messageTextWidget are not set, this sets the style
  /// for the default message text widget
  final TextStyle? messageTextStyle;

  /// This replaces only the text widget of the message widget and is shown within
  /// the message widget
  final Widget? messageTextWidget;

  /// If messageWidget and messageTextWidget are not set, this specifies the
  /// text to use in the default message text widget
  final String? messageText;

  final ShowMessageParameters? showMessageParameters;

  /// The vertical distance between the chat icon and it's bounds in one of its
  /// default resting spaces
  final double chatIconVerticalOffset;

  /// The horizontal distance between the chat icon and it's bounds in one of its
  /// default resting spaces
  final double chatIconHorizontalOffset;

  FloatingChatButton(
      {required this.constraints,
      required this.onTap,
      this.shouldPutWidgetInCircle = true,
      this.chatIconWidget,
      this.chatIconColor,
      this.chatIconBackgroundColor,
      this.chatIconSize,
      this.chatIconWidgetHeight,
      this.chatIconWidgetWidth,
      this.chatIconBorderColor = Colors.blue,
      this.chatIconBorderWidth = 4,
      this.messageWidget,
      this.messageCrossFadeTime,
      this.messageVerticalSpacing = 10,
      this.messageBackgroundColor,
      this.messageTextStyle,
      this.messageTextWidget,
      this.messageText,
      this.showMessageParameters,
      this.chatIconVerticalOffset = 30,
      this.chatIconHorizontalOffset = 30,
      Key? key})
      : assert(chatIconWidget == null ||
            (chatIconColor == null &&
                chatIconBackgroundColor == null &&
                chatIconSize == null &&
                chatIconWidgetHeight == null &&
                chatIconWidgetWidth == null)),
        assert(messageWidget == null ||
            (messageBackgroundColor == null && messageTextWidget == null)),
        assert(messageTextWidget == null || (messageTextStyle == null)),
        super(key: key);
  @override
  FloatingChatButtonState createState() => FloatingChatButtonState();
}

class FloatingChatButtonState extends State<FloatingChatButton> {
  Widget? messageWidget;
  Widget? messageTextWidget;
  String? messageText;
  bool isTop = false;
  bool isRight = true;
  bool isTimeToShowMessage = false;
  Timer? _timer;

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  void showMessage(
      {String? messageText,
      Duration? duration,
      Widget? messageWidget,
      Widget? messageTextWidget}) {
    setState(() {
      this.messageWidget = messageWidget;
      this.messageTextWidget = messageTextWidget;
      this.messageText = messageText;
      isTimeToShowMessage = true;
    });
    if (duration != null) {
      _scheduleMessageDisappearing(duration: duration);
    }
  }

  void hideMessage() {
    setState(() {
      isTimeToShowMessage = false;
    });
  }

  void _scheduleMessageShowing() {
    if (widget.showMessageParameters?.delayDuration != null) {
      _timer = Timer(widget.showMessageParameters!.delayDuration!, () {
        setState(() {
          isTimeToShowMessage = true;
        });
        _scheduleMessageDisappearing();
      });
    } else {
      setState(() {
        isTimeToShowMessage = true;
      });
      _scheduleMessageDisappearing();
    }
  }

  void _scheduleMessageDisappearing({Duration? duration}) {
    Duration? durationUntilDisappers;
    if (duration != null) {
      durationUntilDisappers = duration;
    } else if (widget.showMessageParameters?.durationToShowMessage != null) {
      durationUntilDisappers =
          widget.showMessageParameters?.durationToShowMessage;
    }
    if (durationUntilDisappers != null) {
      _timer = Timer(durationUntilDisappers, () {
        setState(() {
          isTimeToShowMessage = false;
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    messageWidget = widget.messageWidget;
    messageTextWidget = widget.messageTextWidget;
    messageText = widget.messageText;
    if (_getShouldShowMessageThisTime()) {
      _scheduleMessageShowing();
    }
  }

  bool _getShouldShowMessageThisTime() {
    var isWithinMessageFrequency = true;
    if (widget.showMessageParameters?.showMessageFrequency != null) {
      var randomNum = Random().nextDouble();
      if (randomNum > widget.showMessageParameters!.showMessageFrequency!) {
        isWithinMessageFrequency = false;
      }
    }
    return isWithinMessageFrequency;
  }

  @override
  Widget build(BuildContext context) {
    var floatingChatIcon = FloatingChatIcon(
      onTap: widget.onTap,
      isTop: isTop,
      isRight: isRight,
      message: messageText,
      shouldShowMessage: isTimeToShowMessage,
      shouldPutWidgetInCircle: widget.shouldPutWidgetInCircle,
      chatIconWidget: widget.chatIconWidget,
      chatIconColor: widget.chatIconColor,
      chatIconBackgroundColor: widget.chatIconBackgroundColor,
      chatIconSize: widget.chatIconSize,
      chatIconWidgetHeight: widget.chatIconWidgetHeight,
      chatIconWidgetWidth: widget.chatIconWidgetWidth,
      chatIconBorderColor: widget.chatIconBorderColor,
      chatIconBorderWidth: widget.chatIconBorderWidth,
      messageCrossFadeTime: widget.messageCrossFadeTime,
      messageVerticalSpacing: widget.messageVerticalSpacing,
      messageWidget: messageWidget,
      messageBackgroundColor: widget.messageBackgroundColor,
      messageTextStyle: widget.messageTextStyle,
      messageTextWidget: messageTextWidget,
      messageMaxWidth:
          widget.constraints.maxWidth - (widget.chatIconHorizontalOffset * 2),
    );
    return Positioned(
      bottom: (isTop) ? null : widget.chatIconVerticalOffset,
      top: (isTop) ? widget.chatIconVerticalOffset : null,
      right: (isRight) ? widget.chatIconHorizontalOffset : null,
      left: (isRight) ? null : widget.chatIconHorizontalOffset,
      child: Draggable(
        child: floatingChatIcon,
        feedback: floatingChatIcon,
        childWhenDragging: Container(),
        onDragEnd: (draggableDetails) {
          setState(() {
            isTop = (draggableDetails.offset.dy <
                (MediaQuery.of(context).size.height) / 2);
            isRight = (draggableDetails.offset.dx >
                (MediaQuery.of(context).size.width) / 2);
          });
        },
      ),
    );
  }
}

/// Parameters of when to show the message if it shouldn't be shown at all times
class ShowMessageParameters {
  /// If there should be a delay between the widget being built and the message appearing,
  /// then specify here. Defaults to no delay
  final Duration? delayDuration;

  /// If the message should show only for a certain amount of time, specify that here
  final Duration? durationToShowMessage;

  /// If the message should randomly show for a percentage of the times that the
  /// widget is instantiated, specify that here.
  ///
  /// Provide a value between 0 and 1. Defaults to 1
  final double? showMessageFrequency;

  ShowMessageParameters(
      {this.delayDuration,
      this.durationToShowMessage,
      this.showMessageFrequency});
}
