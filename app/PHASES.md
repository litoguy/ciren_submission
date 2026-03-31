# CampusAI Flutter App — Phase Plan

> **Workflow:** Claude handles architecture, spec, and logic. Gemini CLI executes file
> writes and terminal commands. Each phase produces a LOG.md entry.
>
> **Flutter binary:** `/Users/kevinafenyo/flutter/bin/flutter`
> **Project root:** `/Users/kevinafenyo/Documents/GitHub/gemini/campusAI/app`
> **Log file:** `app/LOG.md`
> **Handoff file:** `app/CONTINUE.md`

---

## Design Reference

### Colors
| Token | Hex | Usage |
|---|---|---|
| `colorPrimary` | `#8B1A2B` | Buttons, active nav, headers |
| `colorPrimaryDark` | `#5E0F1A` | Hover/pressed states |
| `colorPrimaryLight` | `#B02438` | Gradient accents |
| `colorGold` | `#C9922A` | CTA, mic button, highlights |
| `colorGoldLight` | `#E8B455` | Chip borders, hover gold |
| `colorBackground` | `#0F0205` | Main background |
| `colorSurface` | `#120508` | Bottom sheet, cards |
| `colorCardIcon` | `#1E0A0C` | Icon circle backgrounds |
| `colorTextPrimary` | `#FFFFFF` | Headings, names |
| `colorTextSecondary` | `rgba(255,255,255,0.6)` | Labels, subtitles |
| `colorTextMuted` | `rgba(255,255,255,0.3)` | Placeholders |

### Typography
- **Headings:** Playfair Display (700)
- **Body / UI:** DM Sans (400 regular, 500 medium)

### Design Language
Dark ambient background. Large maroon radial glow blob centered upper screen.
Bottom sheet darkens to near-black. Gold accent on the primary action button.
Floating content — no hard navbars. Modelled on the reference image provided.

---

## Pages (4 total)

1. **Splash Screen** — Logo + tagline + "Get Started"
2. **Home Screen** — Greeting, ambient glow, quick topic cards, input bar
3. **Chat Screen** — Full conversation UI with Gemini API
4. **Topics / FAQ Screen** — Browsable topic grid + frequently asked questions

---

## Phase 0 — Project Bootstrap
**Time estimate:** 30 minutes
**Owner:** Gemini executes, Claude verifies

### Goal
Create the Flutter project, install all dependencies, set up folder structure,
configure fonts, and verify a clean build before any UI is written.

### Pre-flight reads
- None (clean project, nothing exists yet)

### Actions

**[GEMINI EXECUTES]** Step 0.1 — Create Flutter project
```bash
cd /Users/kevinafenyo/Documents/GitHub/gemini/campusAI/app
/Users/kevinafenyo/flutter/bin/flutter create . --org com.ktinnovations --project-name campus_ai
```

**[GEMINI EXECUTES]** Step 0.2 — Add dependencies to `pubspec.yaml`
Add under `dependencies:`:
```yaml
  google_generative_ai: ^0.4.6
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  go_router: ^14.2.0
  google_fonts: ^6.2.1
  flutter_animate: ^4.5.0
  http: ^1.2.1
  shared_preferences: ^2.2.3
  flutter_dotenv: ^5.1.0
  lottie: ^3.1.0
```
Add under `dev_dependencies:`:
```yaml
  riverpod_generator: ^2.4.0
  build_runner: ^2.4.11
  custom_lint: ^0.6.4
  riverpod_lint: ^2.3.10
```
Add under `flutter:`:
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

**[GEMINI EXECUTES]** Step 0.3 — Create asset folders
```bash
mkdir -p /Users/kevinafenyo/Documents/GitHub/gemini/campusAI/app/assets/fonts
mkdir -p /Users/kevinafenyo/Documents/GitHub/gemini/campusAI/app/assets/images
```

**[GEMINI EXECUTES]** Step 0.4 — Download fonts
```bash
cd /Users/kevinafenyo/Documents/GitHub/gemini/campusAI/app/assets/fonts
curl -L "https://fonts.gstatic.com/s/playfairdisplay/v37/nuFvD-vYSZviVYUb_rj3ij__anPXJzDwcbmjWBN2PKdFvXDXbtM.ttf" -o PlayfairDisplay-Bold.ttf
curl -L "https://fonts.gstatic.com/s/dmsans/v15/rP2Hp2ywxg089UriCZa4ET-DNl0.ttf" -o DMSans-Regular.ttf
curl -L "https://fonts.gstatic.com/s/dmsans/v15/rP2Hp2ywxg089UriCZa4ET-DNl0.ttf" -o DMSans-Medium.ttf
```

**[GEMINI EXECUTES]** Step 0.5 — Create `.env` file
```
GEMINI_API_KEY=your_key_here
```

**[GEMINI EXECUTES]** Step 0.6 — Create lib folder structure
```bash
mkdir -p /Users/kevinafenyo/Documents/GitHub/gemini/campusAI/app/lib/core/theme
mkdir -p /Users/kevinafenyo/Documents/GitHub/gemini/campusAI/app/lib/core/constants
mkdir -p /Users/kevinafenyo/Documents/GitHub/gemini/campusAI/app/lib/features/splash
mkdir -p /Users/kevinafenyo/Documents/GitHub/gemini/campusAI/app/lib/features/home
mkdir -p /Users/kevinafenyo/Documents/GitHub/gemini/campusAI/app/lib/features/chat
mkdir -p /Users/kevinafenyo/Documents/GitHub/gemini/campusAI/app/lib/features/topics
mkdir -p /Users/kevinafenyo/Documents/GitHub/gemini/campusAI/app/lib/services
mkdir -p /Users/kevinafenyo/Documents/GitHub/gemini/campusAI/app/lib/models
mkdir -p /Users/kevinafenyo/Documents/GitHub/gemini/campusAI/app/lib/router
```

**[GEMINI EXECUTES]** Step 0.7 — Install packages
```bash
cd /Users/kevinafenyo/Documents/GitHub/gemini/campusAI/app
/Users/kevinafenyo/flutter/bin/flutter pub get
```

### Verification
```bash
cd /Users/kevinafenyo/Documents/GitHub/gemini/campusAI/app
/Users/kevinafenyo/flutter/bin/flutter analyze
```
Expected: `No issues found!` or only info-level hints.

### LOG.md entry
```
## Phase 0 — Project Bootstrap
- Date: [DATE]
- Status: COMPLETE
- Files created: pubspec.yaml (modified), .env, lib/ structure (9 dirs)
- Assets: PlayfairDisplay-Bold.ttf, DMSans-Regular.ttf, DMSans-Medium.ttf
- Verification: flutter analyze — no issues
```

---

## Phase 1 — Theme, Router & App Shell
**Time estimate:** 30 minutes
**Owner:** Claude writes spec, Gemini executes

### Goal
Set up the app theme (colors, typography), GoRouter with all 4 routes,
and the main `main.dart` entry point with ProviderScope + dotenv.

### Pre-flight reads
- `/Users/kevinafenyo/Documents/GitHub/gemini/campusAI/app/pubspec.yaml`
- `/Users/kevinafenyo/Documents/GitHub/gemini/campusAI/app/lib/main.dart`

### Actions

**[CLAUDE HANDLES]** — Write `lib/core/theme/app_theme.dart`
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const background   = Color(0xFF0F0205);
  static const surface      = Color(0xFF120508);
  static const cardIcon     = Color(0xFF1E0A0C);
  static const primary      = Color(0xFF8B1A2B);
  static const primaryDark  = Color(0xFF5E0F1A);
  static const primaryLight = Color(0xFFB02438);
  static const gold         = Color(0xFFC9922A);
  static const goldLight    = Color(0xFFE8B455);
  static const textPrimary  = Color(0xFFFFFFFF);
  static const textSecondary = Color(0x99FFFFFF);
  static const textMuted    = Color(0x4DFFFFFF);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.gold,
      surface: AppColors.surface,
      background: AppColors.background,
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

**[CLAUDE HANDLES]** — Write `lib/router/app_router.dart`
```dart
import 'package:go_router/go_router.dart';
import 'package:campus_ai/features/splash/splash_screen.dart';
import 'package:campus_ai/features/home/home_screen.dart';
import 'package:campus_ai/features/chat/chat_screen.dart';
import 'package:campus_ai/features/topics/topics_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/home',   builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/chat',   builder: (_, state) {
      final topic = state.uri.queryParameters['topic'];
      return ChatScreen(initialTopic: topic);
    }),
    GoRoute(path: '/topics', builder: (_, __) => const TopicsScreen()),
  ],
);
```

**[CLAUDE HANDLES]** — Write `lib/main.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_ai/core/theme/app_theme.dart';
import 'package:campus_ai/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
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

**[GEMINI EXECUTES]** — Create stub screens (empty) so router compiles:
Create each of these files with just a basic Scaffold stub:
- `lib/features/splash/splash_screen.dart`
- `lib/features/home/home_screen.dart`
- `lib/features/chat/chat_screen.dart`
- `lib/features/topics/topics_screen.dart`

Each stub:
```dart
import 'package:flutter/material.dart';
class [ScreenName] extends StatelessWidget {
  const [ScreenName]({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('[ScreenName]')),
  );
}
// For ChatScreen only, add: final String? initialTopic; const ChatScreen({super.key, this.initialTopic});
```

### Verification
```bash
cd /Users/kevinafenyo/Documents/GitHub/gemini/campusAI/app
/Users/kevinafenyo/flutter/bin/flutter analyze
```
Expected: No issues.

### LOG.md entry
```
## Phase 1 — Theme, Router & App Shell
- Date: [DATE]
- Status: COMPLETE
- Files created: lib/core/theme/app_theme.dart, lib/router/app_router.dart,
  lib/main.dart (rewritten), 4x stub screens
- Verification: flutter analyze — no issues
```

---

## Phase 2 — Gemini Service + Knowledge Base
**Time estimate:** 45 minutes
**Owner:** Claude writes spec, Gemini executes

### Goal
Build the `GeminiService` that calls the Gemini API with the CU knowledge base
injected as the system prompt. Also create the `knowledge_base.dart` constants
file where the campus data lives.

### Pre-flight reads
- `/Users/kevinafenyo/Documents/GitHub/gemini/campusAI/app/lib/main.dart`
- `/Users/kevinafenyo/Documents/GitHub/gemini/campusAI/app/.env`

### Actions

**[CLAUDE HANDLES]** — Write `lib/core/constants/knowledge_base.dart`
```dart
// This file is populated by the content research teammate.
// Replace each [SECTION] block with real Central University data.
const String cuKnowledgeBase = """
## CENTRAL UNIVERSITY GHANA — CAMPUS KNOWLEDGE BASE
## Miotso Campus, Accra-Aflao Road, Near Dawhenya

### 1. ACADEMIC STRUCTURE
School of Engineering & Technology (SET)
School of Pharmacy (SoP)
Central Law School
School of Medical Sciences
School of Nursing & Midwifery
Faculty of Arts & Social Sciences (FASS)
School of Architecture & Design (SADe)
Central Business School (CBS)
School of Graduate Studies & Research
Centre for Distance & Professional Education (CODE)

[PASTE FULL PROGRAMME LIST AND YEAR STRUCTURE HERE]

### 2. ACADEMIC CALENDAR
[PASTE SEMESTER DATES, EXAM PERIODS, REGISTRATION DEADLINES, HOLIDAYS]

### 3. FEES & FINANCE
[PASTE TUITION BY PROGRAMME AND LEVEL, PAYMENT DEADLINES, ACCEPTED METHODS]
Payment methods accepted: Mobile Money (MTN, Vodafone, AirtelTigo), Bank transfer, Finance Office (cash)
Finance Office contact: [NUMBER]

### 4. REGISTRATION & ADMISSIONS
Student portal: https://student.central.edu.gh/login
Eligibility checker: https://eligibility.central.edu.gh
Online application: https://central.edu.gh/online
[PASTE REGISTRATION STEPS, DEADLINES, REQUIRED DOCUMENTS]

### 5. CAMPUS FACILITIES
Library: https://central.edu.gh/library — [PASTE HOURS AND LOCATION]
Health/Counselling: https://central.edu.gh/couselling-career-service
Examination timetable: https://webcms.central.edu.gh/wp-content/uploads/2026/01/Exams-Timetable.pdf
[PASTE CAFETERIA/CANTEEN HOURS, COMPUTER LAB LOCATIONS, CHAPEL, SRC OFFICE]

### 6. KEY CONTACTS
Main phone (Miotso): +2330303318580
Admissions: +2330307020540
WhatsApp: +2330233313180
Email: verification@central.edu.gh
Email: pr@central.edu.gh
[PASTE DEPARTMENTAL OFFICERS, REGISTRAR, FINANCE OFFICE CONTACTS]

### 7. EXAMINATIONS & GRADING
[PASTE GPA SCALE, GRADE BOUNDARIES, EXAM RULES, RESIT PROCESS]
Resit timetable: https://webcms.central.edu.gh/wp-content/uploads/2026/02/Resit-Timetable.pdf
Student handbook: https://webcms.central.edu.gh/wp-content/uploads/2026/02/undergraduate-students-handbook-FINAL-compressed.pdf

### 8. STUDENT LIFE
[PASTE CLUBS, SRC STRUCTURE, HOSTEL NAMES AND APPLICATION, TRANSPORT]

### 9. CURRENT ANNOUNCEMENTS
[PASTE ACTIVE NOTICES, DEADLINES, EVENTS THIS SEMESTER]
""";

const String systemPrompt = """
You are CampusAI, an intelligent assistant for Central University Ghana, Miotso Campus.
You help students, prospective students, and staff get accurate, helpful answers about
campus life, academics, fees, facilities, and administrative processes.

You have been provided with verified information about Central University Ghana below.
ONLY answer questions using the information provided. If the answer is not in the
provided information, say: "I don't have that information right now. Please contact
the relevant office directly or visit centraluni.edu.gh." Do NOT make up or guess
any information — accuracy is critical for a university context.

Always be:
- Friendly and conversational, like a knowledgeable senior student helping a fresher
- Concise — give direct answers, not essays
- Specific — use exact figures, dates, names when available
- Helpful — if you can't answer fully, point them to the right office or contact

If the user writes in Twi, Pidgin, or informal English, respond naturally in the same tone.

For fee amounts, always add: "Please confirm with the Finance Office as fees may be updated."
For deadlines, always add: "Please verify with the Registrar's Office to confirm this is current."

--- CAMPUS KNOWLEDGE BASE START ---
$cuKnowledgeBase
--- CAMPUS KNOWLEDGE BASE END ---
""";
```

**[CLAUDE HANDLES]** — Write `lib/services/gemini_service.dart`
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:campus_ai/core/constants/knowledge_base.dart';

class GeminiService {
  late final GenerativeModel _model;
  late final ChatSession _chat;

  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    _model = GenerativeModel(
      model: 'gemini-1.5-pro',
      apiKey: apiKey,
      systemInstruction: Content.system(systemPrompt),
      generationConfig: GenerationConfig(
        temperature: 0.3,
        maxOutputTokens: 512,
      ),
    );
    _chat = _model.startChat();
  }

  Future<String> sendMessage(String userMessage) async {
    try {
      final response = await _chat.sendMessage(Content.text(userMessage));
      return response.text ?? 'Sorry, I could not get a response. Please try again.';
    } catch (e) {
      return 'Something went wrong. Please check your connection and try again.';
    }
  }

  void resetChat() {
    _chat = _model.startChat();
  }
}
```

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

**[CLAUDE HANDLES]** — Write `lib/services/chat_provider.dart`
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_ai/models/chat_message.dart';
import 'package:campus_ai/services/gemini_service.dart';

final geminiServiceProvider = Provider<GeminiService>((ref) => GeminiService());

final chatMessagesProvider =
    StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  return ChatNotifier(ref.read(geminiServiceProvider));
});

final isLoadingProvider = StateProvider<bool>((ref) => false);

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final GeminiService _gemini;
  ChatNotifier(this._gemini) : super([]);

  Future<void> sendMessage(String text, WidgetRef ref) async {
    if (text.trim().isEmpty) return;

    state = [
      ...state,
      ChatMessage(text: text, role: MessageRole.user, timestamp: DateTime.now()),
    ];

    ref.read(isLoadingProvider.notifier).state = true;

    final response = await _gemini.sendMessage(text);

    state = [
      ...state,
      ChatMessage(text: response, role: MessageRole.assistant, timestamp: DateTime.now()),
    ];

    ref.read(isLoadingProvider.notifier).state = false;
  }

  void clear() {
    state = [];
    _gemini.resetChat();
  }
}
```

### Verification
```bash
cd /Users/kevinafenyo/Documents/GitHub/gemini/campusAI/app
/Users/kevinafenyo/flutter/bin/flutter analyze
```
Expected: No issues.

### LOG.md entry
```
## Phase 2 — Gemini Service + Knowledge Base
- Date: [DATE]
- Status: COMPLETE
- Files created: lib/core/constants/knowledge_base.dart,
  lib/services/gemini_service.dart, lib/models/chat_message.dart,
  lib/services/chat_provider.dart
- Note: knowledge_base.dart contains placeholder sections — fill before demo
- Verification: flutter analyze — no issues
```

---

## Phase 3 — Splash Screen
**Time estimate:** 20 minutes
**Owner:** Claude writes spec, Gemini executes

### Goal
Build the splash screen: full dark background, maroon radial glow, CU shield
logo centered, CampusAI wordmark, tagline, auto-navigate to Home after 2.5s.

### Pre-flight reads
- `lib/features/splash/splash_screen.dart` (current stub)
- `lib/core/theme/app_theme.dart`
- `lib/router/app_router.dart`

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
  @override
  State<SplashScreen> createState() => _SplashScreenState();
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
    body: Stack(
      children: [
        // Ambient glow blob
        Positioned(
          top: MediaQuery.of(context).size.height * 0.1,
          left: 0, right: 0,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.6,
                colors: [
                  Color(0x668B1A2B),
                  Color(0x228B1A2B),
                  Color(0x000F0205),
                ],
              ),
            ),
          ),
        ),
        // Content
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // CU Shield placeholder (replace with actual SVG/image)
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.school, color: AppColors.gold, size: 40),
              ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.8, 0.8)),
              const SizedBox(height: 24),
              Text(
                'CampusAI',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 36, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(begin: 0.2),
              const SizedBox(height: 8),
              Text(
                'Central University Ghana',
                style: GoogleFonts.dmSans(
                  fontSize: 14, color: AppColors.textSecondary,
                ),
              ).animate().fadeIn(delay: 500.ms, duration: 600.ms),
              const SizedBox(height: 4),
              Text(
                'Your AI campus guide',
                style: GoogleFonts.dmSans(
                  fontSize: 12, color: AppColors.gold,
                ),
              ).animate().fadeIn(delay: 700.ms, duration: 600.ms),
            ],
          ),
        ),
        // Bottom powered by
        Positioned(
          bottom: 40, left: 0, right: 0,
          child: Text(
            'Powered by Google Gemini',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textMuted),
          ).animate().fadeIn(delay: 900.ms),
        ),
      ],
    ),
  );
}
```

### Verification
```bash
/Users/kevinafenyo/flutter/bin/flutter analyze
```
Run on simulator/device and confirm: glow renders, logo appears, auto-navigates to home at 2.5s.

### LOG.md entry
```
## Phase 3 — Splash Screen
- Date: [DATE]
- Status: COMPLETE
- Files modified: lib/features/splash/splash_screen.dart
- Verification: flutter analyze clean, visual confirmed on device
```

---

## Phase 4 — Home Screen
**Time estimate:** 45 minutes
**Owner:** Claude writes spec, Gemini executes

### Goal
Full home screen implementation: ambient glow background, floating greeting
(Playfair Display large), bottom sheet with scrollable quick-topic cards,
gold-accented input bar that navigates to Chat on tap.

### Pre-flight reads
- `lib/features/home/home_screen.dart` (current stub)
- `lib/core/theme/app_theme.dart`
- `lib/router/app_router.dart`

### Actions

**[CLAUDE HANDLES]** — Write `lib/features/home/home_screen.dart`
Full implementation with:
- Stack layout: background → glow blob → floating content → bottom sheet
- Greeting top-left: "Good morning," + student name in Playfair Display 36px
- Bottom sheet (DraggableScrollableSheet, minChildSize 0.38, maxChildSize 0.65):
  - Section label "Quick Topics" in DMSans 11px muted
  - Horizontal ListView of topic cards (icon circle in cardIcon color + label)
  - Topics: Fees & Payments, Exam Dates, Registration, Facilities, Handbook, Contacts
  - "Recent Questions" section (static placeholder for now)
- Bottom input bar pinned: text field "Ask CampusAI anything..." + gold mic FAB
- Tapping input bar OR mic → `context.push('/chat')`
- Tapping a topic card → `context.push('/chat?topic=fees')` etc.

Note: Student name is hardcoded as "Student" for hackathon. Can be made dynamic later.

[Gemini: Claude will produce this full file in the session when Phase 4 is triggered.
The spec above is sufficient to implement it.]

### Verification
```bash
/Users/kevinafenyo/flutter/bin/flutter analyze
```
Visual check: glow visible, bottom sheet draggable, topic cards scroll horizontally,
tapping input navigates to chat.

### LOG.md entry
```
## Phase 4 — Home Screen
- Date: [DATE]
- Status: COMPLETE
- Files modified: lib/features/home/home_screen.dart
- Verification: flutter analyze clean, navigation confirmed
```

---

## Phase 5 — Chat Screen
**Time estimate:** 60 minutes
**Owner:** Claude writes spec, Gemini executes

### Goal
Full chat screen: message list (bot + user bubbles), typing indicator,
bottom input bar with send button, Gemini API integration via chat_provider.

### Pre-flight reads
- `lib/features/chat/chat_screen.dart`
- `lib/services/chat_provider.dart`
- `lib/models/chat_message.dart`
- `lib/core/theme/app_theme.dart`

### Actions

**[CLAUDE HANDLES]** — Write `lib/features/chat/chat_screen.dart`
Full implementation with:
- Same dark ambient background as home (consistency)
- AppBar: back arrow + "CampusAI" title (Playfair Display) + gold online dot
- ListView.builder for messages, auto-scrolls to bottom on new message
- Bot bubble: surface color background, left-aligned, DMSans 14px
- User bubble: primary maroon background, right-aligned, DMSans 14px white
- "Verify with the relevant office" disclaimer shown under first bot response only
- Typing indicator: 3 animated dots in gold color while isLoadingProvider is true
- If `initialTopic` is not null, send it as the first message automatically on init
- Bottom input row: TextField + gold CircleAvatar send button
- Send on TextField submit OR button tap
- Clear chat button in AppBar actions (icon: refresh)

[Gemini: Claude will produce this full file in the session when Phase 5 is triggered.]

### Verification
```bash
/Users/kevinafenyo/flutter/bin/flutter analyze
```
Manual test: type a question, tap send, confirm response appears. Test with topic
pre-fill from home screen.

### LOG.md entry
```
## Phase 5 — Chat Screen
- Date: [DATE]
- Status: COMPLETE
- Files modified: lib/features/chat/chat_screen.dart
- Verification: flutter analyze clean, Gemini responses confirmed live
```

---

## Phase 6 — Topics / FAQ Screen
**Time estimate:** 30 minutes
**Owner:** Claude writes spec, Gemini executes

### Goal
Topics screen: top section shows topic category grid. Bottom section shows
"Frequently Asked Questions" list. Tapping any topic or FAQ navigates to
Chat with the relevant pre-filled question.

### Pre-flight reads
- `lib/features/topics/topics_screen.dart`
- `lib/core/theme/app_theme.dart`

### Actions

**[CLAUDE HANDLES]** — Write `lib/core/constants/topics_data.dart`
```dart
class TopicItem {
  final String label;
  final String icon;
  final String chatPrompt;
  const TopicItem({required this.label, required this.icon, required this.chatPrompt});
}

const List<TopicItem> topics = [
  TopicItem(label: 'Fees & Payments', icon: '💰', chatPrompt: 'What are the fees for this academic year?'),
  TopicItem(label: 'Exam Dates', icon: '📅', chatPrompt: 'When are the upcoming exams?'),
  TopicItem(label: 'Registration', icon: '📝', chatPrompt: 'How do I register for courses?'),
  TopicItem(label: 'Facilities', icon: '🏛️', chatPrompt: 'What facilities are available on campus?'),
  TopicItem(label: 'Student Handbook', icon: '📖', chatPrompt: 'Where can I find the student handbook?'),
  TopicItem(label: 'Key Contacts', icon: '📞', chatPrompt: 'What are the key office contacts at Central University?'),
  TopicItem(label: 'Admissions', icon: '🎓', chatPrompt: 'What are the admission requirements?'),
  TopicItem(label: 'Hostels', icon: '🏠', chatPrompt: 'Tell me about hostels and accommodation at Central University.'),
];

const List<String> faqs = [
  'How much are Level 200 Engineering fees?',
  'When does second semester registration close?',
  'Where is the library and what are its opening hours?',
  'How do I check my admission status?',
  'What is the GPA grading scale at Central University?',
  'How do I apply for a resit exam?',
  'Where is the Finance Office located?',
  'What Mobile Money options are accepted for fee payment?',
];
```

**[CLAUDE HANDLES]** — Write `lib/features/topics/topics_screen.dart`
Full implementation with:
- Same dark ambient background
- AppBar: back arrow + "Topics & FAQ" title
- GridView.count(crossAxisCount: 2) for 8 topic cards
  - Each card: dark surface container, icon (emoji large), label DMSans
  - Tap → `context.push('/chat?topic=...')`  with chatPrompt as query param
- Divider + "Frequently Asked Questions" section label
- ListView of FAQ items: each is a ListTile with gold arrow icon
  - Tap → `context.push('/chat?topic=...')` with the FAQ text as prompt

[Gemini: Claude will produce this full file in the session when Phase 6 is triggered.]

### Verification
```bash
/Users/kevinafenyo/flutter/bin/flutter analyze
```
Visual check: grid renders, FAQ list renders, tapping navigates to chat with pre-fill.

### LOG.md entry
```
## Phase 6 — Topics & FAQ Screen
- Date: [DATE]
- Status: COMPLETE
- Files created: lib/core/constants/topics_data.dart
- Files modified: lib/features/topics/topics_screen.dart
- Verification: flutter analyze clean, navigation confirmed
```

---

## Phase 7 — Bottom Navigation Shell
**Time estimate:** 20 minutes
**Owner:** Claude writes spec, Gemini executes

### Goal
Wrap Home, Chat, and Topics in a shared bottom navigation bar so users can
switch between them without losing state. Splash remains outside the shell.

### Pre-flight reads
- `lib/router/app_router.dart`

### Actions

**[CLAUDE HANDLES]** — Refactor `app_router.dart` to use ShellRoute
Add a `ShellRoute` wrapping `/home`, `/chat`, `/topics` with a shared
`ScaffoldWithNavBar` widget that shows the bottom nav.

Bottom nav items:
- Home (icon: home outline / filled)
- Chat (icon: chat bubble outline / filled)
- Topics (icon: grid view outline / filled)

Active item color: `AppColors.gold`
Inactive item color: `AppColors.textMuted`
Background: `AppColors.surface`
No labels — icon only for clean look.

[Gemini: Claude will produce the full refactored router and nav shell widget
in the session when Phase 7 is triggered.]

### Verification
```bash
/Users/kevinafenyo/flutter/bin/flutter analyze
```
Visual check: bottom nav visible on all 3 main screens, active tab highlights in gold,
switching tabs preserves state.

### LOG.md entry
```
## Phase 7 — Bottom Navigation Shell
- Date: [DATE]
- Status: COMPLETE
- Files modified: lib/router/app_router.dart
- Files created: lib/features/shell/scaffold_with_nav.dart
- Verification: flutter analyze clean, nav confirmed on all screens
```

---

## Phase 8 — Polish, Build & Demo Prep
**Time estimate:** 30 minutes
**Owner:** Gemini executes under Claude direction

### Goal
Final polish, fill knowledge base with real CU data, test full flow,
build release APK for demo.

### Actions

**[GEMINI EXECUTES]** — Fill knowledge base
Open `lib/core/constants/knowledge_base.dart` and replace all `[PASTE ...]`
sections with the actual data collected by the content research teammate.

**[GEMINI EXECUTES]** — Build APK
```bash
cd /Users/kevinafenyo/Documents/GitHub/gemini/campusAI/app
/Users/kevinafenyo/flutter/bin/flutter build apk --release --split-per-abi
```

**[GEMINI EXECUTES]** — Run on device for final check
```bash
/Users/kevinafenyo/flutter/bin/flutter run --release
```

### Verification
Full manual walkthrough: Splash → Home → Chat (ask 3 questions) → Topics → FAQ tap → Chat.
Confirm all Gemini responses are accurate and the app doesn't crash.

### LOG.md entry
```
## Phase 8 — Polish, Build & Demo Prep
- Date: [DATE]
- Status: COMPLETE
- Knowledge base: FILLED with real CU data
- Build: APK generated at build/app/outputs/flutter-apk/
- Verification: Full manual walkthrough complete — no crashes
```

---

## Phase Summary

| Phase | Description | Est. Time | Status |
|---|---|---|---|
| 0 | Project Bootstrap | 30 min | ⬜ |
| 1 | Theme, Router & Shell | 30 min | ⬜ |
| 2 | Gemini Service + KB | 45 min | ⬜ |
| 3 | Splash Screen | 20 min | ⬜ |
| 4 | Home Screen | 45 min | ⬜ |
| 5 | Chat Screen | 60 min | ⬜ |
| 6 | Topics / FAQ Screen | 30 min | ⬜ |
| 7 | Bottom Nav Shell | 20 min | ⬜ |
| 8 | Polish & Demo Prep | 30 min | ⬜ |
| | **Total** | **5h 10min** | |
