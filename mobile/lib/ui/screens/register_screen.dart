import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
<<<<<<< HEAD
import 'package:go_router/go_router.dart';
import '../../ui/themes/app_theme.dart';
import '../widgets/auth_hero_header.dart';
=======
import '../../ui/themes/app_theme.dart';
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
import '../../providers/auth_provider.dart';
import 'home_screen.dart';
import 'technician_registration_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final String selectedRole;
<<<<<<< HEAD

=======
  
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
  const RegisterScreen({super.key, required this.selectedRole});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

<<<<<<< HEAD
class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
=======
class _RegisterScreenState extends ConsumerState<RegisterScreen> {
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
<<<<<<< HEAD
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
=======
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

<<<<<<< HEAD
  bool get _isTechnician => widget.selectedRole == 'technician';

  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _loadingAction = 'register');
=======
  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
      final success = await ref.read(authProvider.notifier).register(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        role: widget.selectedRole,
      );
<<<<<<< HEAD
      if (mounted) setState(() => _loadingAction = null);
      if (success && mounted) {
        if (_isTechnician) {
=======
      
      if (success && mounted) {
        if (widget.selectedRole == 'technician') {
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const TechnicianRegistrationScreen()),
            (route) => false,
          );
        } else {
          Navigator.of(context).pushAndRemoveUntil(
<<<<<<< HEAD
            PageRouteBuilder(
              pageBuilder: (_, a, __) => const HomeScreen(),
              transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
              transitionDuration: const Duration(milliseconds: 400),
            ),
=======
            MaterialPageRoute(builder: (_) => const HomeScreen()),
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
            (route) => false,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
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
=======
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
                const SizedBox(height: 40),
                
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
                
                const SizedBox(height: 30),
                
                // Welcome text - centered
                Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSm),
                Text(
                  widget.selectedRole == 'technician' 
                    ? 'Register as a Technician'
                    : 'Register as a Customer',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Name fields - full width
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _firstNameController,
                          label: 'First Name',
                          hint: 'John',
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingMd),
                      Expanded(
                        child: _buildTextField(
                          controller: _lastNameController,
                          label: 'Last Name',
                          hint: 'Doe',
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppTheme.spacingLg),
                
                // Phone field - full width
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
                
                // Password field - full width
                SizedBox(
                  width: double.infinity,
                  child: _buildTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'Create password',
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
                        return 'Please enter a password';
                      }
                      if (value!.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                ),
                
                const SizedBox(height: AppTheme.spacingLg),
                
                // Confirm password field - full width
                SizedBox(
                  width: double.infinity,
                  child: _buildTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    hint: 'Confirm password',
                    icon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ),
                
                const SizedBox(height: AppTheme.spacing2xl),
                
                // Register button with error handling
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
                  text: 'Create Account',
                  onPressed: _register,
                  isLoading: authState.isLoading,
                );
              },
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingLg),
          
          // Login link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Already have an account? ",
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text(
                  'Sign In',
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
),
);
  }

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
      ],
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
    );
  }
}
