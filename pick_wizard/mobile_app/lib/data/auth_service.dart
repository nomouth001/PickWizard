/// 034 OAuth: JWT 토큰 관리 (SecureStorage)
/// 책임: 토큰 저장/조회/삭제, 로그아웃

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthService {
  AuthService() : _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _keyAccessToken = 'luckyai645_access_token';

  final FlutterSecureStorage _storage;

  Future<String?> getToken() => _storage.read(key: _keyAccessToken);

  Future<void> setToken(String token) => _storage.write(key: _keyAccessToken, value: token);

  Future<void> clearToken() => _storage.delete(key: _keyAccessToken);

  /// 로그아웃: 저장된 토큰 삭제
  Future<void> logout() => clearToken();
}
