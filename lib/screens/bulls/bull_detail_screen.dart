import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../models/bull.dart';
import '../../providers/bull_provider.dart';

class BullDetailScreen extends StatefulWidget {
  final Bull bull;

  const BullDetailScreen({super.key, required this.bull});

  @override
  State<BullDetailScreen> createState() => _BullDetailScreenState();
}

class _BullDetailScreenState extends State<BullDetailScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BullProvider>().loadBullById(widget.bull.id);
      _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _shareBull(Bull bull) {
    final StringBuffer message = StringBuffer();
    message.writeln('Check out this bull on Naad Bailgada!');
    message.writeln('');
    message.writeln('🐂 ${bull.name}');
    if (bull.breed != null) message.writeln('Breed: ${bull.breed}');
    message.writeln('');
    message.writeln('Open in Naad Bailgada app: naad://bull/${bull.id}');
    
    Share.share(message.toString(), subject: 'Bull Profile - ${bull.name}');
  }

  Future<void> _callOwner(String phone) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BullProvider>(
      builder: (context, provider, child) {
        final detailedBull = provider.currentBull;
        final bull = detailedBull ?? widget.bull;
        
        return Scaffold(
          backgroundColor: const Color(0xFFF2F4F8),
          body: CustomScrollView(
            slivers: [
              _buildSliverAppBar(bull),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeaderInfo(bull),
                          const SizedBox(height: 24),
                          _buildStatsGrid(bull),
                          const SizedBox(height: 24),
                          if (bull.description != null && bull.description!.isNotEmpty) ...[
                            _buildSectionTitle('Description'),
                            const SizedBox(height: 12),
                            Text(
                              bull.description!,
                              style: const TextStyle(fontSize: 15, color: Colors.black54, height: 1.5),
                            ),
                            const SizedBox(height: 32),
                          ],
                          _buildOwnerCard(bull),
                          const SizedBox(height: 80), // Space for FAB
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _shareBull(bull),
            backgroundColor: AppTheme.primaryOrange,
            icon: const Icon(Icons.share, color: Colors.white),
            label: const Text('Share Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(Bull bull) {
    return SliverAppBar(
      expandedHeight: 400.0,
      pinned: true,
      stretch: true,
      backgroundColor: AppTheme.primaryOrange,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'bull_${bull.id}',
              child: bull.photoUrl != null
                ? CachedNetworkImage(
                    imageUrl: bull.photoUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_,__) => Container(color: Colors.grey.shade200),
                  )
                : Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.pets, size: 80, color: Colors.grey),
                  ),
            ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.6),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo(Bull bull) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                bull.name,
                style: const TextStyle(
                  fontSize: 32, 
                  fontWeight: FontWeight.w900, 
                  color: AppTheme.textDark,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            if (bull.breed != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  bull.breed!.toUpperCase(),
                  style: const TextStyle(
                    color: AppTheme.primaryOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        if (bull.registrationNumber != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Reg. #${bull.registrationNumber}',
              style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500),
            ),
          ),
      ],
    );
  }

  Widget _buildStatsGrid(Bull bull) {
    List<Widget> cards = [];

    // 1. Wins
    if (bull.statistics != null) {
      cards.add(Expanded(
        child: _buildStatCard(
          'Wins',
          '${bull.statistics!.firstPlaceWins}',
          Icons.emoji_events,
          Colors.amber,
          isHighlight: true,
        ),
      ));
    }

    // 2. Color
    if (bull.color != null && bull.color!.isNotEmpty) {
      cards.add(Expanded(
        child: _buildStatCard(
          'Color',
          bull.color!,
          Icons.palette,
          Colors.purple.shade400,
        ),
      ));
    }

    // 3. Age
    if (bull.birthYear != null) {
      cards.add(Expanded(
        child: _buildStatCard(
          'Age',
          bull.displayAge,
          Icons.access_time_filled,
          Colors.blue.shade400,
        ),
      ));
    }

    if (cards.isEmpty) return const SizedBox.shrink();

    // Add spacing between cards
    List<Widget> children = [];
    for (int i = 0; i < cards.length; i++) {
      children.add(cards[i]);
      if (i < cards.length - 1) {
        children.add(const SizedBox(width: 12));
      }
    }

    return Row(
      children: children,
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, {bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: isHighlight ? Border.all(color: color.withOpacity(0.5), width: 1) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark),
    );
  }

  Widget _buildOwnerCard(Bull bull) {
    if (bull.owner == null && bull.ownerName == null) return const SizedBox.shrink();
    
    final name = bull.owner?.name ?? bull.ownerName ?? 'Unknown Owner';
    final address = bull.owner?.address ?? bull.ownerAddress ?? 'No Address';
    final phone = bull.owner?.phone;
    final photoUrl = bull.owner?.photoUrl;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
             color: Colors.black.withOpacity(0.05),
             blurRadius: 15,
             offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                 width: 60, height: 60,
                 decoration: BoxDecoration(
                   shape: BoxShape.circle,
                   color: AppTheme.primaryOrange.withOpacity(0.1),
                   border: Border.all(color: Colors.grey.shade100, width: 2),
                 ),
                 child: ClipOval(
                   child: photoUrl != null
                       ? CachedNetworkImage(
                           imageUrl: photoUrl,
                           fit: BoxFit.cover,
                           placeholder: (context, url) => const Icon(Icons.person, color: AppTheme.primaryOrange),
                           errorWidget: (context, url, error) => const Icon(Icons.person, color: AppTheme.primaryOrange),
                         )
                       : const Icon(Icons.person, color: AppTheme.primaryOrange, size: 30),
                 ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Owner',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                  ],
                ),
              ),
              if (phone != null && phone.isNotEmpty)
                InkWell(
                  onTap: () => _callOwner(phone),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.phone, size: 16, color: AppTheme.textDark),
                        const SizedBox(width: 8),
                        Text(
                          phone,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, size: 20, color: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  address,
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade700, height: 1.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
