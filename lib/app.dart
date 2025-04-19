// Flutter SDK
import 'package:flutter/material.dart';

// External packages
import 'package:supabase_flutter/supabase_flutter.dart';

// Internal app imports
import 'views/auth_view.dart';
import 'views/home_view.dart';
import 'views/splash_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AirClip',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00E5FF)),
        scaffoldBackgroundColor: const Color(0xFF101926),
        textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
      ),
      initialRoute: '/splash',
      routes: {
        '/': (context) => const RootPage(),
        '/splash': (context) => const SplashView(),
        '/login': (context) => const AuthView(),
        '/home': (context) => const HomeView(),
      },
    );
  }
}

class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      return const HomeView();
    } else {
      return const AuthView();
    }
  }
}
