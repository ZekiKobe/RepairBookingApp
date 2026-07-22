import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import '../../ui/themes/app_theme.dart';
<<<<<<< HEAD
import '../widgets/auth_hero_header.dart';
=======
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _authService = AuthService();

  // Steps: 0 = phone, 1 = OTP, 2 = new password
  int _step = 0;
  bool _isLoading = false;
  String? _error;

  // Step 0
  final _phoneCtrl = TextEditingController();
  final _phoneFKey = GlobalKey<FormState>();
  String? _devOtp; // shown in dev mode since no SMS

  // Step 1
  final List<TextEditingController> _otpCtrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFoci = List.generate(6, (_) => FocusNode());

  // Step 2
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _passFKey = GlobalKey<FormState>();
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    for (final c in _otpCtrls) c.dispose();
    for (final f in _otpFoci) f.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  String get _otpValue => _otpCtrls.map((c) => c.text).join();

  // ── Step 0: request OTP ────────────────────────────────────────────────────
  Future<void> _sendOtp() async {
    if (!(_phoneFKey.currentState?.validate() ?? false)) return;
    setState(() { _isLoading = true; _error = null; });

    final res = await _authService.forgotPassword(_phoneCtrl.text.trim());
    setState(() { _isLoading = false; });

    if (res.success) {
      setState(() {
        _devOtp = res.data; // backend returns OTP for dev/testing
        _step = 1;
      });
    } else {
      setState(() => _error = res.message);
    }
  }

  // ── Step 1: verify OTP ─────────────────────────────────────────────────────
  Future<void> _verifyOtp() async {
    if (_otpValue.length < 6) {
      setState(() => _error = 'Please enter the full 6-digit code');
      return;
    }
    setState(() { _isLoading = true; _error = null; });

    final res = await _authService.verifyOtp(_phoneCtrl.text.trim(), _otpValue);
    setState(() { _isLoading = false; });

    if (res.success) {
      setState(() => _step = 2);
    } else {
      setState(() => _error = res.message);
    }
  }

  // ── Step 2: reset password ─────────────────────────────────────────────────
  Future<void> _resetPassword() async {
    if (!(_passFKey.currentState?.validate() ?? false)) return;
    setState(() { _isLoading = true; _error = null; });

    final res = await _authService.resetPassword(
      _phoneCtrl.text.trim(), _otpValue, _newPassCtrl.text,
    );
    setState(() { _isLoading = false; });

    if (res.success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Password reset successfully! Please log in.'),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
      ));
      Navigator.pop(context);
    } else {
      setState(() => _error = res.message);
    }
  }

<<<<<<< HEAD
  IconData _heroIcon() {
    switch (_step) {
      case 0:
        return Icons.lock_reset_rounded;
      case 1:
        return Icons.sms_outlined;
      default:
        return Icons.lock_outline_rounded;
    }
  }

  Widget _buildProgressDots() {
    return Row(
      children: List.generate(3, (i) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(right: 6),
        width: _step == i ? 24 : 8,
        height: 8,
        decoration: BoxDecoration(
          color: _step >= i ? AppTheme.primaryColor : AppTheme.surfaceLighter,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        ),
      )),
    );
  }

  String _heroSubtitle() {
    const base = [
      'Enter your registered phone number to receive a verification code.',
      '',
      'Choose a strong password for your account.',
    ];
    if (_step == 1) {
      return 'Enter the 6-digit code sent to\n${_phoneCtrl.text.trim()}';
    }
    return base[_step];
=======
  // ── Shared header ──────────────────────────────────────────────────────────
  Widget _buildHeader() {
    final titles = ['Forgot Password', 'Enter OTP', 'New Password'];
    final subtitles = [
      'Enter your registered phone number to receive a verification code.',
      'Enter the 6-digit code sent to\n${_phoneCtrl.text.trim()}',
      'Choose a strong password for your account.',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress dots
        Row(
          children: List.generate(3, (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(right: 6),
            width: _step == i ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: _step >= i ? AppTheme.primaryColor : AppTheme.surfaceLighter,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
          )),
        ),
        const SizedBox(height: AppTheme.spacingLg),
        // Icon
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: AppTheme.primaryGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            boxShadow: [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Icon(_step == 0 ? Icons.lock_reset_outlined : _step == 1 ? Icons.sms_outlined : Icons.lock_outline_rounded,
              color: Colors.white, size: 28),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        Text(titles[_step], style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
        const SizedBox(height: 6),
        Text(subtitles[_step], style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5)),
      ],
    );
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
  }

  // ── Error banner ───────────────────────────────────────────────────────────
  Widget _buildError() {
    if (_error == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd, vertical: AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: AppTheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppTheme.error, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(_error!, style: const TextStyle(color: AppTheme.error, fontSize: 13))),
        ],
      ),
    );
  }

  // ── Step 0: phone field ────────────────────────────────────────────────────
  Widget _buildPhoneStep() {
    return Form(
      key: _phoneFKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: _inputDecoration('Phone Number', '09XXXXXXXX', Icons.phone_outlined),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Phone number is required';
              if (v.trim().length < 9) return 'Enter a valid phone number';
              return null;
            },
          ),
          const SizedBox(height: AppTheme.spacingXl),
          _buildPrimaryButton('Send OTP', _sendOtp),
        ],
      ),
    );
  }

  // ── Step 1: OTP boxes ──────────────────────────────────────────────────────
  Widget _buildOtpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dev hint
        if (_devOtp != null)
          Container(
            margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              color: AppTheme.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: AppTheme.info.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.developer_mode, color: AppTheme.info, size: 18),
                const SizedBox(width: 8),
                Text('Dev OTP: $_devOtp', style: const TextStyle(color: AppTheme.info, fontSize: 13, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        // 6 OTP boxes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (i) => SizedBox(
<<<<<<< HEAD
            width: 54,
            height: 62,
=======
            width: 46,
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
            child: TextFormField(
              controller: _otpCtrls[i],
              focusNode: _otpFoci[i],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
<<<<<<< HEAD
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
              decoration: InputDecoration(
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                filled: true,
                fillColor: AppTheme.surfaceLight,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd), borderSide: const BorderSide(color: AppTheme.hairline)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd), borderSide: const BorderSide(color: AppTheme.hairline)),
=======
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: AppTheme.surfaceLight,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd), borderSide: const BorderSide(color: Color(0xFF2C3044))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd), borderSide: const BorderSide(color: Color(0xFF2C3044))),
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (val) {
                if (val.isNotEmpty && i < 5) {
                  _otpFoci[i + 1].requestFocus();
                } else if (val.isEmpty && i > 0) {
                  _otpFoci[i - 1].requestFocus();
                }
                setState(() {});
              },
            ),
          )),
        ),
        const SizedBox(height: AppTheme.spacingXl),
        _buildPrimaryButton('Verify Code', _verifyOtp),
        const SizedBox(height: AppTheme.spacingMd),
        Center(
          child: TextButton(
            onPressed: _isLoading ? null : () {
              for (final c in _otpCtrls) c.clear();
              setState(() { _step = 0; _error = null; _devOtp = null; });
            },
            child: const Text('Resend OTP', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  // ── Step 2: new password ───────────────────────────────────────────────────
  Widget _buildNewPasswordStep() {
    return Form(
      key: _passFKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _newPassCtrl,
            obscureText: _obscureNew,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: _inputDecoration('New Password', 'At least 6 characters', Icons.lock_outline,
              suffix: IconButton(
                icon: Icon(_obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppTheme.textTertiary, size: 20),
                onPressed: () => setState(() => _obscureNew = !_obscureNew),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              if (v.length < 6) return 'At least 6 characters';
              return null;
            },
          ),
          const SizedBox(height: AppTheme.spacingMd),
          TextFormField(
            controller: _confirmPassCtrl,
            obscureText: _obscureConfirm,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: _inputDecoration('Confirm Password', 'Re-enter your password', Icons.lock_outline,
              suffix: IconButton(
                icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppTheme.textTertiary, size: 20),
                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please confirm your password';
              if (v != _newPassCtrl.text) return 'Passwords do not match';
              return null;
            },
          ),
          const SizedBox(height: AppTheme.spacingXl),
          _buildPrimaryButton('Reset Password', _resetPassword),
        ],
      ),
    );
  }

  // ── Shared input decoration ────────────────────────────────────────────────
  InputDecoration _inputDecoration(String label, String hint, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: AppTheme.textTertiary, fontSize: 14),
      hintStyle: const TextStyle(color: AppTheme.textTertiary, fontSize: 13),
      prefixIcon: Icon(icon, color: AppTheme.textTertiary, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppTheme.surfaceLight,
<<<<<<< HEAD
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd), borderSide: const BorderSide(color: AppTheme.hairline)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd), borderSide: const BorderSide(color: AppTheme.hairline)),
=======
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd), borderSide: const BorderSide(color: Color(0xFF2C3044))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd), borderSide: const BorderSide(color: Color(0xFF2C3044))),
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd), borderSide: const BorderSide(color: AppTheme.error)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd), borderSide: const BorderSide(color: AppTheme.error, width: 1.5)),
    );
  }

  // ── Primary button ─────────────────────────────────────────────────────────
  Widget _buildPrimaryButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: GestureDetector(
        onTap: _isLoading ? null : onPressed,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: AppTheme.primaryGradient, begin: Alignment.centerLeft, end: Alignment.centerRight),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            boxShadow: [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Center(
            child: _isLoading
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                : Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final steps = [_buildPhoneStep, _buildOtpStep, _buildNewPasswordStep];
<<<<<<< HEAD
    const titles = ['Forgot Password', 'Enter OTP', 'New Password'];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthHeroHeader(
            title: titles[_step],
            subtitle: _heroSubtitle(),
            onBack: () {
              if (_step > 0) {
                setState(() {
                  _step--;
                  _error = null;
                });
              } else {
                Navigator.pop(context);
              }
            },
            variant: AuthHeroVariant.neutral,
            icon: _heroIcon(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProgressDots(),
                  const SizedBox(height: AppTheme.spacingLg),
                  _buildError(),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: KeyedSubtree(
                      key: ValueKey(_step),
                      child: steps[_step](),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
=======

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Back button
              GestureDetector(
                onTap: () {
                  if (_step > 0) {
                    setState(() { _step--; _error = null; });
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusMd), boxShadow: AppTheme.shadowSm),
                  child: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary, size: 20),
                ),
              ),
              const SizedBox(height: 32),
              _buildHeader(),
              const SizedBox(height: AppTheme.spacingXl),
              _buildError(),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: KeyedSubtree(
                  key: ValueKey(_step),
                  child: steps[_step](),
                ),
              ),
            ],
          ),
        ),
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
      ),
    );
  }
}
