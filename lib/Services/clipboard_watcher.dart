//Dependencies
import 'dart:async';
import 'package:flutter/services.dart';

class ClipboardWatcher {
  final Duration interval;
  final void Function(String newClipboard) onClipboardChange;

  String? _lastValue;
  Timer? _timer;

  ClipboardWatcher({
    required this.onClipboardChange,
    this.interval = const Duration(seconds: 2),
  });

  void start() {
    _timer = Timer.periodic(interval, (_) async {
      final data = await Clipboard.getData('text/plain');
      final current = data?.text;
      if (current != null && current != _lastValue) {
        _lastValue = current;
        onClipboardChange(current);
      }
    });
  }

  void stop() {
    _timer?.cancel();
  }
}
