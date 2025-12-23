import 'package:flutter/material.dart';
import 'dart:async';
import '../config/theme.dart';

class BannerCarousel extends StatefulWidget {
  final bool showLoginPrompt;
  final VoidCallback? onLoginTap;

  const BannerCarousel({
    super.key,
    this.showLoginPrompt = false,
    this.onLoginTap,
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  // Banner data: quotes, images, and CTAs
  final List<BannerData> _banners = [
    BannerData(
      quoteMarathi: 'आमच्यासाठी एकच नाद आहे—\nबैलगाडा शर्यत!',
      quoteEnglish: 'There is only one passion —\nBullock Cart Racing',
      gradient: const LinearGradient(
        colors: [Color(0xFFFF6B35), Color(0xFFFF8C61)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.emoji_events,
    ),
    BannerData(
      quoteMarathi: 'वेग नाही, पण जिद्द आहे!',
      quoteEnglish: 'Not just speed,\nbut determination!',
      gradient: const LinearGradient(
        colors: [Color(0xFFF7B801), Color(0xFFFFD700)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.flash_on,
    ),
    BannerData(
      quoteMarathi: 'माती, बैल आणि स्पर्धा—\nहेच आमचे जीवन!',
      quoteEnglish: 'Soil, Bulls & Competition—\nThis is our life!',
      gradient: const LinearGradient(
        colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.grass,
    ),
    BannerData(
      quoteMarathi: 'परंपरा आणि पराक्रम!',
      quoteEnglish: 'Tradition & Valor!',
      gradient: const LinearGradient(
        colors: [Color(0xFF5E35B1), Color(0xFF9575CD)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.castle,
    ),
    BannerData(
      quoteMarathi: 'शेतकऱ्यांची शक्ती,\nबैलगाड्यांचा वेग!',
      quoteEnglish: "Farmer's strength,\nCart's speed!",
      gradient: const LinearGradient(
        colors: [Color(0xFFD32F2F), Color(0xFFEF5350)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.agriculture,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentPage < _banners.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Carousel - Increased height to prevent overflow
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              return _buildBannerCard(_banners[index]);
            },
          ),
        ),
        const SizedBox(height: 12),

        // Page indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
            (index) => _buildPageIndicator(index == _currentPage),
          ),
        ),

        // Login prompt (only for non-logged-in users)
        if (widget.showLoginPrompt) ...[
          const SizedBox(height: 20),
          _buildLoginPrompt(),
        ],
      ],
    );
  }

  Widget _buildBannerCard(BannerData banner) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: banner.gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative background pattern
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Content - Using Flexible layout to prevent overflow
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    banner.icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),

                // Marathi Quote - Flexible to prevent overflow
                Flexible(
                  child: Text(
                    banner.quoteMarathi,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                      letterSpacing: 0.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 6),

                // English Translation - Flexible to prevent overflow
                Flexible(
                  child: Text(
                    banner.quoteEnglish,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                      fontStyle: FontStyle.italic,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryOrange : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryOrange.withOpacity(0.1),
            Colors.orange.shade50,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryOrange.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryOrange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.lock_open,
              color: AppTheme.primaryOrange,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'अधिक पहा! / See More!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Login to explore races, champions & more',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: widget.onLoginTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Login',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BannerData {
  final String quoteMarathi;
  final String quoteEnglish;
  final Gradient gradient;
  final IconData icon;

  BannerData({
    required this.quoteMarathi,
    required this.quoteEnglish,
    required this.gradient,
    required this.icon,
  });
}
