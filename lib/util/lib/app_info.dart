/// information about this app
library;

import 'dart:io';

const String name = 'Gensokyo Radio Miniplayer';
const String version = String.fromEnvironment('FLUTTER_BUILD_NAME', defaultValue: 'unknownver');
final String userAgent = 'GR Miniplayer/$version (${Platform.operatingSystem}; github.com/Fenekhu/gr_miniplayer)';