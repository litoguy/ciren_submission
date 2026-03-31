import 'package:shared_preferences/shared_preferences.dart';
import 'package:campus_ai/core/constants/app_constants.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get _p {
    if (_prefs == null) throw StateError('StorageService not initialized');
    return _prefs!;
  }

  // Session ID (guest)
  static String? get sessionId => _p.getString(AppConstants.sessionIdKey);
  static Future<void> setSessionId(String id) =>
      _p.setString(AppConstants.sessionIdKey, id);

  // Tokens (authenticated)
  static String? get accessToken => _p.getString(AppConstants.accessTokenKey);
  static String? get refreshToken => _p.getString(AppConstants.refreshTokenKey);
  static Future<void> setTokens(String access, String refresh) async {
    await _p.setString(AppConstants.accessTokenKey, access);
    await _p.setString(AppConstants.refreshTokenKey, refresh);
  }
  static Future<void> clearTokens() async {
    await _p.remove(AppConstants.accessTokenKey);
    await _p.remove(AppConstants.refreshTokenKey);
  }

  // User name
  static String? get userName => _p.getString(AppConstants.userNameKey);
  static Future<void> setUserName(String name) =>
      _p.setString(AppConstants.userNameKey, name);

  static bool get isAuthenticated => accessToken != null;
}
