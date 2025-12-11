import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/race.dart';
import '../utils/date_helper.dart';

class RaceCard extends StatelessWidget {
  final Race race;
  final bool isRecent;
  final VoidCallback onTap;

  const RaceCard({
    super.key,
    required this.race,
    required this.isRecent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Badge
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isRecent
                      ? AppTheme.successGreen.withOpacity(0.1)
                      : AppTheme.infoBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Icon(
                  isRecent ? Icons.check_circle : Icons.schedule,
                  color: isRecent ? AppTheme.successGreen : AppTheme.infoBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),

              // Race Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Race Name
                    Text(
                      race.name,
                      style: AppTheme.heading3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTheme.spacingXs),

                    // Date
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: AppTheme.textLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateHelper.formatDate(race.raceDate),
                          style: AppTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingXs),

                    // Location
                    if (race.address.isNotEmpty)
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: AppTheme.textLight,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              race.address,
                              style: AppTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),

              // Countdown/Status Badge
              if (!isRecent)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.infoBlue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    DateHelper.getCountdownBadge(race.raceDate),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
