import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const _prefix = 'cache_';
  static const _ttlPrefix = 'ttl_';
  static const defaultTtl = Duration(minutes: 30);

  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  Future<void> put(String key, dynamic data, {Duration ttl = defaultTtl}) async {
    final jsonStr = jsonEncode(data);
    await _prefs.setString('$_prefix$key', jsonStr);
    await _prefs.setInt(
      '$_ttlPrefix$key',
      DateTime.now().add(ttl).millisecondsSinceEpoch,
    );
  }

  Future<T?> get<T>(String key) async {
    final ttl = await _prefs.getInt('$_ttlPrefix$key');
    if (ttl == null || DateTime.now().millisecondsSinceEpoch > ttl) {
      // Expired or not found
      await remove(key);
      return null;
    }
    final jsonStr = await _prefs.getString('$_prefix$key');
    if (jsonStr == null) return null;
    return jsonDecode(jsonStr) as T;
  }

  Future<void> remove(String key) async {
    await _prefs.remove('$_prefix$key');
    await _prefs.remove('$_ttlPrefix$key');
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
