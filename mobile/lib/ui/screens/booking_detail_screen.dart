import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../ui/themes/app_theme.dart';
import '../../models/booking_model.dart';
import '../../providers/bookings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/booking_service.dart';
import 'chat_screen.dart';

class BookingDetailScreen extends ConsumerStatefulWidget {
  final BookingModel booking;

  const BookingDetailScreen({super.key, required this.booking});

  @override
  ConsumerState<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends ConsumerState<BookingDetailScreen> {
  late BookingModel _booking;
  final _bookingService = BookingService();
  bool _reviewed = false;

  @override
  void initState() {
    super.initState();
    _booking = widget.booking;
  }

  String _techName() {
    if (_booking.technician is Map) {
      final u = _booking.technician['user'];
      if (u is Map) {
        return '${u['firstName'] ?? ''} ${u['lastName'] ?? ''}'.trim();
      }
    }
    return 'Technician';
  }

  String _techInitials() {
    final name = _techName();
    return name.split(' ').where((e) => e.isNotEmpty).map((e) => e[0]).join('');
  }

  String _techId() {
    if (_booking.technician is Map) {
      return _booking.technician['_id'] ?? _booking.technicianId ?? '';
    }
    return _booking.technicianId ?? '';
  }

  Map<String, dynamic> _statusConfig(String status) {
    const configs = {
      'pending':     {'label': 'Pending',     'color': 0xFFF59E0B, 'icon': Icons.schedule},
      'accepted':    {'label': 'Accepted',    'color': 0xFF6366F1, 'icon': Icons.check_circle_outline},
      'on_the_way':  {'label': 'On The Way',  'color': 0xFF3B82F6, 'icon': Icons.directions_car_outlined},
      'in_progress': {'label': 'In Progress', 'color': 0xFF8B5CF6, 'icon': Icons.construction},
      'completed':   {'label': 'Completed',   'color': 0xFF10B981, 'icon': Icons.check_circle},
      'cancelled':   {'label': 'Cancelled',   'color': 0xFFEF4444, 'icon': Icons.cancel_outlined},
    };
    return configs[status] ?? configs['pending']!;
  }

  Future<void> _cancelBooking() async {
    HapticFeedback.mediumImpact();
    final confirmed = await showConfirmModal(
      context,
      title: 'Cancel Booking',
      message: 'Are you sure you want to cancel this booking?',
      confirmLabel: 'Yes, Cancel',
      cancelLabel: 'No',
      icon: Icons.cancel_outlined,
      iconColor: AppTheme.error,
    );
    if (!confirmed || !mounted) return;

    final ok = await ref.read(bookingsProvider.notifier).cancelBooking(_booking.id);
    if (ok && mounted) {
      setState(() => _booking = _copyBooking(status: 'cancelled'));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Booking cancelled'),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  // Helper: copy booking with overrides
  BookingModel _copyBooking({String? status, String? paymentStatus}) {
    return BookingModel(
      id: _booking.id, user: _booking.user, userId: _booking.userId,
      technician: _booking.technician, technicianId: _booking.technicianId,
      service: _booking.service, serviceId: _booking.serviceId,
      status: status ?? _booking.status,
      description: _booking.description,
      address: _booking.address, price: _booking.price,
      scheduledDate: _booking.scheduledDate, timeSlot: _booking.timeSlot,
      createdAt: _booking.createdAt, updatedAt: _booking.updatedAt,
      completedAt: status == 'completed' ? DateTime.now() : _booking.completedAt,
      paymentStatus: paymentStatus ?? _booking.paymentStatus,
    );
  }

  Future<void> _acceptBooking() async {
    HapticFeedback.mediumImpact();
    final ok = await ref.read(bookingsProvider.notifier).acceptBooking(_booking.id);
    if (ok && mounted) {
      setState(() => _booking = _copyBooking(status: 'accepted'));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Booking accepted!'),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> _updateStatus(String status) async {
    HapticFeedback.mediumImpact();
    final ok = await ref.read(bookingsProvider.notifier).updateBookingStatus(_booking.id, status);
    if (ok && mounted) {
      setState(() => _booking = _copyBooking(status: status));
    }
  }

  // ── Completion sheet (shown to customer when job is completed) ─────────────
  Future<void> _showCompletionSheet() async {
    int _rating = 5;
    final _commentCtrl = TextEditingController();
    bool _isSubmitting = false;
    bool _paymentDone = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                // Drag handle
                Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.textMuted, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 12),
                // Success icon
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(color: AppTheme.success.withOpacity(0.12), shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 38),
                ),
                const SizedBox(height: 8),
                const Text('Job Completed!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                const SizedBox(height: 2),
                Text('Rate your experience with ${_techName()}', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                const SizedBox(height: 14),
                // Star rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) => GestureDetector(
                    onTap: () => setSheet(() => _rating = i + 1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        i < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: AppTheme.warning,
                        size: 40,
                      ),
                    ),
                  )),
                ),
                const SizedBox(height: 12),
                // Comment
                TextField(
                  controller: _commentCtrl,
                  maxLines: 3,
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Share your experience (optional)...',
                    hintStyle: const TextStyle(color: AppTheme.textTertiary, fontSize: 13),
                    filled: true,
                    fillColor: AppTheme.surfaceLight,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd), borderSide: const BorderSide(color: AppTheme.hairline)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd), borderSide: const BorderSide(color: AppTheme.hairline)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 12),
                // Payment info
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.payments_outlined, color: AppTheme.primaryColor, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Payment Amount', style: TextStyle(fontSize: 12, color: AppTheme.textTertiary)),
                            Text('ETB ${_booking.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
                          ],
                        ),
                      ),
                      if (_paymentDone)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppTheme.success.withOpacity(0.15), borderRadius: BorderRadius.circular(AppTheme.radiusFull)),
                          child: const Text('Paid', style: TextStyle(color: AppTheme.success, fontSize: 12, fontWeight: FontWeight.w700)),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: GestureDetector(
                    onTap: _isSubmitting ? null : () async {
                      setSheet(() => _isSubmitting = true);

                      // Submit review
                      await _bookingService.submitReview(
                        bookingId: _booking.id,
                        rating: _rating,
                        comment: _commentCtrl.text.trim(),
                      );

                      // Step 1: initiate payment
                      final intentRes = await _bookingService.initiatePayment(_booking.id);
                      if (!ctx.mounted) return;

                      if (!intentRes.success) {
                        setSheet(() => _isSubmitting = false);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(intentRes.message ?? 'Payment initiation failed'),
                          backgroundColor: AppTheme.error,
                          behavior: SnackBarBehavior.floating,
                        ));
                        return;
                      }

                      final checkoutUrl = intentRes.data?['checkoutUrl'] as String? ?? '';
                      final txRef = intentRes.data?['txRef'] as String?;
                      final provider = intentRes.data?['provider'] as String? ?? 'mock';

                      // Step 2: open checkout for real providers
                      if (provider != 'mock' && checkoutUrl.isNotEmpty && !checkoutUrl.startsWith('repairbooking://')) {
                        final uri = Uri.parse(checkoutUrl);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.inAppWebView);
                        }
                      }

                      // Step 3: confirm with backend
                      final payRes = await _bookingService.confirmPayment(_booking.id, txRef: txRef);
                      setSheet(() { _isSubmitting = false; _paymentDone = payRes.success; });
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      if (mounted) {
                        setState(() {
                          _reviewed = true;
                          if (payRes.success) _booking = _copyBooking(paymentStatus: 'paid');
                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(payRes.success ? 'Review submitted & payment confirmed!' : 'Review submitted! Payment pending.'),
                          backgroundColor: payRes.success ? AppTheme.success : AppTheme.warning,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                        ));
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: AppTheme.primaryGradient),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        boxShadow: [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: Center(
                        child: _isSubmitting
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : const Text('Submit Review & Confirm Payment', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ),
              ],
              ),
            ),
          ),
        ),
      ),
    );
    _commentCtrl.dispose();
  }

  void _openChat() {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => ChatScreen(
        bookingId: _booking.id,
        otherUserName: _techName(),
        otherUserInitials: _techInitials(),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final isTechnician = currentUser?.role == 'technician';
    final cfg = _statusConfig(_booking.status);
    final statusColor = Color(cfg['color'] as int);
    final dateStr = '${_booking.scheduledDate.day}/${_booking.scheduledDate.month}/${_booking.scheduledDate.year}';

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(AppTheme.spacingLg, AppTheme.spacingLg, AppTheme.spacingLg, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(color: AppTheme.hairline, width: 1),
                      ),
                      child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppTheme.textPrimary),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  const Text('Booking Details',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            const Divider(color: AppTheme.hairline, height: 1),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                children: [
                  // Status banner
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingMd),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(color: statusColor.withOpacity(0.15), shape: BoxShape.circle),
                          child: Icon(cfg['icon'] as IconData, color: statusColor, size: 22),
                        ),
                        const SizedBox(width: AppTheme.spacingMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(cfg['label'] as String,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: statusColor)),
                              Text('Booking #${_booking.id.substring(_booking.id.length - 6).toUpperCase()}',
                                  style: const TextStyle(fontSize: 12, color: AppTheme.textTertiary)),
                            ],
                          ),
                        ),
                        if (_booking.paymentStatus == 'paid')
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.success.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                            ),
                            child: const Text('Paid', style: TextStyle(color: AppTheme.success, fontSize: 12, fontWeight: FontWeight.w700)),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacingLg),

                  // Service & technician card
                  _infoCard([
                    _infoRow(Icons.build_outlined, 'Service', _booking.service?.name ?? 'Repair Service'),
                    _dividerRow(),
                    _infoRow(Icons.person_outlined, 'Technician', _techName()),
                    _dividerRow(),
                    _infoRow(Icons.calendar_today_outlined, 'Date', dateStr),
                    if (_booking.timeSlot != null) ...[
                      _dividerRow(),
                      _infoRow(Icons.access_time, 'Time Slot', _booking.timeSlot!),
                    ],
                    _dividerRow(),
                    _infoRow(Icons.location_on_outlined, 'Address', _booking.address),
                    _dividerRow(),
                    _infoRow(Icons.payments_outlined, 'Price', 'ETB ${_booking.price.toStringAsFixed(0)}'),
                    _dividerRow(),
                    _infoRow(Icons.credit_score_outlined, 'Payment', _booking.paymentStatus == 'paid' ? 'Paid ✓' : 'Pending'),
                  ]),

                  if (_booking.description != null && _booking.description!.isNotEmpty) ...[
                    const SizedBox(height: AppTheme.spacingMd),
                    _infoCard([
                      _infoRow(Icons.notes_outlined, 'Description', _booking.description!),
                    ]),
                  ],

                  const SizedBox(height: AppTheme.spacingLg),

                  // Message button (always shown for active bookings)
                  if (_booking.status != 'cancelled') ...[
                    _actionButton(
                      label: 'Message ${isTechnician ? 'Customer' : 'Technician'}',
                      icon: Icons.chat_bubble_outline_rounded,
                      gradient: AppTheme.primaryGradient,
                      onTap: _openChat,
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                  ],

                  // Technician actions
                  if (isTechnician) ...[
                    if (_booking.status == 'pending')
                      _actionButton(
                        label: 'Accept Booking',
                        icon: Icons.check_circle_outline,
                        gradient: AppTheme.successGradient,
                        onTap: _acceptBooking,
                      ),
                    if (_booking.status == 'accepted')
                      _actionButton(
                        label: 'Mark as In Progress',
                        icon: Icons.construction,
                        gradient: AppTheme.primaryGradient,
                        onTap: () => _updateStatus('in_progress'),
                      ),
                    if (_booking.status == 'in_progress')
                      _actionButton(
                        label: 'Mark as Completed',
                        icon: Icons.check_circle,
                        gradient: AppTheme.successGradient,
                        onTap: () => _updateStatus('completed'),
                      ),
                  ],

                  // Customer: rate & pay when job completed and not yet paid
                  if (!isTechnician &&
                      _booking.status == 'completed' &&
                      _booking.paymentStatus != 'paid' &&
                      !_reviewed) ...[
                    const SizedBox(height: AppTheme.spacingSm),
                    _actionButton(
                      label: 'Rate & Confirm Payment',
                      icon: Icons.star_rate_rounded,
                      gradient: AppTheme.successGradient,
                      onTap: _showCompletionSheet,
                    ),
                  ],

                  // Customer cancel
                  if (!isTechnician &&
                      (_booking.status == 'pending' || _booking.status == 'accepted')) ...[
                    const SizedBox(height: AppTheme.spacingSm),
                    _actionButton(
                      label: 'Cancel Booking',
                      icon: Icons.cancel_outlined,
                      gradient: AppTheme.errorGradient,
                      onTap: _cancelBooking,
                    ),
                  ],

                  const SizedBox(height: AppTheme.spacingXl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.hairline, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(children: children),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          SizedBox(width: 90, child: Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textTertiary))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.textPrimary))),
        ],
      ),
    );
  }

  Widget _dividerRow() => const Divider(color: AppTheme.hairline, height: 1);

  Widget _actionButton({
    required String label,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: [
            BoxShadow(color: gradient.first.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
