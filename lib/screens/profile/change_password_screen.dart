import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/language_provider.dart';
import '../../services/auth_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String username;

  const ChangePasswordScreen({super.key, required this.username});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _error;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      final lang = context.read<LanguageProvider>();
      setState(() {
        _error = lang.getText('passwords_not_match');
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _authService.changePassword(
        username: widget.username,
        oldPassword: _oldPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (mounted) {
        final lang = context.read<LanguageProvider>();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lang.getText('password_changed')),
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
        title: Text(lang.getText('change_password')),
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
                Icons.lock_outline,
                size: 64,
                color: AppTheme.primaryOrange,
              ),
              const SizedBox(height: AppTheme.spacingLg),
              Text(
                lang.getText('change_your_password'),
                textAlign: TextAlign.center,
                style: AppTheme.heading2,
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Text(
                lang.getText('enter_current_new_password'),
                textAlign: TextAlign.center,
                style: AppTheme.bodyMedium,
              ),
              const SizedBox(height: AppTheme.spacingXl),

              // Current Password
              TextFormField(
                controller: _oldPasswordController,
                decoration: InputDecoration(
                  labelText: lang.getText('current_password'),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureOld ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() => _obscureOld = !_obscureOld),
                  ),
                ),
                obscureText: _obscureOld,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return lang.getText('enter_current_password');
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.spacingMd),

              // New Password
              TextFormField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: lang.getText('new_password'),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNew ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
                obscureText: _obscureNew,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return lang.getText('enter_new_password');
                  }
                  if (value.length < 6) {
                    return lang.getText('password_min_6');
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.spacingMd),

              // Confirm New Password
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: lang.getText('confirm_new_password'),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                obscureText: _obscureConfirm,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return lang.getText('confirm_password');
                  }
                  return null;
                },
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
                onPressed: _isLoading ? null : _handleChangePassword,
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
                    : Text(lang.getText('change_password')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
