import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';
import 'home_tab.dart';
import '../races/races_screen.dart';
import '../bulls/bulls_screen.dart';
import '../marketplace/available_bulls_screen.dart';
import 'package:provider/provider.dart';
import '../profile/profile_screen.dart';
import '../auth/login_screen.dart';
import '../../providers/race_provider.dart';
import '../../providers/bull_provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/auth_provider.dart';

class MainScreen extends StatefulWidget {
  final int? initialTabIndex;

  const MainScreen({super.key, this.initialTabIndex});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeTab(),
    const RacesScreen(),
    const BullsScreen(),
    const AvailableBullsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Set initial tab index if provided
    _selectedIndex = widget.initialTabIndex ?? 0;

    // Load Home races by default when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final raceProvider = context.read<RaceProvider>();
      if (!raceProvider.isLoadedHome) {
        raceProvider.loadHomeRaces();
      }
    });
  }

  void _onItemTapped(int index) {
    // Add haptic feedback on tab tap
    HapticFeedback.lightImpact();

    final authProvider = context.read<AuthProvider>();
    final isLoggedIn = authProvider.isLoggedIn;

    // If user is not logged in and trying to access anything other than Home
    if (!isLoggedIn && index != 0) {
      // Show login screen with redirect info
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              LoginScreen(redirectTabIndex: index),
          transitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
      return;
    }

    setState(() {
      _selectedIndex = index;
    });

    // Lazy load data based on tab selection
    switch (index) {
      case 0: // Home
        final raceProvider = context.read<RaceProvider>();
        if (!raceProvider.isLoadedHome) {
          raceProvider.loadHomeRaces();
        }
        break;
      case 1: // Races
        final raceProvider = context.read<RaceProvider>();
        if (!raceProvider.isLoadedAll) {
          raceProvider.loadAllRaces();
        }
        break;
      case 2: // Community (Bulls/Owners)
        final bullProvider = context.read<BullProvider>();
        if (!bullProvider.isLoaded) {
          bullProvider.loadBulls();
        }
        break;
      case 3: // Available Bulls (Marketplace)
        final marketplaceProvider = context.read<MarketplaceProvider>();
        if (!marketplaceProvider.isLoaded) {
          marketplaceProvider.loadListings();
        }
        break;
      case 4: // Profile
        // Profile data usually loaded on app start or handled within screen
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final isLoggedIn = authProvider.isLoggedIn;

        // Build bottom navigation items - exclude Profile if not logged in
        List<BottomNavigationBarItem> navItems = [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: context.watch<LanguageProvider>().getText('nav_home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.emoji_events),
            label: context.watch<LanguageProvider>().getText('nav_races'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.groups),
            label: context.watch<LanguageProvider>().getText('nav_community'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.volunteer_activism),
            label: context.watch<LanguageProvider>().getText('nav_available'),
          ),
        ];

        // Add Profile tab only if logged in
        if (isLoggedIn) {
          navItems.add(
            BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: context.watch<LanguageProvider>().getText('nav_profile'),
            ),
          );
        }

        // Ensure selected index is valid (handle logout from Profile tab)
        final int safeIndex = _selectedIndex >= navItems.length ? 0 : _selectedIndex;

        // Reset state if out of bounds
        if (_selectedIndex >= navItems.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _selectedIndex = 0;
              });
            }
          });
        }

        return Scaffold(
          body: IndexedStack(
            index: safeIndex,
            children: _screens,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: safeIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppTheme.primaryOrange,
            unselectedItemColor: AppTheme.textLight,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            items: navItems,
          ),
        );
      },
    );
  }
}
