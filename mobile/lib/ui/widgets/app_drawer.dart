import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../themes/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notifications_provider.dart';
import '../../providers/messages_provider.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/notifications_screen.dart' as notif_screen;
import '../screens/settings_screens.dart';
import '../screens/technician_registration_screen.dart';

class AppDrawer extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onNavTap;

  const AppDrawer({
    super.key,
    required this.currentIndex,
    required this.onNavTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isTechnician = user?.role == 'technician';
    final unreadMessages = ref.watch(messagesProvider).unreadCount;
    final unreadNotifs = ref.watch(notificationsProvider).unreadCount;

    final fullName = user != null ? '${user.firstName} ${user.lastName}' : 'User';
    final initials = user != null
        ? '${user.firstName.isNotEmpty ? user.firstName[0] : ''}${user.lastName.isNotEmpty ? user.lastName[0] : ''}'
        : 'U';

    return Drawer(
      width: 280,
      backgroundColor: AppTheme.backgroundWhite,
      child: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.hairline)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Avatar
                      Container(
                        width: 58, height: 58,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: AppTheme.primaryGradient),
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
                        ),
                        child: user?.avatar != null
                            ? ClipOval(child: Image.network(user!.avatar!, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Center(child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)))))
                            : Center(child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))),
                      ),
                      const Spacer(),
                      // Close button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 34, height: 34,
                          decoration: BoxDecoration(color: AppTheme.surfaceLighter, borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.close_rounded, color: AppTheme.textSecondary, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  const SizedBox(height: 4),
                  Text(user?.phone ?? '', style: const TextStyle(fontSize: 13, color: AppTheme.textTertiary)),
                  const SizedBox(height: 10),
                  // Role badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: AppTheme.primaryGradient),
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified, color: Colors.white, size: 12),
                        const SizedBox(width: 5),
                        Text(
                          isTechnician ? 'Technician' : 'Customer',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Navigation items ───────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('Main'),
                    if (isTechnician) ...[
                      _navItem(context, index: 0, icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded, label: 'Dashboard', current: currentIndex, onTap: onNavTap),
                      _navItem(context, index: 1, icon: Icons.work_outline, activeIcon: Icons.work_rounded, label: 'My Jobs', current: currentIndex, onTap: onNavTap),
                    ] else ...[
                      _navItem(context, index: 0, icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home', current: currentIndex, onTap: onNavTap),
                      _navItem(context, index: 1, icon: Icons.calendar_today_outlined, activeIcon: Icons.calendar_today_rounded, label: 'Bookings', current: currentIndex, onTap: onNavTap),
                    ],
                    _navItem(context, index: 2, icon: Icons.chat_bubble_outline, activeIcon: Icons.chat_bubble_rounded, label: 'Messages', current: currentIndex, onTap: onNavTap, badge: unreadMessages),
                    _navItem(context, index: 3, icon: Icons.person_outline, activeIcon: Icons.person_rounded, label: 'Profile', current: currentIndex, onTap: onNavTap),

                    const SizedBox(height: 8),
                    _divider(),
                    _sectionLabel('Account'),

                    _actionItem(
                      context,
                      icon: Icons.edit_outlined,
                      label: 'Edit Profile',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                      },
                    ),
                    _actionItem(
                      context,
                      icon: Icons.notifications_outlined,
                      label: 'Notifications',
                      badge: unreadNotifs,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const notif_screen.NotificationsScreen()));
                      },
                    ),
                    if (isTechnician)
                      _actionItem(
                        context,
                        icon: Icons.assignment_ind_outlined,
                        label: 'Professional Profile',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const TechnicianRegistrationScreen()));
                        },
                      ),

                    const SizedBox(height: 8),
                    _divider(),
                    _sectionLabel('More'),

                    _actionItem(
                      context,
                      icon: Icons.location_on_outlined,
                      label: 'My Addresses',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const MyAddressesScreen()));
                      },
                    ),
                    _actionItem(
                      context,
                      icon: Icons.payment_outlined,
                      label: 'Payment Methods',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodsScreen()));
                      },
                    ),
                    _actionItem(
                      context,
                      icon: Icons.help_outline,
                      label: 'Help & Support',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen()));
                      },
                    ),
                    _actionItem(
                      context,
                      icon: Icons.info_outline,
                      label: 'About',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()));
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ── Logout ─────────────────────────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppTheme.hairline)),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    Navigator.pop(context);
                    final confirmed = await showConfirmModal(
                      context,
                      title: 'Logout',
                      message: 'Are you sure you want to log out?',
                      confirmLabel: 'Logout',
                      icon: Icons.logout_rounded,
                      iconColor: AppTheme.error,
                    );
                    if (!confirmed) return;
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                  borderRadius: BorderRadius.circular(0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    child: Row(
                      children: [
                        Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(color: AppTheme.error.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.logout_rounded, color: AppTheme.error, size: 20),
                        ),
                        const SizedBox(width: 14),
                        const Text('Logout', style: TextStyle(color: AppTheme.error, fontSize: 15, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 1.2),
      ),
    );
  }

  Widget _divider() {
    return const Divider(color: AppTheme.hairline, height: 16, indent: 20, endIndent: 20);
  }

  Widget _navItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int current,
    required ValueChanged<int> onTap,
    int badge = 0,
  }) {
    final selected = current == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          onTap(index);
        },
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(colors: AppTheme.primaryGradient, begin: Alignment.centerLeft, end: Alignment.centerRight)
                : null,
            color: selected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(selected ? activeIcon : icon, color: selected ? Colors.white : AppTheme.textSecondary, size: 20),
                  if (badge > 0) _badgeWidget(badge),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 14, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: selected ? Colors.white : AppTheme.textSecondary),
                ),
              ),
              if (selected)
                Container(
                  width: 6, height: 6,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), shape: BoxShape.circle),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    int badge = 0,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, color: AppTheme.textSecondary, size: 20),
                  if (badge > 0) _badgeWidget(badge),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textSecondary)),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badgeWidget(int count) {
    return Positioned(
      right: -6, top: -6,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
        constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
        child: Text(
          count > 99 ? '99+' : '$count',
          style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
