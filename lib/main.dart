import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'presentation/providers/providers_setup.dart';
import 'presentation/screens/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── 1. Lock orientation ──────────────────────────────────────────────────
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // ── 2. Initialize Hive ───────────────────────────────────────────────────
  await Hive.initFlutter();
  // Open all persistent boxes
  await Future.wait([
    Hive.openBox<String>('cities_cache'),
    Hive.openBox<String>('timetables'),
    Hive.openBox<String>('user_prefs'),
    Hive.openBox<String>('saved_routes'),
    Hive.openBox<String>('saved_stops'),
    Hive.openBox<String>('cache_meta'),
  ]);

  // ── 3. Initialize Firebase ───────────────────────────────────────────────
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // ── 4. Initialize Crashlytics ─────────────────────────────────────────────
    if (!kIsWeb) {
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }
  } catch (e) {
    debugPrint('Firebase initialization error (using stub options?): $e');
  }

  // ── 5. Run app ───────────────────────────────────────────────────────────
  runApp(
    ProviderScope(
      child: const BusIndiaApp(),
    ),
  );
}

class BusIndiaApp extends ConsumerStatefulWidget {
  const BusIndiaApp({super.key});

  @override
  ConsumerState<BusIndiaApp> createState() => _BusIndiaAppState();
}

class _BusIndiaAppState extends ConsumerState<BusIndiaApp> {
  @override
  void initState() {
    super.initState();
    // Initialize notification service after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initServices();
    });
  }

  Future<void> _initServices() async {
    try {
      final notifService = ref.read(notificationServiceProvider);
      await notifService.initialize();
    } catch (_) {
      // Non-fatal — app continues without notifications
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BusIndia',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
