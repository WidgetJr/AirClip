import 'package:flutter/material.dart';

class AuthTextFields extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController? confirmPasswordController;
  final TextEditingController? fullNameController;
  final bool isLogin;

  const AuthTextFields({
    super.key,
    required this.emailController,
    required this.passwordController,
    this.confirmPasswordController,
    this.fullNameController,
    required this.isLogin,
  });

  @override
  State<AuthTextFields> createState() => _AuthTextFieldsState();
}

class _AuthTextFieldsState extends State<AuthTextFields> {
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!widget.isLogin && widget.fullNameController != null) ...[
          TextField(
            controller: widget.fullNameController,
            decoration: const InputDecoration(
              hintText: 'Full Name',
              filled: true,
              fillColor: Colors.white10,
            ),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: widget.emailController,
          decoration: const InputDecoration(
            hintText: 'Email',
            filled: true,
            fillColor: Colors.white10,
          ),
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: widget.passwordController,
          obscureText: !_showPassword,
          decoration: InputDecoration(
            hintText: 'Password',
            filled: true,
            fillColor: Colors.white10,
            suffixIcon: IconButton(
              icon: Icon(
                _showPassword ? Icons.visibility : Icons.visibility_off,
                color: Colors.white70,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _showPassword = !_showPassword;
                });
              },
            ),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        if (!widget.isLogin && widget.confirmPasswordController != null) ...[
          const SizedBox(height: 12),
          TextField(
            controller: widget.confirmPasswordController,
            obscureText: !_showConfirmPassword,
            decoration: InputDecoration(
              hintText: 'Confirm Password',
              filled: true,
              fillColor: Colors.white10,
              suffixIcon: IconButton(
                icon: Icon(
                  _showConfirmPassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Colors.white70,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _showConfirmPassword = !_showConfirmPassword;
                  });
                },
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ],
    );
  }
}
