//Dependencies
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:airclip/viewmodels/auth_viewmodel.dart';

class AuthSubmitButton extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController? confirmPasswordController;
  final TextEditingController? fullNameController;
  final bool isLogin;

  const AuthSubmitButton({
    super.key,
    required this.emailController,
    required this.passwordController,
    this.confirmPasswordController,
    this.fullNameController,
    required this.isLogin,
  });

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);

    return Column(
      children: [
        if (authVM.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              authVM.errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00E5FF),
          ),
          onPressed:
              authVM.isLoading
                  ? null
                  : () async {
                    final email = emailController.text.trim();
                    final password = passwordController.text.trim();
                    final fullName = fullNameController?.text.trim() ?? '';
                    final confirmPassword =
                        confirmPasswordController?.text.trim() ?? '';

                    if (!isLogin) {
                      final error = validateSignUp(
                        fullName: fullName,
                        email: email,
                        password: password,
                        confirmPassword: confirmPassword,
                      );
                      if (error != null) {
                        authVM.setError(error);
                        return;
                      }
                    }

                    if (isLogin) {
                      await authVM.login(email, password, context);
                    } else {
                      await authVM.signUp(email, password, fullName, context);
                    }
                  },
          child:
              authVM.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(isLogin ? 'Login' : 'Sign Up'),
        ),
      ],
    );
  }

  /// Validación para Sign Up
  String? validateSignUp({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    if (fullName.isEmpty) return 'Please enter your full name';
    if (email.isEmpty) return 'Please enter your email';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    if (password.isEmpty) return 'Please enter your password';
    if (password.length < 6) {
      return 'Password must be at least 6 characters long';
    }

    if (!RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%^&*(),.?":{}|<>]).{6,}$',
    ).hasMatch(password)) {
      return 'Password must contain uppercase, lowercase, a number and a special character';
    }

    if (confirmPassword.isEmpty) return 'Please confirm your password';
    if (password != confirmPassword) return 'Passwords do not match';

    return null; // todo OK
  }
}
