import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:visualcheckup/core/l10n/l10n_extensions.dart';
import 'package:visualcheckup/features/community/data/community_image_upload_service.dart';
import 'package:visualcheckup/features/community/data/health_community_repository.dart';
import 'package:visualcheckup/features/community/domain/health_community_models.dart';
import 'package:visualcheckup/features/community/presentation/widgets/community_avatar_and_report.dart';

typedef CommunityPhotoPicker = Future<Uint8List?> Function(ImageSource source);

/// 1-on-1 Health Community chat screen with:
/// - Opt-in message request approval (Accept / Decline / Block)
/// - Compressed Cloudflare R2 image attachment uploads (camera & gallery)
/// - Peer-support medical safety disclaimer
/// - Mute, Block, Report, Delete for me, and Delete for everyone controls
class HealthChatScreen extends StatefulWidget {
  const HealthChatScreen({
    super.key,
    required this.myUid,
    required this.myDisplayName,
    this.myPhotoUrl,
    required this.peer,
    required this.repository,
    this.uploadService,
    this.photoPicker,
  });

  final String myUid;
  final String myDisplayName;
  final String? myPhotoUrl;
  final HealthCommunityProfile peer;
  final HealthCommunityRepository repository;
  final CommunityImageUploadService? uploadService;
  final CommunityPhotoPicker? photoPicker;

  @override
  State<HealthChatScreen> createState() => _HealthChatScreenState();
}

class _HealthChatScreenState extends State<HealthChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final CommunityImageUploadService _uploadService;
  CommunityConversation? _conversation;
  List<CommunityChatMessage> _messages = const [];
  bool _loading = true;
  bool _sending = false;
  bool _uploadingImage = false;
  bool _iBlockedPeer = false;

  String get _chatId =>
      CommunityConversation.chatIdFor(widget.myUid, widget.peer.uid);

  @override
  void initState() {
    super.initState();
    _uploadService =
        widget.uploadService ?? R2CommunityImageUploadService.instance;
    _loadChat();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadChat() async {
    final blocks = await widget.repository.loadBlockedUsers(widget.myUid);
    final convo = await widget.repository.loadConversation(_chatId);
    final msgs = await widget.repository.loadMessages(
      _chatId,
      myUid: widget.myUid,
    );
    await widget.repository.markConversationRead(
      chatId: _chatId,
      myUid: widget.myUid,
    );
    if (!mounted) return;
    setState(() {
      _iBlockedPeer = blocks.contains(widget.peer.uid);
      _conversation = convo;
      _messages = msgs;
      _loading = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendTextOrImage({String? imageUrl, String? imageKey}) async {
    if (_sending) return;
    final l10n = context.l10n;
    final text = _textController.text.trim();
    if (text.isEmpty && (imageUrl == null || imageUrl.isEmpty)) return;

    setState(() => _sending = true);
    final status = await widget.repository.sendMessage(
      senderUid: widget.myUid,
      senderDisplayName: widget.myDisplayName,
      senderPhotoUrl: widget.myPhotoUrl,
      receiver: widget.peer,
      text: text,
      imageUrl: imageUrl,
      imageKey: imageKey,
      imagePreviewFallbackLabel: '📷 ${l10n.commPhotoLabel}',
    );
    if (!mounted) return;
    setState(() => _sending = false);

    switch (status) {
      case SendMessageStatus.sent:
        _textController.clear();
        await _loadChat();
        break;
      case SendMessageStatus.rateLimited:
        _toast(l10n.commRateLimited);
        break;
      case SendMessageStatus.blocked:
        _toast(l10n.commBlockedNotice);
        break;
      case SendMessageStatus.receiverDisabledMessages:
      case SendMessageStatus.senderDisabledMessages:
        _toast(l10n.commMessagesDisabled);
        break;
      case SendMessageStatus.requestDeclined:
        _toast(l10n.commBlockedNotice);
        break;
      case SendMessageStatus.dailyLimitExceeded:
        _toast(l10n.commRateLimited);
        break;
      case SendMessageStatus.emptyContent:
      case SendMessageStatus.error:
        break;
    }
  }

  Future<void> _pickAndSendImage(ImageSource source) async {
    if (_uploadingImage || _sending) return;
    setState(() => _uploadingImage = true);
    try {
      Uint8List? bytes;
      if (widget.photoPicker != null) {
        bytes = await widget.photoPicker!(source);
      } else {
        final picker = ImagePicker();
        final file = await picker.pickImage(
          source: source,
          maxWidth: 1600,
          imageQuality: 85,
        );
        if (file != null) {
          bytes = await file.readAsBytes();
        }
      }
      if (bytes == null || !mounted) return;

      final uploaded = await _uploadService.uploadBytes(
        bytes,
        folder: 'community_chat',
      );
      if (!mounted) return;
      await _sendTextOrImage(
        imageUrl: uploaded.url,
        imageKey: uploaded.objectKey,
      );
    } on CommunityUploadException catch (e) {
      if (mounted) _toast(e.message);
    } catch (_) {
      // Ignore user cancellation gracefully.
    } finally {
      if (mounted) setState(() => _uploadingImage = false);
    }
  }

  Future<void> _openImageSourceSheet() async {
    if (widget.photoPicker != null) {
      await _pickAndSendImage(ImageSource.gallery);
      return;
    }
    final l10n = context.l10n;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: Text(l10n.medTakePhoto),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: Text(l10n.medPickGallery),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source != null && mounted) {
      await _pickAndSendImage(source);
    }
  }

  Future<void> _respondToRequest(bool accept) async {
    await widget.repository.respondToMessageRequest(
      chatId: _chatId,
      accept: accept,
    );
    await _loadChat();
    if (!accept && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _toggleMute() async {
    final currentlyMuted = _conversation?.isMutedFor(widget.myUid) ?? false;
    await widget.repository.toggleMuteConversation(
      chatId: _chatId,
      myUid: widget.myUid,
      muted: !currentlyMuted,
    );
    await _loadChat();
  }

  Future<void> _toggleBlock() async {
    final l10n = context.l10n;
    if (_iBlockedPeer) {
      await widget.repository.unblockUser(
        myUid: widget.myUid,
        targetUid: widget.peer.uid,
      );
      await _loadChat();
    } else {
      await widget.repository.blockUser(
        myUid: widget.myUid,
        targetUid: widget.peer.uid,
      );
      if (!mounted) return;
      _toast(l10n.commBlockedToast);
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _showMessageActions(CommunityChatMessage msg) async {
    final l10n = context.l10n;
    final isMine = msg.senderId == widget.myUid;
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded),
              title: Text(l10n.commDeleteForMe),
              onTap: () => Navigator.of(ctx).pop('delete_me'),
            ),
            if (isMine)
              ListTile(
                leading: Icon(
                  Icons.delete_forever_rounded,
                  color: Theme.of(ctx).colorScheme.error,
                ),
                title: Text(
                  l10n.commDeleteForEveryone,
                  style: TextStyle(color: Theme.of(ctx).colorScheme.error),
                ),
                onTap: () => Navigator.of(ctx).pop('delete_all'),
              )
            else
              ListTile(
                leading: Icon(
                  Icons.flag_outlined,
                  color: Theme.of(ctx).colorScheme.error,
                ),
                title: Text(l10n.commReportUser),
                onTap: () => Navigator.of(ctx).pop('report'),
              ),
          ],
        ),
      ),
    );

    if (!mounted || action == null) return;
    if (action == 'delete_me') {
      await widget.repository.deleteMessageForMe(
        chatId: _chatId,
        messageId: msg.id,
        myUid: widget.myUid,
      );
      await _loadChat();
    } else if (action == 'delete_all') {
      await widget.repository.deleteMessageForEveryone(
        chatId: _chatId,
        messageId: msg.id,
      );
      await _loadChat();
    } else if (action == 'report') {
      await showCommunityReportDialog(
        context: context,
        repository: widget.repository,
        reporterUid: widget.myUid,
        targetType: 'message',
        targetId: '${_chatId}_${msg.id}',
      );
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isMuted = _conversation?.isMutedFor(widget.myUid) ?? false;
    final isPendingIncoming =
        _conversation?.isPendingIncomingFor(widget.myUid) ?? false;
    final canCompose = !_iBlockedPeer && widget.peer.allowMessages;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CommunityAvatar(
              initials: widget.peer.initials,
              photoUrl: widget.peer.visiblePhotoUrl,
              radius: 18,
              accentColor: widget.peer.healthGoals.first.accentColor,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.peer.visibleName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${widget.peer.country.flag} ${widget.peer.city.isNotEmpty ? widget.peer.city : widget.peer.country.label}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            key: const Key('comm_chat_menu_button'),
            onSelected: (value) async {
              if (value == 'mute') {
                await _toggleMute();
              } else if (value == 'report') {
                await showCommunityReportDialog(
                  context: context,
                  repository: widget.repository,
                  reporterUid: widget.myUid,
                  targetType: 'profile',
                  targetId: widget.peer.uid,
                );
              } else if (value == 'block') {
                await _toggleBlock();
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'mute',
                child: Row(
                  children: [
                    Icon(
                      isMuted
                          ? Icons.notifications_active_outlined
                          : Icons.notifications_off_outlined,
                      size: 19,
                    ),
                    const SizedBox(width: 10),
                    Text(isMuted ? l10n.commUnmuteChat : l10n.commMuteChat),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.flag_outlined, size: 19, color: colorScheme.error),
                    const SizedBox(width: 10),
                    Text(l10n.commReportUser),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'block',
                child: Row(
                  children: [
                    Icon(Icons.block_rounded, size: 19, color: colorScheme.error),
                    const SizedBox(width: 10),
                    Text(
                      _iBlockedPeer ? l10n.commUnblockUser : l10n.commBlockUser,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Peer-support medical safety notice
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: colorScheme.primaryContainer.withValues(alpha: 0.4),
            child: Row(
              children: [
                Icon(
                  Icons.health_and_safety_outlined,
                  size: 17,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.commSafetyBanner,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Incoming Message Request Approval banner
          if (isPendingIncoming)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(12, 10, 12, 4),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.secondary.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.commRequestBannerTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.commRequestBannerBody,
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          key: const Key('comm_request_accept_button'),
                          onPressed: () => _respondToRequest(true),
                          child: Text(l10n.commRequestAccept),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          key: const Key('comm_request_decline_button'),
                          onPressed: () => _respondToRequest(false),
                          child: Text(l10n.commRequestDecline),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Messages List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            l10n.commChatPlaceholder,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isMine = msg.senderId == widget.myUid;
                          final timeStr = DateFormat('HH:mm').format(msg.sentAt);
                          return Align(
                            alignment: isMine
                                ? AlignmentDirectional.centerEnd
                                : AlignmentDirectional.centerStart,
                            child: GestureDetector(
                              onLongPress: () => _showMessageActions(msg),
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.76,
                                ),
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isMine
                                      ? colorScheme.primary
                                      : colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(18),
                                    topRight: const Radius.circular(18),
                                    bottomLeft:
                                        Radius.circular(isMine ? 18 : 4),
                                    bottomRight:
                                        Radius.circular(isMine ? 4 : 18),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (msg.hasImage) ...[
                                      CommunityImagePreview(
                                        imageUrl: msg.imageUrl!,
                                      ),
                                      if (msg.text.isNotEmpty)
                                        const SizedBox(height: 8),
                                    ],
                                    if (msg.text.isNotEmpty)
                                      Align(
                                        alignment: AlignmentDirectional.centerStart,
                                        child: Text(
                                          msg.text,
                                          style: TextStyle(
                                            color: isMine
                                                ? Colors.white
                                                : colorScheme.onSurface,
                                            fontSize: 15,
                                            height: 1.35,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          timeStr,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isMine
                                                ? Colors.white70
                                                : colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        if (isMine) ...[
                                          const SizedBox(width: 4),
                                          Icon(
                                            msg.isRead
                                                ? Icons.done_all_rounded
                                                : Icons.done_rounded,
                                            size: 14,
                                            color: Colors.white70,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),

          // Composer Bar
          if (!canCompose)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  _iBlockedPeer
                      ? l10n.commBlockedNotice
                      : l10n.commMessagesDisabled,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.45),
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    IconButton(
                      key: const Key('comm_chat_attach_photo_button'),
                      tooltip: l10n.commAttachPhoto,
                      onPressed: _uploadingImage ? null : _openImageSourceSheet,
                      icon: _uploadingImage
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add_photo_alternate_outlined),
                    ),
                    Expanded(
                      child: TextField(
                        key: const Key('comm_chat_input_field'),
                        controller: _textController,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendTextOrImage(),
                        decoration: InputDecoration(
                          hintText: l10n.commChatPlaceholder,
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.55),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(22),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    FilledButton(
                      key: const Key('comm_chat_send_button'),
                      style: FilledButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(12),
                      ),
                      onPressed: _sending ? null : _sendTextOrImage,
                      child: const Icon(Icons.send_rounded, size: 20),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
