import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:airclip/viewmodels/auth_viewmodel.dart';
import 'package:airclip/widgets/auth_card.dart';

class AuthView extends StatelessWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthViewModel(),
      child: const Scaffold(body: Center(child: AuthCard())),
    );
  }
}
