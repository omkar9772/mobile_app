import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/app_config.dart';
import '../../models/race.dart';
import '../../widgets/race_card.dart';
import 'race_days_screen.dart';
import '../../providers/race_provider.dart';
import '../../providers/language_provider.dart';

class RacesScreen extends StatefulWidget {
  const RacesScreen({super.key});

  @override
  State<RacesScreen> createState() => _RacesScreenState();
}

class _RacesScreenState extends State<RacesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more when 200px from bottom
      context.read<RaceProvider>().loadMoreRaces();
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(
      Duration(milliseconds: AppConfig.searchDebounceMs),
      () {
        setState(() {
          _searchQuery = query;
        });
      },
    );
  }

  List<Race> _filterRaces(List<Race> races) {
    if (_searchQuery.isEmpty) {
      return races;
    }

    final query = _searchQuery.toLowerCase();
    return races.where((race) {
      final name = race.name.toLowerCase();
      final location = race.address.toLowerCase();
      return name.contains(query) || location.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.getText('all_races')),
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
                    child: Text(lang.getText('retry')),
                  ),
                ],
              ),
            );
          }

          final filteredRaces = _filterRaces(provider.allRaces);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: lang.getText('search_races'),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingMd,
                      vertical: AppTheme.spacingSm,
                    ),
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
              Expanded(
                child: filteredRaces.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchQuery.isEmpty
                                  ? Icons.emoji_events_outlined
                                  : Icons.search_off,
                              size: 64,
                              color: AppTheme.textLight,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? lang.getText('no_races_found')
                                  : lang.getText('no_races_match'),
                              style: const TextStyle(
                                fontSize: 18,
                                color: AppTheme.textLight,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => provider.loadAllRaces(),
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
                          itemCount: filteredRaces.length + (provider.isLoadingMore ? 1 : 0) + (!provider.hasMore && filteredRaces.isNotEmpty ? 1 : 0),
                          itemBuilder: (context, index) {
                            // Loading indicator at bottom
                            if (index == filteredRaces.length && provider.isLoadingMore) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            // No more items indicator
                            if (index == filteredRaces.length && !provider.hasMore) {
                              return Padding(
                                padding: const EdgeInsets.all(16),
                                child: Center(
                                  child: Text(
                                    lang.getText('no_more_races'),
                                    style: const TextStyle(
                                      color: AppTheme.textLight,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              );
                            }

                            final race = filteredRaces[index];
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
                      ),
              ),
            ],
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
