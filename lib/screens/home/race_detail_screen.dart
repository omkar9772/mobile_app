import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/race.dart';
import '../../utils/date_helper.dart';

class RaceDetailScreen extends StatelessWidget {
  final Race race;

  const RaceDetailScreen({super.key, required this.race});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Race Details'),
        backgroundColor: AppTheme.primaryOrange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    race.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          race.status.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Details
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date & Time
                  _buildDetailRow(
                    Icons.calendar_today,
                    'Date',
                    DateHelper.formatDate(race.raceDate),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),

                  // Location
                  if (race.address.isNotEmpty) ...[
                    _buildDetailRow(
                      Icons.location_on,
                      'Location',
                      race.address,
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                  ],

                  // Track Length
                  _buildDetailRow(
                    Icons.straighten,
                    'Track Length',
                    race.getTrackLength(),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),

                  // Participants
                  _buildDetailRow(
                    Icons.groups,
                    'Participants',
                    '${race.totalParticipants}',
                  ),
                  const SizedBox(height: AppTheme.spacingMd),

                  // Description
                  if (race.description != null && race.description!.isNotEmpty) ...[
                    const Text(
                      'Description',
                      style: AppTheme.heading3,
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    Text(
                      race.description!,
                      style: AppTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppTheme.spacingLg),
                  ],

                  // Results
                  if (race.results != null && race.results!.isNotEmpty) ...[
                    const Text(
                      'Results',
                      style: AppTheme.heading3,
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    ...race.results!.asMap().entries.map((entry) {
                      final result = entry.value;
                      return Card(
                        margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: result.position == 1
                                  ? const Color(0xFFFFD700)
                                  : result.position == 2
                                      ? const Color(0xFFC0C0C0)
                                      : result.position == 3
                                          ? const Color(0xFFCD7F32)
                                          : AppTheme.backgroundLight,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${result.position}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: result.position <= 3
                                      ? Colors.white
                                      : AppTheme.textDark,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            result.bullName ?? 'Bull #${result.bullId}',
                            style: AppTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            result.ownerName ?? 'Unknown Owner',
                            style: AppTheme.bodySmall,
                          ),
                          trailing: result.timeMilliseconds != null
                              ? Text(
                                  result.getFormattedTime(),
                                  style: AppTheme.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryOrange,
                                  ),
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryOrange),
        const SizedBox(width: AppTheme.spacingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textLight,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
