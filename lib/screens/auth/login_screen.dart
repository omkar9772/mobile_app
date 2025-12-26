import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui'; // For ImageFilter
import '../../config/theme.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../home/main_screen.dart';

class LoginScreen extends StatefulWidget {
  final int? redirectTabIndex;
  final Widget? redirectToScreen;

  const LoginScreen({
    super.key,
    this.redirectTabIndex,
    this.redirectToScreen,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  // Animation Controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Login form
  final _loginFormKey = GlobalKey<FormState>();
  final _loginUsernameController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  String? _loginError;

  // Register form
  final _registerFormKey = GlobalKey<FormState>();
  final _registerFullNameController = TextEditingController();
  final _registerUsernameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPhoneController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  String? _registerError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Animation Init
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _loginUsernameController.dispose();
    _loginPasswordController.dispose();
    _registerFullNameController.dispose();
    _registerUsernameController.dispose();
    _registerEmailController.dispose();
    _registerPhoneController.dispose();
    _registerPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;

    setState(() {
      _loginError = null;
    });

    try {
      await context.read<AuthProvider>().login(
        _loginUsernameController.text.trim(),
        _loginPasswordController.text,
      );

      if (mounted) {
        // If there's a specific screen to redirect to, go there
        if (widget.redirectToScreen != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => widget.redirectToScreen!),
          );
        } else {
          // Otherwise go to MainScreen with the specified tab index
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => MainScreen(initialTabIndex: widget.redirectTabIndex),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loginError = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  Future<void> _handleRegister() async {
    if (!_registerFormKey.currentState!.validate()) return;

    setState(() {
      _registerError = null;
    });

    try {
      await context.read<AuthProvider>().register(RegisterRequest(
        fullName: _registerFullNameController.text.trim(),
        username: _registerUsernameController.text.trim(),
        email: _registerEmailController.text.trim(),
        phone: _registerPhoneController.text.trim().isEmpty
            ? null
            : _registerPhoneController.text.trim(),
        password: _registerPasswordController.text,
      ));

      if (mounted) {
        // If there's a specific screen to redirect to, go there
        if (widget.redirectToScreen != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => widget.redirectToScreen!),
          );
        } else {
          // Otherwise go to MainScreen with the specified tab index
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => MainScreen(initialTabIndex: widget.redirectTabIndex),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _registerError = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with Gradient and Blur
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFFF9F43), Color(0xFFFFC043)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Subtly patterned or overlaid background if needed
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo Section
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Consumer<LanguageProvider>(
                          builder: (context, lang, _) => Column(
                            children: [
                              Text(
                                lang.getText('app_title'),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                lang.getText('app_subtitle'),
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        
                        // Auth Card
                        ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 450),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.95), // Slight transparency for glass feel
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 25,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Custom Toggle Tab Bar
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      height: 55,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: TabBar(
                                        controller: _tabController,
                                        indicator: BoxDecoration(
                                          color: AppTheme.primaryOrange,
                                          borderRadius: BorderRadius.circular(22),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppTheme.primaryOrange.withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        labelColor: Colors.white,
                                        unselectedLabelColor: Colors.grey.shade600,
                                        labelStyle: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                        indicatorSize: TabBarIndicatorSize.tab,
                                        dividerColor: Colors.transparent,
                                        padding: const EdgeInsets.all(5),
                                        tabs: [
                                          Tab(text: context.watch<LanguageProvider>().getText('login')),
                                          Tab(text: context.watch<LanguageProvider>().getText('register')),
                                        ],
                                      ),
                                    ),
                                  ),
                                  
                                  // Tab Views
                                  AnimatedSize(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    child: SizedBox(
                                      height: 480, // Fixed height or adjust dynamic logic if needed
                                      child: Consumer<AuthProvider>(
                                        builder: (context, authProvider, _) {
                                          return TabBarView(
                                            controller: _tabController,
                                            children: [
                                              _buildLoginForm(authProvider.isLoading),
                                              _buildRegisterForm(authProvider.isLoading),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(bool isLoading) {
    final lang = context.watch<LanguageProvider>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _loginFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            _buildTextField(
              controller: _loginUsernameController,
              label: lang.getText('username'),
              icon: Icons.person_outline,
              validator: (v) => v?.isEmpty == true ? lang.getText('required') : null,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _loginPasswordController,
              label: lang.getText('password'),
              icon: Icons.lock_outline,
              isPassword: true,
              validator: (v) => v?.isEmpty == true ? lang.getText('required') : null,
            ),

            if (_loginError != null) ...[
              const SizedBox(height: 20),
              _buildErrorBanner(_loginError!),
            ],

            const SizedBox(height: 32),
            _buildPrimaryButton(
              text: lang.getText('login'),
              onPressed: _handleLogin,
              isLoading: isLoading,
            ),

            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () {
                   // Implement forgot password if needed
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(
                       content: Text('Please contact info@naadbailgada.com to reset your password'),
                       duration: Duration(seconds: 4),
                     ),
                   );
                },
                child: Text(lang.getText('forgot_password'), style: TextStyle(color: Colors.grey.shade600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterForm(bool isLoading) {
    final lang = context.watch<LanguageProvider>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _registerFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(
              controller: _registerFullNameController,
              label: lang.getText('full_name'),
              icon: Icons.badge_outlined,
              validator: (v) => v?.isEmpty == true ? lang.getText('required') : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _registerUsernameController,
              label: lang.getText('username'),
              icon: Icons.account_circle_outlined,
              validator: (v) => (v?.length ?? 0) < 3 ? lang.getText('min_3_chars') : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _registerEmailController,
              label: lang.getText('email'),
              icon: Icons.email_outlined,
              inputType: TextInputType.emailAddress,
              validator: (v) => !(v?.contains('@') ?? false) ? lang.getText('invalid_email') : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _registerPhoneController,
              label: lang.getText('phone_optional'),
              icon: Icons.phone_outlined,
              inputType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _registerPasswordController,
              label: lang.getText('password'),
              icon: Icons.lock_outline,
              isPassword: true,
              validator: (v) => (v?.length ?? 0) < 6 ? lang.getText('min_6_chars') : null,
            ),

            if (_registerError != null) ...[
              const SizedBox(height: 20),
              _buildErrorBanner(_registerError!),
            ],

            const SizedBox(height: 32),
            _buildPrimaryButton(
              text: lang.getText('create_account'),
              onPressed: _handleRegister,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? inputType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: inputType,
      style: const TextStyle(fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryOrange.withOpacity(0.7)),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.primaryOrange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback onPressed,
    required bool isLoading,
  }) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryOrange.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryOrange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0, // Handled by container
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  Widget _buildErrorBanner(String error) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: TextStyle(color: Colors.red.shade700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
