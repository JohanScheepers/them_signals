import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals_flutter/signals_core.dart';

/// A [SignalsKeyValueStore] backed by [SharedPreferences].
class SharedPreferencesStore implements SignalsKeyValueStore {
  final SharedPreferences prefs;
  SharedPreferencesStore(this.prefs);

  @override
  Future<String?> getItem(String key) async => prefs.getString(key);

  @override
  Future<void> removeItem(String key) async => prefs.remove(key);

  @override
  Future<void> setItem(String key, String value) async =>
      prefs.setString(key, value);
}
