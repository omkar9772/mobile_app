import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../config/app_config.dart';
import '../../models/owner.dart';
import '../../providers/owner_provider.dart';
import '../../providers/language_provider.dart';
import 'owner_profile_screen.dart';

class OwnersListView extends StatefulWidget {
  const OwnersListView({super.key});

  @override
  State<OwnersListView> createState() => _OwnersListViewState();
}

class _OwnersListViewState extends State<OwnersListView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Load owners when view is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<OwnerProvider>();
      if (!provider.isLoaded) {
        provider.loadOwners();
      }
    });
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
      context.read<OwnerProvider>().loadMoreOwners();
    }
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(
      Duration(milliseconds: AppConfig.searchDebounceMs),
      () async {
        await context.read<OwnerProvider>().search(_searchController.text);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Consumer<OwnerProvider>(
      builder: (context, provider, child) {
        return CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildSearchBar(provider, lang),

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
            else if (provider.owners.isEmpty)
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
                    (context, index) => _buildOwnerCard(provider.owners[index]),
                    childCount: provider.owners.length,
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
              if (!provider.hasMore && provider.owners.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        lang.getText('no_more_owners'),
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

  Widget _buildSearchBar(OwnerProvider provider, LanguageProvider lang) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 15),
        decoration: const BoxDecoration(
          color: Color(0xFFF2F4F8),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => _onSearchChanged(),
          decoration: InputDecoration(
            hintText: lang.getText('search_owners'),
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: const Icon(Icons.search, color: AppTheme.primaryOrange, size: 20),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
                    onPressed: () async {
                      _searchController.clear();
                      await provider.search('');
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
    );
  }

  Widget _buildOwnerCard(Owner owner) {
    final lang = context.watch<LanguageProvider>();
    return GestureDetector(
      onTap: () => _navigateToProfile(owner),
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
                    tag: 'owner_${owner.id}',
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: owner.photoUrl != null
                          ? CachedNetworkImage(
                              imageUrl: owner.photoUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey.shade50,
                                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey.shade50,
                                child: Icon(Icons.person, color: Colors.grey.shade300, size: 32),
                              ),
                            )
                          : Container(
                              color: Colors.grey.shade50,
                              child: Icon(Icons.person, color: Colors.grey.shade300, size: 32),
                            ),
                    ),
                  ),
                  if (owner.bullCount != null && owner.bullCount! > 0)
                    Positioned(
                      top: 8, right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryOrange,
                          borderRadius: BorderRadius.circular(12), // Pill shape
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.emoji_events, color: Colors.white, size: 10),
                            const SizedBox(width: 4),
                            Text(
                              '${owner.bullCount} ${lang.getText('bulls_count')}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            owner.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (owner.photoUrl != null) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            size: 16,
                            color: Colors.blue,
                          ),
                        ],
                      ],
                    ),

                    if (owner.address != null)
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 12, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              owner.address!,
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

  Widget _buildError(String error, OwnerProvider provider, LanguageProvider lang) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppTheme.errorRed),
          const SizedBox(height: 16),
          Text(error, style: const TextStyle(color: AppTheme.errorRed)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => provider.loadOwners(),
            child: Text(lang.getText('retry')),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(OwnerProvider provider, LanguageProvider lang) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty
                ? lang.getText('no_owners_found')
                : lang.getText('no_owners_match'),
            style: TextStyle(fontSize: 16, color: Colors.grey.shade400, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _navigateToProfile(Owner owner) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OwnerProfileScreen(owner: owner),
      ),
    );
  }
}
