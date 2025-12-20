import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/race.dart';
import '../../widgets/race_card.dart';
import 'race_days_screen.dart';
import '../../providers/race_provider.dart';

class RacesScreen extends StatefulWidget {
  const RacesScreen({super.key});

  @override
  State<RacesScreen> createState() => _RacesScreenState();
}

class _RacesScreenState extends State<RacesScreen> {
  @override
  void initState() {
    super.initState();
    // Eager loading removed for lazy loading implementation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Races'),
        backgroundColor: AppTheme.primaryOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<RaceProvider>().loadAllRaces(),
          ),
        ],
      ),
      body: Consumer<RaceProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingAll) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorAll != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppTheme.errorRed),
                  const SizedBox(height: 16),
                  Text(provider.errorAll!, style: const TextStyle(color: AppTheme.errorRed)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadAllRaces(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.allRaces.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 64,
                    color: AppTheme.textLight,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No races found',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadAllRaces(),
            child: ListView.builder(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              itemCount: provider.allRaces.length,
              itemBuilder: (context, index) {
                final race = provider.allRaces[index];
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
                    race: race,
                    isRecent: race.isCompleted,
                    onTap: () => _navigateToDetail(race),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _navigateToDetail(Race race) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RaceDaysScreen(race: race),
      ),
    );
  }
}
