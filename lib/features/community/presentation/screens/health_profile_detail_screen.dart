import 'package:flutter/material.dart';
import 'package:visualcheckup/core/l10n/l10n_extensions.dart';
import 'package:visualcheckup/core/l10n/locale_controller.dart';
import 'package:visualcheckup/core/theme/app_theme.dart';
import 'package:visualcheckup/features/community/data/community_image_upload_service.dart';
import 'package:visualcheckup/features/community/data/health_community_repository.dart';
import 'package:visualcheckup/features/community/domain/health_community_models.dart';
import 'package:visualcheckup/features/community/presentation/screens/health_chat_screen.dart';
import 'package:visualcheckup/features/community/presentation/widgets/community_avatar_and_report.dart';

/// Detailed public view of another member's Health Community profile, with
/// Profile Like toggle, Direct Message entry, Report, and Block actions.
class HealthProfileDetailScreen extends StatefulWidget {
  const HealthProfileDetailScreen({
    super.key,
    required this.profile,
    required this.myUid,
    required this.myDisplayName,
    this.myPhotoUrl,
    required this.repository,
    this.uploadService,
    this.photoPicker,
  });

  final HealthCommunityProfile profile;
  final String myUid;
  final String myDisplayName;
  final String? myPhotoUrl;
  final HealthCommunityRepository repository;
  final CommunityImageUploadService? uploadService;
  final CommunityPhotoPicker? photoPicker;

  @override
  State<HealthProfileDetailScreen> createState() =>
      _HealthProfileDetailScreenState();
}

class _HealthProfileDetailScreenState extends State<HealthProfileDetailScreen> {
  late HealthCommunityProfile _profile;
  bool _liking = false;
  bool _blocked = false;

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
    _loadBlockState();
  }

  Future<void> _loadBlockState() async {
    final blocks = await widget.repository.loadBlockedUsers(widget.myUid);
    if (!mounted) return;
    setState(() => _blocked = blocks.contains(_profile.uid));
  }

  Future<void> _toggleLike() async {
    if (_liking) return;
    setState(() => _liking = true);
    final updated = await widget.repository.toggleProfileLike(
      targetUid: _profile.uid,
      myUid: widget.myUid,
    );
    if (!mounted) return;
    setState(() {
      if (updated != null) _profile = updated;
      _liking = false;
    });
  }

  Future<void> _openChat() async {
    final blockedNow = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => HealthChatScreen(
          myUid: widget.myUid,
          myDisplayName: widget.myDisplayName,
          myPhotoUrl: widget.myPhotoUrl,
          peer: _profile,
          repository: widget.repository,
          uploadService: widget.uploadService,
          photoPicker: widget.photoPicker,
        ),
      ),
    );
    if (blockedNow == true && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _toggleBlock() async {
    final l10n = context.l10n;
    if (_blocked) {
      await widget.repository.unblockUser(
        myUid: widget.myUid,
        targetUid: _profile.uid,
      );
      if (!mounted) return;
      setState(() => _blocked = false);
    } else {
      await widget.repository.blockUser(
        myUid: widget.myUid,
        targetUid: _profile.uid,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.commBlockedToast)),
      );
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isLiked = _profile.isLikedBy(widget.myUid);
    final accent = _profile.healthGoals.first.accentColor;
    final langName = LocaleController.optionForCode(_profile.languageCode).nativeName;

    return Scaffold(
      appBar: AppBar(
        title: Text(_profile.visibleName),
        actions: [
          PopupMenuButton<String>(
            key: const Key('comm_profile_safety_menu'),
            onSelected: (value) async {
              if (value == 'report') {
                await showCommunityReportDialog(
                  context: context,
                  repository: widget.repository,
                  reporterUid: widget.myUid,
                  targetType: 'profile',
                  targetId: _profile.uid,
                );
              } else if (value == 'block') {
                await _toggleBlock();
              }
            },
            itemBuilder: (_) => [
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
                    Text(_blocked ? l10n.commUnblockUser : l10n.commBlockUser),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? const [Color(0xFF133636), Color(0xFF0E2223)]
                    : const [AppTheme.primaryTeal, AppTheme.secondaryMint],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryTeal.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                CommunityAvatar(
                  initials: _profile.initials,
                  photoUrl: _profile.visiblePhotoUrl,
                  radius: 40,
                  accentColor: Colors.white,
                ),
                const SizedBox(height: 12),
                Text(
                  _profile.visibleName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (!_profile.hideRealName && _profile.nickname.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    '@${_profile.nickname}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: [
                    _HeaderPill(
                      text:
                          '${_profile.country.flag} ${_profile.city.isNotEmpty ? '${_profile.city}, ' : ''}${_profile.country.label}',
                    ),
                    _HeaderPill(text: '🌐 $langName'),
                    _HeaderPill(
                      text: '❤️ ${l10n.commLikesCount(_profile.likesCount)}',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Primary Actions: Like & Send Message
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: OutlinedButton.icon(
                    key: const Key('comm_detail_like_button'),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isLiked
                          ? const Color(0xFFE11D48).withValues(alpha: 0.12)
                          : null,
                      foregroundColor: isLiked
                          ? const Color(0xFFE11D48)
                          : colorScheme.onSurface,
                      side: BorderSide(
                        color: isLiked
                            ? const Color(0xFFE11D48)
                            : colorScheme.outlineVariant,
                      ),
                    ),
                    onPressed: _liking ? null : _toggleLike,
                    icon: Icon(
                      isLiked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                    ),
                    label: Text(
                      isLiked ? l10n.commUnlikeAction : l10n.commLikeAction,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: FilledButton.icon(
                    key: const Key('comm_detail_message_button'),
                    onPressed:
                        (_profile.allowMessages && !_blocked) ? _openChat : null,
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                    label: Text(
                      l10n.commSendMessage,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (!_profile.allowMessages) ...[
            const SizedBox(height: 8),
            Text(
              l10n.commMessagesDisabled,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Health Goals Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.favorite_rounded, size: 18, color: accent),
                      const SizedBox(width: 8),
                      Text(
                        l10n.commFieldGoals,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final goal in _profile.healthGoals)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: goal.accentColor.withValues(alpha: 0.13),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: goal.accentColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                goal.icon,
                                size: 15,
                                color: goal.accentColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                goal.localizedLabel(l10n),
                                style: TextStyle(
                                  color: goal.accentColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Daily Wellness Focus
          if (_profile.dailyFocus.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(
                    Icons.wb_sunny_outlined,
                    color: colorScheme.primary,
                  ),
                ),
                title: Text(
                  l10n.commFieldDailyFocus,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  _profile.dailyFocus.trim(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],

          // Bio / Health Journey
          if (_profile.showBio && _profile.bio.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.format_quote_rounded,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.commFieldBio,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _profile.bio.trim(),
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
