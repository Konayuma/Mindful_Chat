import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/welcome_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/home_screen.dart';
import 'screens/video_splash_screen.dart';
import 'screens/affirmation_screen.dart';
import 'screens/bookmarks_screen.dart';
import 'screens/journal_screen.dart';
import 'screens/personalization_wizard_screen.dart';
import 'services/supabase_service.dart';
import 'services/supabase_auth_service.dart';
import 'services/theme_service.dart';
import 'services/notification_service.dart';
import 'services/user_preferences_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Hide status bar and set system UI overlay style
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [],
  );
  
  // Set system UI overlay style for better appearance
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Initialize Supabase
  try {
    await SupabaseService.initialize();
    print('✅ Supabase initialized successfully');
  } catch (e) {
    print('❌ Supabase initialization error: $e');
  }
  
  // Initialize theme service
  await ThemeService().initialize();
  
  // Initialize notification service
  await NotificationService().initialize();
  
  runApp(const MentalHealthApp());
}

class MentalHealthApp extends StatefulWidget {
  const MentalHealthApp({super.key});

  @override
  State<MentalHealthApp> createState() => _MentalHealthAppState();
}

class _MentalHealthAppState extends State<MentalHealthApp> {
  final _themeService = ThemeService();

  @override
  void initState() {
    super.initState();
    _themeService.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _themeService.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mental Health App',
      themeMode: _themeService.themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8FEC95),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Satoshi',
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8FEC95),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Satoshi',
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        cardColor: const Color(0xFF1E1E1E),
      ),
      home: VideoSplashScreen(
        nextScreen: const AuthChecker(),
      ),
      // Named routes for She-Inspires features
      routes: {
        '/home': (context) => const HomeScreen(),
        '/chat': (context) => const ChatScreen(),
        '/affirmation': (context) => const AffirmationScreen(),
        '/bookmarks': (context) => const BookmarksScreen(),
        '/journal': (context) => const JournalScreen(),
      },
    );
  }
}

/// Check if user is already signed in (data persistence)
class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  bool _isLoading = true;
  bool _needsOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final isSignedIn = SupabaseAuthService.instance.isSignedIn;
    
    if (isSignedIn) {
      // Check if user has completed onboarding
      final prefsService = UserPreferencesService();
      final needsOnboarding = !(await prefsService.isOnboardingCompleted());
      
      if (mounted) {
        setState(() {
          _needsOnboarding = needsOnboarding;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8FEC95)),
          ),
        ),
      );
    }

    final isSignedIn = SupabaseAuthService.instance.isSignedIn;
    
    if (!isSignedIn) {
      print('ℹ️ No user session - showing welcome screen');
      return const WelcomeScreen();
    }
    
    if (_needsOnboarding) {
      print('ℹ️ User needs onboarding - showing wizard');
      return const PersonalizationWizardScreen();
    }
    
    print('✅ User session found and onboarding complete - navigating to home');
    return const HomeScreen();
  }
}
