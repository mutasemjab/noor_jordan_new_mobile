import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class LocalStorage {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;

  LocalStorage(this._secureStorage, this._prefs);

  // ── Token ──────────────────────────────────────────────
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: AppConstants.tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: AppConstants.tokenKey);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: AppConstants.tokenKey);
  }

  // ── User Type ──────────────────────────────────────────
  Future<void> saveUserType(String type) async {
    await _prefs.setString(AppConstants.userTypeKey, type);
  }

  String? getUserType() => _prefs.getString(AppConstants.userTypeKey);

  // ── User Data ──────────────────────────────────────────
  Future<void> saveUserData(Map<String, dynamic> data) async {
    await _prefs.setString(AppConstants.userKey, jsonEncode(data));
  }

  Map<String, dynamic>? getUserData() {
    final raw = _prefs.getString(AppConstants.userKey);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // ── Cache ──────────────────────────────────────────────
  Future<void> cacheData(String key, dynamic data) async {
    await _prefs.setString(key, jsonEncode(data));
    await _prefs.setString(
        '${key}_${AppConstants.lastUpdateKey}',
        DateTime.now().toIso8601String());
  }

  dynamic getCachedData(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  String? getLastUpdateTime(String key) {
    return _prefs.getString('${key}_${AppConstants.lastUpdateKey}');
  }

  // ── Clear ──────────────────────────────────────────────
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    await _prefs.clear();
  }

  Future<void> clearUserSession() async {
    await _secureStorage.delete(key: AppConstants.tokenKey);
    await _prefs.remove(AppConstants.userKey);
    await _prefs.remove(AppConstants.userTypeKey);
  }
}
