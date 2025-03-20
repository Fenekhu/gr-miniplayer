import 'package:shared_preferences/shared_preferences.dart';

// initialized in main()
late SharedPreferencesWithCache sharedPrefs;

// i wanted sharedPrefs to be global
// which means this file can't be a library
// so I had to put these in a class to mimic a library alias.

// ignore: camel_case_types
class shared_prefs {
  static bool _initialized = false;

  static Future<void> ensureInitialized() async {
    if (!_initialized) await _init();
  }

  static Future<void> _init() async {
    sharedPrefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: null,
      )
    );
    _initialized = true;
  }
}