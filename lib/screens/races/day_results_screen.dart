import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/race.dart';
import '../../models/bull.dart';
import '../../utils/date_helper.dart';
import '../bulls/bull_detail_screen.dart';
import '../../providers/race_provider.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'widgets/result_poster_widget.dart';

class DayResultsScreen extends StatefulWidget {
  final Race race;
  final RaceDay day;

  const DayResultsScreen({
    super.key,
    required this.race,
    required this.day,
  });

  @override
  State<DayResultsScreen> createState() => _DayResultsScreenState();
}

class _DayResultsScreenState extends State<DayResultsScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RaceProvider>().loadDayResults(widget.day.id);
    });
  }

  void _navigateToBullDetail(Map<String, dynamic>? bullData) {
    if (bullData == null) return;

    final bull = Bull(
      id: bullData['id'] ?? '',
      name: bullData['name'] ?? 'Unknown',
      breed: bullData['breed'],
      color: bullData['color'],
      photoUrl: bullData['photo_url'],
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BullDetailScreen(bull: bull),
      ),
    );
  }

  Future<void> _shareResult(RaceResult result) async {
    File? tempFile;
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryOrange),
        ),
      );

      final imageBytes = await _screenshotController.captureFromWidget(
        Container(
          color: Colors.transparent,
          child: MediaQuery(
            data: const MediaQueryData(
              devicePixelRatio: 1.0,
              textScaleFactor: 1.0,
            ),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: RaceResultPoster(
                result: result,
                race: widget.race,
                day: widget.day,
              ),
            ),
          ),
        ),
        delay: const Duration(milliseconds: 2000),
        pixelRatio: 8.0,
      );

      // Hide loading indicator
      if (mounted) Navigator.pop(context);

      if (kIsWeb) {
        // Web: Use XFile.fromData to avoid file system access
        await Share.shareXFiles(
          [XFile.fromData(
            imageBytes,
            mimeType: 'image/png',
            name: 'race_result_${result.id}.png'
          )],
          text: 'Check out this race result on Naad Bailgada! 🐂💨',
        );
      } else {
        // Mobile: Save to temp file
        final directory = await getTemporaryDirectory();
        tempFile = await File('${directory.path}/race_result_${result.id}.png').create();
        await tempFile.writeAsBytes(imageBytes);

        await Share.shareXFiles(
          [XFile(tempFile.path)],
          text: 'Check out this race result on Naad Bailgada! 🐂💨',
        );

        // Clean up temporary file after sharing
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      }
    } catch (e) {
      // Hide loading indicator if showing
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share result: $e')),
        );
      }
    } finally {
      // Ensure temp file is cleaned up even if an error occurs
      if (tempFile != null && await tempFile.exists()) {
        try {
          await tempFile.delete();
        } catch (e) {
          // Ignore cleanup errors
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      body: Consumer<RaceProvider>(
        builder: (context, provider, child) {
          final results = provider.dayResults;
          final isLoading = provider.isLoadingResults;
          final error = provider.errorResults;

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(),

              if (isLoading)
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
              else if (error != null)
                SliverFillRemaining(
                  child: _buildError(error, provider),
                )
              else if (results.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: Text("No results found for this day.")),
                )
              else 
                SliverPadding(
                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                   sliver: SliverList(
                     delegate: SliverChildBuilderDelegate(
                       (context, index) => _buildResultCard(results[index]),
                       childCount: results.length,
                     ),
                   ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 100.0,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.primaryOrange,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Day ${widget.day.dayNumber}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              DateHelper.formatDate(widget.day.raceDate),
              style: const TextStyle(fontSize: 10,  fontWeight: FontWeight.normal, color: Colors.white70),
            ),
          ],
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
          child: Stack(
            children: [
              Positioned(
                 right: -20, bottom: -20,
                 child: Icon(Icons.emoji_events, size: 140, color: Colors.white.withOpacity(0.1)),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildError(String error, RaceProvider provider) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(error, style: const TextStyle(color: Colors.redAccent)),
          TextButton(
             onPressed: () => provider.loadDayResults(widget.day.id),
             child: const Text('Retry'),
          )
        ],
      ),
    );
  }

  Widget _buildResultCard(RaceResult result) {
    final bool isPodium = result.position <= 3 && !result.isDisqualified;
    Color? medalColor;
    if (result.position == 1) medalColor = const Color(0xFFFFD700);
    else if (result.position == 2) medalColor = const Color(0xFFC0C0C0);
    else if (result.position == 3) medalColor = const Color(0xFFCD7F32);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isPodium ? Border.all(color: medalColor!, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Header (Position & Status)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: result.isDisqualified ? Colors.red.shade50 : (isPodium ? medalColor!.withOpacity(0.1) : Colors.grey.shade50),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                if (result.isDisqualified)
                   const Icon(Icons.block, color: Colors.red, size: 16)
                else if (isPodium)
                   Icon(Icons.emoji_events, color: medalColor!.withOpacity(1.0), size: 16)
                else
                   Icon(Icons.flag, color: Colors.grey.shade600, size: 16),
                   
                const SizedBox(width: 8),
                Text(
                  result.isDisqualified ? 'DISQUALIFIED' : 'POSITION ${result.position}',
                  style: TextStyle(
                    fontSize: 12, 
                    fontWeight: FontWeight.bold,
                    color: result.isDisqualified ? Colors.red : (isPodium ? Colors.black87 : Colors.grey.shade700),
                    letterSpacing: 1.0,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _shareResult(result),
                  icon: Icon(Icons.share_outlined, size: 20, color: Colors.grey.shade700),
                  tooltip: 'Share Result',
                ),
                if (!result.isDisqualified)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.timer_outlined, size: 14, color: Colors.grey.shade800),
                        const SizedBox(width: 4),
                        Text(
                          result.getFormattedTime(),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bulls
                IntrinsicHeight(
                  child: Row(
                    children: [
                       Expanded(child: _buildBullInfo(result.bull1Name, result.bull1PhotoUrl, () => _navigateToBullDetail(result.bull1))),
                       const VerticalDivider(),
                       Expanded(child: _buildBullInfo(result.bull2Name, result.bull2PhotoUrl, () => _navigateToBullDetail(result.bull2))),
                    ],
                  ),
                ),
                const Divider(height: 24),
                
                // Owner Info
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${result.owner1Name}${result.owner2Name != null ? ' & ${result.owner2Name}' : ''}',
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                
                if (result.isDisqualified && result.disqualificationReason != null)
                   Padding(
                     padding: const EdgeInsets.only(top: 12),
                     child: Container(
                       padding: const EdgeInsets.all(8),
                       width: double.infinity,
                       decoration: BoxDecoration(
                         color: Colors.red.shade50,
                         borderRadius: BorderRadius.circular(8),
                       ),
                       child: Text(
                         'Reason: ${result.disqualificationReason}',
                         style: TextStyle(color: Colors.red.shade700, fontSize: 12, fontStyle: FontStyle.italic),
                       ),
                     ),
                   ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBullInfo(String name, String? photoUrl, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
             width: 64, height: 64,
             decoration: BoxDecoration(
               shape: BoxShape.circle,
               border: Border.all(color: Colors.grey.shade200, width: 2),
             ),
             child: ClipOval(
               child: photoUrl != null
                 ? CachedNetworkImage(
                     imageUrl: photoUrl,
                     fit: BoxFit.cover,
                     errorWidget: (_,__,___) => Padding(
                       padding: const EdgeInsets.all(8.0),
                       child: SvgPicture.asset('assets/images/logo.svg', fit: BoxFit.contain),
                     ),
                   )
                 : Padding(
                     padding: const EdgeInsets.all(8.0),
                     child: SvgPicture.asset('assets/images/logo.svg', fit: BoxFit.contain),
                   ),
             ),
          ),
          const SizedBox(height: 8),
          Text(
            name == 'Unknown' ? 'Contact admin to add image' : name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          const Text(
            'Champion',
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
