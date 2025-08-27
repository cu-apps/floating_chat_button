import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'src/floating_chat_icon.dart';

class FloatingChatButton extends StatefulWidget {
  /// The FloatingChatButton can be stacked on top of another view inside its
  /// parent. This specifies the widget that it should be stacked on top of
  final Widget? background;

  /// Must give the constraints that the chat widget is built under
  // final BoxConstraints constraints;

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

  /// On drag end, animates how the [chatIconWidget] approaches corners.
  /// If null, default value is [Curves.elasticOut].
  final Curve chatIconAnimationCurve;

  /// On drag end, specifies how long the [chatIconWidget] approaches corners.
  /// If null, default value is 1 second.
  final Duration? chatIconAnimationDuration;

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

  /// The width of the border around the message. Defaults to no border
  final double? messageBorderWidth;

  /// Color of the border around the message
  final Color? messageBorderColor;

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

  const FloatingChatButton(
      {this.background,
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
      this.chatIconAnimationCurve = Curves.elasticOut,
      this.chatIconAnimationDuration = const Duration(seconds: 1),
      this.messageWidget,
      this.messageCrossFadeTime,
      this.messageVerticalSpacing = 10,
      this.messageBackgroundColor,
      this.messageTextStyle,
      this.messageTextWidget,
      this.messageText,
      this.messageBorderWidth,
      this.messageBorderColor,
      this.showMessageParameters,
      this.chatIconVerticalOffset = 30,
      this.chatIconHorizontalOffset = 30,
      super.key})
      : assert(chatIconWidget == null ||
            (chatIconSize == null &&
                chatIconWidgetHeight == null &&
                chatIconWidgetWidth == null)),
        assert(messageWidget == null ||
            (messageBackgroundColor == null && messageTextWidget == null)),
        assert(messageTextWidget == null || (messageTextStyle == null));
  @override
  FloatingChatButtonState createState() => FloatingChatButtonState();
}

class FloatingChatButtonState extends State<FloatingChatButton>
    with SingleTickerProviderStateMixin {
  Widget? messageWidget;
  Widget? messageTextWidget;
  String? messageText;
  bool isTop = false;
  bool isRight = true;
  bool isTimeToShowMessage = false;
  Timer? _timer;
  Offset? _releaseOffset;

  // Animate the chat widget movement
  late final AnimationController _animationController;

  // Tweens the chat widget animation
  late final _tween = Tween(
    begin: 0.0,
    end: 1.0,
  ).animate(
    CurvedAnimation(
      parent: _animationController,
      curve: widget.chatIconAnimationCurve,
    ),
  );

  // Needed to obtain a reference to the chat icon widget itself
  GlobalKey chatIconKey = GlobalKey();

  // The current size of the chat icon widget
  Offset? _chatIconSize;

  // The current size of the entire area used by the chat icon + message widget
  Offset? _chatIconWithMessageSize;

  // The local position of the chat icon widget itself
  Offset? _chatIconDragStart;

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  /// Shows a message (or replaces the currently shown message) with the message given.
  /// You should only provide one of messageText, messageWidget, and messageTextWidget
  void showMessage(
      {String? messageText,
      Duration? duration,
      Widget? messageWidget,
      Widget? messageTextWidget}) {
    _setStateIfMounted(
      () {
        this.messageWidget = messageWidget;
        this.messageTextWidget = messageTextWidget;
        this.messageText = messageText;
        isTimeToShowMessage = true;
      },
    );
    if (duration != null) {
      _scheduleMessageDisappearing(duration: duration);
    }
  }

  /// Removes any messages which are currently showing
  void hideMessage() {
    _setStateIfMounted(
      () {
        isTimeToShowMessage = false;
      },
    );
  }

  /// This helper function determines the "cross-over" point
  /// on the screen based on drag amount stored in [draggableDetails]
  /// and the centroid of the widget.
  ///
  /// The widget centroid is calculated from its parent layouts and
  /// and offset is applied accounting for the cross-over point so
  /// that the widget appears to animate smoothly from its release
  /// point to the destination corner. Without this adjustment,
  /// the orientation of the widget as it slides to one of the
  /// corners will be obviously mis-aligned visually and does not
  /// appear natural.
  void _calculateReleasePosition(
    BuildContext layoutContext,
    DraggableDetails draggableDetails,
  ) {
    final Size mqSize = MediaQuery.of(context).size;
    final double w = mqSize.width;
    final double h = mqSize.height;

    final Offset dragOffset = draggableDetails.offset;

    // Calculate the midpoint wrt the visible location of the
    // icon chat widget, irrespective of any message widgets
    final Offset crossOver = switch (_chatIconDragStart) {
      final Offset start => dragOffset + start,
      _ => dragOffset
    };

    isTop = (crossOver.dy < h * 0.5);
    isRight = (crossOver.dx > w * 0.5);

    // Total offset of all "parent" contexts halved
    final p = _calcOffsets([context, layoutContext]).scale(0.5, 0.5);
    _releaseOffset = dragOffset - p;

    // Update adjusted drag position relative to the widget
    final Offset r = switch ((_chatIconSize, _chatIconWithMessageSize)) {
      (final Offset c, final Offset m) => (m - c) + c,
      _ => Offset.zero
    };

    if (!isTop) {
      _releaseOffset = Offset(
        _releaseOffset!.dx,
        (h - p.dy) - (_releaseOffset!.dy + p.dy + r.dy),
      );
    }

    if (isRight) {
      _releaseOffset = Offset(
        (w - p.dx) - (_releaseOffset!.dx + p.dx + r.dx),
        _releaseOffset!.dy,
      );
    }

    _animationController.forward(from: 0.0);
  }

  void _scheduleMessageShowing() {
    if (widget.showMessageParameters?.delayDuration != null) {
      _timer = Timer(
        widget.showMessageParameters!.delayDuration!,
        () {
          _setStateIfMounted(
            () {
              isTimeToShowMessage = true;
            },
          );
          _scheduleMessageDisappearing();
        },
      );
    } else {
      _setStateIfMounted(
        () {
          isTimeToShowMessage = true;
        },
      );
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
      _timer = Timer(
        durationUntilDisappers,
        () {
          _setStateIfMounted(
            () {
              isTimeToShowMessage = false;
            },
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.chatIconAnimationDuration,
      vsync: this,
    );
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

  /// Accumulates parent widget offsets for the [Positioned] widget
  Offset _calcOffsets(List<BuildContext> contexts) {
    return contexts
        .map<Offset>(
          (e) => switch (e.findRenderObject()) {
            final RenderBox r => r.localToGlobal(Offset.zero),
            _ => Offset.zero,
          },
        )
        .fold<Offset>(Offset.zero, (prev, e) => prev + e);
  }

  // We need to calculate the drag offset relative to the chatIcon.
  // This is because all calculations are w.r.t. the chatIcon resting
  // in the 4 possible corners, irrespective of the message widget size.
  // We use the drag stategy to obtain those widgets dimensions as they
  // are rendered by then.
  Offset _dragStrategy(
      Draggable<Object> _, BuildContext context, Offset position) {
    final RenderBox? chatIcon =
        chatIconKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? parent = context.findRenderObject() as RenderBox?;

    // No work can be done
    if (parent == null || chatIcon == null) return Offset.zero;

    _chatIconSize = Offset(chatIcon.size.width, chatIcon.size.height);
    _chatIconWithMessageSize = Offset(parent.size.width, parent.size.height);
    _chatIconDragStart = chatIcon.globalToLocal(position);

    return parent.globalToLocal(position);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext layoutContext, BoxConstraints constraints) {
        final FloatingChatIcon floatingChatIcon = FloatingChatIcon(
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
              constraints.maxWidth - (widget.chatIconHorizontalOffset * 2),
        );

        return Stack(
          children: [
            if (widget.background != null) widget.background!,
            AnimatedBuilder(
              animation: _animationController,
              child: Draggable(
                key: chatIconKey,
                feedback: floatingChatIcon,
                childWhenDragging: Container(),
                dragAnchorStrategy: _dragStrategy,
                onDragStarted: () {
                  _animationController.stop();
                },
                onDragEnd: (draggableDetails) {
                  _setStateIfMounted(
                    () => _calculateReleasePosition(
                      layoutContext,
                      draggableDetails,
                    ),
                  );
                },
                child: floatingChatIcon,
              ),
              builder: (BuildContext context, Widget? child) {
                if (child == null) return const SizedBox.shrink();
                final double dt =
                    _animationController.isAnimating ? _tween.value : 1.0;
                final Offset w = Offset(
                  widget.chatIconHorizontalOffset,
                  widget.chatIconVerticalOffset,
                );
                final Offset s = switch (_releaseOffset) {
                  null => w,
                  Offset r => Offset(lerpDouble(r.dx, w.dx, dt) ?? w.dx,
                      lerpDouble(r.dy, w.dy, dt) ?? w.dy),
                };
                return Positioned(
                  bottom: (isTop) ? null : s.dy,
                  top: (isTop) ? s.dy : null,
                  right: (isRight) ? s.dx : null,
                  left: (isRight) ? null : s.dx,
                  child: child,
                );
              },
            ),
          ],
        );
      },
    );
    // return
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
