import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ui/themes/app_theme.dart';
import '../../providers/bookings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/booking_model.dart';
import 'booking_detail_screen.dart';

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final isTech = ref.read(currentUserProvider)?.role == 'technician';
      ref.read(bookingsProvider.notifier).loadBookings(isTechnician: isTech);
    });
  }

  List<BookingModel> _getFilteredBookings(BookingsState state) {
    return switch (_selectedFilter) {
      'pending' => state.pending,
      'active' => state.active,
      'completed' => state.completed,
      'cancelled' => state.cancelled,
      _ => [...state.pending, ...state.active, ...state.completed, ...state.cancelled],
    };
  }

  @override
  Widget build(BuildContext context) {
    final bookingsState = ref.watch(bookingsProvider);
    final filteredBookings = _getFilteredBookings(bookingsState);
    final isTechnician = ref.watch(currentUserProvider)?.role == 'technician';

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Bookings',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${filteredBookings.length} bookings',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      final isTech = ref.read(currentUserProvider)?.role == 'technician';
                      ref.read(bookingsProvider.notifier).loadBookings(isTechnician: isTech);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.hairline, width: 1),
                      ),
                      child: const Icon(Icons.refresh, color: AppTheme.textPrimary, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // Filter chips
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'All',
                      count: bookingsState.pending.length +
                          bookingsState.active.length +
                          bookingsState.completed.length +
                          bookingsState.cancelled.length,
                      isSelected: _selectedFilter == 'all',
                      onTap: () => setState(() => _selectedFilter = 'all'),
                    ),
                    _FilterChip(
                      label: 'Pending',
                      count: bookingsState.pending.length,
                      isSelected: _selectedFilter == 'pending',
                      onTap: () => setState(() => _selectedFilter = 'pending'),
                      accentColor: AppTheme.warning,
                    ),
                    _FilterChip(
                      label: 'Active',
                      count: bookingsState.active.length,
                      isSelected: _selectedFilter == 'active',
                      onTap: () => setState(() => _selectedFilter = 'active'),
                      accentColor: AppTheme.primaryColor,
                    ),
                    _FilterChip(
                      label: 'Completed',
                      count: bookingsState.completed.length,
                      isSelected: _selectedFilter == 'completed',
                      onTap: () => setState(() => _selectedFilter = 'completed'),
                      accentColor: AppTheme.success,
                    ),
                    _FilterChip(
                      label: 'Cancelled',
                      count: bookingsState.cancelled.length,
                      isSelected: _selectedFilter == 'cancelled',
                      onTap: () => setState(() => _selectedFilter = 'cancelled'),
                      accentColor: AppTheme.error,
                    ),
                  ],
                ),
              ),
            ),

            // Bookings list
            Expanded(
              child: bookingsState.isLoading && filteredBookings.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : filteredBookings.isEmpty
                  ? _buildEmptyState(_selectedFilter)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      itemCount: filteredBookings.length,
                      itemBuilder: (context, index) => _BookingCard(
                        booking: filteredBookings[index],
                        isFirst: index == 0,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String filter) {
    final messages = {
      'pending': 'No pending bookings',
      'active': 'No active bookings',
      'completed': 'No completed bookings',
      'cancelled': 'No cancelled bookings',
      'all': 'No bookings yet',
    };
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor.withOpacity(0.2), AppTheme.primaryLight.withOpacity(0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.calendar_today_outlined,
              size: 32,
              color: AppTheme.primaryLight,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            messages[filter]!,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your bookings will appear here',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? accentColor;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(colors: AppTheme.primaryGradient)
                : null,
            color: isSelected ? null : AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: isSelected
                ? null
                : Border.all(color: AppTheme.hairline, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (accentColor != null && !isSelected)
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                ),
              ),
              if (count > 0)
                Container(
                  margin: const EdgeInsets.only(left: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.2)
                        : AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppTheme.textTertiary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final bool isFirst;

  const _BookingCard({required this.booking, this.isFirst = false});

  @override
  Widget build(BuildContext context) {
    final statusConfig = {
      'pending': {'color': AppTheme.warning, 'label': 'Pending', 'icon': Icons.schedule},
      'accepted': {'color': AppTheme.primaryAccent, 'label': 'Accepted', 'icon': Icons.check_circle_outline},
      'in_progress': {'color': AppTheme.primaryColor, 'label': 'In Progress', 'icon': Icons.construction},
      'completed': {'color': AppTheme.success, 'label': 'Completed', 'icon': Icons.check_circle},
      'cancelled': {'color': AppTheme.error, 'label': 'Cancelled', 'icon': Icons.cancel},
    };
    final cfg = statusConfig[booking.status] ?? statusConfig['pending']!;
    final serviceName = booking.service?.name ?? 'Repair Service';
    final techName = booking.technician is Map
        ? '${booking.technician['user']?['firstName'] ?? ''} ${booking.technician['user']?['lastName'] ?? ''}'.trim()
        : '';
    final dateStr = '${booking.scheduledDate.day.toString().padLeft(2, '0')}/${booking.scheduledDate.month.toString().padLeft(2, '0')}/${booking.scheduledDate.year}';

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => BookingDetailScreen(booking: booking),
        ));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12, top: isFirst ? 4 : 0),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.hairline, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top accent line based on status
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: cfg['color'] as Color,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status and date row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (cfg['color'] as Color).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(cfg['icon'] as IconData, size: 12, color: cfg['color'] as Color),
                            const SizedBox(width: 4),
                            Text(
                              cfg['label'] as String,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: cfg['color'] as Color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Service info row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Service icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.build, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      // Service details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              serviceName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              techName.isNotEmpty ? techName : 'Technician assigned',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Price tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${booking.price.toStringAsFixed(0)} ETB',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Bottom info bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 14, color: AppTheme.textTertiary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            booking.timeSlot ?? 'Time not specified',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, size: 12, color: AppTheme.textTertiary),
                      ],
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
}
