//Dart SDK
import 'dart:async';

// Flutter SDK
import 'package:flutter/material.dart';

// Internal app imports
import 'package:airclip/app.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(_createRoute());
    });
  }

  Route _createRoute() {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (context, animation, secondaryAnimation) => const RootPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(
          begin: const Offset(0.0, 0.2),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOut));

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: animation.drive(tween),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001124),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Center(child: Image.asset('assets/app_icon.png', width: 120)),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.only(bottom: 24.0),
            child: Column(
              children: [
                Text(
                  'from',
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
                Text(
                  'Paiztech',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
