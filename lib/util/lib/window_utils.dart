/// provides functionality involving the display window.
library;
import 'dart:io';

import 'package:gr_miniplayer/util/lib/app_settings.dart' as app_settings;
import 'package:window_manager/window_manager.dart';
//import 'package:screen_retriever/screen_retriever.dart';

/// a listener that saves window size and position information to settings in response to events.
class WindowListenerImpl with WindowListener {
  const WindowListenerImpl();

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

// since the listener is stateless, it can be const.
const _listener = WindowListenerImpl();

/// positions, sizes, styles, etc. the window before displaying it.
Future<void> setupWindow() async {
  await windowManager.ensureInitialized();

  // removed because this issue only affects debug mode?
  //Display display = await screenRetriever.getPrimaryDisplay(); // needed to get the display's scale factor. may be always null on macos.

  // I've noticed scale-factor awareness behaves differently in debug/release mode.
  // debug: positioned right, sized wrong
  // release: positioned wrong, sized right
  WindowOptions windowOptions = WindowOptions(
    size: app_settings.windowSize /* * (display.scaleFactor?.toDouble() ?? 1)*/,
    skipTaskbar: false, // if true, the titlebar size will be added to the window size, causing it to grow with every launch
    titleBarStyle: TitleBarStyle.hidden, // hides titlebar and buttons in windows
    windowButtonVisibility: false, // hides titlebar and buttons in macos and linux
  );

  windowManager.addListener(_listener);

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    // uncomment line below to lock aspect ratio. See resetWindowSize() as well.
    //await windowManager.setAspectRatio(windowWidth / windowHeight);
    await windowManager.setMaximizable(false);
    await windowManager.setPosition(app_settings.windowPos); // see above note about size/positioning in debug/release
    await windowManager.show();
    await windowManager.focus();
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
