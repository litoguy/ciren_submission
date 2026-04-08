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
    title: 'Campus Mind',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: ThemeMode.system,
    routerConfig: appRouter,
  );
}
