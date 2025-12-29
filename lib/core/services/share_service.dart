import 'dart:async';

class ShareService {
  static final StreamController<String> _linkController =
      StreamController<String>.broadcast();

  static Stream<String> get linkStream => _linkController.stream;

  static Future<void> init() async {
    // share disabilitato temporaneamente
  }

  static Future<String?> getInitialSharedText() async {
    return null;
  }

  static void dispose() {
    _linkController.close();
  }
}
