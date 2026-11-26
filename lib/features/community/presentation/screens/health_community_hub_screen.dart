import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:visualcheckup/core/l10n/l10n_extensions.dart';
import 'package:visualcheckup/core/theme/app_theme.dart';
import 'package:visualcheckup/features/admin/data/admin_repository.dart';
import 'package:visualcheckup/features/admin/domain/admin_models.dart';
import 'package:visualcheckup/features/admin/presentation/widgets/global_announcement_and_promo_banners.dart';
import 'package:visualcheckup/features/auth/domain/auth_user.dart';
import 'package:visualcheckup/features/community/data/community_image_upload_service.dart';
import 'package:visualcheckup/features/community/data/health_community_repository.dart';
import 'package:visualcheckup/features/community/data/support_group_repository.dart';
import 'package:visualcheckup/features/community/data/wellness_wall_repository.dart';
import 'package:visualcheckup/features/community/domain/health_community_models.dart';
import 'package:visualcheckup/features/community/presentation/screens/health_chat_screen.dart';
import 'package:visualcheckup/features/community/presentation/screens/health_profile_detail_screen.dart';
import 'package:visualcheckup/features/community/presentation/widgets/community_avatar_and_report.dart';
import 'package:visualcheckup/features/community/presentation/widgets/community_wall_and_groups_tabs.dart';
import 'package:visualcheckup/features/community/presentation/widgets/social_profile_view.dart';

/// Main Global Health Community hub for VisualCheckUp (Social Formula Bank style).
///
/// 5 social tabs:
/// 1. Discover — worldwide health buddies with Online Now, Same Condition,
///    Condition, Goal & Country filters, plus Like, Friend & Message actions.
/// 2. Wall — Experience & Q&A Wall with Verified Doctor replies.
/// 3. Groups — Chronic condition & wellness support groups with live group chat.
/// 4. Messages — 1-on-1 conversations and Message Requests.
/// 5. My Profile — Social Profile Showcase, interactive stats, mood & editor.
class HealthCommunityHubScreen extends StatefulWidget {
  const HealthCommunityHubScreen({
    super.key,
    required this.currentUser,
    required this.repository,
    this.adminRepository,
    this.wellnessWallRepository,
    this.supportGroupRepository,
    this.uploadService,
    this.photoPicker,
    this.urlLauncher,
    this.initialTabIndex = 0,
  });

  final AuthUser currentUser;
  final HealthCommunityRepository repository;
  final AdminRepository? adminRepository;
  final WellnessWallRepository? wellnessWallRepository;
  final SupportGroupRepository? supportGroupRepository;
  final CommunityImageUploadService? uploadService;
  final CommunityPhotoPicker? photoPicker;
  final CommunityUrlLauncher? urlLauncher;
  final int initialTabIndex;

  @override
  State<HealthCommunityHubScreen> createState() =>
      _HealthCommunityHubScreenState();
}

class _HealthCommunityHubScreenState extends State<HealthCommunityHubScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final CommunityImageUploadService _uploadService;
  late final WellnessWallRepository _wallRepository;
  late final SupportGroupRepository _groupRepository;

  final TextEditingController _searchController = TextEditingController();

  bool _loading = true;
  HealthCommunityProfile? _myProfile;
  List<HealthCommunityProfile> _discoverList = const [];
  List<CommunityConversation> _conversations = const [];
  Map<String, FriendshipStatus> _friendStatusByPeerUid = const {};

  HealthGoalTag? _goalFilter;
  ChronicCondition? _conditionFilter;
  bool _sameConditionOnly = false;
  bool _onlineOnly = false;
  String _countryFilter = 'ALL';

  String get _myUid => widget.currentUser.id;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 4),
    );
    _uploadService =
        widget.uploadService ?? R2CommunityImageUploadService.instance;
    _wallRepository = widget.wellnessWallRepository ??
        WellnessWallRepository(useFirebase: widget.repository.useFirebase);
    _groupRepository = widget.supportGroupRepository ??
        SupportGroupRepository(useFirebase: widget.repository.useFirebase);
    widget.repository.updateOnlinePresence(_myUid, isOnline: true);
    _loadAll();
  }

  @override
  void dispose() {
    widget.repository.updateOnlinePresence(_myUid, isOnline: false);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    final myProfile = await widget.repository.loadMyProfile(_myUid);
    final discover = await widget.repository.discoverProfiles(
      myUid: _myUid,
      goalFilter: _goalFilter,
      conditionFilter: _conditionFilter,
      sameConditionAsMe: _sameConditionOnly,
      onlineOnly: _onlineOnly,
      countryCodeFilter: _countryFilter,
      searchQuery: _searchController.text,
    );
    final convos = await widget.repository.loadConversations(_myUid);
    final friendships = await widget.repository.loadFriendships(_myUid);
    final friendMap = <String, FriendshipStatus>{};
    for (final f in friendships) {
      final peerUid = f.peerIdFor(_myUid);
      if (peerUid.isNotEmpty) {
        friendMap[peerUid] = f.status;
      }
    }
    if (!mounted) return;
    setState(() {
      _myProfile = myProfile;
      _discoverList = discover;
      _conversations = convos;
      _friendStatusByPeerUid = friendMap;
      _loading = false;
    });
  }

  Future<void> _refreshDiscover() async {
    final discover = await widget.repository.discoverProfiles(
      myUid: _myUid,
      goalFilter: _goalFilter,
      conditionFilter: _conditionFilter,
      sameConditionAsMe: _sameConditionOnly,
      onlineOnly: _onlineOnly,
      countryCodeFilter: _countryFilter,
      searchQuery: _searchController.text,
    );
    if (!mounted) return;
    setState(() => _discoverList = discover);
  }

  Future<void> _toggleQuickLike(HealthCommunityProfile target) async {
    final updated = await widget.repository.toggleProfileLike(
      targetUid: target.uid,
      myUid: _myUid,
    );
    if (updated == null || !mounted) return;
    setState(() {
      _discoverList = _discoverList
          .map((p) => p.uid == updated.uid ? updated : p)
          .toList();
    });
  }

  Future<void> _toggleFriendRequest(HealthCommunityProfile target) async {
    final currentStatus = _friendStatusByPeerUid[target.uid];
    if (currentStatus != null) {
      final pairId = FriendshipRecord.pairIdFor(_myUid, target.uid);
      await widget.repository.removeFriend(pairId);
      if (!mounted) return;
      setState(() {
        final next = Map<String, FriendshipStatus>.from(_friendStatusByPeerUid);
        next.remove(target.uid);
        _friendStatusByPeerUid = next;
      });
      return;
    }

    final rec = await widget.repository.sendFriendRequest(
      myUid: _myUid,
      myName: _myProfile?.visibleName ?? widget.currentUser.displayName,
      target: target,
    );
    if (rec == null || !mounted) return;
    setState(() {
      _friendStatusByPeerUid = {
        ..._friendStatusByPeerUid,
        target.uid: rec.status,
      };
    });
  }

  Future<void> _openDirectChat(HealthCommunityProfile target) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => HealthChatScreen(
          myUid: _myUid,
          myDisplayName:
              _myProfile?.visibleName ?? widget.currentUser.displayName,
          myPhotoUrl: _myProfile?.visiblePhotoUrl,
          myEmail: widget.currentUser.email,
          peer: target,
          repository: widget.repository,
          uploadService: _uploadService,
          photoPicker: widget.photoPicker,
        ),
      ),
    );
    await _loadAll();
  }

  Future<void> _openProfileDetail(HealthCommunityProfile target) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => HealthProfileDetailScreen(
          profile: target,
          myUid: _myUid,
          myDisplayName:
              _myProfile?.visibleName ?? widget.currentUser.displayName,
          myNickname: _myProfile?.nickname ?? '',
          myPhotoUrl: _myProfile?.visiblePhotoUrl,
          myEmail: widget.currentUser.email,
          repository: widget.repository,
          uploadService: _uploadService,
          photoPicker: widget.photoPicker,
          urlLauncher: widget.urlLauncher,
        ),
      ),
    );
    await _loadAll();
  }

  Future<void> _openConversation(CommunityConversation convo) async {
    final peerId = convo.peerIdFor(_myUid);
    final peerProfile = await widget.repository.getProfile(peerId) ??
        HealthCommunityProfile(
          uid: peerId,
          displayName: convo.peerNameFor(_myUid),
          photoUrl: convo.peerPhotoFor(_myUid),
          updatedAt: convo.lastMessageAt,
        );
    if (!mounted) return;
    await _openDirectChat(peerProfile);
  }

  int get _unreadCount => _conversations
      .where((c) => !c.isMutedFor(_myUid) && c.isUnreadFor(_myUid))
      .length;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.commMenuTitle),
        bottom: TabBar(
          controller: _tabController,
          labelPadding: const EdgeInsets.symmetric(horizontal: 2),
          labelStyle: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          tabs: [
            Tab(
              icon: const Icon(Icons.public_rounded, size: 19),
              text: l10n.commTabDiscover,
            ),
            Tab(
              icon: const Icon(Icons.dynamic_feed_rounded, size: 19),
              text: l10n.commTabWall,
            ),
            Tab(
              icon: const Icon(Icons.groups_rounded, size: 19),
              text: l10n.commTabGroups,
            ),
            Tab(
              icon: _unreadCount > 0
                  ? Badge(
                      label: Text('$_unreadCount'),
                      child: const Icon(Icons.forum_outlined, size: 19),
                    )
                  : const Icon(Icons.forum_outlined, size: 19),
              text: l10n.commTabMessages,
            ),
            Tab(
              icon: const Icon(Icons.person_rounded, size: 19),
              text: l10n.commTabMyProfile,
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDiscoverTab(context),
                CommunityWellnessWallTab(
                  myUid: _myUid,
                  myDisplayName: _myProfile?.visibleName ??
                      widget.currentUser.displayName,
                  myCountryCode: _myProfile?.countryCode ?? 'TR',
                  repository: _wallRepository,
                ),
                CommunitySupportGroupsTab(
                  myUid: _myUid,
                  myDisplayName: _myProfile?.visibleName ??
                      widget.currentUser.displayName,
                  myCountryCode: _myProfile?.countryCode ?? 'TR',
                  myLanguageCode: _myProfile?.languageCode ?? 'tr',
                  repository: _groupRepository,
                ),
                _buildMessagesTab(context),
                SocialProfileView(
                  currentUser: widget.currentUser,
                  repository: widget.repository,
                  uploadService: _uploadService,
                  photoPicker: widget.photoPicker,
                  urlLauncher: widget.urlLauncher,
                  onProfileChanged: _loadAll,
                ),
              ],
            ),
    );
  }

  Widget _buildDiscoverTab(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Compact Search + Country Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('comm_discover_search_field'),
                  controller: _searchController,
                  onChanged: (_) => _refreshDiscover(),
                  decoration: InputDecoration(
                    hintText: l10n.commSearchHint,
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    isDense: true,
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.45),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButtonHideUnderline(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: DropdownButton<String>(
                    key: const Key('comm_country_filter_dropdown'),
                    value: _countryFilter,
                    isDense: true,
                    items: [
                      DropdownMenuItem(
                        value: 'ALL',
                        child: Text('🌍 ${l10n.commFilterAllCountries}'),
                      ),
                      for (final c in CommunityCountryOption.all)
                        if (c.code != 'GLOBAL')
                          DropdownMenuItem(
                            value: c.code,
                            child: Text('${c.flag} ${c.code}'),
                          ),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _countryFilter = v);
                      _refreshDiscover();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        // Quick Peer Match Filters: Online Now, Same Condition, Condition & Goals
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: FilterChip(
                  key: const Key('comm_filter_online_only'),
                  visualDensity: VisualDensity.compact,
                  avatar: Icon(
                    Icons.circle,
                    size: 10,
                    color: _onlineOnly ? Colors.white : const Color(0xFF16A34A),
                  ),
                  label: Text(l10n.commFilterOnlineOnly),
                  selected: _onlineOnly,
                  selectedColor: const Color(0xFF16A34A),
                  labelStyle: TextStyle(
                    color: _onlineOnly ? Colors.white : null,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                  onSelected: (selected) {
                    setState(() => _onlineOnly = selected);
                    _refreshDiscover();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: FilterChip(
                  key: const Key('comm_filter_same_condition'),
                  visualDensity: VisualDensity.compact,
                  avatar: Icon(
                    Icons.medical_information_outlined,
                    size: 15,
                    color: _sameConditionOnly
                        ? Colors.white
                        : const Color(0xFFD97706),
                  ),
                  label: Text(l10n.commFilterSameCondition),
                  selected: _sameConditionOnly,
                  selectedColor: const Color(0xFFD97706),
                  labelStyle: TextStyle(
                    color: _sameConditionOnly ? Colors.white : null,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                  onSelected: (selected) {
                    if (selected &&
                        (_myProfile == null ||
                            !_myProfile!.hasAnyChronicCondition)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.commSameConditionPrompt)),
                      );
                      return;
                    }
                    setState(() => _sameConditionOnly = selected);
                    _refreshDiscover();
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                margin: const EdgeInsets.only(right: 6),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _conditionFilter != null
                      ? _conditionFilter!.accentColor.withValues(alpha: 0.14)
                      : colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(14),
                  border: _conditionFilter != null
                      ? Border.all(
                          color: _conditionFilter!.accentColor
                              .withValues(alpha: 0.5),
                        )
                      : null,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<ChronicCondition?>(
                    key: const Key('comm_condition_filter_dropdown'),
                    value: _conditionFilter,
                    isDense: true,
                    items: [
                      DropdownMenuItem<ChronicCondition?>(
                        value: null,
                        child: Text(
                          '🩺 ${l10n.commFilterAllConditions}',
                          style: const TextStyle(fontSize: 12.5),
                        ),
                      ),
                      for (final cond in ChronicCondition.values)
                        DropdownMenuItem<ChronicCondition?>(
                          value: cond,
                          child: Text(
                            cond.localizedLabel(l10n),
                            style: const TextStyle(fontSize: 12.5),
                          ),
                        ),
                    ],
                    onChanged: (v) {
                      setState(() => _conditionFilter = v);
                      _refreshDiscover();
                    },
                  ),
                ),
              ),
              for (final goal in HealthGoalTag.values)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    key: Key('comm_goal_filter_${goal.name}'),
                    visualDensity: VisualDensity.compact,
                    avatar: Icon(
                      goal.icon,
                      size: 14,
                      color: _goalFilter == goal
                          ? Colors.white
                          : goal.accentColor,
                    ),
                    label: Text(
                      goal.localizedLabel(l10n),
                      style: const TextStyle(fontSize: 12),
                    ),
                    selected: _goalFilter == goal,
                    selectedColor: goal.accentColor,
                    labelStyle: TextStyle(
                      color: _goalFilter == goal ? Colors.white : null,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) {
                      setState(
                        () => _goalFilter = _goalFilter == goal ? null : goal,
                      );
                      _refreshDiscover();
                    },
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // Discovered Social Health Profiles Feed
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 2, 14, 24),
            children: [
              // Slim 1-line Privacy & Safety Notice
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      size: 14,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        l10n.commSafetyBanner,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GlobalAnnouncementBanner(
                repository: widget.adminRepository,
                margin: const EdgeInsets.only(bottom: 8),
              ),
              HealthPromotionBanner(
                placement: PromotionPlacement.communityTop,
                repository: widget.adminRepository,
                margin: const EdgeInsets.only(bottom: 8),
              ),
              if (_discoverList.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 40,
                  ),
                  child: Text(
                    l10n.commEmptyDiscover,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                for (final profile in _discoverList) ...[
                  _buildSocialMemberCard(context, profile),
                  const SizedBox(height: 8),
                ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialMemberCard(
    BuildContext context,
    HealthCommunityProfile profile,
  ) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLiked = profile.isLikedBy(_myUid);
    final friendStatus = _friendStatusByPeerUid[profile.uid];
    final accent = profile.healthGoals.first.accentColor;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        key: Key('comm_profile_card_${profile.uid}'),
        onTap: () => _openProfileDetail(profile),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subtle accent top strip
            Container(
              height: 3.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent, accent.withValues(alpha: 0.35)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CommunityAvatar(
                            initials: profile.initials,
                            photoUrl: profile.visiblePhotoUrl,
                            radius: 22,
                            accentColor: accent,
                          ),
                          if (profile.isVisibleOnline)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF16A34A),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: colorScheme.surface,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    profile.visibleName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                if (profile.isVerified) ...[
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.verified_rounded,
                                    size: 15,
                                    color: Color(0xFF0284C7),
                                  ),
                                ],
                                if (profile.mood != null) ...[
                                  const SizedBox(width: 4),
                                  Text(
                                    profile.mood!.emoji,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 1),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    '${profile.country.flag} ${profile.city.isNotEmpty ? '${profile.city} • ' : ''}${profile.country.label}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (profile.isVisibleOnline) ...[
                                  const SizedBox(width: 5),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF16A34A)
                                          .withValues(alpha: 0.14),
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    child: Text(
                                      l10n.commOnlineNow,
                                      style: const TextStyle(
                                        color: Color(0xFF16A34A),
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                                if (profile.hasMusic) ...[
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.music_note_rounded,
                                    size: 13,
                                    color: MusicLinkHelper.detectPlatformColor(
                                      profile.currentMusicUrl,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (profile.showBio && profile.bio.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      profile.bio.trim(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(height: 1.3),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 5,
                    runSpacing: 4,
                    children: [
                      if (profile.showChronicConditions)
                        for (final cond in profile.chronicConditions)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: cond.accentColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(9),
                              border: Border.all(
                                color: cond.accentColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  cond.icon,
                                  size: 11,
                                  color: cond.accentColor,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  cond.localizedLabel(l10n),
                                  style: TextStyle(
                                    color: cond.accentColor,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      if (profile.showChronicConditions &&
                          profile.customChronicCondition.trim().isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2.5,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer
                                .withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Text(
                            '🩺 ${profile.customChronicCondition.trim()}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 10.5,
                            ),
                          ),
                        ),
                      for (final goal in profile.healthGoals.take(2))
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2.5,
                          ),
                          decoration: BoxDecoration(
                            color: goal.accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                goal.icon,
                                size: 11,
                                color: goal.accentColor,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                goal.localizedLabel(l10n),
                                style: TextStyle(
                                  color: goal.accentColor,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Divider(height: 1),
                  // Compact 3-Action Social Footer: Like • Friend • Message
                  SizedBox(
                    height: 36,
                    child: Row(
                      children: [
                        TextButton.icon(
                          key: Key('comm_like_btn_${profile.uid}'),
                          style: TextButton.styleFrom(
                            foregroundColor: isLiked
                                ? const Color(0xFFE11D48)
                                : colorScheme.onSurfaceVariant,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () => _toggleQuickLike(profile),
                          icon: Icon(
                            isLiked
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 17,
                          ),
                          label: Text(
                            '${profile.likesCount}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        TextButton.icon(
                          key: Key('comm_friend_btn_${profile.uid}'),
                          style: TextButton.styleFrom(
                            foregroundColor:
                                friendStatus == FriendshipStatus.accepted
                                    ? const Color(0xFF16A34A)
                                    : colorScheme.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () => _toggleFriendRequest(profile),
                          icon: Icon(
                            friendStatus == FriendshipStatus.accepted
                                ? Icons.how_to_reg_rounded
                                : friendStatus == FriendshipStatus.pending
                                    ? Icons.hourglass_top_rounded
                                    : Icons.person_add_alt_1_outlined,
                            size: 16,
                          ),
                          label: Text(
                            friendStatus == FriendshipStatus.accepted
                                ? l10n.commFriendsConnected
                                : friendStatus == FriendshipStatus.pending
                                    ? l10n.commFriendPending
                                    : l10n.commAddFriend,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (profile.allowMessages)
                          TextButton.icon(
                            key: Key('comm_msg_btn_${profile.uid}'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.primaryTeal,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () => _openDirectChat(profile),
                            icon: const Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 15,
                            ),
                            label: Text(
                              l10n.commTabMessages,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                              ),
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

  Widget _buildMessagesTab(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_conversations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.mark_chat_unread_outlined,
                size: 56,
                color: colorScheme.primary.withValues(alpha: 0.55),
              ),
              const SizedBox(height: 14),
              Text(
                l10n.commInboxEmpty,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
      itemCount: _conversations.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final convo = _conversations[index];
        final peerName = convo.peerNameFor(_myUid);
        final peerPhoto = convo.peerPhotoFor(_myUid);
        final isUnread = convo.isUnreadFor(_myUid);
        final isPending = convo.isPendingIncomingFor(_myUid);
        final isMuted = convo.isMutedFor(_myUid);
        final timeStr = DateFormat('HH:mm').format(convo.lastMessageAt);
        final initials = peerName.trim().isNotEmpty
            ? peerName.trim().substring(0, 1).toUpperCase()
            : 'M';

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onTap: () => _openConversation(convo),
            leading: CommunityAvatar(
              initials: initials,
              photoUrl: peerPhoto,
              radius: 23,
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    peerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: isUnread ? FontWeight.w900 : FontWeight.w700,
                    ),
                  ),
                ),
                if (isPending)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      l10n.commMessageRequestBadge,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                if (isMuted) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 15,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ],
            ),
            subtitle: Text(
              convo.lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: isUnread ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  timeStr,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (isUnread) ...[
                  const SizedBox(height: 4),
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
