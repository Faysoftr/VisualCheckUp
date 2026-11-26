import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:visualcheckup/core/l10n/l10n_extensions.dart';
import 'package:visualcheckup/core/theme/app_theme.dart';
import 'package:visualcheckup/features/community/data/support_group_repository.dart';
import 'package:visualcheckup/features/community/data/wellness_wall_repository.dart';
import 'package:visualcheckup/features/community/domain/health_community_models.dart';
import 'package:visualcheckup/features/community/domain/support_group_models.dart';
import 'package:visualcheckup/features/community/domain/wellness_wall_models.dart';
import 'package:visualcheckup/features/community/presentation/widgets/community_avatar_and_report.dart';

/// Experience & Q&A Wall tab wired to [WellnessWallRepository].
class CommunityWellnessWallTab extends StatefulWidget {
  const CommunityWellnessWallTab({
    super.key,
    required this.myUid,
    required this.myDisplayName,
    required this.myCountryCode,
    required this.repository,
  });

  final String myUid;
  final String myDisplayName;
  final String myCountryCode;
  final WellnessWallRepository repository;

  @override
  State<CommunityWellnessWallTab> createState() =>
      _CommunityWellnessWallTabState();
}

class _CommunityWellnessWallTabState extends State<CommunityWellnessWallTab> {
  bool _loading = true;
  ChronicCondition? _conditionFilter;
  List<WellnessWallPost> _posts = const [];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    final posts = await widget.repository.loadPosts(
      conditionFilter: _conditionFilter,
    );
    if (!mounted) return;
    setState(() {
      _posts = posts;
      _loading = false;
    });
  }

  Future<void> _toggleLike(WellnessWallPost post) async {
    final updated = await widget.repository.toggleLike(
      postId: post.id,
      uid: widget.myUid,
    );
    if (updated == null || !mounted) return;
    setState(() {
      _posts = _posts.map((p) => p.id == updated.id ? updated : p).toList();
    });
  }

  Future<void> _openCreatePostDialog() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => _CreateWallPostSheet(
        initialCondition: _conditionFilter,
        onPublish: (title, body, condition) => widget.repository.createPost(
          authorUid: widget.myUid,
          authorName: widget.myDisplayName,
          authorCountryCode: widget.myCountryCode,
          condition: condition,
          title: title,
          body: body,
        ),
      ),
    );
    if (created == true) {
      await _loadPosts();
    }
  }

  Future<void> _openCommentsSheet(WellnessWallPost post) async {
    final initialComments = await widget.repository.loadComments(post.id);
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => _WallCommentsSheet(
        initialComments: initialComments,
        onAddComment: (text) async {
          final added = await widget.repository.addComment(
            postId: post.id,
            authorUid: widget.myUid,
            authorName: widget.myDisplayName,
            text: text,
          );
          if (added == null) return null;
          return widget.repository.loadComments(post.id);
        },
      ),
    );
    await _loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.commWallTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              FilledButton.icon(
                key: const Key('comm_wall_new_post_btn'),
                onPressed: _openCreatePostDialog,
                icon: const Icon(Icons.edit_note_rounded, size: 18),
                label: Text(l10n.commWallNewPost),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(l10n.commFilterAllConditions),
                  selected: _conditionFilter == null,
                  onSelected: (_) {
                    setState(() => _conditionFilter = null);
                    _loadPosts();
                  },
                ),
              ),
              for (final cond in ChronicCondition.values)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    avatar: Icon(cond.icon, size: 15, color: cond.accentColor),
                    label: Text(cond.localizedLabel(l10n)),
                    selected: _conditionFilter == cond,
                    onSelected: (_) {
                      setState(
                        () => _conditionFilter =
                            _conditionFilter == cond ? null : cond,
                      );
                      _loadPosts();
                    },
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: _posts.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      l10n.commWallEmpty,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
                  itemCount: _posts.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, idx) {
                    final post = _posts[idx];
                    final liked = post.isLikedBy(widget.myUid);
                    final initials = post.authorName.trim().isNotEmpty
                        ? post.authorName.trim().substring(0, 1).toUpperCase()
                        : 'U';

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CommunityAvatar(
                                  initials: initials,
                                  radius: 20,
                                  accentColor: post.condition?.accentColor ??
                                      AppTheme.primaryTeal,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${post.authorName} ${post.country.flag}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13.5,
                                        ),
                                      ),
                                      Text(
                                        DateFormat('dd MMM, HH:mm')
                                            .format(post.createdAt),
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (post.hasDoctorReply)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F766E)
                                          .withValues(alpha: 0.14),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.verified_rounded,
                                          size: 13,
                                          color: Color(0xFF0F766E),
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          l10n.commWallDoctorReplyBadge,
                                          style: const TextStyle(
                                            color: Color(0xFF0F766E),
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            if (post.condition != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: post.condition!.accentColor
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  post.condition!.localizedLabel(l10n),
                                  style: TextStyle(
                                    color: post.condition!.accentColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              post.title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              post.body,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Divider(height: 1),
                            Row(
                              children: [
                                TextButton.icon(
                                  key: Key('comm_wall_like_${post.id}'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: liked
                                        ? const Color(0xFFE11D48)
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                  onPressed: () => _toggleLike(post),
                                  icon: Icon(
                                    liked
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    size: 18,
                                  ),
                                  label: Text('${post.likesCount}'),
                                ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  key: Key('comm_wall_comments_${post.id}'),
                                  onPressed: () => _openCommentsSheet(post),
                                  icon: const Icon(
                                    Icons.chat_bubble_outline_rounded,
                                    size: 17,
                                  ),
                                  label: Text(
                                    '${post.commentCount} ${l10n.commWallCommentsTitle}',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// Chronic Condition & Wellness Support Groups tab wired to
/// [SupportGroupRepository].
class CommunitySupportGroupsTab extends StatefulWidget {
  const CommunitySupportGroupsTab({
    super.key,
    required this.myUid,
    required this.myDisplayName,
    required this.myCountryCode,
    required this.myLanguageCode,
    required this.repository,
  });

  final String myUid;
  final String myDisplayName;
  final String myCountryCode;
  final String myLanguageCode;
  final SupportGroupRepository repository;

  @override
  State<CommunitySupportGroupsTab> createState() =>
      _CommunitySupportGroupsTabState();
}

class _CommunitySupportGroupsTabState extends State<CommunitySupportGroupsTab> {
  bool _loading = true;
  ChronicCondition? _conditionFilter;
  List<HealthSupportGroup> _groups = const [];

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final groups = await widget.repository.loadGroups(
      conditionFilter: _conditionFilter,
    );
    if (!mounted) return;
    setState(() {
      _groups = groups;
      _loading = false;
    });
  }

  Future<void> _toggleJoin(HealthSupportGroup group) async {
    final updated = await widget.repository.toggleMembership(
      groupId: group.id,
      uid: widget.myUid,
    );
    if (updated == null || !mounted) return;
    setState(() {
      _groups = _groups.map((g) => g.id == updated.id ? updated : g).toList();
    });
  }

  Future<void> _openGroupChat(HealthSupportGroup group) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SupportGroupChatScreen(
          group: group,
          myUid: widget.myUid,
          myDisplayName: widget.myDisplayName,
          repository: widget.repository,
        ),
      ),
    );
    await _loadGroups();
  }

  Future<void> _openCreateGroupSheet() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => _CreateSupportGroupSheet(
        initialCondition: _conditionFilter,
        onCreate: (name, desc, condition) => widget.repository.createGroup(
          name: name,
          description: desc,
          condition: condition,
          countryCode: widget.myCountryCode,
          languageCode: widget.myLanguageCode,
          creatorUid: widget.myUid,
          creatorName: widget.myDisplayName,
        ),
      ),
    );
    if (created == true) {
      await _loadGroups();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.commGroupsTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              FilledButton.icon(
                key: const Key('comm_groups_create_btn'),
                onPressed: _openCreateGroupSheet,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(l10n.commGroupsCreate),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(l10n.commFilterAllConditions),
                  selected: _conditionFilter == null,
                  onSelected: (_) {
                    setState(() => _conditionFilter = null);
                    _loadGroups();
                  },
                ),
              ),
              for (final cond in ChronicCondition.values)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    avatar: Icon(cond.icon, size: 15, color: cond.accentColor),
                    label: Text(cond.localizedLabel(l10n)),
                    selected: _conditionFilter == cond,
                    onSelected: (_) {
                      setState(
                        () => _conditionFilter =
                            _conditionFilter == cond ? null : cond,
                      );
                      _loadGroups();
                    },
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: _groups.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      l10n.commGroupsEmpty,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
                  itemCount: _groups.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, idx) {
                    final group = _groups[idx];
                    final joined = group.isMember(widget.myUid);

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor:
                                      group.accentColor.withValues(alpha: 0.14),
                                  child: Icon(
                                    group.icon,
                                    color: group.accentColor,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        group.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${group.country.flag} ${l10n.commGroupsMembersCount(group.memberCount)}',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (group.description.trim().isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                group.description.trim(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  height: 1.4,
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: joined
                                      ? OutlinedButton.icon(
                                          key: Key(
                                            'comm_group_join_${group.id}',
                                          ),
                                          onPressed: () => _toggleJoin(group),
                                          icon: const Icon(
                                            Icons.check_rounded,
                                            size: 17,
                                          ),
                                          label: Text(l10n.commGroupsJoined),
                                        )
                                      : FilledButton.tonalIcon(
                                          key: Key(
                                            'comm_group_join_${group.id}',
                                          ),
                                          onPressed: () => _toggleJoin(group),
                                          icon: const Icon(
                                            Icons.group_add_outlined,
                                            size: 17,
                                          ),
                                          label: Text(l10n.commGroupsJoin),
                                        ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: FilledButton.icon(
                                    key: Key('comm_group_chat_${group.id}'),
                                    onPressed: () => _openGroupChat(group),
                                    icon: const Icon(
                                      Icons.forum_outlined,
                                      size: 17,
                                    ),
                                    label: Text(l10n.commGroupsOpenChat),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// Group chat room screen for a [HealthSupportGroup].
class SupportGroupChatScreen extends StatefulWidget {
  const SupportGroupChatScreen({
    super.key,
    required this.group,
    required this.myUid,
    required this.myDisplayName,
    required this.repository,
  });

  final HealthSupportGroup group;
  final String myUid;
  final String myDisplayName;
  final SupportGroupRepository repository;

  @override
  State<SupportGroupChatScreen> createState() => _SupportGroupChatScreenState();
}

class _SupportGroupChatScreenState extends State<SupportGroupChatScreen> {
  final TextEditingController _inputCtrl = TextEditingController();
  bool _loading = true;
  List<SupportGroupMessage> _messages = const [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    final msgs = await widget.repository.loadMessages(widget.group.id);
    if (!mounted) return;
    setState(() {
      _messages = msgs;
      _loading = false;
    });
  }

  Future<void> _send() async {
    final l10n = context.l10n;
    final txt = _inputCtrl.text.trim();
    if (txt.isEmpty) return;
    final sent = await widget.repository.sendMessage(
      groupId: widget.group.id,
      senderUid: widget.myUid,
      senderName: widget.myDisplayName,
      text: txt,
    );
    if (!mounted) return;
    if (sent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.safetyContentBlocked)),
      );
      return;
    }
    _inputCtrl.clear();
    await _loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.group.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            Text(
              l10n.commGroupsMembersCount(widget.group.memberCount),
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    itemCount: _messages.length,
                    itemBuilder: (_, idx) {
                      final msg = _messages[idx];
                      final isMe = msg.senderUid == widget.myUid;
                      return Align(
                        alignment: isMe
                            ? AlignmentDirectional.centerEnd
                            : AlignmentDirectional.centerStart,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          constraints: const BoxConstraints(maxWidth: 300),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe
                                ? colorScheme.primary
                                : colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isMe)
                                Text(
                                  msg.senderName,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              Text(
                                msg.text,
                                style: TextStyle(
                                  color: isMe
                                      ? colorScheme.onPrimary
                                      : colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                DateFormat('HH:mm').format(msg.sentAt),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isMe
                                      ? colorScheme.onPrimary
                                          .withValues(alpha: 0.75)
                                      : colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: const Key('comm_group_chat_input'),
                      controller: _inputCtrl,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: l10n.commChatPlaceholder,
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    key: const Key('comm_group_chat_send'),
                    onPressed: _send,
                    icon: const Icon(Icons.send_rounded, size: 19),
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

class _CreateWallPostSheet extends StatefulWidget {
  const _CreateWallPostSheet({
    required this.initialCondition,
    required this.onPublish,
  });

  final ChronicCondition? initialCondition;
  final Future<WellnessWallPost?> Function(
    String title,
    String body,
    ChronicCondition? condition,
  ) onPublish;

  @override
  State<_CreateWallPostSheet> createState() => _CreateWallPostSheetState();
}

class _CreateWallPostSheetState extends State<_CreateWallPostSheet> {
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _bodyCtrl = TextEditingController();
  ChronicCondition? _selectedCondition;

  @override
  void initState() {
    super.initState();
    _selectedCondition = widget.initialCondition;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        4,
        16,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.commWallNewPost,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('comm_wall_title_input'),
              controller: _titleCtrl,
              maxLength: 120,
              decoration: InputDecoration(
                hintText: l10n.commWallPostTitleHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('comm_wall_body_input'),
              controller: _bodyCtrl,
              maxLines: 4,
              maxLength: 1000,
              decoration: InputDecoration(
                hintText: l10n.commWallPostBodyHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<ChronicCondition?>(
              initialValue: _selectedCondition,
              decoration: InputDecoration(
                labelText: l10n.commFieldChronicConditions,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              items: [
                DropdownMenuItem<ChronicCondition?>(
                  value: null,
                  child: Text(l10n.commFilterAllConditions),
                ),
                for (final c in ChronicCondition.values)
                  DropdownMenuItem<ChronicCondition?>(
                    value: c,
                    child: Text(c.localizedLabel(l10n)),
                  ),
              ],
              onChanged: (v) => setState(() => _selectedCondition = v),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                key: const Key('comm_wall_publish_btn'),
                onPressed: () async {
                  final t = _titleCtrl.text.trim();
                  final b = _bodyCtrl.text.trim();
                  if (t.isEmpty || b.isEmpty) return;
                  final res = await widget.onPublish(t, b, _selectedCondition);
                  if (!context.mounted) return;
                  if (res == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.safetyContentBlocked)),
                    );
                    return;
                  }
                  Navigator.of(context).pop(true);
                },
                icon: const Icon(Icons.send_rounded, size: 18),
                label: Text(l10n.commWallPublishBtn),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WallCommentsSheet extends StatefulWidget {
  const _WallCommentsSheet({
    required this.initialComments,
    required this.onAddComment,
  });

  final List<WellnessWallComment> initialComments;
  final Future<List<WellnessWallComment>?> Function(String text) onAddComment;

  @override
  State<_WallCommentsSheet> createState() => _WallCommentsSheetState();
}

class _WallCommentsSheetState extends State<_WallCommentsSheet> {
  final TextEditingController _commentCtrl = TextEditingController();
  late List<WellnessWallComment> _comments;

  @override
  void initState() {
    super.initState();
    _comments = widget.initialComments;
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        4,
        16,
        MediaQuery.of(context).viewInsets.bottom + 18,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${l10n.commWallCommentsTitle} (${_comments.length})',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 320),
            child: _comments.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        l10n.commWallEmpty,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: _comments.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, idx) {
                      final c = _comments[idx];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: c.isVerifiedDoctor
                              ? const Color(0xFF0F766E).withValues(alpha: 0.1)
                              : colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(14),
                          border: c.isVerifiedDoctor
                              ? Border.all(
                                  color: const Color(0xFF0F766E)
                                      .withValues(alpha: 0.35),
                                )
                              : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    c.authorName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                if (c.isVerifiedDoctor)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F766E),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      l10n.doctorVerifiedBadge,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              c.text,
                              style:
                                  theme.textTheme.bodySmall?.copyWith(height: 1.4),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('comm_wall_comment_input'),
                  controller: _commentCtrl,
                  decoration: InputDecoration(
                    hintText: l10n.commWallCommentHint,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                key: const Key('comm_wall_comment_send'),
                onPressed: () async {
                  final txt = _commentCtrl.text.trim();
                  if (txt.isEmpty) return;
                  final refreshed = await widget.onAddComment(txt);
                  if (!context.mounted) return;
                  if (refreshed == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.safetyContentBlocked)),
                    );
                    return;
                  }
                  _commentCtrl.clear();
                  setState(() => _comments = refreshed);
                },
                icon: const Icon(Icons.send_rounded, size: 19),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CreateSupportGroupSheet extends StatefulWidget {
  const _CreateSupportGroupSheet({
    required this.initialCondition,
    required this.onCreate,
  });

  final ChronicCondition? initialCondition;
  final Future<HealthSupportGroup?> Function(
    String name,
    String desc,
    ChronicCondition? condition,
  ) onCreate;

  @override
  State<_CreateSupportGroupSheet> createState() =>
      _CreateSupportGroupSheetState();
}

class _CreateSupportGroupSheetState extends State<_CreateSupportGroupSheet> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  ChronicCondition? _selectedCondition;

  @override
  void initState() {
    super.initState();
    _selectedCondition = widget.initialCondition;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        4,
        16,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.commGroupsCreate,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('comm_group_name_input'),
              controller: _nameCtrl,
              maxLength: 80,
              decoration: InputDecoration(
                hintText: l10n.commGroupsNameHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('comm_group_desc_input'),
              controller: _descCtrl,
              maxLines: 3,
              maxLength: 300,
              decoration: InputDecoration(
                hintText: l10n.commGroupsDescHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<ChronicCondition?>(
              initialValue: _selectedCondition,
              decoration: InputDecoration(
                labelText: l10n.commFieldChronicConditions,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              items: [
                DropdownMenuItem<ChronicCondition?>(
                  value: null,
                  child: Text(l10n.commFilterAllConditions),
                ),
                for (final c in ChronicCondition.values)
                  DropdownMenuItem<ChronicCondition?>(
                    value: c,
                    child: Text(c.localizedLabel(l10n)),
                  ),
              ],
              onChanged: (v) => setState(() => _selectedCondition = v),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                key: const Key('comm_group_save_btn'),
                onPressed: () async {
                  final n = _nameCtrl.text.trim();
                  final d = _descCtrl.text.trim();
                  if (n.isEmpty) return;
                  final res = await widget.onCreate(n, d, _selectedCondition);
                  if (!context.mounted) return;
                  if (res == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.safetyContentBlocked)),
                    );
                    return;
                  }
                  Navigator.of(context).pop(true);
                },
                icon: const Icon(Icons.group_add_rounded, size: 18),
                label: Text(l10n.commGroupsCreate),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
