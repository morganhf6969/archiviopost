import 'dart:async';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class ShareServiceImpl {
  static final StreamController<String> _controller =
      StreamController<String>.broadcast();

  static Stream<String> get linkStream => _controller.stream;

  static void init() {
    // App avviata da share (quando era chiusa)
    getInitialText().then((text) {
      if (text != null && text.isNotEmpty) {
        _controller.add(text);
      }
    });

    // App già aperta
    getTextStream().listen((text) {
      if (text != null && text.isNotEmpty) {
        _controller.add(text);
      }
    });
  }
}
