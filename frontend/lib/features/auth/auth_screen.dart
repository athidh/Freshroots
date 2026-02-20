import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../dashboard/user_dashboard_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final _signUpUsernameController = TextEditingController();
  final _signUpEmailController = TextEditingController();
  final _signUpPasswordController = TextEditingController();
  final _signUpConfirmPasswordController = TextEditingController();

  final _loginUsernameController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _signUpUsernameController.dispose();
    _signUpEmailController.dispose();
    _signUpPasswordController.dispose();
    _signUpConfirmPasswordController.dispose();
    _loginUsernameController.dispose();
    _loginPasswordController.dispose();
    super.dispose();
  }

  void _handleAuth() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, a1, a2) => const UserDashboardScreen(),
        transitionsBuilder: (context, animation, a2, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Top gradient accent
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 280,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.forestGreen,
                    AppTheme.forestGreenLight.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -40,
                    top: -30,
                    child: Icon(
                      Icons.eco_rounded,
                      size: 200,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                  Positioned(
                    left: -20,
                    bottom: -10,
                    child: Icon(
                      Icons.route_rounded,
                      size: 120,
                      color: Colors.white.withValues(alpha: 0.04),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.route_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Fresh',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                  Text(
                                    'Route',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: AppTheme.sunsetOrangeLight,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                ],
                              ),
                              Text(
                                'Premium Logistics',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 12,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .moveX(begin: -20, end: 0),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Main card
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                      child: Column(
                        children: [
                          // Tab Bar
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.forestGreen
                                  .withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              onTap: (_) => setState(() {}),
                              indicator: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppTheme.forestGreen,
                                    AppTheme.forestGreenLight,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              indicatorSize: TabBarIndicatorSize.tab,
                              dividerColor: Colors.transparent,
                              labelColor: Colors.white,
                              unselectedLabelColor: AppTheme.textSecondary,
                              labelStyle: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                              tabs: const [
                                Tab(text: 'Sign Up'),
                                Tab(text: 'Login'),
                              ],
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 200.ms)
                              .scale(
                                begin: const Offset(0.96, 0.96),
                                end: const Offset(1, 1),
                              ),
                          const SizedBox(height: 24),

                          // Tab Content
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _buildSignUpForm(),
                                _buildLoginForm(),
                              ],
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
        ],
      ),
    );
  }

  Widget _buildSignUpForm() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildTextField(
            controller: _signUpUsernameController,
            label: 'Full Name',
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _signUpEmailController,
            label: 'Email Address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _signUpPasswordController,
            label: 'Password',
            icon: Icons.lock_outline_rounded,
            isPassword: true,
            obscure: _obscurePassword,
            onToggleObscure: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _signUpConfirmPasswordController,
            label: 'Confirm Password',
            icon: Icons.lock_outline_rounded,
            isPassword: true,
            obscure: _obscureConfirmPassword,
            onToggleObscure: () => setState(
              () => _obscureConfirmPassword = !_obscureConfirmPassword,
            ),
          ),
          const SizedBox(height: 28),
          _buildPrimaryButton('Create Account', Icons.arrow_forward_rounded),
          const SizedBox(height: 20),
          _buildDividerWithText('or continue with'),
          const SizedBox(height: 20),
          _buildSocialButtons(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account? ',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              GestureDetector(
                onTap: () => _tabController.animateTo(1),
                child: const Text(
                  'Login',
                  style: TextStyle(
                    color: AppTheme.forestGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).moveY(begin: 10, end: 0);
  }

  Widget _buildLoginForm() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(
            'Welcome back!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sign in to manage your deliveries',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 28),
          _buildTextField(
            controller: _loginUsernameController,
            label: 'Username or Email',
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _loginPasswordController,
            label: 'Password',
            icon: Icons.lock_outline_rounded,
            isPassword: true,
            obscure: _obscurePassword,
            onToggleObscure: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text(
                'Forgot Password?',
                style: TextStyle(
                  color: AppTheme.sunsetOrange,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildPrimaryButton('Login', Icons.login_rounded),
          const SizedBox(height: 20),
          _buildDividerWithText('or continue with'),
          const SizedBox(height: 20),
          _buildSocialButtons(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account? ",
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              GestureDetector(
                onTap: () => _tabController.animateTo(0),
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                    color: AppTheme.forestGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).moveY(begin: 10, end: 0);
  }

  Widget _buildPrimaryButton(String text, IconData icon) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.forestGreen.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _handleAuth,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Icon(icon, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDividerWithText(String text) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300)),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildSocialButton(Icons.g_mobiledata_rounded, 'Google'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSocialButton(Icons.apple_rounded, 'Apple'),
        ),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, String label) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 22),
      label: Text(label, style: const TextStyle(fontSize: 13)),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.textPrimary,
        minimumSize: const Size(0, 48),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggleObscure,
  }) {
    return _PremiumTextField(
      controller: controller,
      label: label,
      icon: icon,
      keyboardType: keyboardType,
      isPassword: isPassword,
      obscure: obscure,
      onToggleObscure: onToggleObscure,
    );
  }
}

class _PremiumTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final bool isPassword;
  final bool obscure;
  final VoidCallback? onToggleObscure;

  const _PremiumTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.obscure = false,
    this.onToggleObscure,
  });

  @override
  State<_PremiumTextField> createState() => _PremiumTextFieldState();
}

class _PremiumTextFieldState extends State<_PremiumTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: AppTheme.forestGreen.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        keyboardType: widget.keyboardType,
        obscureText: widget.isPassword ? widget.obscure : false,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          prefixIcon: Icon(
            widget.icon,
            color: _isFocused
                ? AppTheme.forestGreen
                : AppTheme.textSecondary,
            size: 20,
          ),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    widget.obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                  onPressed: widget.onToggleObscure,
                )
              : null,
          labelText: widget.label,
          floatingLabelStyle: const TextStyle(
            color: AppTheme.forestGreen,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
