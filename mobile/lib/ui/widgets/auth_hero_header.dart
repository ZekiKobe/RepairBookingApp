import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../themes/app_theme.dart';

enum AuthHeroVariant {
  /// Primary brand gradient (customer auth)
  customer,

  /// Deeper slate gradient (technician auth)
  technician,

  /// Mid-tone slate (role picker, etc.)
  neutral,
}

/// Shared hero for login / register / role selection — wave shape, glass chips, editorial type.
class AuthHeroHeader extends StatelessWidget {
  const AuthHeroHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onBack,
    this.variant = AuthHeroVariant.customer,
    this.icon,
    this.customIconRow,
  }) : assert(
          icon != null || customIconRow != null,
          'Provide icon or customIconRow',
        );

  final String title;
  final String subtitle;
  final VoidCallback onBack;
  final AuthHeroVariant variant;
  final IconData? icon;
  final Widget? customIconRow;

  List<Color> get _gradient {
    switch (variant) {
      case AuthHeroVariant.technician:
        return const [
          Color(0xFF0A2433),
          Color(0xFF153A52),
          Color(0xFF1E4D6B),
        ];
      case AuthHeroVariant.neutral:
        return const [
          Color(0xFF153A52),
          Color(0xFF1E4D6B),
          Color(0xFF3D7BA8),
        ];
      case AuthHeroVariant.customer:
        return const [
          Color(0xFF0F3550),
          Color(0xFF1E4D6B),
          Color(0xFF2A6A8F),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return ClipPath(
      clipper: _AuthHeroWaveClipper(),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -60,
              right: -40,
              child: _glowBlob(160, Colors.white.withValues(alpha: 0.07)),
            ),
            Positioned(
              bottom: 20,
              left: -50,
              child: _glowBlob(120, Colors.white.withValues(alpha: 0.06)),
            ),
            Positioned(
              top: 80,
              right: 30,
              child: _glowBlob(70, Colors.white.withValues(alpha: 0.05)),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24, top + 16, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _GlassIconButton(
                    onTap: onBack,
                    icon: Icons.arrow_back_rounded,
                  ),
                  const SizedBox(height: 22),
                  if (customIconRow != null)
                    customIconRow!
                  else
                    _HeroIconBadge(icon: icon!),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    style: GoogleFonts.fraunces(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      height: 1.12,
                      letterSpacing: -0.6,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: GoogleFonts.dmSans(
                      fontSize: 14.5,
                      height: 1.45,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glowBlob(double size, Color color) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}

class _HeroIconBadge extends StatelessWidget {
  const _HeroIconBadge({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            color: Colors.white.withValues(alpha: 0.18),
            alignment: Alignment.center,
            child: Icon(icon, color: Colors.white, size: 32),
          ),
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.onTap,
    required this.icon,
  });

  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.28),
                  width: 1,
                ),
                color: Colors.white.withValues(alpha: 0.14),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
          ),
        ),
      ),
    );
  }
}

/// Register: icon + role pill in one row.
class AuthHeroRegisterIconRow extends StatelessWidget {
  const AuthHeroRegisterIconRow({
    super.key,
    required this.isTechnician,
  });

  final bool isTechnician;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(19),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                color: Colors.white.withValues(alpha: 0.18),
                alignment: Alignment.center,
                child: Icon(
                  isTechnician
                      ? Icons.engineering_rounded
                      : Icons.person_add_alt_1_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.32),
            ),
            color: Colors.white.withValues(alpha: 0.12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isTechnician ? Icons.build_rounded : Icons.person_rounded,
                color: Colors.white,
                size: 15,
              ),
              const SizedBox(width: 8),
              Text(
                isTechnician ? 'Technician' : 'Customer',
                style: GoogleFonts.dmSans(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AuthHeroWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 32);
    path.quadraticBezierTo(
      size.width * 0.22,
      size.height + 8,
      size.width * 0.5,
      size.height - 18,
    );
    path.quadraticBezierTo(
      size.width * 0.78,
      size.height - 44,
      size.width,
      size.height - 26,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
