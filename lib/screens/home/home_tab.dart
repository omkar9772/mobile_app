import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/race.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../services/race_service.dart';
import '../../widgets/race_card.dart';
import '../auth/login_screen.dart';
import 'race_detail_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final AuthService _authService = AuthService();
  final RaceService _raceService = RaceService();

  User? _currentUser;
  List<Race> _recentRaces = [];
  List<Race> _upcomingRaces = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load user info
      _currentUser = await _authService.getCurrentUser();

      // Load races
      final recentFuture = _raceService.getRecentRaces(limit: 4);
      final upcomingFuture = _raceService.getUpcomingRaces(limit: 4);

      final results = await Future.wait([recentFuture, upcomingFuture]);

      setState(() {
        _recentRaces = results[0];
        _upcomingRaces = results[1];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: AppTheme.errorRed),
                    const SizedBox(height: 16),
                    Text(_error!, style: const TextStyle(color: AppTheme.errorRed)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Recent Races Section
                  if (_recentRaces.isNotEmpty) ...[
                    _buildSectionHeader('Recent Races', Icons.check_circle),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingMd,
                      ),
                      itemCount: _recentRaces.length,
                      itemBuilder: (context, index) {
                        return RaceCard(
                          race: _recentRaces[index],
                          isRecent: true,
                          onTap: () => _navigateToDetail(_recentRaces[index]),
                        );
                      },
                    ),
                  ],

                  // Upcoming Races Section
                  if (_upcomingRaces.isNotEmpty) ...[
                    _buildSectionHeader('Upcoming Races', Icons.calendar_today),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingMd,
                      ),
                      itemCount: _upcomingRaces.length,
                      itemBuilder: (context, index) {
                        return RaceCard(
                          race: _upcomingRaces[index],
                          isRecent: false,
                          onTap: () => _navigateToDetail(_upcomingRaces[index]),
                        );
                      },
                    ),
                  ],

                  // Empty state
                  if (_recentRaces.isEmpty && _upcomingRaces.isEmpty) ...[
                    const SizedBox(height: 100),
                    const Icon(
                      Icons.emoji_events_outlined,
                      size: 64,
                      color: AppTheme.textLight,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No races available',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: FlexibleSpaceBar(
          title: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Naad Bailgada',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'बैलगाडा शर्यत',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
          ),
          titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        ),
      ),
      actions: [
        if (_currentUser != null)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        _currentUser!.username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: _handleLogout,
                ),
              ],
            ),
          ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _loadData,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacingMd,
        AppTheme.spacingLg,
        AppTheme.spacingMd,
        AppTheme.spacingSm,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryOrange),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppTheme.heading3.copyWith(color: AppTheme.primaryOrange),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(Race race) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RaceDetailScreen(race: race),
      ),
    );
  }
}
