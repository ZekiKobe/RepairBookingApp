import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repair_booking/l10n/app_localizations.dart';

import '../../ui/themes/app_theme.dart';
import '../../models/notification_model.dart';
import '../../providers/notifications_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(notificationsProvider.notifier).load());
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'booking_new':        return Icons.add_circle_outline_rounded;
      case 'booking_accepted':   return Icons.check_circle_outline_rounded;
      case 'booking_cancelled':  return Icons.cancel_outlined;
      case 'booking_in_progress':return Icons.construction_rounded;
      case 'booking_completed':  return Icons.verified_rounded;
      case 'new_message':        return Icons.chat_bubble_outline_rounded;
      case 'review_received':    return Icons.star_outline_rounded;
      case 'payment_received':   return Icons.payments_outlined;
      default:                   return Icons.notifications_outlined;
    }
  }

  Color _colorFor(String type) {
    switch (type) {
      case 'booking_new':        return AppTheme.primaryColor;
      case 'booking_accepted':   return AppTheme.success;
      case 'booking_cancelled':  return AppTheme.error;
      case 'booking_in_progress':return AppTheme.warning;
      case 'booking_completed':  return AppTheme.success;
      case 'new_message':        return AppTheme.primaryLight;
      case 'review_received':    return AppTheme.warning;
      case 'payment_received':   return AppTheme.success;
      default:                   return AppTheme.textTertiary;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppTheme.spacingLg, AppTheme.spacingLg, AppTheme.spacingLg, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          boxShadow: AppTheme.shadowSm,
                          border: Border.all(color: AppTheme.hairline),
                        ),
                        child: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.notificationFeedTitle,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            l10n.notificationFeedSubtitle,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (state.unreadCount > 0)
                      TextButton(
                        onPressed: () => ref.read(notificationsProvider.notifier).markAllRead(),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        ),
                        child: const Text('Mark all read', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacingMd)),

            // Content
            if (state.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.notifications.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72, height: 72,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.notifications_none_rounded, size: 36, color: AppTheme.primaryColor),
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      const Text('No notifications yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                      const SizedBox(height: 6),
                      const Text('You\'ll be notified about bookings\nand messages here.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppTheme.textTertiary)),
                    ],
                  ),
                ),
              )
            else
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(color: AppTheme.surface, boxShadow: AppTheme.shadowSm),
                  child: Column(
                    children: [
                      for (int i = 0; i < state.notifications.length; i++) ...[
                        _buildTile(state.notifications[i]),
                        if (i < state.notifications.length - 1)
                          const Divider(height: 1, thickness: 1, color: AppTheme.hairline),
                      ],
                    ],
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacingLg)),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(NotificationModel n) {
    final color = _colorFor(n.type);
    return Material(
      color: n.isRead ? Colors.transparent : AppTheme.primaryColor.withOpacity(0.04),
      child: InkWell(
        onTap: () {
          if (!n.isRead) ref.read(notificationsProvider.notifier).markOneRead(n.id);
        },
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Icon(_iconFor(n.type), color: color, size: 22),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(n.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w700,
                                color: AppTheme.textPrimary,
                              )),
                        ),
                        if (!n.isRead)
                          Container(
                            width: 8, height: 8,
                            decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(n.body, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4)),
                    const SizedBox(height: 4),
                    Text(_timeAgo(n.createdAt), style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
