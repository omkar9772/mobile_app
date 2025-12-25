import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/theme.dart';
import 'package:provider/provider.dart';
import 'screens/home/main_screen.dart';
import 'screens/bulls/bull_detail_screen.dart';
import 'services/bull_service.dart';
import 'providers/auth_provider.dart';
import 'providers/bull_provider.dart';
import 'providers/owner_provider.dart';
import 'providers/race_provider.dart';
import 'providers/marketplace_provider.dart';
import 'providers/language_provider.dart';
import 'providers/notification_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (skip on web for now - notifications not supported on web)
  if (!kIsWeb) {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint('Error initializing Firebase: $e');
    }
  }

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BullProvider()),
        ChangeNotifierProvider(create: (_) => OwnerProvider()),
        ChangeNotifierProvider(create: (_) => RaceProvider()),
        ChangeNotifierProvider(create: (_) => MarketplaceProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const NaadBailgadaApp(),
    ),
  );
}

class NaadBailgadaApp extends StatefulWidget {
  const NaadBailgadaApp({super.key});

  @override
  State<NaadBailgadaApp> createState() => _NaadBailgadaAppState();
}

class _NaadBailgadaAppState extends State<NaadBailgadaApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late AppLinks _appLinks;
  final BullService _bullService = BullService();

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    // Handle links when app is already running
    _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });

    // Handle initial link if app was opened from a deep link
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      // Handle error
      debugPrint('Error getting initial link: $e');
    }
  }

  Future<void> _handleDeepLink(Uri uri) async {
    // Check if the scheme is 'naad' and path matches bull profile
    if (uri.scheme == 'naad' && uri.host == 'bull') {
      // Extract bull ID from path (e.g., naad://bull/123)
      final bullId = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;

      if (bullId != null) {
        try {
          // Fetch the bull details
          final bull = await _bullService.getBullById(bullId);

          // Navigate to bull detail screen
          _navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => BullDetailScreen(bull: bull),
            ),
          );
        } catch (e) {
          debugPrint('Error loading bull: $e');
          // Show error message to user
          _navigatorKey.currentState?.context.let((context) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Unable to load bull profile. Please try again.'),
              ),
            );
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Naad Bailgada',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}

extension _ContextExtension on BuildContext? {
  void let(void Function(BuildContext context) block) {
    if (this != null) {
      block(this!);
    }
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 1));

    // Initialize notifications (skip on web - push notifications not supported)
    if (mounted && !kIsWeb) {
      try {
        final notificationProvider =
            Provider.of<NotificationProvider>(context, listen: false);
        await notificationProvider.initialize();
        await notificationProvider.subscribeToRaceNotifications();
      } catch (e) {
        debugPrint('Error initializing notifications: $e');
      }
    }

    // Always navigate to MainScreen, regardless of auth status
    // MainScreen will handle showing/hiding Profile tab based on auth
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Naad Bailgada',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'बैलगाडा शर्यत',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
