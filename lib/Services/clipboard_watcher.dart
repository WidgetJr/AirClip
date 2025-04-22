// Dart core
import 'dart:async';
import 'dart:io';

// Flutter SDK
import 'package:flutter/services.dart';

// External packages
import 'package:pasteboard/pasteboard.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ClipboardWatcher {
  final Duration interval;
  final void Function(String newClipboard) onTextChange;
  final void Function(File imageFile)? onImagePaste;

  String? _lastText;
  String? _lastImageHash;
  Timer? _timer;

  ClipboardWatcher({
    required this.onTextChange,
    this.onImagePaste,
    this.interval = const Duration(seconds: 2),
  });

  void start() {
    _timer = Timer.periodic(interval, (_) async {
      // text
      final data = await Clipboard.getData('text/plain');
      final currentText = data?.text;
      if (currentText != null && currentText != _lastText) {
        _lastText = currentText;
        onTextChange(currentText);
      }

      // image
      final image = await Pasteboard.image;
      if (image != null) {
        final imageHash = _hashBytes(image);
        if (imageHash != _lastImageHash) {
          _lastImageHash = imageHash;

          final tempDir = await getTemporaryDirectory();
          final fileName = '${const Uuid().v4()}.png';
          final path = '${tempDir.path}/$fileName';
          final imageFile = File(path);
          await imageFile.writeAsBytes(image);

          onImagePaste?.call(imageFile);
        }
      }
    });
  }

  void stop() => _timer?.cancel();

  String _hashBytes(List<int> bytes) {
    return bytes.fold<int>(0, (a, b) => a + b).toString();
  }
}
