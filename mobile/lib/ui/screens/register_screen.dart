import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../ui/themes/app_theme.dart';
import '../widgets/auth_hero_header.dart';
import '../../providers/auth_provider.dart';
import 'home_screen.dart';
import 'technician_registration_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final String selectedRole;

  const RegisterScreen({super.key, required this.selectedRole});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _loadingAction; // 'register' | 'google'
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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _isTechnician => widget.selectedRole == 'technician';

  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _loadingAction = 'register');
      final success = await ref.read(authProvider.notifier).register(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        role: widget.selectedRole,
      );
      if (mounted) setState(() => _loadingAction = null);
      if (success && mounted) {
        if (_isTechnician) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const TechnicianRegistrationScreen()),
            (route) => false,
          );
        } else {
          Navigator.of(context).pushAndRemoveUntil(
            PageRouteBuilder(
              pageBuilder: (_, a, __) => const HomeScreen(),
              transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
              transitionDuration: const Duration(milliseconds: 400),
            ),
            (route) => false,
          );
        }
      }
    }
  }

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

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          AuthHeroHeader(
            title: 'Create Account',
            subtitle: 'Fill in the details to get started',
            onBack: () => Navigator.pop(context),
            variant: _isTechnician
                ? AuthHeroVariant.technician
                : AuthHeroVariant.customer,
            customIconRow: AuthHeroRegisterIconRow(isTechnician: _isTechnician),
          ),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).padding.bottom + 48),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name row
                        Row(
                          children: [
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('First Name'),
                                const SizedBox(height: 8),
                                _inputField(
                                  controller: _firstNameController,
                                  hint: 'John',
                                  icon: Icons.person_outline_rounded,
                                  validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                                ),
                              ],
                            )),
                            const SizedBox(width: 12),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('Last Name'),
                                const SizedBox(height: 8),
                                _inputField(
                                  controller: _lastNameController,
                                  hint: 'Doe',
                                  icon: Icons.person_outline_rounded,
                                  validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                                ),
                              ],
                            )),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Phone
                        _label('Phone Number'),
                        const SizedBox(height: 8),
                        _inputField(
                          controller: _phoneController,
                          hint: '0911234467',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),

                        // Password
                        _label('Password'),
                        const SizedBox(height: 8),
                        _inputField(
                          controller: _passwordController,
                          hint: 'Create a strong password',
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
                        const SizedBox(height: 16),

                        // Confirm password
                        _label('Confirm Password'),
                        const SizedBox(height: 8),
                        _inputField(
                          controller: _confirmPasswordController,
                          hint: 'Re-enter your password',
                          icon: Icons.lock_outline_rounded,
                          obscure: _obscureConfirm,
                          suffix: IconButton(
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                            icon: Icon(
                              _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppTheme.textTertiary, size: 20,
                            ),
                          ),
                          validator: (v) {
                            if (v != _passwordController.text) return 'Passwords do not match';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Create Account button
                        _primaryButton(
                          label: 'Create Account',
                          isLoading: _loadingAction == 'register',
                          disabled: _loadingAction != null,
                          onTap: _register,
                        ),
                        const SizedBox(height: 20),

                        // Divider
                        Row(
                          children: [
                            const Expanded(child: Divider(color: AppTheme.hairline)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              child: Text('or', style: TextStyle(color: AppTheme.textTertiary, fontSize: 12)),
                            ),
                            const Expanded(child: Divider(color: AppTheme.hairline)),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Google button
                        _googleButton(_loadingAction == 'google', _loadingAction != null),
                        const SizedBox(height: 24),

                        // Sign in link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Already have an account? ',
                                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                            GestureDetector(
                              onTap: () {
                                final nav = Navigator.of(context);
                                if (nav.canPop()) {
                                  nav.popUntil((route) => route.isFirst);
                                } else {
                                  context.go('/login');
                                }
                              },
                              child: const Text('Sign In',
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
      ),
    );
  }

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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
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
                  style: const TextStyle(color: Colors.white, fontSize: 16,
                      fontWeight: FontWeight.w700, letterSpacing: 0.3)),
        ),
      ),
    );
  }

  Widget _googleButton(bool isLoading, bool disabled) {
    return GestureDetector(
      onTap: (isLoading || disabled) ? null : () async {
        setState(() => _loadingAction = 'google');
        final success = await ref.read(authProvider.notifier).loginWithGoogle(role: widget.selectedRole);
        if (mounted) setState(() => _loadingAction = null);
        if (!mounted) return;
        if (success) {
          if (_isTechnician) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const TechnicianRegistrationScreen()),
              (route) => false,
            );
          } else {
            Navigator.of(context).pushAndRemoveUntil(
              PageRouteBuilder(
                pageBuilder: (_, a, __) => const HomeScreen(),
                transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
                transitionDuration: const Duration(milliseconds: 400),
              ),
              (route) => false,
            );
          }
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
    );
  }
}
