import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/user_bull_sell.dart';
import '../../services/user_bull_service.dart';
import 'add_bull_screen.dart';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';

class MyBullsScreen extends StatefulWidget {
  const MyBullsScreen({Key? key}) : super(key: key);

  @override
  State<MyBullsScreen> createState() => _MyBullsScreenState();
}

class _MyBullsScreenState extends State<MyBullsScreen> {
  final UserBullService _bullService = UserBullService();
  UserBullSellList? _bullsList;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBulls();
  }

  Future<void> _loadBulls() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final bulls = await _bullService.getMyBulls();
      setState(() {
        _bullsList = bulls;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteBull(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Listing'),
        content: const Text('Are you sure you want to remove this bull from sale?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _bullService.deleteBull(id);
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Listing removed successfully')),
          );
          _loadBulls();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : CustomScrollView(
                  slivers: [
                    _buildSliverAppBar(),
                    if (_bullsList != null) ...[
                      SliverToBoxAdapter(
                        child: _buildDashboardCard(),
                      ),
                      if (_bullsList!.bulls.isEmpty)
                         SliverFillRemaining(
                           child: _buildEmptyState(),
                         )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => _buildBullCard(_bullsList!.bulls[index], index),
                              childCount: _bullsList!.bulls.length,
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
      floatingActionButton: _bullsList != null && _bullsList!.canAddMore
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddBullScreen(),
                  ),
                );
                if (result == true) {
                  _loadBulls();
                }
              },
              backgroundColor: AppTheme.primaryOrange,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Bull', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: true,
      pinned: true,
      backgroundColor: AppTheme.primaryOrange,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 60, bottom: 16), // Offset for back button
        title: const Text(
          'My Listings',
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
               right: -20, top: -20,
               child: Icon(Icons.sell_outlined, size: 140, color: Colors.white.withOpacity(0.1)),
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Active Listings',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_bullsList!.activeCount}/${_bullsList!.maxAllowed}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.storefront, color: AppTheme.primaryOrange, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _bullsList!.maxAllowed > 0 
                  ? _bullsList!.activeCount / _bullsList!.maxAllowed 
                  : 0,
              backgroundColor: Colors.grey.shade100,
              valueColor: const AlwaysStoppedAnimation(AppTheme.primaryOrange),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _bullsList!.canAddMore 
                ? 'You can list ${_bullsList!.remainingSlots} more bull(s).' 
                : 'You have reached your listing limit.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildBullCard(UserBullSell bull, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100).clamp(0, 500)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
         return Transform.translate(
           offset: Offset(0, 30 * (1 - value)),
           child: Opacity(opacity: value, child: child),
         );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            // Image Section
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: bull.imageUrl.isNotEmpty
                       ? CachedNetworkImage(
                           imageUrl: bull.imageUrl,
                           fit: BoxFit.cover,
                           placeholder: (_,__) => Container(color: Colors.grey.shade100),
                           errorWidget: (_,__,___) => Container(color: Colors.grey.shade100, child: const Icon(Icons.image_not_supported)),
                         )
                       : Container(color: Colors.grey.shade100, child: const Icon(Icons.image_not_supported)),
                  ),
                ),
                // Price Tag
                Positioned(
                  top: 12, right: 12,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          bull.formattedPriceShort,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
                // Status Badge
                Positioned(
                  top: 12, left: 12,
                  child: _buildStatusChip(bull),
                ),
              ],
            ),
            
            // Content Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        bull.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                      ),
                      if (bull.breed != null)
                        Text(
                          bull.breed!,
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (bull.location != null)
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(
                        bull.location!,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                   const SizedBox(height: 16),
                   SizedBox(
                     width: double.infinity,
                     child: OutlinedButton.icon(
                       onPressed: () => _deleteBull(bull.id),
                       icon: const Icon(Icons.delete_outline, size: 18),
                       label: const Text('Delete Listing'),
                       style: OutlinedButton.styleFrom(
                         foregroundColor: AppTheme.errorRed,
                         side: const BorderSide(color: AppTheme.errorRed),
                         padding: const EdgeInsets.symmetric(vertical: 12),
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                       ),
                     ),
                   ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(UserBullSell bull) {
    Color color;
    String label;
    IconData icon;

    if (bull.isSold) {
      color = Colors.grey;
      label = 'Sold';
      icon = Icons.done;
    } else if (bull.isExpired) {
      color = AppTheme.errorRed;
      label = 'Expired';
      icon = Icons.access_time;
    } else {
      color = AppTheme.successGreen;
      label = 'Active';
      icon = Icons.check_circle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
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
          Icon(Icons.add_shopping_cart, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 24),
          const Text(
            'No Active Listings',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark),
          ),
          const SizedBox(height: 8),
          Text(
            'Start selling your champions on Naad!',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppTheme.errorRed),
          const SizedBox(height: 16),
          Text('Error: $_error', style: const TextStyle(color: AppTheme.errorRed)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadBulls,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
