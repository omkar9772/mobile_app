import 'package:flutter/material.dart';
import '../../config/theme.dart';
import 'home_tab.dart';
import '../races/races_screen.dart';
import '../bulls/bulls_screen.dart';
import '../marketplace/available_bulls_screen.dart';
import 'package:provider/provider.dart';
import '../profile/profile_screen.dart';
import '../../providers/race_provider.dart';
import '../../providers/bull_provider.dart';
import '../../providers/marketplace_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

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

  void _onItemTapped(int index) {
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
      case 2: // Bulls
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
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryOrange,
        unselectedItemColor: AppTheme.textLight,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Races',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'Bulls',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism),
            label: 'Available',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
