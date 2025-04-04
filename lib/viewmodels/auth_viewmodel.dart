//Dependencies
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthViewModel extends ChangeNotifier {
  final _client = Supabase.instance.client;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void setError(String? message) => _setError(message);

  Future<void> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    _setLoading(true);
    _setError(null);

    try {
      final res = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.session != null) {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _setError('Could not log in.');
      }
    } on AuthException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Unexpected error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signUp(
    String email,
    String password,
    String fullName,
    BuildContext context,
  ) async {
    _setLoading(true);
    _setError(null);

    try {
      final res = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      if (res.user != null) {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _setError('Could not register user.');
      }
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('user already registered')) {
        _setError('An account with this email already exists.');
      } else {
        _setError(e.message);
      }
    } catch (e) {
      _setError('Unexpected error: $e');
    } finally {
      _setLoading(false);
    }
  }
}
