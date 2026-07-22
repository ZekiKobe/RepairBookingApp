import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
<<<<<<< HEAD
import 'package:socket_io_client/socket_io_client.dart' as IO;

=======
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
import '../../ui/themes/app_theme.dart';
import '../../providers/messages_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/message_model.dart';
<<<<<<< HEAD
import '../../services/api_service.dart';
=======
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739

class ChatScreen extends ConsumerStatefulWidget {
  final String? bookingId;      // set for booking-based chat
  final String? receiverId;     // set for direct chat
  final String otherUserName;
  final String otherUserInitials;
  final DateTime? lastSeenAt;   // last message time from the other user

  const ChatScreen({
    super.key,
    this.bookingId,
    this.receiverId,
    required this.otherUserName,
    required this.otherUserInitials,
    this.lastSeenAt,
  }) : assert(bookingId != null || receiverId != null, 'bookingId or receiverId required');

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;
  Timer? _pollTimer;
  MessageModel? _editingMessage;
  List<File> _attachments = [];
  final _imagePicker = ImagePicker();
<<<<<<< HEAD
  IO.Socket? _socket;
=======
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await _loadMessages();
      _scrollToBottom();
    });
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) _loadMessages();
    });
<<<<<<< HEAD
    _connectBookingSocket();
  }

  void _connectBookingSocket() {
    final bid = widget.bookingId;
    if (bid == null) return;
    final token = ApiService().token;
    if (token == null) return;
    try {
      final origin = ApiService.socketOrigin;
      _socket = IO.io(
        origin,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setAuth({'token': token})
            .enableReconnection()
            .build(),
      );
      _socket!.onConnect((_) {
        _socket!.emit('join_booking', bid);
      });
      _socket!.on('booking_message', (_) {
        if (mounted) _loadMessages();
      });
      _socket!.connect();
    } catch (_) {}
=======
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
<<<<<<< HEAD
    _socket?.dispose();
=======
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
    _messageController.dispose();
    _scrollController.dispose();
    // Refresh unread count when leaving chat
    ref.read(messagesProvider.notifier).loadUnreadCount();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final xfile = await _imagePicker.pickImage(source: source, imageQuality: 80);
    if (xfile != null) setState(() => _attachments.add(File(xfile.path)));
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _attachments.add(File(result.files.single.path!)));
    }
  }

  void _showAttachmentSheet() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(color: AppTheme.textMuted, borderRadius: BorderRadius.circular(2))),
            _sheetTile(Icons.photo_camera_outlined, 'Camera', AppTheme.pastelBlue, AppTheme.primaryColor,
                () { Navigator.pop(context); _pickImage(ImageSource.camera); }),
            _sheetTile(Icons.photo_library_outlined, 'Photo Library', AppTheme.pastelGreen, AppTheme.success,
                () { Navigator.pop(context); _pickImage(ImageSource.gallery); }),
            _sheetTile(Icons.videocam_outlined, 'Video', AppTheme.pastelPurple, AppTheme.primaryLight,
                () async {
                  Navigator.pop(context);
                  final xfile = await _imagePicker.pickVideo(source: ImageSource.gallery);
                  if (xfile != null) setState(() => _attachments.add(File(xfile.path)));
                }),
            _sheetTile(Icons.insert_drive_file_outlined, 'Document / PDF', AppTheme.pastelOrange, AppTheme.primaryAccent,
                () { Navigator.pop(context); _pickFile(); }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _sheetTile(IconData icon, String label, Color bg, Color fg, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Container(width: 42, height: 42,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
        child: Icon(icon, color: fg, size: 22)),
      title: Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w500)),
    );
  }

  void _startEdit(MessageModel msg) {
    HapticFeedback.selectionClick();
    setState(() {
      _editingMessage = msg;
      _messageController.text = msg.content;
    });
    _messageController.selection = TextSelection.fromPosition(
        TextPosition(offset: _messageController.text.length));
  }

  void _cancelEdit() {
    setState(() { _editingMessage = null; _messageController.clear(); });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _loadMessages() async {
    if (widget.bookingId != null) {
      await ref.read(messagesProvider.notifier).loadMessages(widget.bookingId!);
    } else {
      await ref.read(messagesProvider.notifier).loadDirectMessages(widget.receiverId!);
    }
  }

  Future<void> _send() async {
    final text = _messageController.text.trim();
    final hasAttachment = _attachments.isNotEmpty;
    if (text.isEmpty && !hasAttachment || _isSending) return;
    HapticFeedback.mediumImpact();
    _messageController.clear();
    final attachments = List<File>.from(_attachments);
    setState(() { _isSending = true; _attachments = []; _editingMessage = null; });

    // For now send text; attachment upload can be extended via multipart
    await ref.read(messagesProvider.notifier).sendMessage(
      bookingId: widget.bookingId,
      receiverId: widget.receiverId,
      content: text.isEmpty
          ? attachments.map((f) => f.path.split(Platform.pathSeparator).last).join(', ')
          : text,
    );

    setState(() => _isSending = false);
    _scrollToBottom();
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatDateHeader(DateTime dt) {
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return 'Today';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (dt.year == yesterday.year && dt.month == yesterday.month && dt.day == yesterday.day) {
      return 'Yesterday';
    }
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(messagesProvider);
    final currentUser = ref.watch(currentUserProvider);
    final messages = state.currentMessages;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(AppTheme.spacingMd, AppTheme.spacingMd, AppTheme.spacingMd, AppTheme.spacingMd),
              decoration: BoxDecoration(
                color: AppTheme.surface,
<<<<<<< HEAD
                border: Border(bottom: BorderSide(color: AppTheme.hairline, width: 1)),
=======
                border: Border(bottom: BorderSide(color: const Color(0xFF2C3044), width: 1)),
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppTheme.textPrimary),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: AppTheme.primaryGradient),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Center(
                      child: Text(widget.otherUserInitials,
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.otherUserName,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                        _buildPresenceText(),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _loadMessages(),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                      child: const Icon(Icons.refresh, size: 18, color: AppTheme.textSecondary),
                    ),
                  ),
                ],
              ),
            ),

            // Messages list
            Expanded(
              child: state.isLoading && messages.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 64, height: 64,
                                decoration: BoxDecoration(
                                  color: AppTheme.pastelBlue,
                                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                                ),
                                child: const Icon(Icons.chat_bubble_outline, size: 32, color: AppTheme.primaryColor),
                              ),
                              const SizedBox(height: AppTheme.spacingMd),
                              const Text('No messages yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                              const SizedBox(height: 6),
                              const Text('Say hello!', style: TextStyle(fontSize: 13, color: AppTheme.textTertiary)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd, vertical: AppTheme.spacingMd),
                          itemCount: messages.length,
                          itemBuilder: (context, i) {
                            final msg = messages[i];
                            final isMe = msg.senderId == currentUser?.id;
                            // Date header
                            final showDate = i == 0 ||
                                !_sameDay(messages[i - 1].createdAt, msg.createdAt);
                            return Column(
                              children: [
                                if (showDate) _buildDateHeader(msg.createdAt),
                                _buildBubble(msg, isMe),
                              ],
                            );
                          },
                        ),
            ),

            // Input bar
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
<<<<<<< HEAD
                border: Border(top: BorderSide(color: AppTheme.hairline, width: 1)),
=======
                border: Border(top: BorderSide(color: const Color(0xFF2C3044), width: 1)),
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Edit mode banner
                  if (_editingMessage != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: AppTheme.primaryColor.withOpacity(0.10),
                      child: Row(
                        children: [
                          const Icon(Icons.edit, size: 16, color: AppTheme.primaryColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text('Editing message',
                              style: const TextStyle(fontSize: 12, color: AppTheme.primaryColor, fontWeight: FontWeight.w500)),
                          ),
                          GestureDetector(
                            onTap: _cancelEdit,
                            child: const Icon(Icons.close, size: 18, color: AppTheme.textTertiary),
                          ),
                        ],
                      ),
                    ),
                  // Attachment previews
                  if (_attachments.isNotEmpty)
                    SizedBox(
                      height: 72,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        itemCount: _attachments.length,
                        itemBuilder: (_, i) {
                          final f = _attachments[i];
                          final isImg = ['.jpg','.jpeg','.png','.gif','.webp']
                              .any((ext) => f.path.toLowerCase().endsWith(ext));
                          return Stack(
                            children: [
                              Container(
                                width: 56, height: 56, margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: isImg
                                    ? ClipRRect(borderRadius: BorderRadius.circular(10),
                                        child: Image.file(f, fit: BoxFit.cover))
                                    : const Icon(Icons.insert_drive_file_outlined, color: AppTheme.primaryAccent, size: 28),
                              ),
                              Positioned(
                                top: 0, right: 8,
                                child: GestureDetector(
                                  onTap: () => setState(() => _attachments.removeAt(i)),
                                  child: Container(
                                    width: 18, height: 18,
                                    decoration: const BoxDecoration(color: AppTheme.error, shape: BoxShape.circle),
                                    child: const Icon(Icons.close, size: 12, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  // Text row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: _showAttachmentSheet,
                          child: Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceLight,
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            ),
                            child: const Icon(Icons.attach_file_rounded, size: 20, color: AppTheme.textSecondary),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceLight,
                              borderRadius: BorderRadius.circular(20),
<<<<<<< HEAD
                              border: Border.all(color: AppTheme.hairline, width: 1),
=======
                              border: Border.all(color: const Color(0xFF2C3044), width: 1),
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
                            ),
                            child: TextField(
                              controller: _messageController,
                              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                              maxLines: 4,
                              minLines: 1,
                              textInputAction: TextInputAction.newline,
                              decoration: const InputDecoration(
                                hintText: 'Type a message...',
                                hintStyle: TextStyle(color: AppTheme.textTertiary, fontSize: 14),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _isSending ? null : _send,
                          child: Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              gradient: _isSending ? null : const LinearGradient(colors: AppTheme.primaryGradient),
                              color: _isSending ? AppTheme.surfaceLight : null,
                              shape: BoxShape.circle,
                              boxShadow: _isSending ? null : [
                                BoxShadow(color: AppTheme.primaryColor.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4)),
                              ],
                            ),
                            child: _isSending
                                ? const Padding(padding: EdgeInsets.all(12),
                                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryColor))
                                : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
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
    );
  }

  Widget _buildPresenceText() {
    // Find the most recent message sent BY the other user
    final state = ref.watch(messagesProvider);
    final currentUser = ref.watch(currentUserProvider);
    final msgs = state.currentMessages;

    DateTime? lastActive = widget.lastSeenAt;
    for (final m in msgs.reversed) {
      if (m.senderId != currentUser?.id) {
        lastActive = m.createdAt;
        break;
      }
    }

    if (lastActive == null) {
      return const Text('Offline', style: TextStyle(fontSize: 12, color: AppTheme.textTertiary));
    }

    final diff = DateTime.now().difference(lastActive);
    if (diff.inMinutes <= 5) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7, height: 7,
            margin: const EdgeInsets.only(right: 5),
            decoration: const BoxDecoration(color: AppTheme.success, shape: BoxShape.circle),
          ),
          const Text('Online', style: TextStyle(fontSize: 12, color: AppTheme.success)),
        ],
      );
    }

    final String label;
    if (diff.inMinutes < 60) {
      label = '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      label = '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      label = 'Yesterday';
    } else {
      label = '${diff.inDays}d ago';
    }

    return Text('Last seen $label', style: const TextStyle(fontSize: 12, color: AppTheme.textTertiary));
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _buildDateHeader(DateTime dt) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(child: Divider(color: AppTheme.textMuted, height: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(_formatDateHeader(dt),
                style: const TextStyle(fontSize: 12, color: AppTheme.textTertiary, fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Divider(color: AppTheme.textMuted, height: 1)),
        ],
      ),
    );
  }

  Widget _buildBubble(MessageModel msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: isMe ? () => _startEdit(msg) : null,
        child: Container(
          margin: EdgeInsets.only(
            bottom: 6,
            left: isMe ? 64 : 0,
            right: isMe ? 0 : 64,
          ),
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isMe ? const LinearGradient(colors: AppTheme.primaryGradient) : null,
                  color: isMe ? null : const Color(0xFF1E2130),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isMe ? 16 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 16),
                  ),
<<<<<<< HEAD
                  border: isMe ? null : Border.all(color: AppTheme.hairline, width: 1),
=======
                  border: isMe ? null : Border.all(color: const Color(0xFF2C3044), width: 1),
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
                  boxShadow: [
                    BoxShadow(
                      color: isMe
                          ? AppTheme.primaryColor.withOpacity(0.25)
                          : Colors.black.withOpacity(0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  msg.content,
                  style: TextStyle(
                    fontSize: 14,
                    color: isMe ? Colors.white : AppTheme.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isMe)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text('Hold to edit',
                          style: const TextStyle(fontSize: 9, color: AppTheme.textTertiary)),
                    ),
                  Text(_formatTime(msg.createdAt),
                      style: const TextStyle(fontSize: 10, color: AppTheme.textTertiary)),
                  if (isMe) ...[const SizedBox(width: 4),
                    Icon(msg.isRead ? Icons.done_all : Icons.done,
                        size: 13,
                        color: msg.isRead ? AppTheme.primaryColor : AppTheme.textTertiary),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
