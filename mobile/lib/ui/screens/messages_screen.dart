import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ui/themes/app_theme.dart';
import '../../providers/messages_provider.dart';
import '../../models/message_model.dart';
import 'chat_screen.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(messagesProvider.notifier).loadConversations();
      ref.read(messagesProvider.notifier).loadUnreadCount();
    });
  }

  List<Color> _avatarColors(int index) {
    final palette = [
      [AppTheme.pastelBlue, AppTheme.info],
      [AppTheme.pastelOrange, AppTheme.primaryAccent],
      [AppTheme.pastelGreen, AppTheme.success],
      [AppTheme.pastelYellow, AppTheme.warning],
      [AppTheme.pastelPurple, AppTheme.primaryColor],
    ];
    return palette[index % palette.length];
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final messagesState = ref.watch(messagesProvider);
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Messages',
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your conversations',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => ref.read(messagesProvider.notifier).loadConversations(),
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

            if (messagesState.isLoading)
              const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())))
            else if (messagesState.conversations.isEmpty)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacing2xl),
                    child: Column(
                      children: [
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            color: AppTheme.pastelBlue,
                            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          ),
                          child: Icon(Icons.chat_bubble_outline, size: 40, color: AppTheme.primaryColor),
                        ),
                        const SizedBox(height: AppTheme.spacingLg),
                        const Text('No messages yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                        const SizedBox(height: AppTheme.spacingSm),
                        const Text('Messages from your bookings will appear here', style: TextStyle(fontSize: 14, color: AppTheme.textTertiary), textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      boxShadow: AppTheme.shadowSm,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        for (int i = 0; i < messagesState.conversations.length; i++)
                          ...[
                            _buildConversationTile(messagesState.conversations[i], i),
                            if (i < messagesState.conversations.length - 1)
                              const Divider(height: 1, thickness: 1, indent: 76, color: AppTheme.hairline),
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

  Widget _buildConversationTile(ConversationModel conv, int index) {
    final colors = _avatarColors(index);
    final name = conv.otherUser?.fullName ?? 'User';
    final initials = name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join('');
    final lastMsg = conv.lastMessage?.content ?? '';
    final time = conv.lastMessage != null ? _timeAgo(conv.lastMessage!.createdAt) : '';
    final hasUnread = conv.unreadCount > 0;

    return InkWell(
            onTap: () {
              final lastSeenAt = conv.lastMessage?.createdAt;
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => conv.bookingId != null
                    ? ChatScreen(
                        bookingId: conv.bookingId,
                        otherUserName: name,
                        otherUserInitials: initials,
                        lastSeenAt: lastSeenAt,
                      )
                    : ChatScreen(
                        receiverId: conv.otherUser?.id,
                        otherUserName: name,
                        otherUserInitials: initials,
                        lastSeenAt: lastSeenAt,
                      ),
              ));
            },
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Row(
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(color: colors[0], borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                    child: Center(child: Text(initials, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colors[1]))),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(name, style: TextStyle(fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600, fontSize: 15, color: AppTheme.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ),
                            const SizedBox(width: 8),
                            Text(time, style: TextStyle(fontSize: 11, fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w500, color: hasUnread ? AppTheme.primaryColor : AppTheme.textTertiary)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lastMsg,
                          style: TextStyle(color: hasUnread ? AppTheme.textPrimary : AppTheme.textSecondary, fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal, fontSize: 13),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (hasUnread) ...[
                    const SizedBox(width: AppTheme.spacingSm),
                    Container(
                      width: 22, height: 22,
                      decoration: BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle),
                      child: Center(child: Text('${conv.unreadCount}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
