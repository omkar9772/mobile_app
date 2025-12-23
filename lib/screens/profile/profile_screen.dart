import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../auth/login_screen.dart';
import '../user_bulls/my_bulls_screen.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _handleLogout() async {
    final lang = context.read<LanguageProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang.getText('logout_confirm_title')),
        content: Text(lang.getText('logout_confirm_msg')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(lang.getText('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorRed,
            ),
            child: Text(lang.getText('logout')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (mounted) {
        await context.read<AuthProvider>().logout();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      }
    }
  }

  Future<void> _launchUrl(Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        final lang = context.read<LanguageProvider>();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(lang.getText('could_not_launch_app'))),
        );
      }
    }
  }

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'info@naadbailgada.com',
      query: 'subject=Support Request',
    );
    await _launchUrl(emailLaunchUri);
  }

  Future<void> _launchWhatsApp() async {
    // WhatsApp URL format: https://wa.me/<number>?text=<message>
    // Number must include country code without + (e.g., 919511784812)
    // User provided: 9511784812. Assuming India (+91).
    const number = '919511784812'; 
    const message = 'Hello, I would like to share details about Races/Bulls/Owners.';
    final Uri whatsappUrl = Uri.parse(
        'https://wa.me/$number?text=${Uri.encodeComponent(message)}');
    await _launchUrl(whatsappUrl);
  }

  Future<void> _launchYoutube() async {
    final Uri url = Uri.parse('https://www.youtube.com/@naad_bailgada_official');
    await _launchUrl(url);
  }

  Future<void> _launchInstagram() async {
    final Uri url = Uri.parse('https://www.instagram.com/naad_bailgada.official/');
    await _launchUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = authProvider.currentUser;

          if (user == null) {
            return const Center(child: Text("Not logged in"));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(user.username, user.fullName),
                const SizedBox(height: 16),
                _buildInfoSection(user.email, user.phone),
                const SizedBox(height: 24),
                _buildSettingsSection(context, user.username),
                const SizedBox(height: 24),
                _buildSupportSection(),
                const SizedBox(height: 24),
                _buildSocialSection(), // New section
                const SizedBox(height: 24),
                _buildLogoutButton(),
                const SizedBox(height: 32),
                _buildAppInfo(),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  // ... existing _buildHeader, _buildInfoSection, _buildMiniInfoChip

  Widget _buildSupportSection() {
    final lang = context.watch<LanguageProvider>();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 12),
            child: Text(
              lang.getText('support_contribution'),
              style: AppTheme.heading3,
            ),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.mail_outline,
            title: lang.getText('email_us'),
            subtitle: lang.getText('email_address'),
            onTap: _launchEmail,
          ),
          const Divider(height: 1, indent: 60, endIndent: 20),
          _buildSettingsTile(
            context,
            icon: Icons.message_outlined,
            title: lang.getText('share_via_whatsapp'),
            subtitle: lang.getText('submit_race_bull_details'),
            onTap: _launchWhatsApp,
          ),
        ],
      ),
    );
  }

  Widget _buildSocialSection() {
    final lang = context.watch<LanguageProvider>();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 12),
            child: Text(
              lang.getText('follow_us'),
              style: AppTheme.heading3,
            ),
          ),
          _buildSettingsTile(
            context,
            icon: FontAwesomeIcons.youtube,
            title: lang.getText('youtube'),
            subtitle: lang.getText('naad_bailgada_official'),
            onTap: _launchYoutube,
            iconColor: Colors.red,
          ),
          const Divider(height: 1, indent: 60, endIndent: 20),
          _buildSettingsTile(
            context,
            icon: FontAwesomeIcons.instagram,
            title: lang.getText('instagram'),
            subtitle: lang.getText('instagram_handle'),
            onTap: _launchInstagram,
            iconColor: Colors.purple,
          ),
        ],
      ),
    );
  }

  // Removed stray closing brace here

  Widget _buildHeader(String username, String? fullName) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Background Gradient
        Container(
          height: 180,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
        ),
        // Content
        Positioned(
          bottom: -50,
          child: Column(
            children: [
              // Avatar
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: const Icon(
                  Icons.person,
                  size: 60,
                  color: AppTheme.primaryOrange,
                ),
              ),
              const SizedBox(height: 12),
              // Name text is now below the avatar which is overlapping
              // We need to adjust layout. 
              // Actually, standard profile designs have name INSIDE the header or BELOW the overlap.
              // Let's put name below the overlap area in the main column, 
              // but for now, let's keep the avatar overlapping the bottom edge.
            ],
          ),
        ),
        // Username inside header (optional) or below.
        // Let's put a welcome text or similar in the header if needed.
        Positioned(
          top: 60,
          child: Consumer<LanguageProvider>(
            builder: (context, lang, _) => Text(
              lang.getText('profile'),
              style: AppTheme.heading2.copyWith(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(String? email, String? phone) {
    return Padding(
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24), // Space for overlapping avatar
      child: Column(
        children: [
          // User Name & Details
          Consumer<AuthProvider>(
            builder: (context, provider, _) {
              final user = provider.currentUser;
              return Column(
                children: [
                  Text(
                    user?.username ?? 'User',
                    style: AppTheme.heading2,
                  ),
                  if (user?.fullName != null && user!.fullName!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      user.fullName!,
                      style: AppTheme.bodyMedium.copyWith(color: AppTheme.textLight),
                    ),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          
          // Contact Info Helpers
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (email != null) 
                 _buildMiniInfoChip(Icons.email_outlined, email),
              if (email != null && phone != null)
                 const SizedBox(width: 12),
              if (phone != null)
                 _buildMiniInfoChip(Icons.phone_outlined, phone),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.textLight),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, String username) {
    final lang = context.watch<LanguageProvider>();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            context,
            icon: Icons.pets_outlined,
            title: lang.getText('my_bulls_for_sale'),
            subtitle: lang.getText('manage_listings'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyBullsScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1, indent: 60, endIndent: 20),
          _buildSettingsTile(
            context,
            icon: Icons.edit_outlined,
            title: lang.getText('edit_profile'),
            subtitle: lang.getText('update_details'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1, indent: 60, endIndent: 20),
          _buildSettingsTile(
            context,
            icon: Icons.lock_outline,
            title: lang.getText('change_password'),
            subtitle: lang.getText('update_security'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangePasswordScreen(
                    username: username,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (iconColor ?? AppTheme.primaryOrange).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor ?? AppTheme.primaryOrange, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTheme.heading3.copyWith(fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTheme.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textLight),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Consumer<LanguageProvider>(
      builder: (context, lang, _) => TextButton.icon(
        onPressed: _handleLogout,
        icon: const Icon(Icons.logout, size: 20),
        label: Text(
          lang.getText('log_out'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.errorRed,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildAppInfo() {
    return Consumer<LanguageProvider>(
      builder: (context, lang, _) => Column(
        children: [
          Image.asset(
            'assets/images/logo.png',
            width: 24,
            height: 24,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            lang.getText('app_version'),
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textLight.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }
}
