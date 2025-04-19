// Dart core
import 'dart:io';

// Flutter SDK
import 'package:flutter/material.dart';

// Flutter packages
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:window_manager/window_manager.dart';

// Internal app imports
import 'package:airclip/app.dart';
import 'package:airclip/viewmodels/auth_viewmodel.dart';
import 'package:airclip/viewmodels/clipboard_history_viewmodel.dart';
import 'package:airclip/Services/tray_service.dart';

class WindowCloseHandler with WindowListener {
  @override
  void onWindowClose() async {
    await windowManager.hide();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  await windowManager.ensureInitialized();
  await windowManager.setPreventClose(true);
  windowManager.addListener(WindowCloseHandler());

  await windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setSize(const Size(400, 600));
    await windowManager.setMinimumSize(const Size(400, 600));
    if (!Platform.isMacOS) await windowManager.setSkipTaskbar(true);
    await windowManager.show();
    if (!Platform.isMacOS) await windowManager.setResizable(false);
    await windowManager.center();
    await windowManager.focus();
  });

  await initTray();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ClipboardHistoryViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}
