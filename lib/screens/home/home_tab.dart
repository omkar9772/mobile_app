import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/race.dart';
import '../../models/user.dart';
import '../../widgets/race_card.dart';
import '../../widgets/banner_carousel.dart';
import '../auth/login_screen.dart';
import '../races/race_days_screen.dart';
import '../../providers/auth_provider.dart';
import '../../providers/race_provider.dart';
import 'dart:ui';
import '../../providers/language_provider.dart'; // Extended imports for UI polish if needed

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().checkAuth();
      context.read<RaceProvider>().loadHomeRaces();
    });
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final lang = context.read<LanguageProvider>();
        return AlertDialog(
          title: Text(lang.getText('logout_confirm_title')),
          content: Text(lang.getText('logout_confirm_msg')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(lang.getText('cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: AppTheme.errorRed),
              child: Text(lang.getText('logout')),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      if (mounted) {
        await context.read<AuthProvider>().logout();
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8), // Slightly more sophisticated gray
      body: Consumer2<AuthProvider, RaceProvider>(
        builder: (context, authProvider, raceProvider, child) {
          final currentUser = authProvider.currentUser;
          final recentRaces = raceProvider.recentRaces;
          final upcomingRaces = raceProvider.upcomingRaces;
          final isLoading = raceProvider.isLoadingHome || authProvider.isLoading;
          final error = raceProvider.errorHome;

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(currentUser),
              
              if (isLoading)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          color: AppTheme.primaryOrange,
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'नाद एकच… बैलगाडा!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryOrange,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (error != null)
                SliverFillRemaining(
                  child: _buildErrorState(error, raceProvider),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 32),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 24),

                      // Banner Carousel - Show login prompt only if not logged in
                      BannerCarousel(
                        showLoginPrompt: currentUser == null,
                        onLoginTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 32),

                      // Recent Races Section
                      if (recentRaces.isNotEmpty) ...[
                        _buildSectionHeader(context.watch<LanguageProvider>().getText('recent_results'), Icons.emoji_events_outlined),
                        _buildRaceList(recentRaces, isRecent: true),
                        const SizedBox(height: 32),
                      ],

                      // Decorative Quote Section (between sections)
                      if (recentRaces.isNotEmpty && upcomingRaces.isNotEmpty)
                        _buildDecorativeQuote(),

                      // Upcoming Races Section
                      if (upcomingRaces.isNotEmpty) ...[
                        _buildSectionHeader(context.watch<LanguageProvider>().getText('upcoming_races'), Icons.calendar_month_outlined),
                        _buildRaceList(upcomingRaces, isRecent: false),
                      ],

                      // Footer Quote (at end of all content)
                      if (recentRaces.isNotEmpty || upcomingRaces.isNotEmpty)
                        _buildFooterQuote(),

                      // Empty State
                      if (recentRaces.isEmpty && upcomingRaces.isEmpty)
                         _buildEmptyState(),
                    ]),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(User? currentUser) {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.primaryOrange,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            color: AppTheme.primaryOrange,

          ),
          child: Stack(
            children: [
              // Decorative background circles
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                left: -20,
                bottom: -40,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              
              // Header Content
              Positioned(
                left: 20,
                bottom: 30, // Adjust positioning
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Show welcome message only if logged in
                    if (currentUser != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Consumer<LanguageProvider>(
                          builder: (context, lang, _) => Text(
                            '${lang.getText('welcome_back')}, ${currentUser.username} 👋',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    if (currentUser != null) const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Consumer<LanguageProvider>(
                          builder: (context, lang, _) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lang.getText('app_title'),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                lang.getText('app_subtitle'),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Consumer<LanguageProvider>(
          builder: (context, lang, _) => TextButton(
            onPressed: () => lang.toggleLanguage(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 0),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                lang.isMarathi ? 'EN' : 'मराठी',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () => context.read<RaceProvider>().loadHomeRaces(),
        ),
        // Wrap auth-dependent button in Consumer to ensure it rebuilds
        Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            final user = authProvider.currentUser;
            // Show logout button only if logged in
            if (user != null) {
              return IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: _handleLogout,
              );
            }
            // Show login button if not logged in
            else {
              return IconButton(
                icon: const Icon(Icons.login, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.primaryOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppTheme.primaryOrange),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRaceList(List<Race> races, {required bool isRecent}) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: races.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 400 + (index * 100).clamp(0, 600)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: RaceCard(
            race: races[index],
            isRecent: isRecent,
            onTap: () => _navigateToDetail(races[index]),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String error, RaceProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.cloud_off_rounded, size: 48, color: Colors.red.shade400),
            ),
            const SizedBox(height: 24),
            Text(
              "Oops! Something went wrong",
              style: AppTheme.heading3.copyWith(color: AppTheme.textDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textLight),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => provider.loadHomeRaces(),
              icon: const Icon(Icons.refresh),
              label: Text(context.read<LanguageProvider>().getText('try_again')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFooterQuote() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
      child: Column(
        children: [
          // Divider
          Container(
            height: 1,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.grey.shade300,
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Quote with icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_awesome,
                color: AppTheme.primaryOrange,
                size: 20,
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  'नाद जपणारे व्यासपीठ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.auto_awesome,
                color: AppTheme.primaryOrange,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // App name
          Text(
            'Naad Bailgada',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativeQuote() {
    final quotes = [
      {'text': 'शर्यत नाही, हा आहे नाद!', 'icon': Icons.campaign},
      {'text': 'बैलगाडा संस्कृतीचा डिजिटल अभिमान', 'icon': Icons.workspace_premium},
      {'text': 'बैलांची ताकद… शेतकऱ्याचा अभिमान', 'icon': Icons.celebration},
    ];

    final randomQuote = quotes[DateTime.now().hour % quotes.length];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B35), Color(0xFFFF8C61)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryOrange.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  randomQuote['icon'] as IconData,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  randomQuote['text'] as String,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.3,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final quotes = [
      'पिढ्यानपिढ्या चाललेला नाद',
      'संस्कृती धावते, तेव्हा बैलगाडा धावतो',
      'रक्तात माती, नादात बैलगाडा',
      'गावाचा थरार, बैलगाड्यांचा नाद',
      'नाद जपणारे व्यासपीठ',
    ];

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryOrange.withOpacity(0.1),
                    AppTheme.primaryOrange.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.emoji_events_outlined, size: 56, color: AppTheme.primaryOrange.withOpacity(0.6)),
            ),
            const SizedBox(height: 20),
            Text(
              context.watch<LanguageProvider>().getText('no_races'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 32),
            // Rotating Quote Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryOrange.withOpacity(0.15),
                    AppTheme.primaryOrange.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryOrange.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.scale(
                      scale: 0.8 + (0.2 * value),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  children: [
                    Icon(
                      Icons.format_quote,
                      color: AppTheme.primaryOrange.withOpacity(0.5),
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      quotes[DateTime.now().second % quotes.length],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                        height: 1.4,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(Race race) {
    final authProvider = context.read<AuthProvider>();
    final isLoggedIn = authProvider.isLoggedIn;

    // If user is not logged in, redirect to login screen
    if (!isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(
            redirectToScreen: RaceDaysScreen(race: race),
          ),
        ),
      );
      return;
    }

    // User is logged in, navigate to race detail
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RaceDaysScreen(race: race),
      ),
    );
  }
}
