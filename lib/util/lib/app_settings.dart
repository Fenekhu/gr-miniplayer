/// The settings for this app.
/// Note that the values here represent the values stored in sharedPrefs,
/// not necessarily the things they describe. 
/// (eg, setting windowX wont move the window, but will change the window X on next open.)
library;

import 'dart:ui';

import 'package:gr_miniplayer/util/lib/shared_prefs.dart';
import 'package:gr_miniplayer/util/enum/art_quality.dart';
import 'package:gr_miniplayer/util/enum/stream_endpoint.dart';

/* The following Property classes are wrappers around SharedPreferences settings,
 * providing a default value and getters/setters that wrap sharedPrefs operations.
 */

class BoolProperty {
  /// The key this value will be stored as in sharedPrefs
  final String key;
  /// The default value if the key is not present.
  final bool defaultValue;
  const BoolProperty(this.key, this.defaultValue);

  bool get value => sharedPrefs.getBool(key) ?? defaultValue;
  set value(bool v) => sharedPrefs.setBool(key, v);
}

class IntProperty {
  /// The key this value will be stored as in sharedPrefs
  final String key;
  /// The default value if the key is not present.
  final int defaultValue;
  const IntProperty(this.key, this.defaultValue);

  int get value => sharedPrefs.getInt(key) ?? defaultValue;
  set value(int v) => sharedPrefs.setInt(key, v);
}

class DoubleProperty {
  /// The key this value will be stored as in sharedPrefs
  final String key;
  /// The default value if the key is not present.
  final double defaultValue;
  const DoubleProperty(this.key, this.defaultValue);

  double get value => sharedPrefs.getDouble(key) ?? defaultValue;
  set value(double v) => sharedPrefs.setDouble(key, v);
}

class StringProperty {
  /// The key this value will be stored as in sharedPrefs
  final String key;
  /// The default value if the key is not present.
  final String defaultValue;
  const StringProperty(this.key, this.defaultValue);

  String get value => sharedPrefs.getString(key) ?? defaultValue;
  set value(String v) => sharedPrefs.setString(key, v);
}

class StringListProperty {
  /// The key this value will be stored as in sharedPrefs
  final String key;
  /// The default value if the key is not present.
  final List<String> defaultValue;
  const StringListProperty(this.key, this.defaultValue);

  List<String> get value => sharedPrefs.getStringList(key) ?? defaultValue;
  set value(List<String> v) => sharedPrefs.setStringList(key, v);
}

const _windowXProp = DoubleProperty('window.x', 0);
const _windowYProp = DoubleProperty('window.y', 0);
const _defWindowWidthProp = DoubleProperty('window.defaultWidth', 288);
const _defWindowHeightProp = DoubleProperty('window.defaultHeight', 416);

const _artQualityProp = StringProperty('art.quality', '500');
const _streamEndpointProp = StringProperty('stream.endpoint', '2');

const _volumeProp = DoubleProperty('player.volume', 1);
const _cachingPauseProp = BoolProperty('player.cachingPause', false);

double get windowX => _windowXProp.value;
set windowX(double v) => _windowXProp.value = v;

double get windowY => _windowYProp.value;
set windowY(double v) => _windowYProp.value = v;

double get defaultWindowWidth => _defWindowWidthProp.value;
set defaultWindowWidth(double v) => _defWindowWidthProp.value = v;

double get defaultWindowHeight => _defWindowHeightProp.value;
set defaultWindowHeight(double v) => _defWindowHeightProp.value = v;

// window width and window height require special functionality because the default value is not constant.
double get windowWidth => sharedPrefs.getDouble('window.width') ?? defaultWindowWidth;
set windowWidth(double v) => sharedPrefs.setDouble('window.width', v);

double get windowHeight => sharedPrefs.getDouble('window.height') ?? defaultWindowHeight;
set windowHeight(double v) => sharedPrefs.setDouble('window.height', v);

final Offset defaultWindowPos = Offset(_windowXProp.defaultValue, _windowYProp.defaultValue);

/// wraps windowX and windowY as an Offset
Offset get windowPos => Offset(windowX, windowY);
set windowPos(Offset v) { windowX = v.dx; windowY = v.dy; }

/// wraps defaultWindowWidth and defaultWindowHeight as a Size
Size get defaultWindowSize => Size(defaultWindowWidth, defaultWindowHeight);
set defaultWindowSize(Size v) { defaultWindowWidth = v.width; defaultWindowHeight = v.height; }

/// wraps windowWidth and windowHeight as a Size
Size get windowSize => Size(windowWidth, windowHeight);
set windowSize(Size v) { windowWidth = v.width; windowHeight = v.height; }

ArtQuality get artQuality => ArtQuality.fromValue(_artQualityProp.value);
set artQuality(ArtQuality v) => _artQualityProp.value = v.value;

StreamEndpoint get streamEndpoint => StreamEndpoint.fromValue(_streamEndpointProp.value);
set streamEndpoint(StreamEndpoint v) => _streamEndpointProp.value = v.value;

double get playerVolume => _volumeProp.value;
set playerVolume(double v) => _volumeProp.value = v;

bool get cachingPause => _cachingPauseProp.value;
set cachingPause(bool v) => _cachingPauseProp.value = v;
