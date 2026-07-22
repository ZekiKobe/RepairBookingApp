import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ui/themes/app_theme.dart';
import '../../providers/bookings_provider.dart';
import '../../models/booking_model.dart';

class TechnicianBookingsScreen extends ConsumerStatefulWidget {
  const TechnicianBookingsScreen({super.key});

  @override
  ConsumerState<TechnicianBookingsScreen> createState() => _TechnicianBookingsScreenState();
}

class _TechnicianBookingsScreenState extends ConsumerState<TechnicianBookingsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        ref.read(bookingsProvider.notifier).loadBookings(isTechnician: true));
  }

  @override
  Widget build(BuildContext context) {
    final bookingsState = ref.watch(bookingsProvider);
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingLg),
                  child: Row(
                    children: [
                      Text('My Jobs', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => ref.read(bookingsProvider.notifier).loadBookings(isTechnician: true),
                        child: Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusMd), boxShadow: AppTheme.shadowSm),
                          child: const Icon(Icons.refresh, color: AppTheme.textPrimary, size: 22),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
                  child: Container(
                    decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(AppTheme.radiusLg)),
                    padding: const EdgeInsets.all(4),
                    child: TabBar(
                      isScrollable: false,
                      indicator: BoxDecoration(
                        gradient: const LinearGradient(colors: AppTheme.primaryGradient),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        boxShadow: [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorPadding: EdgeInsets.zero,
                      labelColor: Colors.white,
                      unselectedLabelColor: AppTheme.textSecondary,
                      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      dividerColor: Colors.transparent,
                      splashFactory: NoSplash.splashFactory,
                      overlayColor: MaterialStateProperty.all(Colors.transparent),
                      tabs: const [
                        Tab(text: 'Pending'),
                        Tab(text: 'Active'),
                        Tab(text: 'Completed'),
                        Tab(text: 'Cancelled'),
                      ],
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacingMd)),
            ],
            body: bookingsState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    children: [
                      _TechJobList(bookings: bookingsState.pending, type: 'pending'),
                      _TechJobList(bookings: bookingsState.active, type: 'active'),
                      _TechJobList(bookings: bookingsState.completed, type: 'completed'),
                      _TechJobList(bookings: bookingsState.cancelled, type: 'cancelled'),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _TechJobList extends ConsumerWidget {
  final List<BookingModel> bookings;
  final String type;

  const _TechJobList({required this.bookings, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (bookings.isEmpty) {
      return _EmptyJobState(type: type);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      itemCount: bookings.length,
      itemBuilder: (context, i) => _TechJobCard(booking: bookings[i], type: type),
    );
  }
}

class _EmptyJobState extends StatefulWidget {
  final String type;
  const _EmptyJobState({required this.type});

  @override
  State<_EmptyJobState> createState() => _EmptyJobStateState();
}

class _EmptyJobStateState extends State<_EmptyJobState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.08).animate(
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
    final cfg = _config[widget.type] ?? _config['pending']!;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingLg, vertical: AppTheme.spacingXl),
      child: Column(
        children: [
          const SizedBox(height: AppTheme.spacingLg),

          // ── Animated icon ──────────────────────────────────────────────
          ScaleTransition(
            scale: _scale,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // outer glow ring
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (cfg['color'] as Color).withOpacity(0.08),
                  ),
                ),
                // inner ring
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (cfg['color'] as Color).withOpacity(0.14),
                  ),
                ),
                // icon container
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: cfg['gradient'] as List<Color>,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusLg),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (cfg['color'] as Color).withOpacity(0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(cfg['icon'] as IconData,
                      size: 34, color: Colors.white),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingLg),

          // ── Headline ───────────────────────────────────────────────────
          Text(
            cfg['title'] as String,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            cfg['subtitle'] as String,
            style: const TextStyle(
                fontSize: 14, color: AppTheme.textTertiary),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppTheme.spacingXl),

          // ── Tip cards ──────────────────────────────────────────────────
          ...(cfg['tips'] as List<_Tip>).map((tip) => _TipCard(tip: tip)),

          const SizedBox(height: AppTheme.spacingXl),

          // ── Pull-to-refresh hint ───────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_downward_rounded,
                  size: 14, color: AppTheme.textTertiary),
              const SizedBox(width: 6),
              const Text(
                'Pull down to refresh',
                style:
                    TextStyle(fontSize: 12, color: AppTheme.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
        ],
      ),
    );
  }

  static final Map<String, Map<String, Object>> _config = {
    'pending': {
      'icon': Icons.inbox_outlined,
      'color': AppTheme.primaryColor,
      'gradient': AppTheme.primaryGradient,
      'title': 'No pending requests',
      'subtitle': 'You\'re all caught up!\nNew booking requests will show up here.',
      'tips': [
        _Tip(Icons.wifi_tethering, 'Stay Online',
            'Keep your status online so customers can find and book you.'),
        _Tip(Icons.star_outline_rounded, 'Boost Your Profile',
            'A strong rating and complete profile attract more requests.'),
        _Tip(Icons.notifications_active_outlined, 'Enable Notifications',
            'Turn on push alerts so you never miss a new booking.'),
      ],
    },
    'active': {
      'icon': Icons.construction_outlined,
      'color': AppTheme.info,
      'gradient': [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
      'title': 'No active jobs',
      'subtitle':
          'Accept a pending request to\nstart working on a job.',
      'tips': [
        _Tip(Icons.check_box_outlined, 'Accept Requests',
            'Head to the Pending tab to review and accept new requests.'),
        _Tip(Icons.directions_run_rounded, 'Start Quickly',
            'Customers appreciate a fast response — aim under 15 minutes.'),
      ],
    },
    'completed': {
      'icon': Icons.emoji_events_outlined,
      'color': AppTheme.success,
      'gradient': AppTheme.successGradient,
      'title': 'No completed jobs yet',
      'subtitle':
          'Completed jobs will be shown here.\nKeep up the great work!',
      'tips': [
        _Tip(Icons.thumb_up_outlined, 'Earn 5-Star Reviews',
            'Deliver quality work and follow up to earn top ratings.'),
        _Tip(Icons.trending_up_rounded, 'Track Your Earnings',
            'Your completed jobs directly impact your monthly income.'),
      ],
    },
    'cancelled': {
      'icon': Icons.sentiment_satisfied_alt_outlined,
      'color': AppTheme.success,
      'gradient': AppTheme.successGradient,
      'title': 'No cancellations',
      'subtitle': 'Great job keeping your cancellation\nrate at zero!',
      'tips': [
        _Tip(Icons.handshake_outlined, 'Communicate Early',
            'If there\'s an issue, let the customer know ASAP to avoid cancels.'),
        _Tip(Icons.calendar_today_outlined, 'Manage Your Schedule',
            'Only accept jobs you can realistically complete on time.'),
      ],
    },
  };
}

class _Tip {
  final IconData icon;
  final String title;
  final String body;
  const _Tip(this.icon, this.title, this.body);
}

class _TipCard extends StatelessWidget {
  final _Tip tip;
  const _TipCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.12), width: 1),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.12),
              borderRadius:
                  BorderRadius.circular(AppTheme.radiusSm),
            ),
            child:
                Icon(tip.icon, size: 20, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tip.title,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 3),
                Text(tip.body,
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

class _TechJobCard extends ConsumerWidget {
  final BookingModel booking;
  final String type;

  const _TechJobCard({required this.booking, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceName = booking.service?.name ?? 'Repair Service';
    final customerName = booking.user?.fullName ?? 'Customer';
    final dateStr = '${booking.scheduledDate.day}/${booking.scheduledDate.month}/${booking.scheduledDate.year}';

    final statusCfg = {
      'pending':     {'label': 'Pending',     'colors': AppTheme.warningGradient,  'icon': Icons.schedule},
      'accepted':    {'label': 'Accepted',    'colors': AppTheme.primaryGradient,  'icon': Icons.check},
      'in_progress': {'label': 'In Progress', 'colors': AppTheme.accentGradient,   'icon': Icons.construction},
      'completed':   {'label': 'Completed',   'colors': AppTheme.successGradient,  'icon': Icons.check_circle},
      'cancelled':   {'label': 'Cancelled',   'colors': AppTheme.errorGradient,    'icon': Icons.cancel},
    };
    final cfg = statusCfg[booking.status] ?? statusCfg['pending']!;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusLg), boxShadow: AppTheme.shadowSm),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: cfg['colors'] as List<Color>, begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(cfg['icon'] as IconData, size: 13, color: Colors.white),
                      const SizedBox(width: 5),
                      Text(cfg['label'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                    ],
                  ),
                ),
                const Spacer(),
                Text(dateStr, style: const TextStyle(fontSize: 12, color: AppTheme.textTertiary)),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMd),
            // Service + customer
            Row(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: AppTheme.primaryGradient),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: const Icon(Icons.build, color: Colors.white, size: 26),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(serviceName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                      const SizedBox(height: 3),
                      Row(children: [
                        Icon(Icons.person_outline, size: 13, color: AppTheme.textTertiary),
                        const SizedBox(width: 4),
                        Text(customerName, style: const TextStyle(fontSize: 13, color: AppTheme.textTertiary)),
                      ]),
                      if (booking.address.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Row(children: [
                          Icon(Icons.location_on_outlined, size: 13, color: AppTheme.textTertiary),
                          const SizedBox(width: 4),
                          Expanded(child: Text(booking.address, style: const TextStyle(fontSize: 12, color: AppTheme.textTertiary), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        ]),
                      ],
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
            // Action buttons
            if (type == 'pending') ...[
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
                        await ref.read(bookingsProvider.notifier).cancelBooking(booking.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Job declined'), behavior: SnackBarBehavior.floating,
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
                              content: Text(ok ? 'Job accepted!' : 'Failed'),
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
            ] else if (type == 'active') ...[
              const SizedBox(height: AppTheme.spacingMd),
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: booking.status == 'accepted' ? AppTheme.primaryGradient : AppTheme.successGradient),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: TextButton(
                    onPressed: () async {
                      final nextStatus = booking.status == 'accepted' ? 'in_progress' : 'completed';
                      final ok = await ref.read(bookingsProvider.notifier).updateBookingStatus(booking.id, nextStatus);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(ok ? (nextStatus == 'in_progress' ? 'Job started!' : 'Job completed!') : 'Failed'),
                          backgroundColor: ok ? AppTheme.success : AppTheme.error,
                          behavior: SnackBarBehavior.floating,
                        ));
                      }
                    },
                    child: Text(
                      booking.status == 'accepted' ? '▶  Start Job' : '✓  Mark as Complete',
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
}
