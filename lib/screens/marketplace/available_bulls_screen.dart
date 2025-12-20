import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
import '../../config/theme.dart';
import '../../models/marketplace_listing.dart';
import '../../providers/marketplace_provider.dart';

class AvailableBullsScreen extends StatefulWidget {
  const AvailableBullsScreen({super.key});

  @override
  State<AvailableBullsScreen> createState() => _AvailableBullsScreenState();
}

class _AvailableBullsScreenState extends State<AvailableBullsScreen> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch phone app')),
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
            slivers: [
              _buildSliverAppBar(provider),
              
              if (provider.isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (provider.error != null)
                SliverFillRemaining(
                  child: _buildError(provider),
                )
              else if (provider.listings.isEmpty)
                SliverFillRemaining(
                  child: _buildEmptyState(),
                )
              else
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
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(MarketplaceProvider provider) {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: true,
      pinned: true,
      backgroundColor: AppTheme.primaryOrange,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () => provider.loadListings(),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: const Text(
          'Marketplace',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
             Container(decoration: const BoxDecoration(gradient: AppTheme.primaryGradient)),
             Positioned(
               right: -30, top: -20,
               child: Icon(Icons.shopping_bag_outlined, size: 150, color: Colors.white.withOpacity(0.1)),
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
                        const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(listing.description!, style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87)),
                        const SizedBox(height: 24),
                      ],
                      const Text('Owner', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No bulls available yet',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade400, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
