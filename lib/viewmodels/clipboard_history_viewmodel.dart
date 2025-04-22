// Flutter SDK
import 'package:flutter/material.dart';

// External packages
import 'package:supabase_flutter/supabase_flutter.dart';

// Internal app imports
import 'package:airclip/models/clipboardentry.dart';

class ClipboardHistoryViewModel extends ChangeNotifier {
  final _client = Supabase.instance.client;
  final List<ClipboardEntry> _clipboardHistory = [];
  String? _error;

  List<ClipboardEntry> get clipboardHistory => _clipboardHistory;
  String? get error => _error;

  Future<void> loadHistory() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        _setError('User not logged in');
        return;
      }

      final response = await _client
          .from('clipboard')
          .select('content, timestamp')
          .eq('user_id', userId)
          .order('timestamp', ascending: false)
          .limit(20);

      _clipboardHistory
        ..clear()
        ..addAll(
          response.map<ClipboardEntry>((e) {
            final content = e['content'] as String;
            final isImage = content.startsWith('[img]');
            final url = isImage ? content.substring(5) : content;
            return ClipboardEntry(
              content: url,
              isImage: isImage,
              timestamp: DateTime.tryParse(e['timestamp']) ?? DateTime.now(),
            );
          }),
        );

      _setError(null);
      notifyListeners();
    } catch (e) {
      _setError('Error loading clipboard history: $e');
    }
  }

  void addEntry(String content, {required bool isImage}) {
    _clipboardHistory.insert(
      0,
      ClipboardEntry(
        content: content,
        isImage: isImage,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void setError(String? message) {
    _setError(message);
  }

  void clear() {
    _clipboardHistory.clear();
    _error = null;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }
}
