import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/welcome_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/video_splash_screen.dart';
import 'services/supabase_service.dart';
import 'services/supabase_auth_service.dart';
import 'services/theme_service.dart';

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
    );
  }
}

/// Check if user is already signed in (data persistence)
class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if user session exists (Supabase handles persistence automatically)
    final isSignedIn = SupabaseAuthService.instance.isSignedIn;
    
    if (isSignedIn) {
      print('✅ User session found - navigating to chat');
      return const ChatScreen();
    } else {
      print('ℹ️ No user session - showing welcome screen');
      return const WelcomeScreen();
    }
  }
}
