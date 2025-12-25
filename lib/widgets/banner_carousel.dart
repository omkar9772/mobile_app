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

  // Banner data: quotes, images, and CTAs - Enhanced with powerful new slogans
  final List<BannerData> _banners = [
    BannerData(
      quoteMarathi: 'नाद एकच… बैलगाडा!',
      gradient: const LinearGradient(
        colors: [Color(0xFFFF6B35), Color(0xFFFF8C61)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.campaign,
    ),
    BannerData(
      quoteMarathi: 'ही शर्यत नाही,\nही परंपरा आहे',
      gradient: const LinearGradient(
        colors: [Color(0xFF5E35B1), Color(0xFF9575CD)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.account_balance,
    ),
    BannerData(
      quoteMarathi: 'बैलगाडा शर्यतीचा नाद,\nआता तुमच्या मोबाईलमध्ये',
      gradient: const LinearGradient(
        colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.smartphone,
    ),
    BannerData(
      quoteMarathi: 'बैल नाही,\nतो आमचा अभिमान आहे',
      gradient: const LinearGradient(
        colors: [Color(0xFFD32F2F), Color(0xFFEF5350)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.emoji_events,
    ),
    BannerData(
      quoteMarathi: 'मातीचा सुगंध,\nबैलांचा वेग!',
      gradient: const LinearGradient(
        colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.flash_on,
    ),
    BannerData(
      quoteMarathi: 'गाव ते ग्लोबल –\nNaad Bailgada',
      gradient: const LinearGradient(
        colors: [Color(0xFFF57C00), Color(0xFFFFB74D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.public,
    ),
    BannerData(
      quoteMarathi: 'जिथे ताकद, शौर्य आणि\nनाद एकत्र येतो',
      gradient: const LinearGradient(
        colors: [Color(0xFF7B1FA2), Color(0xFFBA68C8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.shield,
    ),
    BannerData(
      quoteMarathi: 'बैलगाडा म्हणजे केवळ वेग नाही,\nतो आहे वारसा',
      gradient: const LinearGradient(
        colors: [Color(0xFFC2185B), Color(0xFFF06292)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.auto_awesome,
    ),
    BannerData(
      quoteMarathi: 'मातीशी नातं,\nबैलाशी नाद',
      gradient: const LinearGradient(
        colors: [Color(0xFF6D4C41), Color(0xFFA1887F)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.nature_people,
    ),
    BannerData(
      quoteMarathi: 'बैलाची ताकद,\nशेतकऱ्याची ओळख',
      gradient: const LinearGradient(
        colors: [Color(0xFF00796B), Color(0xFF4DB6AC)],
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
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.3,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 3,
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
                  'शर्यत पहा, वेळ मोजा, नाद जपा',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Login करा आणि संपूर्ण अनुभव घ्या',
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
  final Gradient gradient;
  final IconData icon;

  BannerData({
    required this.quoteMarathi,
    required this.gradient,
    required this.icon,
  });
}
