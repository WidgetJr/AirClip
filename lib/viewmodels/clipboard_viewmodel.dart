// clipboard_viewmodel.dart
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class ClipboardViewModel extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;
  final String deviceId = const Uuid().v4();

  String? _lastClipboardText;
  DateTime? _lastSeenTimestamp;
  Timer? _pollingTimer;
  StreamSubscription? _subscription;

  String? _status;
  String? get status => _status;

  void Function(String)? _onRemoteCopy;

  void startListening({
    required String userId,
    required void Function(String newContent) onRemoteCopy,
    void Function(String status)? onStatus,
  }) {
    _onRemoteCopy = onRemoteCopy;
    _startClipboardPolling(userId, onStatus);
    _subscribeToClipboardUpdates(userId, onStatus);
  }

  void stop() {
    _pollingTimer?.cancel();
    _subscription?.cancel();
  }

  void _setStatus(String? msg) {
    _status = msg;
    notifyListeners();
  }

  void _startClipboardPolling(String userId, void Function(String)? onStatus) {
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      try {
        final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
        final currentText = clipboardData?.text;

        if (currentText != null && currentText != _lastClipboardText) {
          _lastClipboardText = currentText;

          final now = DateTime.now();

          await _client.from('clipboard').insert({
            'user_id': userId,
            'device_id': deviceId,
            'content': currentText,
            'timestamp': now.toIso8601String(),
          });

          _lastSeenTimestamp = now;
          onStatus?.call('📤 Copied: "$currentText"');
        }
      } catch (e) {
        onStatus?.call('❌ Clipboard polling error: $e');
        print(e);
      }
    });
  }

  void _subscribeToClipboardUpdates(
    String userId,
    void Function(String)? onStatus,
  ) async {
    try {
      final result =
          await _client
              .from('clipboard')
              .select('timestamp')
              .eq('user_id', userId)
              .order('timestamp', ascending: false)
              .limit(1)
              .maybeSingle();

      if (result != null && result['timestamp'] != null) {
        _lastSeenTimestamp = DateTime.parse(result['timestamp']);
        onStatus?.call('📡 Listening from: $_lastSeenTimestamp');
      }
    } catch (e) {
      onStatus?.call('❌ Error getting last timestamp: $e');
      print(e);
    }

    _subscription = _client
        .from('clipboard')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('timestamp')
        .listen((data) {
          if (data.isNotEmpty) {
            final last = data.last;
            final timestamp = DateTime.parse(last['timestamp']);
            final content = last['content'] as String;
            final sourceDevice = last['device_id'];

            if (sourceDevice != deviceId &&
                (_lastSeenTimestamp == null ||
                    timestamp.isAfter(_lastSeenTimestamp!))) {
              _lastClipboardText = content;
              _lastSeenTimestamp = timestamp;

              _onRemoteCopy?.call(content);
              onStatus?.call('📥 Received: "$content"');
            } else {
              onStatus?.call('⏩ Skipped duplicate or local content');
            }
          }
        });
  }
}
