import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../models/bull.dart';
import '../../services/bull_service.dart';
import 'bull_detail_screen.dart';

class BullsScreen extends StatefulWidget {
  const BullsScreen({super.key});

  @override
  State<BullsScreen> createState() => _BullsScreenState();
}

class _BullsScreenState extends State<BullsScreen> {
  final BullService _bullService = BullService();
  List<Bull> _bulls = [];
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
      final bulls = await _bullService.getAllBulls(limit: 50);
      setState(() {
        _bulls = bulls;
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
        title: const Text('Bulls'),
        backgroundColor: AppTheme.primaryOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBulls,
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
              onPressed: _loadBulls,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_bulls.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              size: 64,
              color: AppTheme.textLight,
            ),
            SizedBox(height: 16),
            Text(
              'No bulls found',
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
      onRefresh: _loadBulls,
      child: GridView.builder(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppTheme.spacingMd,
          mainAxisSpacing: AppTheme.spacingMd,
          childAspectRatio: 0.75,
        ),
        itemCount: _bulls.length,
        itemBuilder: (context, index) {
          final bull = _bulls[index];
          return _buildBullCard(bull);
        },
      ),
    );
  }

  Widget _buildBullCard(Bull bull) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _navigateToDetail(bull),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bull Image
            Expanded(
              child: Container(
                width: double.infinity,
                color: AppTheme.backgroundLight,
                child: bull.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: bull.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(
                            Icons.pets,
                            size: 48,
                            color: AppTheme.textLight,
                          ),
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.pets,
                          size: 48,
                          color: AppTheme.textLight,
                        ),
                      ),
              ),
            ),

            // Bull Info
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bull.name,
                    style: AppTheme.heading3.copyWith(fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppTheme.spacingXs),
                  if (bull.ownerName != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.person,
                          size: 12,
                          color: AppTheme.textLight,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            bull.ownerName!,
                            style: AppTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  if (bull.ownerVillage != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 12,
                          color: AppTheme.textLight,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            bull.ownerVillage!,
                            style: AppTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
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
