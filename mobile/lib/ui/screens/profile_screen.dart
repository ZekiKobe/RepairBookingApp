import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../ui/themes/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bookings_provider.dart';
import 'edit_profile_screen.dart';
import 'settings_screens.dart';
import 'technician_registration_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final bookingsState = ref.watch(bookingsProvider);
    final totalBookings = bookingsState.bookings.length;
    final completedBookings = bookingsState.completed.length;
    final pendingBookings = bookingsState.pending.length;
    final fullName = user != null ? '${user.firstName} ${user.lastName}' : 'User';
    final initials = user != null
        ? '${user.firstName.isNotEmpty ? user.firstName[0] : ''}${user.lastName.isNotEmpty ? user.lastName[0] : ''}'
        : 'U';

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Profile Header - Horizontal Compact Design
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  border: Border.all(color: AppTheme.hairline, width: 1),
                  boxShadow: AppTheme.shadowMd,
                ),
                child: Column(
                  children: [
                    // Accent top strip
                    Container(
                      height: 4,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: AppTheme.primaryGradient),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Avatar — circular; tap opens edit profile to change photo
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute<void>(builder: (_) => const EditProfileScreen()),
                              ),
                              customBorder: const CircleBorder(),
                              child: Ink(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: AppTheme.primaryGradient),
                                  shape: BoxShape.circle,
                                  boxShadow: AppTheme.shadowMd,
                                ),
                                child: ClipOval(
                                  child: user?.avatar != null && user!.avatar!.trim().isNotEmpty
                                      ? Image.network(
                                          user.avatar!.trim(),
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Center(
                                            child: Text(
                                              initials,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Center(
                                          child: Text(
                                            initials,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Info column
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(fullName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                                    ),
                                    // Settings button inline
                                    GestureDetector(
                                      onTap: () => context.push('/settings'),
                                      child: Container(
                                        width: 36, height: 36,
                                        decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(10)),
                                        child: const Icon(Icons.settings_outlined, color: AppTheme.textSecondary, size: 18),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(user?.phone ?? '', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                                const SizedBox(height: 10),
                                // Role badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(colors: AppTheme.primaryGradient),
                                    borderRadius: BorderRadius.all(Radius.circular(20)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.verified, color: Colors.white, size: 14),
                                      const SizedBox(width: 6),
                                      Text(
                                        user?.role == 'technician' ? 'Technician' : user?.role == 'admin' ? 'Admin' : 'Customer',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Complete Profile Banner (technicians only, if profile missing)
            if (user?.role == 'technician')
              SliverToBoxAdapter(
                child: ref.watch(technicianProfileProvider).when(
                  data: (techProfile) {
                    if (techProfile != null) return const SizedBox.shrink();
                    return _buildCompleteProfileBanner(context);
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => _buildCompleteProfileBanner(context),
                ),
              ),

            // Stats Cards - Compact Horizontal
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.hairline, width: 1),
                  ),
                  child: Row(
                    children: [
                      _compactStat(value: '$totalBookings', label: 'Bookings', icon: Icons.calendar_today_outlined, color: AppTheme.primaryColor),
                      Container(width: 1, height: 40, color: AppTheme.hairline, margin: const EdgeInsets.symmetric(horizontal: 8)),
                      _compactStat(value: '$completedBookings', label: 'Completed', icon: Icons.check_circle_outlined, color: AppTheme.success),
                      Container(width: 1, height: 40, color: AppTheme.hairline, margin: const EdgeInsets.symmetric(horizontal: 8)),
                      _compactStat(value: '$pendingBookings', label: 'Pending', icon: Icons.schedule_outlined, color: AppTheme.primaryAccent),
                    ],
                  ),
                ),
              ),
            ),

            // Technician Professional Details
            if (user?.role == 'technician')
              SliverToBoxAdapter(
                child: ref.watch(technicianProfileProvider).when(
                  data: (tech) {
                    if (tech == null) return const SizedBox.shrink();
                    return _buildTechnicianDetails(context, tech);
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),

            // Menu Section Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppTheme.spacingLg, AppTheme.spacingLg, AppTheme.spacingLg, AppTheme.spacingMd),
                child: Text(
                  'Account Settings',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),

            // Menu Items — full width, no gaps, connected
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    subtitle: 'Update your personal information',
                    color: AppTheme.pastelBlue,
                    iconColor: AppTheme.primaryColor,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                  ),
                  _buildMenuItem(
                    icon: Icons.location_on_outlined,
                    title: 'My Addresses',
                    subtitle: 'Manage your saved locations',
                    color: AppTheme.pastelBlue,
                    iconColor: AppTheme.info,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyAddressesScreen())),
                  ),
                  _buildMenuItem(
                    icon: Icons.payment_outlined,
                    title: 'Payment Methods',
                    subtitle: 'Add or remove payment options',
                    color: AppTheme.pastelGreen,
                    iconColor: AppTheme.success,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodsScreen())),
                  ),
                  _buildMenuItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    subtitle: 'Booking updates and messages',
                    color: AppTheme.pastelYellow,
                    iconColor: AppTheme.warning,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                  ),
                  _buildMenuItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    subtitle: 'Get help or contact us',
                    color: AppTheme.pastelPurple,
                    iconColor: AppTheme.primaryAccent,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen())),
                  ),
                  _buildMenuItem(
                    icon: Icons.info_outline,
                    title: 'About',
                    subtitle: 'App version and legal information',
                    color: AppTheme.surfaceLight,
                    iconColor: AppTheme.textSecondary,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen())),
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacingLg)),

            // Logout Button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
                child: GestureDetector(
                  onTap: () async {
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
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(
                        color: AppTheme.error.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.logout,
                          color: AppTheme.error,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Logout',
                          style: TextStyle(
                            color: AppTheme.error,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacingLg)),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicianDetails(BuildContext context, tech) {
    final availability = tech.availability;
    final services = tech.services as List?;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Professional Details',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppTheme.spacingMd),

          // Status + approval
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: AppTheme.hairline, width: 1),
            ),
            child: Row(
              children: [
                _techDetailIcon(Icons.verified_user_outlined,
                    tech.isApproved ? AppTheme.success : AppTheme.warning,
                    tech.isApproved ? AppTheme.pastelGreen : AppTheme.pastelYellow),
                const SizedBox(width: AppTheme.spacingMd),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Account Status',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textTertiary)),
                    const SizedBox(height: 2),
                    Text(
                      tech.isApproved ? 'Approved' : 'Pending Review',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: tech.isApproved ? AppTheme.success : AppTheme.warning,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(
                    color: tech.isApproved ? AppTheme.success : AppTheme.warning,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingMd),

          // Bio
          if (tech.bio != null && tech.bio!.isNotEmpty)
            _techSection(
              icon: Icons.person_outline,
              title: 'About',
              child: Text(tech.bio!, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5)),
            ),

          // Experience
          if (tech.yearsOfExperience != null && tech.yearsOfExperience! > 0)
            _techSection(
              icon: Icons.work_history_outlined,
              title: 'Experience',
              child: Text('${tech.yearsOfExperience} year${tech.yearsOfExperience! > 1 ? 's' : ''} of experience',
                  style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
            ),

          // Services
          if (services != null && services.isNotEmpty)
            _techSection(
              icon: Icons.build_outlined,
              title: 'Services Offered',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: services.map<Widget>((s) {
                  final name = s.name ?? '';
                  final price = s.basePrice ?? 0;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3), width: 1),
                    ),
                    child: Text('$name  •  ETB ${price.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 12, color: AppTheme.primaryColor, fontWeight: FontWeight.w500)),
                  );
                }).toList(),
              ),
            ),

          // Availability
          if (availability != null && (availability is List ? availability.isNotEmpty : (availability as Map).isNotEmpty))
            _techSection(
              icon: Icons.calendar_month_outlined,
              title: 'Working Days',
              child: _buildAvailabilityChips(availability),
            ),

          // Documents
          if (tech.idDocument != null && tech.idDocument!.isNotEmpty ||
              tech.certificationDocument != null && tech.certificationDocument!.isNotEmpty)
            _techSection(
              icon: Icons.folder_outlined,
              title: 'Documents',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (tech.idDocument != null && tech.idDocument!.isNotEmpty)
                    _docRow(Icons.badge_outlined, 'National ID', true),
                  if (tech.certificationDocument != null && tech.certificationDocument!.isNotEmpty)
                    _docRow(Icons.workspace_premium_outlined, 'Certification', true),
                ],
              ),
            ),

          // Edit button
          const SizedBox(height: AppTheme.spacingSm),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TechnicianRegistrationScreen()),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.5), width: 1.5),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_outlined, color: AppTheme.primaryColor, size: 17),
                  SizedBox(width: 8),
                  Text('Update Professional Profile',
                      style: TextStyle(color: AppTheme.primaryColor, fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _techSection({required IconData icon, required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.hairline, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textTertiary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _techDetailIcon(IconData icon, Color iconColor, Color bgColor) {
    return Container(
      width: 42, height: 42,
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
      child: Icon(icon, color: iconColor, size: 20),
    );
  }

  Widget _buildAvailabilityChips(dynamic availability) {
    const dayShort = {'monday': 'Mon', 'tuesday': 'Tue', 'wednesday': 'Wed',
        'thursday': 'Thu', 'friday': 'Fri', 'saturday': 'Sat', 'sunday': 'Sun'};

    List<Map<String, dynamic>> entries = [];
    if (availability is List) {
      // Array format: [{day, slots:[{start,end}]}]
      for (final item in availability) {
        if (item is Map) {
          final day = item['day'] as String? ?? '';
          final slots = item['slots'] as List?;
          final start = slots?.isNotEmpty == true ? (slots!.first['start'] ?? '') : '';
          final end = slots?.isNotEmpty == true ? (slots!.first['end'] ?? '') : '';
          if (day.isNotEmpty) entries.add({'day': day, 'start': start, 'end': end});
        }
      }
    } else if (availability is Map) {
      // Legacy map format: {monday: {enabled, start, end}}
      for (final day in availability.keys) {
        if (availability[day]?['enabled'] == true) {
          entries.add({'day': day, 'start': availability[day]['start'] ?? '', 'end': availability[day]['end'] ?? ''});
        }
      }
    }

    if (entries.isEmpty) return const Text('No availability set', style: TextStyle(fontSize: 13, color: AppTheme.textTertiary));

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: entries.map((e) {
        final short = dayShort[e['day']] ?? e['day'];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppTheme.pastelPurple,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
          child: Text('$short  ${e['start']}–${e['end']}',
              style: const TextStyle(fontSize: 12, color: AppTheme.primaryLight, fontWeight: FontWeight.w500)),
        );
      }).toList(),
    );
  }

  Widget _docRow(IconData icon, String label, bool uploaded) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: uploaded ? AppTheme.success : AppTheme.textTertiary),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.success.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: const Text('Uploaded', style: TextStyle(fontSize: 11, color: AppTheme.success, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteProfileBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppTheme.spacingLg, 0, AppTheme.spacingLg, AppTheme.spacingLg),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2A2450), Color(0xFF1E2130)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: const Icon(Icons.assignment_ind_outlined,
                        color: AppTheme.primaryColor, size: 24),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profile Incomplete',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'You haven\'t submitted your professional profile yet',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingMd),
              const Divider(color: AppTheme.hairline),
              const SizedBox(height: AppTheme.spacingMd),

              // Checklist items
              _bannerCheckItem('Professional bio & experience'),
              _bannerCheckItem('Services you offer & pricing'),
              _bannerCheckItem('Working days & availability'),
              _bannerCheckItem('ID & certification documents'),

              const SizedBox(height: AppTheme.spacingLg),
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: AppTheme.primaryGradient),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const TechnicianRegistrationScreen(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit_outlined, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Complete My Profile',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600),
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
    );
  }

  Widget _bannerCheckItem(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 20, height: 20,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, color: AppTheme.primaryColor, size: 12),
          ),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
    required Color iconColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 22,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
      Material(
        color: AppTheme.surface,
        child: InkWell(
          onTap: onTap,
          child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppTheme.textTertiary,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      const Divider(height: 1, thickness: 1, color: AppTheme.hairline),
      ],
    );
  }

  Widget _compactStat({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary), textAlign: TextAlign.center),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary), overflow: TextOverflow.ellipsis, maxLines: 1, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
