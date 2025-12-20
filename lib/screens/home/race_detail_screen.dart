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
                  // Date Range
                  _buildDetailRow(
                    Icons.calendar_today,
                    'Dates',
                    '${DateHelper.formatDate(race.startDate)} - ${DateHelper.formatDate(race.endDate)}',
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
