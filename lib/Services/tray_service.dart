import 'dart:io';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

Future<void> initTray() async {
  await trayManager.setIcon(
    Platform.isWindows ? 'assets/app_icon.ico' : 'assets/app_icon.png',
  );

  await trayManager.setToolTip('AirClip');

  await trayManager.setContextMenu(
    Menu(
      items: [
        MenuItem(key: 'show', label: 'Show AirClip'),
        MenuItem(key: 'exit', label: 'Exit'),
      ],
    ),
  );

  trayManager.addListener(TrayEventHandlerService());
}

class TrayEventHandlerService with TrayListener {
  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayIconMouseDown() {
    windowManager.show();
    windowManager.focus();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'show':
        windowManager.show();
        windowManager.focus();
        break;
      case 'exit':
        exit(0);
    }
  }
}
