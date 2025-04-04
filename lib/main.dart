import 'dart:io';
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

class WindowCloseHandler with WindowListener {
  @override
  void onWindowClose() async {
    await windowManager.hide();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  await windowManager.ensureInitialized();
  await windowManager.setPreventClose(true);
  windowManager.addListener(WindowCloseHandler());

  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setSize(const Size(400, 600));
    await windowManager.setMinimumSize(const Size(400, 600));

    if (!Platform.isMacOS) {
      await windowManager.setSkipTaskbar(true);
    }

    await windowManager.show();

    if (!Platform.isMacOS) {
      await windowManager.setResizable(false);
    }

    await windowManager.center();
    await windowManager.focus();
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
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ClipboardHistoryViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}
