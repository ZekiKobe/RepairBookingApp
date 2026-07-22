import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../ui/themes/app_theme.dart';
import '../widgets/auth_hero_header.dart';
import 'register_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedRole;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.07), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _continue() {
    if (_selectedRole == null) return;
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, a, __) => RegisterScreen(selectedRole: _selectedRole!),
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          AuthHeroHeader(
            title: 'Who are you?',
            subtitle: 'Select your account type — you can change this later in your profile.',
            onBack: () => Navigator.pop(context),
            variant: AuthHeroVariant.neutral,
            icon: Icons.waving_hand_rounded,
          ),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer card
                      _RoleCard(
                        role: 'user',
                        title: 'Customer',
                        subtitle: 'I need repair services for my devices',
                        icon: Icons.phone_android_rounded,
                        accentColor: AppTheme.primaryColor,
                        features: const [
                          'Book repair services instantly',
                          'Track your repair status',
                          'Chat with technicians',
                        ],
                        isSelected: _selectedRole == 'user',
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _selectedRole = 'user');
                        },
                      ),

                      const SizedBox(height: 16),

                      // Technician card
                      _RoleCard(
                        role: 'technician',
                        title: 'Technician',
                        subtitle: 'I provide professional repair services',
                        icon: Icons.build_rounded,
                        accentColor: AppTheme.primaryDark,
                        features: const [
                          'Receive repair job requests',
                          'Manage your schedule',
                          'Grow your client base',
                        ],
                        isSelected: _selectedRole == 'technician',
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _selectedRole = 'technician');
                        },
                      ),

                      const Spacer(),

                      // Continue button
                      AnimatedOpacity(
                        opacity: _selectedRole != null ? 1.0 : 0.4,
                        duration: const Duration(milliseconds: 250),
                        child: GestureDetector(
                          onTap: _continue,
                          child: Container(
                            height: 54,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: AppTheme.primaryGradient,
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: _selectedRole != null ? [
                                BoxShadow(
                                  color: AppTheme.primaryColor.withOpacity(0.4),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ] : [],
                            ),
                            child: const Center(
                              child: Text('Continue',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3)),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Center(
                        child: Text(
                          'You can update this later in your profile',
                          style: TextStyle(color: AppTheme.textTertiary, fontSize: 12),
                        ),
                      ),

                      SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class _RoleCard extends StatelessWidget {
  final String role;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final List<String> features;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.features,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withOpacity(0.08)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? accentColor : AppTheme.hairline,
            width: isSelected ? 2 : 1.2,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: accentColor.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ] : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: isSelected ? accentColor : accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: isSelected ? Colors.white : accentColor, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 3),
                      Text(subtitle,
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
                // Checkbox
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 26, height: 26,
                  decoration: BoxDecoration(
                    color: isSelected ? accentColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? accentColor : AppTheme.textTertiary,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                      : null,
                ),
              ],
            ),

            // Features — only show when selected
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity, height: 0),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  children: [
                    Divider(color: accentColor.withOpacity(0.2), height: 1),
                    const SizedBox(height: 12),
                    ...features.map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_rounded, color: accentColor, size: 16),
                          const SizedBox(width: 10),
                          Text(f,
                              style: TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 13)),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
              crossFadeState: isSelected
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
      ),
    );
  }
}
