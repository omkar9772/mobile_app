import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../models/owner.dart';
import '../../models/bull.dart';
import '../../services/owner_service.dart';
import 'bull_detail_screen.dart';

class OwnerProfileScreen extends StatefulWidget {
  final Owner owner;

  const OwnerProfileScreen({super.key, required this.owner});

  @override
  State<OwnerProfileScreen> createState() => _OwnerProfileScreenState();
}

class _OwnerProfileScreenState extends State<OwnerProfileScreen> {
  final OwnerService _ownerService = OwnerService();
  final ScrollController _scrollController = ScrollController();

  Owner? _detailedOwner; // Owner with original photo (loads in background)
  List<Bull> _bulls = [];
  bool _isLoadingBulls = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOwnerDetails();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadOwnerDetails() async {
    try {
      // Load bulls and owner details in parallel
      final results = await Future.wait([
        _ownerService.getOwnerBulls(widget.owner.id),
        _ownerService.getOwnerById(widget.owner.id),
      ]);

      if (mounted) {
        setState(() {
          _bulls = results[0] as List<Bull>;
          _detailedOwner = results[1] as Owner;
          _isLoadingBulls = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoadingBulls = false;
        });
      }
    }
  }

  Future<void> _makePhoneCall(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(),
          _buildOwnerInfo(),
          _buildBullsSection(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    // Use detailed owner photo if loaded, fallback to list view photo for Hero transition
    final photoUrl = _detailedOwner?.photoUrl ?? widget.owner.photoUrl;

    return SliverAppBar(
      expandedHeight: 250.0,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.primaryOrange,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'owner_${widget.owner.id}',
              child: photoUrl != null
                  ? CachedNetworkImage(
                      imageUrl: photoUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppTheme.primaryOrange,
                        // No loading spinner - smooth transition from Hero animation
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppTheme.primaryOrange,
                        child: const Icon(Icons.person, color: Colors.white, size: 80),
                      ),
                    )
                  : Container(
                      color: AppTheme.primaryOrange,
                      child: const Icon(Icons.person, color: Colors.white, size: 80),
                    ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnerInfo() {
    // Use detailed owner if loaded, fallback to widget.owner
    final owner = _detailedOwner ?? widget.owner;

    return SliverToBoxAdapter(
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              owner.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 16),

            if (owner.phone != null) ...[
              _buildInfoRow(
                Icons.phone,
                owner.phone!,
                onTap: () => _makePhoneCall(owner.phone!),
              ),
              const SizedBox(height: 12),
            ],

            if (owner.email != null) ...[
              _buildInfoRow(Icons.email, owner.email!),
              const SizedBox(height: 12),
            ],

            if (owner.address != null) ...[
              _buildInfoRow(Icons.location_on, owner.address!),
              const SizedBox(height: 12),
            ],

            if (owner.bullCount != null)
              _buildInfoRow(
                Icons.pets,
                '${owner.bullCount} Champion${owner.bullCount != 1 ? 's' : ''}',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {VoidCallback? onTap}) {
    final content = Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryOrange),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textDark,
            ),
          ),
        ),
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: content,
        ),
      );
    }

    return content;
  }

  Widget _buildBullsSection() {
    if (_isLoadingBulls) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppTheme.errorRed),
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: AppTheme.errorRed)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadOwnerDetails,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_bulls.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pets, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'No bulls found',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Champions',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildBullCard(_bulls[index - 1]),
            );
          },
          childCount: _bulls.length + 1,
        ),
      ),
    );
  }

  Widget _buildBullCard(Bull bull) {
    return GestureDetector(
      onTap: () => _navigateToBullDetail(bull),
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
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: bull.photoUrl != null
                  ? CachedNetworkImage(
                      imageUrl: bull.photoUrl!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey.shade100,
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey.shade100,
                        child: Icon(Icons.pets, color: Colors.grey.shade300, size: 30),
                      ),
                    )
                  : Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey.shade100,
                      child: Icon(Icons.pets, color: Colors.grey.shade300, size: 30),
                    ),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bull.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (bull.breed != null)
                      Text(
                        bull.breed!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                    if (bull.statistics != null)
                      Row(
                        children: [
                          Icon(Icons.emoji_events, size: 14, color: Colors.amber.shade700),
                          const SizedBox(width: 4),
                          Text(
                            '${bull.statistics!.firstPlaceWins} wins',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.flag, size: 14, color: Colors.blue.shade700),
                          const SizedBox(width: 4),
                          Text(
                            '${bull.statistics!.totalRaces} races',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            // Arrow
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToBullDetail(Bull bull) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BullDetailScreen(bull: bull),
      ),
    );
  }
}
