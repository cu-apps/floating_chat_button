<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

Show a draggable floating chat icon button and show messages on screens

## Features

A widget for displaying a chat icon (or custom widget) on top of a background widget.

It can show and hide messages or display a message that is passed in its constructor.

![Alt text](https://github.com/cu-apps/floating_chat_button/blob/master/example/example_gifs/floating_chat_button_example_1.gif?raw=true) ![Alt text](https://github.com/cu-apps/floating_chat_button/blob/master/example/example_gifs/floating_chat_button_example_2.gif?raw=true)
![Alt text](https://github.com/cu-apps/floating_chat_button/blob/master/example/example_gifs/floating_chat_button_example_3.gif?raw=true)
## Getting started

Add it as the body of a scaffold (or other full screen view) and then supply the widget that should be shown under the chat widget as the `background` parameter.

Alternately, use a stack view to position the chat widget and leave the `background` as null.

The `FloatingChatIcon` will default to a blue circle with white chat icon and the `messageWidget` will default to a blue rounded rectangle with white text. All of these colours can be configured or custom widgets can be passed to `chatIconWidget`, `messageWidget` or `messageTextWidget`.

The `ShowMessageParameters` allows you to show the message passed to the constructor after a given `delayDuration`, for the amount of time specified in `durationToShowMessage` and at a random frequency (eg "Only show this message 50% of the time that the widget is instantiated") with `showMessageFrequency`.

## Usage

```dart
@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FloatingChatButton(
          background: BackgroundWidget(),
          onTap: (_) {
            _showBottomSheet(context);
          },
          messageText: "I like this package",
      )
    );
  }
```


