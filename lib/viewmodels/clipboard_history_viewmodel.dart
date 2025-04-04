import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClipboardHistoryViewModel extends ChangeNotifier {
  final _client = Supabase.instance.client;
  final List<String> _clipboardHistory = [];
  String? _error;

  List<String> get clipboardHistory => _clipboardHistory;
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
          .select('content')
          .eq('user_id', userId)
          .order('timestamp', ascending: false)
          .limit(20);

      _clipboardHistory
        ..clear()
        ..addAll(response.map((e) => e['content'] as String));

      _setError(null);
      notifyListeners();
    } catch (e) {
      _setError('Error loading clipboard history: $e');
    }
  }

  void addEntry(String content) {
    _clipboardHistory.insert(0, content);
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
