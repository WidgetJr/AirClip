//Dependencies
import 'package:airclip/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_text_fields.dart';
import 'auth_submit_button.dart';

class AuthCard extends StatefulWidget {
  const AuthCard({super.key});

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final fullNameController = TextEditingController();

  bool isLogin = true;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        isLogin = _tabController.index == 0;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<AuthViewModel>(context, listen: false).setError(null);
      });

      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();
      fullNameController.clear();
    });
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    fullNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFF0B0E1A),
      elevation: 12,
      shadowColor: Colors.black.withOpacity(0.4),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'AirClip',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFFEFF3F8),
              ),
            ),
            const SizedBox(height: 16),
            TabBar(
              controller: _tabController,
              labelColor: Color(0xFF00E5FF),
              unselectedLabelColor: Color(0xFF7A8AA1),
              indicatorColor: Color(0xFF00E5FF),
              tabs: const [Tab(text: 'Login'), Tab(text: 'Sign Up')],
            ),
            const SizedBox(height: 24),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AuthTextFields(
                    emailController: emailController,
                    passwordController: passwordController,
                    confirmPasswordController: confirmPasswordController,
                    fullNameController: fullNameController,
                    isLogin: isLogin,
                  ),
                  const SizedBox(height: 24),
                  AuthSubmitButton(
                    emailController: emailController,
                    passwordController: passwordController,
                    confirmPasswordController: confirmPasswordController,
                    fullNameController: fullNameController,
                    isLogin: isLogin,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
