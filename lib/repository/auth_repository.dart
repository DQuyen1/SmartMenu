import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthManager {
  static final AuthManager _instance = AuthManager._internal();
  factory AuthManager() => _instance;
  AuthManager._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _token;

  Future<void> setToken(String token) async {
    _token = token;
    await _storage.write(key: 'token', value: token);
  }

  Future<String?> getToken() async {
    if (_token != null) return _token;
    return await _storage.read(key: 'token');
  }

  // Future<void> clearToken() async {
  //   _token = null;
  //   await _storage.delete(key: 'token');
  // }
}
