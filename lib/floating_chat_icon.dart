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
    required this.messageMaxWidth,
  })  : assert(chatIconWidget == null ||
            (chatIconColor == null &&
                chatIconBackgroundColor == null &&
                chatIconSize == null &&
                chatIconWidgetHeight == null &&
                chatIconWidgetWidth == null)),
        assert(messageWidget == null ||
            (messageBackgroundColor == null && messageTextWidget == null)),
        assert(messageTextWidget == null || (messageTextStyle == null));

  Widget _getChatWidgetImage() {
    if (chatIconWidget != null) {
      return chatIconWidget!;
    } else {
      return SizedBox(
          width: chatIconWidgetWidth ?? 70,
          height: chatIconWidgetHeight ?? 70,
          child: Icon(
            Icons.chat,
            color: chatIconColor ?? Colors.white,
            size: chatIconSize ?? 35,
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
          color: Colors.white,
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
      duration: const Duration(milliseconds: 250),
      child: shouldShowMessage
          ? Padding(
              padding: EdgeInsets.fromLTRB(
                  0,
                  ((isTop) ? messageVerticalSpacing : 0),
                  0,
                  ((isTop) ? 0 : messageVerticalSpacing)),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).secondaryHeaderColor,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: _getMessageWidget(),
              ))
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
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: messageTextWidget ??
              Text(
                message ?? "",
                style: messageTextStyle ??
                    const TextStyle(fontSize: 24, color: Colors.white),
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
