import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../config/theme.dart';
import '../../../models/race.dart';
import '../../../utils/date_helper.dart';

class RaceResultPoster extends StatelessWidget {
  final RaceResult result;
  final Race race;
  final RaceDay day;

  const RaceResultPoster({
    super.key,
    required this.result,
    required this.race,
    required this.day,
  });

  @override
  Widget build(BuildContext context) {
    // Validate and get safe values
    final safeDayNumber = day.dayNumber;
    final safeRaceDate = day.raceDate;
    final safeRaceName = race.name.isNotEmpty ? race.name : 'Race';
    final safeRaceAddress = race.address.isNotEmpty ? race.address : 'Location TBA';

    return Container(
      width: 450,
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const textLogo(),
               Column(
                 crossAxisAlignment: CrossAxisAlignment.end,
                 children: [
                   Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Day $safeDayNumber · ${DateHelper.formatDate(safeRaceDate)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    safeRaceName,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      const SizedBox(width: 3),
                      SizedBox(
                        width: 170,
                        child: Text(
                          safeRaceAddress,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                 ],
               ),
            ],
          ),
          const SizedBox(height: 24),

          // Main Result Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Position Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.emoji_events,
                      size: 28,
                      color: _getMedalColor(result.position),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'POSITION ${result.position}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Timer
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        result.getFormattedTime(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                const Divider(thickness: 1),
                const SizedBox(height: 20),

                // Bulls
                // Bulls
                Builder(
                  builder: (context) {
                    final hasSecondBull = result.bull2Name != 'Unknown' || result.bull2PhotoUrl != null || result.owner2Name != null;
                    
                    if (!hasSecondBull) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 340,
                            child: _buildBullItem(result.bull1Name, result.bull1PhotoUrl),
                          ),
                        ],
                      );
                    }

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: _buildBullItem(result.bull1Name, result.bull1PhotoUrl),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Icon(
                            Icons.bolt_rounded,
                            size: 72,
                            color: AppTheme.primaryOrange.withOpacity(0.8),
                          ),
                        ),
                        Expanded(
                          child: _buildBullItem(result.bull2Name, result.bull2PhotoUrl),
                        ),
                      ],
                    );
                  }
                ),

                const SizedBox(height: 20),

                // Owner
                Container(
                  padding: const EdgeInsets.all(10),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '|| बैलगाडा मालक ||',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryOrange.withOpacity(0.8),
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${result.owner1Name}${result.owner2Name != null ? ' & ${result.owner2Name}' : ''}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Footer
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'To check full results download',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Naad Bailgada App',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBullItem(String name, String? photoUrl) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 8,
              ),
            ],
          ),
          child: ClipOval(
            child: (photoUrl != null && photoUrl.isNotEmpty)
                ? CachedNetworkImage(
                    imageUrl: photoUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _placeholderImage(),
                    errorWidget: (_, __, ___) => _placeholderImage(),
                  )
                : _placeholderImage(),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          name == 'Unknown' ? '' : name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: AppTheme.textDark,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 3),
        const Text(
          'Champion',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textLight,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _placeholderImage() {
    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.all(16),
      child: Opacity(
        opacity: 0.9,
        child: SvgPicture.asset(
          'assets/images/logo.svg',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Color _getMedalColor(int position) {
      if (position == 1) return const Color(0xFFFFD700);
      if (position == 2) return const Color(0xFFC0C0C0);
      if (position == 3) return const Color(0xFFCD7F32);
      return AppTheme.primaryOrange;
  }
}

class textLogo extends StatelessWidget {
  const textLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'नाद एकच...',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          'बैलगाडा !',
          style: TextStyle(
            fontSize: 23,
            color: Colors.white,
            fontWeight: FontWeight.w900,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}
