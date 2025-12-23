import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;

  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _usernameController = TextEditingController(text: user?.username ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _fullNameController = TextEditingController(text: user?.fullName ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final request = UpdateUserRequest(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        fullName: _fullNameController.text.trim().isEmpty
            ? null
            : _fullNameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
      );

      await context.read<AuthProvider>().updateProfile(request);

      if (mounted) {
        final lang = context.read<LanguageProvider>();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lang.getText('profile_updated')),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.getText('edit_profile')),
        backgroundColor: AppTheme.primaryOrange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.person_outline,
                size: 64,
                color: AppTheme.primaryOrange,
              ),
              const SizedBox(height: AppTheme.spacingLg),
              Text(
                lang.getText('update_your_profile'),
                textAlign: TextAlign.center,
                style: AppTheme.heading2,
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Text(
                lang.getText('edit_personal_info'),
                textAlign: TextAlign.center,
                style: AppTheme.bodyMedium,
              ),
              const SizedBox(height: AppTheme.spacingXl),

              // Username
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: lang.getText('username'),
                  prefixIcon: const Icon(Icons.person),
                  helperText: lang.getText('must_be_unique'),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return lang.getText('enter_username');
                  }
                  if (value.trim().length < 3) {
                    return lang.getText('username_min_3');
                  }
                  if (value.trim().length > 50) {
                    return lang.getText('username_max_50');
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.spacingMd),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: lang.getText('email'),
                  prefixIcon: const Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return lang.getText('enter_email');
                  }
                  if (!value.contains('@')) {
                    return lang.getText('valid_email');
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.spacingMd),

              // Full Name
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: lang.getText('full_name_optional'),
                  prefixIcon: const Icon(Icons.badge),
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),

              // Phone
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: lang.getText('phone_optional'),
                  prefixIcon: const Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),

              // Error Message
              if (_error != null) ...[
                const SizedBox(height: AppTheme.spacingMd),
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  decoration: BoxDecoration(
                    color: AppTheme.errorRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: AppTheme.errorRed),
                  ),
                ),
              ],

              const SizedBox(height: AppTheme.spacingXl),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleUpdateProfile,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(lang.getText('update_profile')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
