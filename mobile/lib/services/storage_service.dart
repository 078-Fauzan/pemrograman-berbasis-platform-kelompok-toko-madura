import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/store_model.dart';

class StorageService {
  static const String _tokenKey = 'umkmate_jwt_token';
  static const String _userKey = 'umkmate_user_data';
  static const String _storeKey = 'umkmate_store_data';
  static const String _baseIpKey = 'umkmate_base_ip';

  /// Simpan sesi login (Token, User, Store)
  static Future<void> saveSession({
    required String token,
    required UserModel user,
    required StoreModel store,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    await prefs.setString(_storeKey, jsonEncode(store.toJson()));
  }

  /// Ambil token JWT
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Ambil data user yang tersimpan
  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJsonStr = prefs.getString(_userKey);
    if (userJsonStr == null) return null;
    try {
      final map = jsonDecode(userJsonStr);
      return UserModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  /// Ambil data toko yang tersimpan
  static Future<StoreModel?> getStore() async {
    final prefs = await SharedPreferences.getInstance();
    final storeJsonStr = prefs.getString(_storeKey);
    if (storeJsonStr == null) return null;
    try {
      final map = jsonDecode(storeJsonStr);
      return StoreModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  /// Hapus sesi (Logout)
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_storeKey);
  }

  /// Simpan & Ambil Custom Server IP
  static Future<void> saveBaseIp(String ip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseIpKey, ip);
  }

  static Future<String?> getBaseIp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_baseIpKey);
  }

  /// Cek apakah pengguna sudah memiliki token aktif
  static Future<bool> hasValidSession() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
