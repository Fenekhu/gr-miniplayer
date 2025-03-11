library;

import 'dart:developer' as developer;
import 'dart:io';

import 'package:gr_miniplayer/util/lib/app_settings.dart' as app_settings;
import 'package:window_manager/window_manager.dart';
import 'package:screen_retriever/screen_retriever.dart';

class WindowListenerImpl with WindowListener {
  @override
  void onWindowResize() {
    if (Platform.isLinux) saveWindowSize();
  }

  @override
  void onWindowResized() => saveWindowSize();

  @override
  void onWindowMove() {
    if (Platform.isLinux) saveWindowPos();
  }

  @override
  void onWindowMoved() => saveWindowPos();
}

final _listener = WindowListenerImpl();

/// positions, sizes, styles, etc. the window before displaying it.
Future<void> setupWindow() async {
  await windowManager.ensureInitialized();

  developer.log('app_settings.windowSize: ${app_settings.windowSize}');
  Display display = await screenRetriever.getPrimaryDisplay();
  developer.log('display.scaleFactor: ${display.scaleFactor}');
  WindowOptions windowOptions = WindowOptions(
    size: app_settings.windowSize * ((display.scaleFactor ?? 1) as double),
    skipTaskbar: false,
  );

  windowManager.addListener(_listener);

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    // uncomment line below to lock aspect ratio. See resetWindowSize() as well.
    //await windowManager.setAspectRatio(windowWidth / windowHeight);
    await windowManager.setMaximizable(false);
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    await windowManager.setPosition(app_settings.windowPos);
    await windowManager.show();
    await windowManager.focus();
    developer.log('window size: ${await windowManager.getSize()}');
  });
}

/// resets the window size to its default.
Future<void> resetWindowSize() async {
  //await windowManager.setAspectRatio(defaultWindowSize.aspectRatio);
  await windowManager.setSize(app_settings.defaultWindowSize);
  saveWindowSize();
}

/// saves the current window dimensions to persistent settings
Future<void> saveWindowSize() async {
  app_settings.windowSize = await windowManager.getSize();
}

/// saves the current window position to persistent settings
Future<void> saveWindowPos() async {
  app_settings.windowPos = await windowManager.getPosition();
}

Future<void> minimize() async => await windowManager.minimize();

Future<void> close() async => await windowManager.close();
