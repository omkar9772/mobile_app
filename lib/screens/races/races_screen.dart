import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/race.dart';
import '../../services/race_service.dart';
import '../../widgets/race_card.dart';
import '../home/race_detail_screen.dart';

class RacesScreen extends StatefulWidget {
  const RacesScreen({super.key});

  @override
  State<RacesScreen> createState() => _RacesScreenState();
}

class _RacesScreenState extends State<RacesScreen> {
  final RaceService _raceService = RaceService();
  List<Race> _races = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRaces();
  }

  Future<void> _loadRaces() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final races = await _raceService.getAllRaces(limit: 50);
      setState(() {
        _races = races;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
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
            onPressed: _loadRaces,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppTheme.errorRed),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: AppTheme.errorRed)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRaces,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_races.isEmpty) {
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
      onRefresh: _loadRaces,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        itemCount: _races.length,
        itemBuilder: (context, index) {
          final race = _races[index];
          return RaceCard(
            race: race,
            isRecent: race.isCompleted,
            onTap: () => _navigateToDetail(race),
          );
        },
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
