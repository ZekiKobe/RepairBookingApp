import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ui/themes/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bookings_provider.dart';
import '../../models/booking_model.dart';
import '../../providers/notifications_provider.dart';
import 'notifications_screen.dart';
<<<<<<< HEAD
import '../widgets/drawer_opener.dart';
=======
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739

class TechnicianHomeScreen extends ConsumerStatefulWidget {
  const TechnicianHomeScreen({super.key});

  @override
  ConsumerState<TechnicianHomeScreen> createState() => _TechnicianHomeScreenState();
}

class _TechnicianHomeScreenState extends ConsumerState<TechnicianHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(bookingsProvider.notifier).loadBookings(isTechnician: true);
      ref.read(notificationsProvider.notifier).loadUnreadCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final bookingsState = ref.watch(bookingsProvider);
    final pending = bookingsState.pending;
    final active = bookingsState.active;
    final completed = bookingsState.completed;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async =>
              ref.read(bookingsProvider.notifier).loadBookings(isTechnician: true),
          child: CustomScrollView(
            slivers: [
<<<<<<< HEAD
              // Sticky top bar
              SliverAppBar(
                pinned: true,
                floating: false,
                backgroundColor: AppTheme.background,
                surfaceTintColor: Colors.transparent,
                shadowColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                toolbarHeight: 60,
                flexibleSpace: FlexibleSpaceBar(
                  background: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
                      child: Row(
                        children: [
                          // Hamburger
                          GestureDetector(
                            onTap: () => DrawerOpener.open(context),
                            child: Container(
                              width: 42, height: 42,
                              decoration: BoxDecoration(
                                color: AppTheme.surface,
                                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                boxShadow: AppTheme.shadowSm,
                                border: Border.all(color: AppTheme.hairline),
                              ),
                              child: const Icon(Icons.menu_rounded, color: AppTheme.textPrimary, size: 20),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Hello, ${user?.firstName ?? 'Technician'}!',
                                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                                Text(user?.fullName ?? 'Dashboard',
                                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                          // Online badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4ADE80).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                              border: Border.all(color: const Color(0xFF4ADE80).withOpacity(0.4)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.circle, color: Color(0xFF4ADE80), size: 7),
                                SizedBox(width: 5),
                                Text('Online', style: TextStyle(color: Color(0xFF4ADE80), fontSize: 11, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildBellButton(context),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Stats card
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(AppTheme.spacingLg, AppTheme.spacingSm, AppTheme.spacingLg, AppTheme.spacingLg),
=======
              // Header
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(AppTheme.spacingLg),
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
                  padding: const EdgeInsets.all(AppTheme.spacingLg),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppTheme.primaryGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                    boxShadow: AppTheme.shadowMd,
                  ),
<<<<<<< HEAD
                  child: Row(
                    children: [
                      _statChip('${pending.length}', 'New Requests', Icons.notification_important_outlined),
                      const SizedBox(width: AppTheme.spacingMd),
                      _statChip('${active.length}', 'Active Jobs', Icons.construction_outlined),
                      const SizedBox(width: AppTheme.spacingMd),
                      _statChip('${completed.length}', 'Completed', Icons.check_circle_outline),
=======
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 52, height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                _initials(user?.fullName ?? ''),
                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacingMd),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Hello, ${user?.firstName ?? 'Technician'}!',
                                    style: const TextStyle(color: Colors.white70, fontSize: 14)),
                                Text(user?.fullName ?? '', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(AppTheme.radiusFull)),
                                child: Row(
                                  children: const [
                                    Icon(Icons.circle, color: Color(0xFF4ADE80), size: 8),
                                    SizedBox(width: 6),
                                    Text('Online', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildBellButton(context),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingLg),
                      // Stats row
                      Row(
                        children: [
                          _statChip('${pending.length}', 'New Requests', Icons.notification_important_outlined),
                          const SizedBox(width: AppTheme.spacingMd),
                          _statChip('${active.length}', 'Active Jobs', Icons.construction_outlined),
                          const SizedBox(width: AppTheme.spacingMd),
                          _statChip('${completed.length}', 'Completed', Icons.check_circle_outline),
                        ],
                      ),
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
                    ],
                  ),
                ),
              ),

              // New Requests Section
              if (pending.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
                    child: Row(
                      children: [
                        Container(width: 4, height: 20, decoration: BoxDecoration(color: AppTheme.primaryAccent, borderRadius: BorderRadius.circular(2))),
                        const SizedBox(width: 8),
                        Text('New Requests', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppTheme.primaryAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(AppTheme.radiusFull)),
                          child: Text('${pending.length}', style: TextStyle(color: AppTheme.primaryAccent, fontWeight: FontWeight.w700, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacingMd)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _buildJobCard(context, ref, pending[i], isNew: true),
                      childCount: pending.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacingLg)),
              ],

              // Active Jobs
              if (active.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
                    child: Row(
                      children: [
                        Container(width: 4, height: 20, decoration: BoxDecoration(color: AppTheme.info, borderRadius: BorderRadius.circular(2))),
                        const SizedBox(width: 8),
                        Text('Active Jobs', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacingMd)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _buildJobCard(context, ref, active[i], isNew: false),
                      childCount: active.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacingLg)),
              ],

              // Empty state
              if (pending.isEmpty && active.isEmpty && !bookingsState.isLoading)
                const SliverToBoxAdapter(child: _HomeDashboardEmptyState()),

              if (bookingsState.isLoading)
                const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))),

<<<<<<< HEAD
              const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacingLg)),
=======
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
            ],
          ),
        ),
      ),
    );
  }

  Widget _statChip(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildJobCard(BuildContext context, WidgetRef ref, BookingModel booking, {required bool isNew}) {
    final serviceName = booking.service?.name ?? 'Repair Service';
    final customerName = booking.user?.fullName ?? 'Customer';
    final dateStr = '${booking.scheduledDate.day}/${booking.scheduledDate.month}/${booking.scheduledDate.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusLg), boxShadow: AppTheme.shadowSm),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: isNew ? AppTheme.accentGradient : AppTheme.primaryGradient),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: Icon(isNew ? Icons.notifications_active : Icons.construction, color: Colors.white, size: 24),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(serviceName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                      const SizedBox(height: 2),
                      Row(children: [
                        Icon(Icons.person_outline, size: 14, color: AppTheme.textTertiary),
                        const SizedBox(width: 4),
                        Text(customerName, style: const TextStyle(fontSize: 13, color: AppTheme.textTertiary)),
                      ]),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
                  child: Text('${booking.price.toStringAsFixed(0)} ETB', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 14, color: AppTheme.textTertiary),
                const SizedBox(width: 4),
                Text(dateStr, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                const SizedBox(width: 12),
                Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textTertiary),
                const SizedBox(width: 4),
                Expanded(child: Text(booking.address, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            ),
            if (isNew) ...[
              const SizedBox(height: AppTheme.spacingMd),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final confirmed = await showConfirmModal(
                          context,
                          title: 'Decline Job',
                          message: 'Are you sure you want to decline this job request?',
                          confirmLabel: 'Decline',
                          icon: Icons.cancel_outlined,
                          iconColor: AppTheme.error,
                        );
                        if (!confirmed || !context.mounted) return;
                        final ok = await ref.read(bookingsProvider.notifier).cancelBooking(booking.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(ok ? 'Job declined' : 'Failed to decline'),
                            backgroundColor: ok ? AppTheme.error : Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ));
                        }
                      },
                      style: OutlinedButton.styleFrom(foregroundColor: AppTheme.error, side: BorderSide(color: AppTheme.error.withOpacity(0.5))),
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(gradient: const LinearGradient(colors: AppTheme.primaryGradient), borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                      child: TextButton(
                        onPressed: () async {
                          final ok = await ref.read(bookingsProvider.notifier).acceptBooking(booking.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(ok ? 'Job accepted!' : 'Failed to accept'),
                              backgroundColor: ok ? AppTheme.success : AppTheme.error,
                              behavior: SnackBarBehavior.floating,
                            ));
                          }
                        },
                        child: const Text('Accept', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: AppTheme.spacingMd),
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(gradient: const LinearGradient(colors: AppTheme.accentGradient), borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                  child: TextButton(
                    onPressed: () async {
                      final nextStatus = booking.status == 'accepted' ? 'in_progress' : 'completed';
                      final label = booking.status == 'accepted' ? 'Start Job' : 'Mark Complete';
                      final ok = await ref.read(bookingsProvider.notifier).updateBookingStatus(booking.id, nextStatus);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(ok ? '$label done!' : 'Failed'),
                          backgroundColor: ok ? AppTheme.success : AppTheme.error,
                          behavior: SnackBarBehavior.floating,
                        ));
                      }
                    },
                    child: Text(
                      booking.status == 'accepted' ? 'Start Job' : 'Mark as Complete',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    return name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join('').toUpperCase();
  }

  Widget _buildBellButton(BuildContext context) {
    final unread = ref.watch(notificationsProvider).unreadCount;
    return GestureDetector(
      onTap: () {
        ref.read(notificationsProvider.notifier).load();
        Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
<<<<<<< HEAD
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              boxShadow: AppTheme.shadowSm,
              border: Border.all(color: AppTheme.hairline),
            ),
            child: const Icon(Icons.notifications_outlined, color: AppTheme.textPrimary, size: 20),
=======
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 20),
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
          ),
          if (unread > 0)
            Positioned(
              right: -3, top: -3,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                child: Text(
                  unread > 99 ? '99+' : unread.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

}

// ── Rich empty state for dashboard ──────────────────────────────────────────

class _HomeDashboardEmptyState extends StatefulWidget {
  const _HomeDashboardEmptyState();

  @override
  State<_HomeDashboardEmptyState> createState() =>
      _HomeDashboardEmptyStateState();
}

class _HomeDashboardEmptyStateState extends State<_HomeDashboardEmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.09).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppTheme.spacingLg, AppTheme.spacingXl,
          AppTheme.spacingLg, AppTheme.spacingMd),
      child: Column(
        children: [
          // ── Animated icon ────────────────────────────────────────────
          ScaleTransition(
            scale: _scale,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryColor.withOpacity(0.06),
                  ),
                ),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryColor.withOpacity(0.11),
                  ),
                ),
                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppTheme.primaryGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.4),
                        blurRadius: 22,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.work_outline_rounded,
                      size: 36, color: Colors.white),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingLg),

          // ── Headline ─────────────────────────────────────────────────
          const Text(
            'No pending jobs',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          const Text(
            'New booking requests will appear here.\nStay online so customers can reach you!',
            style: TextStyle(fontSize: 14, color: AppTheme.textTertiary),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppTheme.spacingXl),

          // ── Tip cards ────────────────────────────────────────────────
          _DashTipCard(
            icon: Icons.wifi_tethering_rounded,
            color: AppTheme.primaryColor,
            title: 'Stay Online',
            body: 'Keep your status online so customers can find and book you instantly.',
          ),
          _DashTipCard(
            icon: Icons.star_outline_rounded,
            color: AppTheme.warning,
            title: 'Boost Your Profile',
            body: 'A complete profile and strong ratings attract more booking requests.',
          ),
          _DashTipCard(
            icon: Icons.notifications_active_outlined,
            color: AppTheme.info,
            title: 'Enable Notifications',
            body: 'Turn on push alerts so you never miss a new job request.',
          ),

          const SizedBox(height: AppTheme.spacingXl),

          // ── Pull-to-refresh hint ──────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.arrow_downward_rounded,
                  size: 13, color: AppTheme.textTertiary),
              SizedBox(width: 6),
              Text('Pull down to refresh',
                  style:
                      TextStyle(fontSize: 12, color: AppTheme.textTertiary)),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
        ],
      ),
    );
  }
}

class _DashTipCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String body;

  const _DashTipCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: color.withOpacity(0.14), width: 1),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 3),
                Text(body,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textTertiary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
