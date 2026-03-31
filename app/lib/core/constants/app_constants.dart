import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';

  static const appName = 'CampusAI';
  static const university = 'Central University Ghana';
  static const sessionIdKey = 'campus_ai_session_id';
  static const accessTokenKey = 'campus_ai_access_token';
  static const refreshTokenKey = 'campus_ai_refresh_token';
  static const userNameKey = 'campus_ai_user_name';
}
