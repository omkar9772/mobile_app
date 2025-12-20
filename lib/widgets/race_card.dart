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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          highlightColor: AppTheme.primaryOrange.withOpacity(0.05),
          splashColor: AppTheme.primaryOrange.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Container
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isRecent
                          ? [
                              AppTheme.successGreen.withOpacity(0.15),
                              AppTheme.successGreen.withOpacity(0.05)
                            ]
                          : [
                              AppTheme.primaryOrange.withOpacity(0.15),
                              AppTheme.primaryOrange.withOpacity(0.05)
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isRecent
                          ? AppTheme.successGreen.withOpacity(0.2)
                          : AppTheme.primaryOrange.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    isRecent ? Icons.emoji_events_outlined : Icons.calendar_month_outlined,
                    color: isRecent ? AppTheme.successGreen : AppTheme.primaryOrange,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        race.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // Metadata Rows
                      Row(
                        children: [
                          Icon(Icons.calendar_today, 
                              size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${DateHelper.formatDate(race.startDate)} - ${DateHelper.formatDate(race.endDate)}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (race.address.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, 
                                size: 14, color: Colors.grey.shade500),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                race.address,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
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

                // Status/Countdown Badge
                if (!isRecent)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryOrange.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      DateHelper.getCountdownBadge(race.startDate),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                   // Subtle checkbox for completed
                   Container(
                     margin: const EdgeInsets.only(left: 8),
                     padding: const EdgeInsets.all(6),
                     decoration: BoxDecoration(
                       shape: BoxShape.circle,
                       color: AppTheme.successGreen.withOpacity(0.1),
                     ),
                     child: const Icon(
                       Icons.check_circle,
                       color: AppTheme.successGreen,
                       size: 18,
                     ),
                   )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
