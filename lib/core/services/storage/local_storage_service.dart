import 'package:shared_preferences/shared_preferences.dart';

/// Simple key-value storage — token + user role
class LocalStorageService {
  LocalStorageService._();
  static final LocalStorageService instance = LocalStorageService._();

  static SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token
  Future<void> saveToken(String token) async =>
      await _prefs!.setString('token', token);
  String? getToken() => _prefs?.getString('token');
  Future<void> clearToken() async => await _prefs!.remove('token');

  // Role: 'owner' | 'manager'
  Future<void> saveRole(String role) async =>
      await _prefs!.setString('role', role);
  String? getRole() => _prefs?.getString('role');

  // User name for display
  Future<void> saveName(String name) async =>
      await _prefs!.setString('name', name);
  String? getName() => _prefs?.getString('name');

  Future<void> clearAll() async => await _prefs!.clear();
}
