import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
import '../../config/theme.dart';
import '../../models/marketplace_listing.dart';
import '../../providers/marketplace_provider.dart';
import '../../providers/language_provider.dart';

class AvailableBullsScreen extends StatefulWidget {
  const AvailableBullsScreen({super.key});

  @override
  State<AvailableBullsScreen> createState() => _AvailableBullsScreenState();
}

class _AvailableBullsScreenState extends State<AvailableBullsScreen> {
  final ScrollController _scrollController = ScrollController();
  int _currentQuoteIndex = 0;
  Timer? _quoteTimer;

  final List<String> _quotes = [
    'खरेदी करा शान… मिळवा विजयाचं मान',
    'खरेदी करा विश्वासाने… जिंका सहजतेने',
    'निवडा उद्याचा हिंद केसरी आणि बनवा घाटाचा राजा',
    'थेट मालकाशी बोला… सौदा पक्का करा',
    'बैलगाडा शर्यत… महाराष्ट्राची शान!',
    'उत्तम बैल… विजयाची पहिली पायरी',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _startQuoteTimer();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _quoteTimer?.cancel();
    super.dispose();
  }

  void _startQuoteTimer() {
    _quoteTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentQuoteIndex = (_currentQuoteIndex + 1) % _quotes.length;
        });
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<MarketplaceProvider>().loadMoreListings();
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (mounted) {
        final lang = context.read<LanguageProvider>();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(lang.getText('could_not_launch_phone'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      body: Consumer<MarketplaceProvider>(
        builder: (context, provider, child) {
          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildSliverAppBar(provider),

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
                  child: _buildError(provider),
                )
              else if (provider.listings.isEmpty)
                SliverFillRemaining(
                  child: _buildEmptyState(),
                )
              else ...[
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildGridCard(provider.listings[index], index),
                      childCount: provider.listings.length,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
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
                if (!provider.hasMore && provider.listings.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Consumer<LanguageProvider>(
                          builder: (context, lang, _) => Text(
                            lang.getText('no_more_listings'),
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(MarketplaceProvider provider) {
    final lang = context.watch<LanguageProvider>();
    return SliverAppBar(
      expandedHeight: 140.0,
      floating: true,
      pinned: true,
      backgroundColor: AppTheme.primaryOrange,
      title: Text(
        lang.getText('marketplace'),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () => provider.loadListings(),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
             Container(decoration: const BoxDecoration(gradient: AppTheme.primaryGradient)),
             Positioned(
               right: -20, top: 40,
               child: Icon(Icons.shopping_bag_outlined, size: 140, color: Colors.white.withOpacity(0.08)),
             ),
             // Animated Catchy Quotes
             Positioned(
               left: 16,
               right: 16,
               bottom: 16,
               child: Center(
                 child: Container(
                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                   decoration: BoxDecoration(
                     color: Colors.white.withOpacity(0.15),
                     borderRadius: BorderRadius.circular(20),
                     border: Border.all(color: Colors.white.withOpacity(0.2)),
                     boxShadow: [
                       BoxShadow(
                         color: Colors.black.withOpacity(0.05),
                         blurRadius: 10,
                         offset: const Offset(0, 4),
                       )
                     ]
                   ),
                   child: AnimatedSwitcher(
                     duration: const Duration(milliseconds: 500),
                     transitionBuilder: (Widget child, Animation<double> animation) {
                       return FadeTransition(opacity: animation, child: SlideTransition(
                         position: Tween<Offset>(begin: const Offset(0.0, 0.5), end: Offset.zero).animate(animation),
                         child: child,
                       ));
                     },
                     child: Text(
                       _quotes[_currentQuoteIndex],
                       key: ValueKey<int>(_currentQuoteIndex),
                       textAlign: TextAlign.center,
                       style: const TextStyle(
                         color: Colors.white,
                         fontSize: 13,
                         fontWeight: FontWeight.w600,
                         letterSpacing: 0.5,
                         shadows: [
                           Shadow(
                             offset: Offset(0, 1),
                             blurRadius: 2,
                             color: Colors.black12,
                           ),
                         ],
                       ),
                     ),
                   ),
                 ),
               ),
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard(MarketplaceListing listing, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 50).clamp(0, 500)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
           scale: 0.9 + (0.1 * value),
           child: Opacity(
             opacity: value,
             child: child,
           ),
        );
      },
      child: GestureDetector(
        onTap: () => _showListingDetails(listing),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: listing.imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: listing.imageUrl!,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(color: Colors.grey.shade100),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey.shade100,
                                child: Icon(Icons.pets, size: 30, color: Colors.grey.shade300),
                              ),
                            )
                          : Container(
                              color: Colors.grey.shade100,
                              child: Center(
                                child: Icon(Icons.pets, size: 30, color: Colors.grey.shade300),
                              ),
                            ),
                    ),
                    Positioned(
                      bottom: 8, right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          listing.formattedPriceShort,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 12, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            listing.location,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
    );
  }

  void _showListingDetails(MarketplaceListing listing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(24),
                    children: [
                      AspectRatio(
                        aspectRatio: 1.0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: listing.imageUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: listing.imageUrl!,
                                  fit: BoxFit.cover,
                                )
                              : Container(color: Colors.grey.shade200),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              listing.name,
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            listing.formattedPriceShort,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryOrange),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(listing.location, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (listing.description != null) ...[
                        Consumer<LanguageProvider>(
                          builder: (context, lang, _) => Text(lang.getText('description'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 8),
                        Text(listing.description!, style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87)),
                        const SizedBox(height: 24),
                      ],
                      Consumer<LanguageProvider>(
                        builder: (context, lang, _) => Text(lang.getText('owner'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                           backgroundColor: AppTheme.primaryOrange.withOpacity(0.1),
                           child: const Icon(Icons.person, color: AppTheme.primaryOrange),
                        ),
                        title: Text(listing.ownerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(listing.ownerMobile),
                        trailing: IconButton.filled(
                          onPressed: () => _makePhoneCall(listing.ownerMobile),
                          icon: const Icon(Icons.phone),
                          style: IconButton.styleFrom(backgroundColor: AppTheme.successGreen),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildError(MarketplaceProvider provider) {
    final lang = context.watch<LanguageProvider>();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppTheme.errorRed),
          const SizedBox(height: 16),
          Text(provider.error!, style: const TextStyle(color: AppTheme.errorRed)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => provider.loadListings(),
            child: Text(lang.getText('retry')),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final lang = context.watch<LanguageProvider>();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            lang.getText('no_bulls_available'),
            style: TextStyle(fontSize: 18, color: Colors.grey.shade400, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
