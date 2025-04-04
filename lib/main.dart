import 'dart:io';

import 'package:airclip/viewmodels/clipboard_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:airclip/config/constants.dart';
import 'package:airclip/app.dart';
import 'package:airclip/widgets/tray_widget.dart';
import 'package:airclip/viewmodels/auth_viewmodel.dart';
import 'package:airclip/viewmodels/clipboard_history_viewmodel.dart';

import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  await windowManager.ensureInitialized();

  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setSize(const Size(400, 600));
    await windowManager.setMinimumSize(const Size(400, 600));
    await windowManager.setSkipTaskbar(true);
    await windowManager.hide();
  });

  await trayManager.setIcon(
    Platform.isWindows ? 'assets/app_icon.ico' : 'assets/app_icon.png',
  );

  await trayManager.setToolTip('AirClip');

  await trayManager.setContextMenu(
    Menu(
      items: [
        MenuItem(key: 'show', label: 'Mostrar AirClip'),
        MenuItem.separator(),
        MenuItem(key: 'exit', label: 'Salir'),
      ],
    ),
  );

  trayManager.addListener(TrayWidget());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ClipboardViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ClipboardHistoryViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}
