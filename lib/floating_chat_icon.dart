import 'package:flutter/material.dart';

class FloatingChatIcon extends StatelessWidget {
  final Function(BuildContext)? onTap;
  final bool isTop;
  final bool isRight;
  final String? message;
  final bool shouldShowMessage;
  final bool shouldPutWidgetInCircle;
  final Widget? chatIconWidget;
  final Color? chatIconColor;
  final Color? chatIconBackgroundColor;
  final double? chatIconSize;
  final double? chatIconWidgetHeight;
  final double? chatIconWidgetWidth;
  final Color chatIconBorderColor;
  final double chatIconBorderWidth;
  final Duration? messageCrossFadeTime;
  final double messageVerticalSpacing;
  final Widget? messageWidget;
  final Color? messageBackgroundColor;
  final TextStyle? messageTextStyle;
  final Widget? messageTextWidget;
  final double messageMaxWidth;
  final double? messageBorderWidth;
  final Color? messageBorderColor;

  FloatingChatIcon({
    this.onTap,
    required this.isTop,
    required this.isRight,
    this.message,
    this.shouldShowMessage = false,
    this.shouldPutWidgetInCircle = true,
    this.chatIconWidget,
    this.chatIconColor,
    this.chatIconBackgroundColor,
    this.chatIconSize,
    this.chatIconWidgetHeight,
    this.chatIconWidgetWidth,
    required this.chatIconBorderColor,
    required this.chatIconBorderWidth,
    this.messageCrossFadeTime,
    this.messageVerticalSpacing = 10,
    this.messageWidget,
    this.messageBackgroundColor,
    this.messageTextStyle,
    this.messageTextWidget,
    this.messageBorderWidth,
    this.messageBorderColor,
    required this.messageMaxWidth,
  })  : assert(chatIconWidget == null ||
            (chatIconSize == null &&
                chatIconWidgetHeight == null &&
                chatIconWidgetWidth == null)),
        assert(messageWidget == null ||
            (messageBackgroundColor == null && messageTextWidget == null)),
        assert(messageTextWidget == null || (messageTextStyle == null));

  static const double defaultChatWidgetImageWidth = 70;
  static const double defaultChatWidgetImageHeight = 70;
  static const double defaultChatIconSize = 35;
  static const int defaultMessageCrossFadeTimeMilliseconds = 250;
  static const double messageBorderRadius = 10;
  static const double messageTextSize = 24;
  static const double messageTextPadding = 0;

  Widget _getChatWidgetImage() {
    if (chatIconWidget != null) {
      return chatIconWidget!;
    } else {
      return SizedBox(
          width: chatIconWidgetWidth ?? defaultChatWidgetImageWidth,
          height: chatIconWidgetHeight ?? defaultChatWidgetImageHeight,
          child: Icon(
            Icons.chat,
            color: chatIconColor ?? Colors.white,
            size: chatIconSize ?? defaultChatIconSize,
          ));
    }
  }

  Widget _getChatCircleWidget(BuildContext context) {
    if (shouldPutWidgetInCircle) {
      return ClipOval(
        child: Material(
          shape: CircleBorder(
              side: BorderSide(
                  color: chatIconBorderColor, width: chatIconBorderWidth)),
          color: chatIconBackgroundColor ?? Colors.blue,
          child: InkWell(
              child: _getChatWidgetImage(),
              onTap: () {
                if (onTap != null) {
                  onTap!(context);
                }
              }),
        ),
      );
    } else {
      return _getChatWidgetImage();
    }
  }

  Widget _getMessageAnimatedSwitcher(BuildContext context) {
    return AnimatedSwitcher(
      duration: messageCrossFadeTime ?? const Duration(milliseconds: defaultMessageCrossFadeTimeMilliseconds),
      child: shouldShowMessage
          ? Padding(
              padding: EdgeInsets.fromLTRB(
                  0,
                  ((isTop) ? messageVerticalSpacing : 0),
                  0,
                  ((isTop) ? 0 : messageVerticalSpacing)),
              child: _getMessageWidget())
          : const SizedBox.shrink(),
    );
  }

  Widget _getMessageWidget() {
    Widget? unboundMessageWidget;
    if (messageWidget == null && messageTextWidget == null && message == null) {
      return Container();
    }
    if (messageWidget != null) {
      unboundMessageWidget = messageWidget!;
    } else {
      unboundMessageWidget = Container(
        decoration: BoxDecoration(
          color: messageBackgroundColor ?? Colors.blue,
          borderRadius: const BorderRadius.all(Radius.circular(messageBorderRadius)),
            border: (messageBorderWidth == null) ? null : Border.all(color: messageBorderColor ?? Colors.white, width: messageBorderWidth!)
        ),
        child: Padding(
          padding: const EdgeInsets.all(messageTextPadding),
          child: messageTextWidget ??
              Text(
                message ?? "",
                style: messageTextStyle ??
                    const TextStyle(fontSize: messageTextSize, color: Colors.white),
              ),
        ),
      );
    }
    return Material(
      type: MaterialType.transparency,
      child: Container(
        constraints: BoxConstraints(maxWidth: messageMaxWidth),
        child: unboundMessageWidget,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          (isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start),
      children: [
        if (!isTop) _getMessageAnimatedSwitcher(context),
        _getChatCircleWidget(context),
        if (isTop) _getMessageAnimatedSwitcher(context),
      ],
    );
  }
}
