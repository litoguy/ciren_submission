import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:campus_ai/core/constants/app_constants.dart';
import 'package:campus_ai/models/topic.dart';
import 'package:campus_ai/models/user.dart';
import 'package:campus_ai/services/storage_service.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);
  @override
  String toString() => message;
}

class ChatResponse {
  final String reply;
  final String? sessionId;
  final bool isGuest;
  ChatResponse({required this.reply, this.sessionId, required this.isGuest});
}

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final AppUser user;
  AuthResponse({required this.accessToken, required this.refreshToken, required this.user});
}

class ApiService {
  final String _base;
  ApiService([String? base]) : _base = base ?? AppConstants.apiBaseUrl;

  Map<String, String> _headers({bool withAuth = false}) {
    final h = {'Content-Type': 'application/json'};
    if (withAuth) {
      final token = StorageService.accessToken;
      if (token != null) h['Authorization'] = 'Bearer $token';
    }
    final sid = StorageService.sessionId;
    if (sid != null && !withAuth) h['X-Session-ID'] = sid;
    return h;
  }

  Map<String, dynamic> _parse(http.Response res) {
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 400 || body['success'] == false) {
      throw ApiException(
        body['error'] as String? ?? 'Something went wrong',
        res.statusCode,
      );
    }
    return body['data'] as Map<String, dynamic>;
  }

  // POST /api/chat
  Future<ChatResponse> chat(String message) async {
    final isAuth = StorageService.isAuthenticated;
    final res = await http.post(
      Uri.parse('$_base/api/chat'),
      headers: _headers(withAuth: isAuth),
      body: jsonEncode({'message': message}),
    );
    final sid = res.headers['x-session-id'];
    if (sid != null) await StorageService.setSessionId(sid);
    final data = _parse(res);
    return ChatResponse(
      reply: data['reply'] as String,
      sessionId: data['sessionId'] as String?,
      isGuest: data['isGuest'] as bool,
    );
  }

  // GET /api/topics
  Future<List<Topic>> getTopics() async {
    final res = await http.get(Uri.parse('$_base/api/topics'), headers: _headers());
    final data = _parse(res);
    return (data['topics'] as List).map((t) => Topic.fromJson(t)).toList();
  }

  // GET /api/faqs
  Future<List<Faq>> getFaqs() async {
    final res = await http.get(Uri.parse('$_base/api/faqs'), headers: _headers());
    final data = _parse(res);
    return (data['faqs'] as List).map((f) => Faq.fromJson(f)).toList();
  }

  // DELETE /api/chat/history
  Future<void> clearHistory() async {
    await http.delete(
      Uri.parse('$_base/api/chat/history'),
      headers: _headers(withAuth: StorageService.isAuthenticated),
    );
  }

  // POST /api/auth/register
  Future<AuthResponse> register(String name, String email, String password) async {
    final res = await http.post(
      Uri.parse('$_base/api/auth/register'),
      headers: _headers(),
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    final data = _parse(res);
    return AuthResponse(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
      user: AppUser.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  // POST /api/auth/login
  Future<AuthResponse> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$_base/api/auth/login'),
      headers: _headers(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = _parse(res);
    return AuthResponse(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
      user: AppUser.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  // POST /api/auth/refresh
  Future<AuthResponse> refreshToken(String token) async {
    final res = await http.post(
      Uri.parse('$_base/api/auth/refresh'),
      headers: _headers(),
      body: jsonEncode({'refreshToken': token}),
    );
    final data = _parse(res);
    return AuthResponse(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
      user: AppUser.fromJson(data['user'] as Map<String, dynamic>),
    );
  }
}
