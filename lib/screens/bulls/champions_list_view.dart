import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../config/app_config.dart';
import '../../models/bull.dart';
import '../../providers/bull_provider.dart';
import '../../providers/language_provider.dart';
import 'bull_detail_screen.dart';

class ChampionsListView extends StatefulWidget {
  const ChampionsListView({super.key});

  @override
  State<ChampionsListView> createState() => _ChampionsListViewState();
}

class _ChampionsListViewState extends State<ChampionsListView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
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
      context.read<BullProvider>().loadMoreBulls();
    }
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(
      Duration(milliseconds: AppConfig.searchDebounceMs),
      () {
        context.read<BullProvider>().search(_searchController.text);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Consumer<BullProvider>(
      builder: (context, provider, child) {
        return CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildSearchAndFilters(provider, lang),

            if (provider.isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: AppTheme.primaryOrange,
                        strokeWidth: 3,
                      ),
                      SizedBox(height: 24),
                      Text(
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
            else if (provider.error != null)
              SliverFillRemaining(
                child: _buildError(provider.error!, provider, lang),
              )
            else if (provider.bulls.isEmpty)
              SliverFillRemaining(
                child: _buildEmptyState(provider, lang),
              )
            else ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildBullCard(provider.bulls[index]),
                    childCount: provider.bulls.length,
                  ),
                ),
              ),

              // Loading more indicator
              if (provider.isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),

              // No more items indicator
              if (!provider.hasMore && provider.bulls.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        lang.getText('no_more_bulls'),
                        style: const TextStyle(
                          color: AppTheme.textLight,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSearchAndFilters(BullProvider provider, LanguageProvider lang) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            decoration: const BoxDecoration(
              color: Color(0xFFF2F4F8),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _onSearchChanged(),
              decoration: InputDecoration(
                hintText: lang.getText('search_champions'),
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: AppTheme.primaryOrange, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          provider.search('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(12),
                   borderSide: const BorderSide(color: AppTheme.primaryOrange, width: 1.5),
                ),
              ),
            ),
          ),

          Container(
            height: 48,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip(lang.getText('filter_all'), 'all', provider),
                const SizedBox(width: 8),
                _buildFilterChip(lang.getText('filter_name'), 'name', provider),
                const SizedBox(width: 8),
                _buildFilterChip(lang.getText('filter_location'), 'location', provider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, BullProvider provider) {
    final isSelected = provider.filterType == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          provider.setFilterType(value);
        }
      },
      backgroundColor: Colors.white,
      selectedColor: AppTheme.primaryOrange,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.textDark,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Colors.transparent : Colors.grey.shade300,
        ),
      ),
      elevation: isSelected ? 2 : 0,
      shadowColor: AppTheme.primaryOrange.withOpacity(0.4),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
    );
  }

  Widget _buildBullCard(Bull bull) {
    return GestureDetector(
      onTap: () => _navigateToDetail(bull),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryOrange.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Section
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'bull_${bull.id}',
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: bull.photoUrl != null
                          ? CachedNetworkImage(
                              imageUrl: bull.photoUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey.shade50,
                                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey.shade50,
                                child: Icon(Icons.pets, color: Colors.grey.shade300, size: 32),
                              ),
                            )
                          : Container(
                              color: Colors.grey.shade50,
                              child: Icon(Icons.pets, color: Colors.grey.shade300, size: 32),
                            ),
                    ),
                  ),
                  if (bull.breed != null)
                    Positioned(
                      top: 8, right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          bull.breed!,
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Info Section
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bull.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                         if (bull.ownerName != null)
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 8,
                                backgroundColor: AppTheme.primaryOrange.withOpacity(0.1),
                                child: const Icon(Icons.person, size: 10, color: AppTheme.primaryOrange),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  bull.ownerName!,
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),

                    if (bull.ownerAddress != null)
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 12, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              bull.ownerAddress!,
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
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

  Widget _buildError(String error, BullProvider provider, LanguageProvider lang) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppTheme.errorRed),
          const SizedBox(height: 16),
          Text(error, style: const TextStyle(color: AppTheme.errorRed)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => provider.loadBulls(),
            child: Text(lang.getText('retry')),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BullProvider provider, LanguageProvider lang) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pets, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty
                ? lang.getText('no_bulls_found')
                : lang.getText('no_bulls_match'),
            style: TextStyle(fontSize: 16, color: Colors.grey.shade400, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(Bull bull) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BullDetailScreen(bull: bull),
      ),
    );
  }
}
