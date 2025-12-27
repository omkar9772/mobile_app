import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../config/theme.dart';
import '../../models/race.dart';
import '../../utils/date_helper.dart';
import 'day_results_screen.dart';
import '../../providers/race_provider.dart';

class RaceDaysScreen extends StatefulWidget {
  final Race race;

  const RaceDaysScreen({super.key, required this.race});

  @override
  State<RaceDaysScreen> createState() => _RaceDaysScreenState();
}

class _RaceDaysScreenState extends State<RaceDaysScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RaceProvider>().loadRaceDays(widget.race.id);
    });
  }

  Future<void> _openMap(String gpsLocation) async {
    try {
      final url = Uri.parse(gpsLocation);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not open location';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open location: $e')),
        );
      }
    }
  }

  void _shareRace(Race race) {
    // Build share message with race details
    final StringBuffer message = StringBuffer();
    message.writeln('Check out this race on Naad Bailgada!');
    message.writeln('');
    message.writeln('🏁 ${race.name}');
    message.writeln('');
    message.writeln('📅 ${DateHelper.formatDate(race.startDate)} - ${DateHelper.formatDate(race.endDate)}');
    if (race.address.isNotEmpty) message.writeln('📍 ${race.address}');
    if (race.trackLength > 0) message.writeln('🏃 Track: ${race.trackLength} ${race.trackLengthUnit}');
    message.writeln('');
    message.writeln('Open in Naad Bailgada app: naad://race/${race.id}');

    Share.share(
      message.toString(),
      subject: 'Race - ${race.name}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      body: Consumer<RaceProvider>(
        builder: (context, provider, child) {
          final days = provider.raceDays;
          final isLoading = provider.isLoadingDays;
          final error = provider.errorDays;

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    children: [
                      // Info Overview Card
                      _buildInfoValues(),
                      
                      const SizedBox(height: 24),
                      
                      // Management / Contact Card or Actions
                      if (widget.race.gpsLocation != null || widget.race.managementContact != null)
                        _buildActionButtons(),
                        
                      const SizedBox(height: 32),
                      
                      // Section Title
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryOrange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.calendar_month_outlined, size: 18, color: AppTheme.primaryOrange),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Race Schedule',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

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
                  child: Center(child: Text(error)),
                )
              else if (days.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('No schedule available yet.')),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildDayCard(days[index]),
                      childCount: days.length,
                    ),
                  ),
                ),
                
              const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.primaryOrange,
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () => _shareRace(widget.race),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16, right: 20),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              widget.race.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.white70, size: 12),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.race.address,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(decoration: const BoxDecoration(gradient: AppTheme.primaryGradient)),
            // Decorative circles
            Positioned(
              right: -50, top: -50,
              child: Container(
                width: 200, height: 200,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoValues() {
    return Container(
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
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Track Length',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.race.trackLength > 0 ? '${widget.race.trackLength} ${widget.race.trackLengthUnit}' : 'N/A',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                ],
              ),
            ),
            VerticalDivider(color: Colors.grey.shade200),
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Dates',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${DateHelper.formatDate(widget.race.startDate).split(',')[0]} - ${DateHelper.formatDate(widget.race.endDate).split(',')[0]}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (widget.race.gpsLocation != null && widget.race.gpsLocation!.isNotEmpty)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _openMap(widget.race.gpsLocation!),
              icon: const Icon(Icons.map_outlined, size: 18),
              label: const Text('Event Location'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryOrange,
                elevation: 0,
                side: const BorderSide(color: AppTheme.primaryOrange),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        
        if (widget.race.gpsLocation != null && widget.race.managementContact != null)
           const SizedBox(width: 12),

        if (widget.race.managementContact != null && widget.race.managementContact!.isNotEmpty)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async {
                 final Uri launchUri = Uri(
                   scheme: 'tel',
                   path: widget.race.managementContact,
                 );
                 if (await canLaunchUrl(launchUri)) {
                   await launchUrl(launchUri);
                 }
              },
              icon: const Icon(Icons.phone_outlined, size: 18),
              label: const Text('Contact Organizer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                foregroundColor: Colors.white,
                elevation: 2,
                shadowColor: AppTheme.primaryOrange.withOpacity(0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDayCard(RaceDay day) {
    final dayOfWeek = DateFormat('EEEE').format(day.raceDate);
    final dateStr = DateHelper.formatDate(day.raceDate);
    final bool isFuture = day.raceDate.isAfter(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DayResultsScreen(race: widget.race, day: day),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Date Badge
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: day.isCompleted ? AppTheme.successGreen.withOpacity(0.1) : (day.isInProgress ? AppTheme.primaryOrange.withOpacity(0.1) : Colors.grey.shade50),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: day.isCompleted ? AppTheme.successGreen.withOpacity(0.2) : (day.isInProgress ? AppTheme.primaryOrange.withOpacity(0.2) : Colors.grey.shade200)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('MMM').format(day.raceDate).toUpperCase(),
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: day.isCompleted ? AppTheme.successGreen : (day.isInProgress ? AppTheme.primaryOrange : Colors.grey)),
                      ),
                      Text(
                        DateFormat('d').format(day.raceDate),
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: day.isCompleted ? AppTheme.successGreen : (day.isInProgress ? AppTheme.primaryOrange : Colors.grey.shade800)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text(
                         'Day ${day.dayNumber}: $dayOfWeek',
                         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                       ),
                       if (day.daySubtitle != null)
                         Padding(
                           padding: const EdgeInsets.only(top: 4),
                           child: Text(
                             day.daySubtitle!,
                             style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                           ),
                         ),
                       const SizedBox(height: 6),
                       Row(
                         children: [
                           Container(
                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                             decoration: BoxDecoration(
                               color: day.isCompleted ? Colors.green.shade50 : (day.isInProgress ? Colors.orange.shade50 : Colors.grey.shade100),
                               borderRadius: BorderRadius.circular(4),
                             ),
                             child: Text(
                               day.status.toUpperCase(),
                               style: TextStyle(
                                 fontSize: 10,
                                 fontWeight: FontWeight.bold,
                                 color: day.isCompleted ? Colors.green : (day.isInProgress ? Colors.orange : Colors.grey),
                               ),
                             ),
                           ),
                           const SizedBox(width: 8),
                           Text(
                             '${day.totalParticipants} Participants',
                             style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                           ),
                         ],
                       )
                    ],
                  ),
                ),
                
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
