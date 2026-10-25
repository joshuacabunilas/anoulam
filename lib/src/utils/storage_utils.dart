import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Static wrapper around SharedPreferences. Call [getInstance] once at
/// startup (see main.dart) before using the getters and setters. Keys live
/// in `StorageHelper`.
class StorageUtil {
  StorageUtil._();

  static SharedPreferences? _preferences;

  static Future<void> getInstance() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get _prefs {
    final prefs = _preferences;
    if (prefs == null) {
      throw StateError('Call StorageUtil.getInstance() before using it.');
    }
    return prefs;
  }

  static String getString(String key, {String defValue = ''}) =>
      _prefs.getString(key) ?? defValue;

  static Future<bool> putString(String key, String value) =>
      _prefs.setString(key, value);

  static bool getBool(String key, {bool defValue = false}) =>
      _prefs.getBool(key) ?? defValue;

  static Future<bool> putBool(String key, {required bool value}) =>
      _prefs.setBool(key, value);

  static List<String> getStringList(String key) =>
      _prefs.getStringList(key) ?? const [];

  static Future<bool> putStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);

  static Future<bool> clearSingleData(String key) => _prefs.remove(key);

  /// Forgets the cached instance so tests can start from fresh mock values.
  @visibleForTesting
  static void reset() => _preferences = null;
}
