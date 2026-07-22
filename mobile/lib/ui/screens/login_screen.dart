import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
<<<<<<< HEAD
import 'package:go_router/go_router.dart';
import 'package:repair_booking/l10n/app_localizations.dart';

import '../../ui/themes/app_theme.dart';
import '../widgets/auth_hero_header.dart';
import '../../providers/auth_provider.dart';
=======
import '../../ui/themes/app_theme.dart';
import '../../providers/auth_provider.dart';
import 'home_screen.dart';
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
import 'role_selection_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

<<<<<<< HEAD
class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
=======
class _LoginScreenState extends ConsumerState<LoginScreen> {
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
<<<<<<< HEAD
  String? _loadingAction; // 'phone' | 'google'
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
=======

  @override
  void dispose() {
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
<<<<<<< HEAD
      setState(() => _loadingAction = 'phone');
=======
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
      final success = await ref.read(authProvider.notifier).login(
        _phoneController.text.trim(),
        _passwordController.text,
      );
<<<<<<< HEAD
      if (mounted) setState(() => _loadingAction = null);
      if (success && mounted) {
        context.go('/home');
=======
      
      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
      }
    }
  }

<<<<<<< HEAD
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    if (authState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(authState.error!)),
          ]),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
          margin: const EdgeInsets.all(16),
        ));
        ref.read(authProvider.notifier).clearError();
      });
    }

    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // ── Gradient hero header ────────────────────────────────────────
          AuthHeroHeader(
            title: l10n.loginTitle,
            subtitle: l10n.loginSubtitle,
            onBack: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/onboarding');
              }
            },
            variant: AuthHeroVariant.customer,
            icon: Icons.handyman_rounded,
          ),

          // ── Form card ──────────────────────────────────────────────────
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Phone
                        _label('Phone Number'),
                        const SizedBox(height: 8),
                        _inputField(
                          controller: _phoneController,
                          hint: '0911345678',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                        ),
                        const SizedBox(height: 18),

                        // Password
                        _label('Password'),
                        const SizedBox(height: 8),
                        _inputField(
                          controller: _passwordController,
                          hint: 'Enter your password',
                          icon: Icons.lock_outline_rounded,
                          obscure: _obscurePassword,
                          suffix: IconButton(
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppTheme.textTertiary, size: 20,
                            ),
                          ),
                          validator: (v) {
                            if (v?.isEmpty ?? true) return 'Required';
                            if (v!.length < 6) return 'At least 6 characters';
                            return null;
                          },
                        ),

                        // Forgot password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 4)),
                            child: const Text('Forgot Password?',
                                style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600, fontSize: 13)),
                          ),
                        ),

                        const SizedBox(height: 8),

                        Semantics(
                          button: true,
                          label: l10n.semanticsLoginButton,
                          child: _primaryButton(
                            label: 'Sign In',
                            isLoading: _loadingAction == 'phone',
                            disabled: _loadingAction != null,
                            onTap: _login,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Divider
                        _divider('or continue with'),

                        const SizedBox(height: 20),

                        // Google
                        _googleButton(_loadingAction == 'google', _loadingAction != null, l10n),

                        const SizedBox(height: 28),

                        // Register link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account? ",
                                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                            GestureDetector(
                              onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const RoleSelectionScreen())),
                              child: const Text('Sign Up',
                                  style: TextStyle(color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.w700, fontSize: 14)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
=======
  void _goToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                
                // Back button - left aligned
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppTheme.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Welcome text - centered
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSm),
                Text(
                  'Sign in to continue',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                
                const SizedBox(height: 50),
                
                // Phone field
                SizedBox(
                  width: double.infinity,
                  child: _buildTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    hint: '09XXXXXXXX',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                ),
                
                const SizedBox(height: AppTheme.spacingLg),
                
                // Password field
                SizedBox(
                  width: double.infinity,
                  child: _buildTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'Enter your password',
                    icon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppTheme.textTertiary,
                        size: 20,
                      ),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter your password';
                      }
                      if (value!.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                ),
                
                const SizedBox(height: AppTheme.spacingSm),
                
                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: AppTheme.spacingLg),
                
                // Login button
                SizedBox(
                  width: double.infinity,
                  child: Consumer(
                    builder: (context, ref, child) {
                      final authState = ref.watch(authProvider);
                      
                      if (authState.error != null) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(authState.error!),
                              backgroundColor: AppTheme.error,
                            ),
                          );
                          ref.read(authProvider.notifier).clearError();
                        });
                      }
                      
                      return SoftGradientButton(
                        text: 'Sign In',
                        onPressed: _login,
                        isLoading: authState.isLoading,
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: AppTheme.spacingXl),
                
                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: AppTheme.textMuted)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
                      child: Text(
                        'or continue with',
                        style: TextStyle(
                          color: AppTheme.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: AppTheme.textMuted)),
                  ],
                ),
                
                const SizedBox(height: AppTheme.spacingXl),
                
                // Social login buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton(Icons.g_mobiledata, 'Google'),
                    const SizedBox(width: AppTheme.spacingMd),
                    _buildSocialButton(Icons.apple, 'Apple'),
                  ],
                ),
                
                const SizedBox(height: AppTheme.spacing2xl),
                
                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: _goToRegister,
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppTheme.spacingXl),
              ],
            ),
          ),
        ),
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
      ),
    );
  }

<<<<<<< HEAD
  Widget _label(String text) => Text(text,
      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600));

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textTertiary, fontSize: 14),
        prefixIcon: Icon(icon, color: AppTheme.textTertiary, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: AppTheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.error, width: 1.8),
        ),
      ),
      validator: validator,
    );
  }

  Widget _primaryButton({required String label, required bool isLoading, bool disabled = false, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: (isLoading || disabled) ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54,
        decoration: BoxDecoration(
          gradient: isLoading
              ? LinearGradient(colors: [AppTheme.textMuted, AppTheme.textMuted])
              : const LinearGradient(
                  colors: AppTheme.primaryGradient,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: isLoading ? [] : [
            BoxShadow(color: AppTheme.primaryColor.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6)),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(width: 22, height: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
              : Text(label,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700,
                      letterSpacing: 0.3)),
        ),
      ),
    );
  }

  Widget _divider(String text) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppTheme.hairline)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(text, style: const TextStyle(color: AppTheme.textTertiary, fontSize: 12)),
        ),
        const Expanded(child: Divider(color: AppTheme.hairline)),
=======
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 15,
            ),
            prefixIcon: Icon(
              icon,
              color: AppTheme.textTertiary,
              size: 20,
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppTheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              borderSide: const BorderSide(color: Color(0xFF2C3044), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              borderSide: const BorderSide(color: Color(0xFF2C3044), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              borderSide: BorderSide(color: AppTheme.primaryColor, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd,
              vertical: AppTheme.spacingMd,
            ),
          ),
          validator: validator,
        ),
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
      ],
    );
  }

<<<<<<< HEAD
  Widget _googleButton(bool isLoading, bool disabled, AppLocalizations l10n) {
    return Semantics(
      button: true,
      label: l10n.semanticsGoogleSignIn,
      child: GestureDetector(
      onTap: (isLoading || disabled) ? null : () async {
        setState(() => _loadingAction = 'google');
        final success = await ref.read(authProvider.notifier).loginWithGoogle();
        if (mounted) setState(() => _loadingAction = null);
        if (success && mounted) {
          context.go('/home');
        }
      },
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.hairline, width: 1.2),
        ),
        child: isLoading
            ? const Center(child: SizedBox(width: 22, height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5)))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Image.network(
                        'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.g_mobiledata, size: 18, color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Continue with Google',
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                ],
              ),
      ),
    ),
=======
  Widget _buildSocialButton(IconData icon, String label) {
    return Container(
      width: 80,
      height: 56,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: const Color(0xFF2C3044)),
      ),
      child: Icon(
        icon,
        size: 28,
        color: AppTheme.textPrimary,
      ),
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
    );
  }
}
