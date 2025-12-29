import 'dart:async';

import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class ShareService {
  static final StreamController<String> _linkController =
      StreamController<String>.broadcast();

  static StreamSubscription<List<SharedMediaFile>>? _mediaSub;

  static Stream<String> get linkStream => _linkController.stream;

  static Future<void> init() async {
    _mediaSub =
        ReceiveSharingIntent.instance.getMediaStream().listen((media) {
      if (media.isNotEmpty && media.first.path.isNotEmpty) {
        _linkController.add(media.first.path);
      }
    });
  }

  static Future<String?> getInitialSharedText() async {
    final media =
        await ReceiveSharingIntent.instance.getInitialMedia();

    if (media != null && media.isNotEmpty) {
      return media.first.path;
    }
    return null;
  }

  static void dispose() {
    _mediaSub?.cancel();
    _linkController.close();
  }
}
