# CampusAI Flutter App — Phase Plan (v2)

> **Architecture change from v1:** Gemini is in the API. The app calls the
> CampusAI API over HTTP. No `google_generative_ai` package in the app.
>
> **Priority:** Functionality first (Phases 0–5), UI polish last (Phases 6–8).
> A working ugly app beats a beautiful broken one at a hackathon demo.
>
> **Workflow:** Claude handles architecture and spec. Gemini CLI executes.
> **Flutter binary:** `/Users/kevinafenyo/flutter/bin/flutter`
> **Project root:** `/Users/kevinafenyo/Documents/GitHub/gemini/campusAI/app`
> **API contracts:** `/Users/kevinafenyo/Documents/GitHub/gemini/campusAI/api/CONTRACTS.md`
> **Log file:** `app/LOG.md`
> **Handoff:** `app/CONTINUE.md`

---

## Architecture

```
Flutter App
    │
    ├── ApiService          ← HTTP client, talks to CampusAI API
    ├── StorageService      ← SharedPreferences (sessionId, tokens, name)
    ├── ChatProvider        ← Riverpod state: messages, loading
    ├── TopicsProvider      ← Riverpod state: topics + FAQs from API
    └── AuthProvider        ← Riverpod state: user, tokens (optional)
```

The app never calls Gemini directly. Every AI interaction goes through
`POST /api/chat`. Topics and FAQs are fetched from `GET /api/topics`
and `GET /api/faqs`. Auth is optional — guest mode must always work.

---

## Dependency List

```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  go_router: ^14.2.0
  google_fonts: ^6.2.1
  flutter_animate: ^4.5.0
  http: ^1.2.1
  shared_preferences: ^2.2.3
  flutter_dotenv: ^5.1.0

dev_dependencies:
  flutter_lints: ^3.0.0
```

> `google_generative_ai` is NOT in the app. Removed from v1.

---

## Folder Structure (target)

```
lib/
├── core/
│   ├── theme/
│   │   └── app_theme.dart          ← Colors + typography
│   └── constants/
│       └── app_constants.dart      ← API base URL, keys
├── models/
│   ├── chat_message.dart           ← Message model
│   ├── topic.dart                  ← Topic model
│   └── user.dart                   ← User model (optional auth)
├── services/
│   ├── api_service.dart            ← All HTTP calls to the API
│   └── storage_service.dart        ← SharedPreferences wrapper
├── providers/
│   ├── chat_provider.dart          ← Chat messages + send logic
│   ├── topics_provider.dart        ← Topics + FAQs state
│   └── auth_provider.dart          ← Auth state (optional)
├── features/
│   ├── splash/
│   │   └── splash_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── chat/
│   │   └── chat_screen.dart
│   ├── topics/
│   │   └── topics_screen.dart
│   └── shell/
│       └── scaffold_with_nav.dart  ← Bottom nav shell
└── router/
    └── app_router.dart
```

---

## Pages (4)
1. **Splash** — Logo, glow, auto-navigate to Home at 2.5s
2. **Home** — Greeting, ambient glow, topic cards, input bar
3. **Chat** — Message list + input, calls API
4. **Topics/FAQ** — Topic grid + FAQ list, pre-fills chat

---

## Phase 0 — Project Bootstrap
**Time estimate:** 25 minutes
**Owner:** Gemini executes

### Goal
Create the Flutter project, install correct dependencies (no Gemini SDK),
set up folder structure, configure fonts, verify clean build.

### Pre-flight reads
- None (clean project)

### Actions

**[GEMINI EXECUTES]** Step 0.1 — Create Flutter project
```bash
cd /Users/kevinafenyo/Documents/GitHub/gemini/campusAI/app
/Users/kevinafenyo/flutter/bin/flutter create . \
  --org com.ktinnovations \
  --project-name campus_ai
```

**[GEMINI EXECUTES]** Step 0.2 — Rewrite `pubspec.yaml` dependencies section
Replace the generated dependencies block with:
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  go_router: ^14.2.0
  google_fonts: ^6.2.1
  flutter_animate: ^4.5.0
  http: ^1.2.1
  shared_preferences: ^2.2.3
  flutter_dotenv: ^5.1.0

dev_dependencies:
  flutter:
    sdk: flutter
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

Add under `flutter:` section:
```yaml
  fonts:
    - family: PlayfairDisplay
      fonts:
        - asset: assets/fonts/PlayfairDisplay-Bold.ttf
          weight: 700
    - family: DMSans
      fonts:
        - asset: assets/fonts/DMSans-Regular.ttf
          weight: 400
        - asset: assets/fonts/DMSans-Medium.ttf
          weight: 500
  assets:
    - assets/fonts/
    - assets/images/
    - .env
```

**[GEMINI EXECUTES]** Step 0.3 — Create folders
```bash
mkdir -p /Users/kevinafenyo/Documents/GitHub/gemini/campusAI/app/assets/fonts
mkdir -p /Users/kevinafenyo/Documents/GitHub/gemini/campusAI/app/assets/images
mkdir -p /Users/kevinafenyo/Documents/GitHub/gemini/campusAI/app/lib/core/theme
mkdir -p /Users/kevinafenyo/Documents/GitHub/gemini/campusAI/app/lib/core/constants
mkdir -p /Users/kevinafenyo/Documents/GitHub/gemini/campusAI/app/lib/models
mkdir -p /Users/kevinafenyo/Documents/GitHub/gemini/campusAI/app/lib/services
mkdir -p /Users/kevinafenyo/Documents/GitHub/gemini/campusAI/app/lib/providers
mkdir -p /Users/kevinafenyo/Documents/GitHub/gemini/campusAI/app/lib/features/splash
mkdir -p /Users/kevinafenyo/Documents/GitHub/gemini/campusAI/app/lib/features/home
mkdir -p /Users/kevinafenyo/Documents/GitHub/gemini/campusAI/app/lib/features/chat
mkdir -p /Users/kevinafenyo/Documents/GitHub/gemini/campusAI/app/lib/features/topics
mkdir -p /Users/kevinafenyo/Documents/GitHub/gemini/campusAI/app/lib/features/shell
mkdir -p /Users/kevinafenyo/Documents/GitHub/gemini/campusAI/app/lib/router
```

**[GEMINI EXECUTES]** Step 0.4 — Download fonts
```bash
cd /Users/kevinafenyo/Documents/GitHub/gemini/campusAI/app/assets/fonts
curl -L "https://fonts.gstatic.com/s/playfairdisplay/v37/nuFvD-vYSZviVYUb_rj3ij__anPXJzDwcbmjWBN2PKdFvXDXbtM.ttf" \
  -o PlayfairDisplay-Bold.ttf
curl -L "https://fonts.gstatic.com/s/dmsans/v15/rP2Hp2ywxg089UriCZa4ET-DNl0.ttf" \
  -o DMSans-Regular.ttf
curl -L "https://fonts.gstatic.com/s/dmsans/v15/rP2Cp2ywxg089UriAAfhel8f.ttf" \
  -o DMSans-Medium.ttf
```

**[GEMINI EXECUTES]** Step 0.5 — Create `.env`
```
API_BASE_URL=http://10.0.2.2:3000
```
> Note: `10.0.2.2` is Android emulator localhost. Use `localhost` for iOS sim
> or real device on same network as the API server.

**[GEMINI EXECUTES]** Step 0.6 — Add `.env` to `.gitignore`
Append to `.gitignore`:
```
.env
```

**[GEMINI EXECUTES]** Step 0.7 — Install packages
```bash
cd /Users/kevinafenyo/Documents/GitHub/gemini/campusAI/app
/Users/kevinafenyo/flutter/bin/flutter pub get
```

### Verification
```bash
/Users/kevinafenyo/flutter/bin/flutter analyze
```
Expected: `No issues found!`

### LOG.md entry
```
## Phase 0 — Project Bootstrap
- Date: [DATE]
- Status: COMPLETE
- Files created: pubspec.yaml, .env, lib/ structure (12 dirs), font assets
- Note: google_generative_ai NOT included — API handles Gemini
- Verification: flutter analyze — no issues
```

---

## Phase 1 — Theme + App Constants
**Time estimate:** 20 minutes
**Owner:** Claude writes spec, Gemini executes

### Goal
Define all colors, typography, and the API base URL constant. Everything
else in the app imports from here. No routing yet — just the design tokens.

### Pre-flight reads
- `pubspec.yaml` (confirm fonts listed)

### Actions

**[CLAUDE HANDLES]** — Write `lib/core/theme/app_theme.dart`
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const background    = Color(0xFF0F0205);
  static const surface       = Color(0xFF120508);
  static const cardIcon      = Color(0xFF1E0A0C);
  static const primary       = Color(0xFF8B1A2B);
  static const primaryDark   = Color(0xFF5E0F1A);
  static const primaryLight  = Color(0xFFB02438);
  static const gold          = Color(0xFFC9922A);
  static const goldLight     = Color(0xFFE8B455);
  static const textPrimary   = Color(0xFFFFFFFF);
  static const textSecondary = Color(0x99FFFFFF);
  static const textMuted     = Color(0x4DFFFFFF);
  static const error         = Color(0xFFE53935);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.gold,
      surface: AppColors.surface,
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
      ),
      titleLarge: GoogleFonts.dmSans(
        fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textPrimary,
      ),
      bodyLarge: GoogleFonts.dmSans(
        fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimary,
      ),
      bodyMedium: GoogleFonts.dmSans(
        fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary,
      ),
      bodySmall: GoogleFonts.dmSans(
        fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textMuted,
      ),
    ),
    useMaterial3: true,
  );
}
```

**[CLAUDE HANDLES]** — Write `lib/core/constants/app_constants.dart`
```dart
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
```

### Verification
```bash
/Users/kevinafenyo/flutter/bin/flutter analyze
```

### LOG.md entry
```
## Phase 1 — Theme + App Constants
- Date: [DATE]
- Status: COMPLETE
- Files created: lib/core/theme/app_theme.dart, lib/core/constants/app_constants.dart
- Verification: flutter analyze — no issues
```

---

## Phase 2 — Models + ApiService + StorageService
**Time estimate:** 30 minutes
**Owner:** Claude writes spec, Gemini executes

### Goal
Define all data models and build the two core services:
- `ApiService` — all HTTP calls matching CONTRACTS.md exactly
- `StorageService` — SharedPreferences wrapper for tokens and sessionId

This is the most critical phase. Everything else depends on it.

### Pre-flight reads
- `/Users/kevinafenyo/Documents/GitHub/gemini/campusAI/api/CONTRACTS.md`
- `lib/core/constants/app_constants.dart`

### Actions

**[CLAUDE HANDLES]** — Write `lib/models/chat_message.dart`
```dart
enum MessageRole { user, assistant }

class ChatMessage {
  final String text;
  final MessageRole role;
  final DateTime timestamp;

  const ChatMessage({
    required this.text,
    required this.role,
    required this.timestamp,
  });
}
```

**[CLAUDE HANDLES]** — Write `lib/models/topic.dart`
```dart
class Topic {
  final String id;
  final String label;
  final String icon;
  final String prompt;

  const Topic({
    required this.id,
    required this.label,
    required this.icon,
    required this.prompt,
  });

  factory Topic.fromJson(Map<String, dynamic> j) => Topic(
    id: j['id'] as String,
    label: j['label'] as String,
    icon: j['icon'] as String,
    prompt: j['prompt'] as String,
  );
}

class Faq {
  final int id;
  final String question;

  const Faq({required this.id, required this.question});

  factory Faq.fromJson(Map<String, dynamic> j) => Faq(
    id: j['id'] as int,
    question: j['question'] as String,
  );
}
```

**[CLAUDE HANDLES]** — Write `lib/models/user.dart`
```dart
class AppUser {
  final String id;
  final String name;
  final String email;

  const AppUser({required this.id, required this.name, required this.email});

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
    id: j['id'] as String,
    name: j['name'] as String,
    email: j['email'] as String,
  );
}
```

**[CLAUDE HANDLES]** — Write `lib/services/storage_service.dart`
```dart
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
```

**[CLAUDE HANDLES]** — Write `lib/services/api_service.dart`
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:campus_ai/core/constants/app_constants.dart';
import 'package:campus_ai/models/chat_message.dart';
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
```

### Verification
```bash
/Users/kevinafenyo/flutter/bin/flutter analyze
```
Expected: No issues.

### LOG.md entry
```
## Phase 2 — Models + ApiService + StorageService
- Date: [DATE]
- Status: COMPLETE
- Files created: lib/models/chat_message.dart, lib/models/topic.dart,
  lib/models/user.dart, lib/services/storage_service.dart,
  lib/services/api_service.dart
- Verification: flutter analyze — no issues
```

---

## Phase 3 — Riverpod Providers
**Time estimate:** 20 minutes
**Owner:** Claude writes spec, Gemini executes

### Goal
Wire up all state providers. These connect ApiService to the UI. After this
phase, the business logic is complete — the UI just reads and writes providers.

### Pre-flight reads
- `lib/services/api_service.dart`
- `lib/services/storage_service.dart`
- `lib/models/chat_message.dart`
- `lib/models/topic.dart`

### Actions

**[CLAUDE HANDLES]** — Write `lib/providers/chat_provider.dart`
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_ai/models/chat_message.dart';
import 'package:campus_ai/services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final isLoadingProvider = StateProvider<bool>((ref) => false);

final chatProvider =
    StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  return ChatNotifier(ref.read(apiServiceProvider), ref);
});

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final ApiService _api;
  final Ref _ref;

  ChatNotifier(this._api, this._ref) : super([]);

  Future<void> send(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message immediately
    state = [
      ...state,
      ChatMessage(text: text.trim(), role: MessageRole.user, timestamp: DateTime.now()),
    ];

    _ref.read(isLoadingProvider.notifier).state = true;

    try {
      final response = await _api.chat(text.trim());
      state = [
        ...state,
        ChatMessage(
          text: response.reply,
          role: MessageRole.assistant,
          timestamp: DateTime.now(),
        ),
      ];
    } on ApiException catch (e) {
      state = [
        ...state,
        ChatMessage(
          text: 'Error: ${e.message}',
          role: MessageRole.assistant,
          timestamp: DateTime.now(),
        ),
      ];
    } finally {
      _ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  Future<void> clear() async {
    await _api.clearHistory();
    state = [];
  }
}
```

**[CLAUDE HANDLES]** — Write `lib/providers/topics_provider.dart`
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_ai/models/topic.dart';
import 'package:campus_ai/providers/chat_provider.dart';

// FutureProvider automatically handles loading/error states
final topicsProvider = FutureProvider<List<Topic>>((ref) async {
  return ref.read(apiServiceProvider).getTopics();
});

final faqsProvider = FutureProvider<List<Faq>>((ref) async {
  return ref.read(apiServiceProvider).getFaqs();
});
```

**[CLAUDE HANDLES]** — Write `lib/providers/auth_provider.dart`
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_ai/models/user.dart';
import 'package:campus_ai/providers/chat_provider.dart';
import 'package:campus_ai/services/storage_service.dart';

class AuthState {
  final AppUser? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  bool get isAuthenticated => user != null;
  AuthState copyWith({AppUser? user, bool? isLoading, String? error}) =>
      AuthState(user: user ?? this.user, isLoading: isLoading ?? this.isLoading, error: error);
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;
  AuthNotifier(this._ref) : super(const AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _ref.read(apiServiceProvider).login(email, password);
      await StorageService.setTokens(res.accessToken, res.refreshToken);
      await StorageService.setUserName(res.user.name);
      state = AuthState(user: res.user);
    } on Exception catch (e) {
      state = AuthState(error: e.toString());
    }
  }

  Future<void> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _ref.read(apiServiceProvider).register(name, email, password);
      await StorageService.setTokens(res.accessToken, res.refreshToken);
      await StorageService.setUserName(res.user.name);
      state = AuthState(user: res.user);
    } on Exception catch (e) {
      state = AuthState(error: e.toString());
    }
  }

  Future<void> logout() async {
    await StorageService.clearTokens();
    state = const AuthState();
  }
}
```

### Verification
```bash
/Users/kevinafenyo/flutter/bin/flutter analyze
```

### LOG.md entry
```
## Phase 3 — Riverpod Providers
- Date: [DATE]
- Status: COMPLETE
- Files created: lib/providers/chat_provider.dart,
  lib/providers/topics_provider.dart, lib/providers/auth_provider.dart
- Verification: flutter analyze — no issues
```

---

## Phase 4 — Router + main.dart + Stub Screens
**Time estimate:** 20 minutes
**Owner:** Claude writes spec, Gemini executes

### Goal
Wire up GoRouter with all 4 routes + bottom nav shell. Write main.dart with
StorageService init. Create stub screens so the whole app compiles and runs.
After this phase: the app launches, navigates between screens, nothing crashes.

### Pre-flight reads
- `lib/core/constants/app_constants.dart`
- `lib/providers/chat_provider.dart`

### Actions

**[CLAUDE HANDLES]** — Write `lib/router/app_router.dart`
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_ai/features/splash/splash_screen.dart';
import 'package:campus_ai/features/chat/chat_screen.dart';
import 'package:campus_ai/features/topics/topics_screen.dart';
import 'package:campus_ai/features/home/home_screen.dart';
import 'package:campus_ai/features/shell/scaffold_with_nav.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (_, __) => const SplashScreen(),
    ),
    ShellRoute(
      builder: (_, __, child) => ScaffoldWithNav(child: child),
      routes: [
        GoRoute(path: '/home',   builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/topics', builder: (_, __) => const TopicsScreen()),
        GoRoute(
          path: '/chat',
          builder: (_, state) => ChatScreen(
            initialMessage: state.uri.queryParameters['message'],
          ),
        ),
      ],
    ),
  ],
);
```

**[CLAUDE HANDLES]** — Write `lib/features/shell/scaffold_with_nav.dart`
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_ai/core/theme/app_theme.dart';

class ScaffoldWithNav extends StatelessWidget {
  final Widget child;
  const ScaffoldWithNav({super.key, required this.child});

  int _locationIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.path;
    if (loc.startsWith('/home'))   return 0;
    if (loc.startsWith('/chat'))   return 1;
    if (loc.startsWith('/topics')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final idx = _locationIndex(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: child,
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withOpacity(0.2),
        selectedIndex: idx,
        onDestinationSelected: (i) {
          switch (i) {
            case 0: context.go('/home');
            case 1: context.go('/chat');
            case 2: context.go('/topics');
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.gold), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble, color: AppColors.gold), label: 'Chat'),
          NavigationDestination(icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view, color: AppColors.gold), label: 'Topics'),
        ],
      ),
    );
  }
}
```

**[CLAUDE HANDLES]** — Write `lib/main.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_ai/core/theme/app_theme.dart';
import 'package:campus_ai/router/app_router.dart';
import 'package:campus_ai/services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await StorageService.init();
  runApp(const ProviderScope(child: CampusAIApp()));
}

class CampusAIApp extends StatelessWidget {
  const CampusAIApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'CampusAI',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.dark,
    routerConfig: appRouter,
  );
}
```

**[GEMINI EXECUTES]** — Create functional stub screens
Each screen is a minimal but compilable Scaffold. ChatScreen needs its
`initialMessage` parameter. All others are simple stubs.

`lib/features/splash/splash_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_ai/core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  @override void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) context.go('/home');
    });
  }
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: const Center(child: Text('CampusAI', style: TextStyle(color: Colors.white, fontSize: 32))),
  );
}
```

`lib/features/home/home_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_ai/core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('Home', style: TextStyle(color: Colors.white, fontSize: 24)),
      const SizedBox(height: 16),
      ElevatedButton(
        onPressed: () => context.go('/chat'),
        child: const Text('Go to Chat'),
      ),
    ])),
  );
}
```

`lib/features/chat/chat_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:campus_ai/core/theme/app_theme.dart';

class ChatScreen extends StatelessWidget {
  final String? initialMessage;
  const ChatScreen({super.key, this.initialMessage});
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: Center(child: Text(
      'Chat${initialMessage != null ? ": $initialMessage" : ""}',
      style: const TextStyle(color: Colors.white),
    )),
  );
}
```

`lib/features/topics/topics_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:campus_ai/core/theme/app_theme.dart';

class TopicsScreen extends StatelessWidget {
  const TopicsScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: const Center(child: Text('Topics', style: TextStyle(color: Colors.white))),
  );
}
```

### Verification
```bash
/Users/kevinafenyo/flutter/bin/flutter analyze
/Users/kevinafenyo/flutter/bin/flutter run   # app should launch and navigate
```
Confirm: splash shows → auto-navigates to home → bottom nav shows → all 3 tabs switch.

### LOG.md entry
```
## Phase 4 — Router + main.dart + Stub Screens
- Date: [DATE]
- Status: COMPLETE
- Files created: lib/router/app_router.dart, lib/features/shell/scaffold_with_nav.dart,
  lib/main.dart, 4x stub screens
- Verification: app launches, navigation confirmed, no crashes
```

---

## Phase 5 — Functional Chat Screen
**Time estimate:** 45 minutes
**Owner:** Claude writes spec, Gemini executes
**PREREQUISITE:** API must be running at `API_BASE_URL`

### Goal
Replace the Chat stub with a fully functional screen. Messages send to the
API. Responses render. Typing indicator shows while waiting. This is the
core feature — it must work before any polish happens.

### Pre-flight reads
- `lib/features/chat/chat_screen.dart` (current stub)
- `lib/providers/chat_provider.dart`
- `lib/models/chat_message.dart`
- `lib/core/theme/app_theme.dart`

### Actions

**[CLAUDE HANDLES]** — Write `lib/features/chat/chat_screen.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campus_ai/core/theme/app_theme.dart';
import 'package:campus_ai/models/chat_message.dart';
import 'package:campus_ai/providers/chat_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String? initialMessage;
  const ChatScreen({super.key, this.initialMessage});
  @override ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    // If launched from a topic/FAQ, send the pre-filled message
    if (widget.initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(chatProvider.notifier).send(widget.initialMessage!);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    ref.read(chatProvider.notifier).send(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider);
    final isLoading = ref.watch(isLoadingProvider);

    // Auto-scroll when messages change
    ref.listen(chatProvider, (_, __) => _scrollToBottom());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('CampusAI',
          style: GoogleFonts.playfairDisplay(color: AppColors.textPrimary, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textMuted),
            onPressed: () => ref.read(chatProvider.notifier).clear(),
            tooltip: 'Clear chat',
          ),
        ],
      ),
      body: Column(children: [
        // Messages list
        Expanded(
          child: messages.isEmpty
            ? Center(child: Text(
                'Ask me anything about Central University',
                style: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 14),
                textAlign: TextAlign.center,
              ))
            : ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length + (isLoading ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i == messages.length) return const _TypingIndicator();
                  return _MessageBubble(message: messages[i], isFirst: i == 1);
                },
              ),
        ),
        // Input row
        _InputRow(controller: _controller, onSend: _send),
      ]),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isFirst;
  const _MessageBubble({required this.message, this.isFirst = false});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(crossAxisAlignment:
          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isUser ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isUser ? 16 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 16),
              ),
            ),
            child: Text(message.text,
              style: GoogleFonts.dmSans(
                color: AppColors.textPrimary, fontSize: 14, height: 1.5)),
          ),
          // "Verify with office" disclaimer under first bot response only
          if (!isUser && isFirst)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text('Please verify important details with the relevant office.',
                style: GoogleFonts.dmSans(
                  color: AppColors.gold, fontSize: 11)),
            ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();
  @override State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: List.generate(3, (i) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          final v = ((_ctrl.value + i * 0.33) % 1.0);
          final scale = 0.6 + 0.4 * (v < 0.5 ? v * 2 : (1 - v) * 2);
          return Container(
            width: 8, height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            transform: Matrix4.diagonal3Values(scale, scale, 1),
            decoration: const BoxDecoration(
              color: AppColors.gold, shape: BoxShape.circle),
          );
        },
      ))),
    );
  }
}

class _InputRow extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  const _InputRow({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
    decoration: const BoxDecoration(
      color: AppColors.surface,
      border: Border(top: BorderSide(color: AppColors.cardIcon)),
    ),
    child: Row(children: [
      Expanded(child: TextField(
        controller: controller,
        style: GoogleFonts.dmSans(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Ask about fees, exams, registration...',
          hintStyle: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 13),
          filled: true,
          fillColor: AppColors.cardIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onSubmitted: (_) => onSend(),
        textInputAction: TextInputAction.send,
      )),
      const SizedBox(width: 10),
      GestureDetector(
        onTap: onSend,
        child: Container(
          width: 44, height: 44,
          decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
          child: const Icon(Icons.send, color: Colors.white, size: 20),
        ),
      ),
    ]),
  );
}
```

### Verification
```bash
/Users/kevinafenyo/flutter/bin/flutter analyze
```
Live test with API running:
1. Open app → tap Chat tab
2. Type "What are the fees for Engineering?" → tap send
3. Confirm: user bubble appears immediately, typing indicator shows, bot reply arrives
4. Confirm: disclaimer shows under first bot reply
5. Tap refresh icon → chat clears

### LOG.md entry
```
## Phase 5 — Functional Chat Screen
- Date: [DATE]
- Status: COMPLETE
- Files modified: lib/features/chat/chat_screen.dart
- Verification: flutter analyze clean, full chat flow confirmed with live API
```

---

## Phase 6 — Functional Topics + Home Screens
**Time estimate:** 35 minutes
**Owner:** Claude writes spec, Gemini executes

### Goal
Replace Topics and Home stubs with functional implementations that fetch
real data from the API and navigate to Chat with pre-filled messages.

### Pre-flight reads
- `lib/features/topics/topics_screen.dart` (stub)
- `lib/features/home/home_screen.dart` (stub)
- `lib/providers/topics_provider.dart`
- `lib/core/theme/app_theme.dart`

### Actions

**[CLAUDE HANDLES]** — Write `lib/features/topics/topics_screen.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campus_ai/core/theme/app_theme.dart';
import 'package:campus_ai/providers/topics_provider.dart';

class TopicsScreen extends ConsumerWidget {
  const TopicsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicsAsync = ref.watch(topicsProvider);
    final faqsAsync  = ref.watch(faqsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('Topics & FAQ',
          style: GoogleFonts.playfairDisplay(color: AppColors.textPrimary, fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Topic grid
          Text('Quick Topics',
            style: GoogleFonts.dmSans(color: AppColors.textMuted,
              fontSize: 11, letterSpacing: 1, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          topicsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
            error: (e, _) => Text('Could not load topics. $e',
              style: GoogleFonts.dmSans(color: AppColors.error)),
            data: (topics) => GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 1.5,
                crossAxisSpacing: 10, mainAxisSpacing: 10,
              ),
              itemCount: topics.length,
              itemBuilder: (_, i) {
                final t = topics[i];
                return GestureDetector(
                  onTap: () => context.go('/chat?message=${Uri.encodeComponent(t.prompt)}'),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardIcon),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(t.icon, style: const TextStyle(fontSize: 22)),
                        const SizedBox(height: 6),
                        Text(t.label,
                          style: GoogleFonts.dmSans(color: AppColors.textPrimary,
                            fontSize: 12, fontWeight: FontWeight.w500)),
                      ]),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // FAQ list
          Text('Frequently Asked Questions',
            style: GoogleFonts.dmSans(color: AppColors.textMuted,
              fontSize: 11, letterSpacing: 1, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          faqsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
            error: (e, _) => Text('Could not load FAQs. $e',
              style: GoogleFonts.dmSans(color: AppColors.error)),
            data: (faqs) => Column(
              children: faqs.map((f) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(f.question,
                  style: GoogleFonts.dmSans(color: AppColors.textPrimary, fontSize: 13)),
                trailing: const Icon(Icons.arrow_forward_ios,
                  color: AppColors.gold, size: 14),
                onTap: () => context.go('/chat?message=${Uri.encodeComponent(f.question)}'),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
```

**[CLAUDE HANDLES]** — Write `lib/features/home/home_screen.dart`
Functional home: greeting, quick-tap topic cards (from API), input bar that navigates to chat.
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campus_ai/core/theme/app_theme.dart';
import 'package:campus_ai/providers/topics_provider.dart';
import 'package:campus_ai/services/storage_service.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning,';
    if (h < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicsAsync = ref.watch(topicsProvider);
    final name = StorageService.userName ?? 'Student';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(children: [
        // Ambient glow
        Positioned(
          top: 0, left: 0, right: 0,
          height: MediaQuery.of(context).size.height * 0.55,
          child: Container(decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.3), radius: 0.75,
              colors: [Color(0x558B1A2B), Color(0x1A8B1A2B), Color(0x000F0205)],
            ),
          )),
        ),
        SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_greeting(),
                  style: GoogleFonts.playfairDisplay(
                    color: AppColors.textSecondary, fontSize: 22)),
                Text(name, style: GoogleFonts.playfairDisplay(
                  color: AppColors.textPrimary, fontSize: 36, fontWeight: FontWeight.w700)),
              ]),
            ),
            const Spacer(),
            // Bottom sheet content
            Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Quick Topics',
                      style: GoogleFonts.dmSans(color: AppColors.textMuted,
                        fontSize: 11, letterSpacing: 1))),
                  const SizedBox(height: 10),
                  // Topics horizontal scroll
                  SizedBox(height: 90, child: topicsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (topics) => ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemCount: topics.length,
                      itemBuilder: (_, i) {
                        final t = topics[i];
                        return GestureDetector(
                          onTap: () => context.go(
                            '/chat?message=${Uri.encodeComponent(t.prompt)}'),
                          child: Container(
                            width: 90,
                            decoration: BoxDecoration(
                              color: AppColors.cardIcon,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(t.icon, style: const TextStyle(fontSize: 24)),
                                const SizedBox(height: 4),
                                Text(t.label, textAlign: TextAlign.center,
                                  style: GoogleFonts.dmSans(
                                    color: AppColors.textSecondary, fontSize: 10),
                                  maxLines: 2, overflow: TextOverflow.ellipsis),
                              ]),
                          ),
                        );
                      },
                    ),
                  )),
                  // Input bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: GestureDetector(
                      onTap: () => context.go('/chat'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.cardIcon,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Row(children: [
                          Expanded(child: Text('Ask CampusAI anything...',
                            style: GoogleFonts.dmSans(
                              color: AppColors.textMuted, fontSize: 14))),
                          Container(width: 36, height: 36,
                            decoration: const BoxDecoration(
                              color: AppColors.gold, shape: BoxShape.circle),
                            child: const Icon(Icons.mic, color: Colors.white, size: 18)),
                        ]),
                      ),
                    ),
                  ),
                ]),
            ),
          ]),
        ),
      ]),
    );
  }
}
```

### Verification
```bash
/Users/kevinafenyo/flutter/bin/flutter analyze
```
Live test:
1. Home screen: topics load from API, tapping a topic card navigates to chat with pre-fill
2. Topics screen: grid loads, FAQ list loads, tapping any item navigates to chat

### LOG.md entry
```
## Phase 6 — Functional Topics + Home Screens
- Date: [DATE]
- Status: COMPLETE
- Files modified: lib/features/topics/topics_screen.dart, lib/features/home/home_screen.dart
- Verification: flutter analyze clean, API data loads, navigation confirmed
```

---

## Phase 7 — Splash Screen Polish
**Time estimate:** 20 minutes
**Owner:** Claude writes spec, Gemini executes

### Goal
Replace the splash stub with the polished version — maroon glow, CU branding,
fade animations, auto-navigate. This is purely visual, functionality is done.

### Pre-flight reads
- `lib/features/splash/splash_screen.dart` (current stub)
- `lib/core/theme/app_theme.dart`

### Actions

**[CLAUDE HANDLES]** — Write `lib/features/splash/splash_screen.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campus_ai/core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) context.go('/home');
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: Stack(children: [
      // Ambient maroon glow
      Positioned.fill(child: Container(decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.2), radius: 0.75,
          colors: [Color(0x668B1A2B), Color(0x228B1A2B), Color(0x000F0205)],
        ),
      ))),
      // Center content
      Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        // CU logo placeholder
        Container(
          width: 88, height: 88,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.gold.withOpacity(0.5), width: 1.5),
          ),
          child: const Icon(Icons.school_rounded, color: AppColors.gold, size: 44),
        ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.7, 0.7)),
        const SizedBox(height: 28),
        Text('CampusAI',
          style: GoogleFonts.playfairDisplay(
            fontSize: 40, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(begin: 0.3),
        const SizedBox(height: 8),
        Text('Central University Ghana',
          style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textSecondary),
        ).animate().fadeIn(delay: 500.ms, duration: 600.ms),
        const SizedBox(height: 4),
        Text('Your AI campus guide',
          style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.w500),
        ).animate().fadeIn(delay: 700.ms, duration: 600.ms),
      ])),
      // Bottom label
      Positioned(bottom: 40, left: 0, right: 0,
        child: Text('Powered by Google Gemini',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textMuted),
        ).animate().fadeIn(delay: 1000.ms),
      ),
    ]),
  );
}
```

### Verification
```bash
/Users/kevinafenyo/flutter/bin/flutter analyze
```
Visual: glow renders, logo fades in, text staggers, auto-navigates at 2.5s.

### LOG.md entry
```
## Phase 7 — Splash Screen Polish
- Date: [DATE]
- Status: COMPLETE
- Files modified: lib/features/splash/splash_screen.dart
- Verification: flutter analyze clean, animations confirmed on device
```

---

## Phase 8 — Full Polish Pass
**Time estimate:** 30 minutes
**Owner:** Claude writes spec, Gemini executes

### Goal
Final visual and UX polish pass across all screens before demo:
- Bottom nav icon colors and active states
- Error states on Topics screen (retry button)
- Empty state on Chat screen
- Loading spinner colors match gold
- No console errors or analyze warnings

### Actions

**[CLAUDE HANDLES]** — These are small targeted fixes.
Claude will produce the exact edit_block specs for each fix in this session
when Phase 8 is triggered — they are too context-dependent to pre-spec.

Key fixes to address:
1. `NavigationBar` theme — force selected icon/indicator to gold, unselected to muted white
2. Topics screen error state — add retry button that calls `ref.invalidate(topicsProvider)`
3. Chat empty state — improve copy and centering with CU logo icon
4. AppBar backgrounds — ensure all match `AppColors.surface` not Material default
5. Keyboard safe area — ensure input bars clear keyboard on all screen sizes
6. `flutter analyze` — fix any remaining lint warnings

### Verification
```bash
/Users/kevinafenyo/flutter/bin/flutter analyze
```
Full walkthrough: Splash → Home → Chat (3 messages) → Topics → tap FAQ → Chat with pre-fill.
No visual glitches, no crashes, no lint issues.

### LOG.md entry
```
## Phase 8 — Full Polish Pass
- Date: [DATE]
- Status: COMPLETE
- Fixes applied: [list specific files changed]
- Verification: flutter analyze clean, full demo walkthrough complete
```

---

## Phase 9 — Build + Demo Prep
**Time estimate:** 20 minutes
**Owner:** Gemini executes

### Goal
Build the release APK. Final end-to-end test with live API.

### Actions

**[GEMINI EXECUTES]** — Build APK
```bash
cd /Users/kevinafenyo/Documents/GitHub/gemini/campusAI/app
/Users/kevinafenyo/flutter/bin/flutter build apk --release --split-per-abi
```

**[GEMINI EXECUTES]** — Install to device
```bash
/Users/kevinafenyo/flutter/bin/flutter install
```

**[GEMINI EXECUTES]** — Final analyze
```bash
/Users/kevinafenyo/flutter/bin/flutter analyze
```

### Verification
Manual walkthrough on physical device with API server running.
Check all 4 screens, confirm no crashes, confirm live Gemini responses.

### LOG.md entry
```
## Phase 9 — Build + Demo Prep
- Date: [DATE]
- Status: COMPLETE
- APK: build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
- Verification: Full walkthrough on device — no crashes
```

---

## Phase Summary

| Phase | Description | Est. Time | Focus | Status |
|---|---|---|---|---|
| 0 | Project Bootstrap | 25 min | Foundation | ⬜ |
| 1 | Theme + Constants | 20 min | Foundation | ⬜ |
| 2 | Models + ApiService + Storage | 30 min | **Functionality** | ⬜ |
| 3 | Riverpod Providers | 20 min | **Functionality** | ⬜ |
| 4 | Router + Shell + Stubs | 20 min | **Functionality** | ⬜ |
| 5 | Functional Chat Screen | 45 min | **Functionality** | ⬜ |
| 6 | Functional Topics + Home | 35 min | **Functionality** | ⬜ |
| 7 | Splash Polish | 20 min | UI Polish | ⬜ |
| 8 | Full Polish Pass | 30 min | UI Polish | ⬜ |
| 9 | Build + Demo Prep | 20 min | Ship | ⬜ |
| | **Total** | **3h 45min** | | |

> Phases 0–6 = working app. Phases 7–9 = polished app.
> If time is short, stop at Phase 6 — you have a functional demo.
