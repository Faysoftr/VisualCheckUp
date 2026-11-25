import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:visualcheckup/core/l10n/l10n_extensions.dart';
import 'package:visualcheckup/core/theme/app_theme.dart';
import 'package:visualcheckup/features/admin/data/admin_repository.dart';
import 'package:visualcheckup/features/admin/domain/admin_models.dart';
import 'package:visualcheckup/features/community/data/community_image_upload_service.dart';
import 'package:visualcheckup/features/community/domain/health_community_models.dart';
import 'package:visualcheckup/features/community/presentation/screens/health_chat_screen.dart';
import 'package:visualcheckup/features/community/presentation/widgets/community_avatar_and_report.dart';

/// VisualCheckUp Admin Control Panel (health-community native; no student/exam
/// sections). Manages live statistics, global announcements, ads/banners,
/// community users, and safety reports.
class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({
    super.key,
    required this.repository,
    this.uploadService,
    this.photoPicker,
    this.initialTabIndex = 0,
  });

  final AdminRepository repository;
  final CommunityImageUploadService? uploadService;
  final CommunityPhotoPicker? photoPicker;
  final int initialTabIndex;

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final CommunityImageUploadService _uploadService;
  final TextEditingController _userSearchController = TextEditingController();

  bool _loading = true;
  AdminDashboardStats? _stats;
  List<GlobalAnnouncement> _announcements = const [];
  List<HealthPromotion> _promotions = const [];
  List<HealthCommunityProfile> _users = const [];
  List<AdminReportItem> _reports = const [];

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
    _refreshAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _userSearchController.dispose();
    super.dispose();
  }

  Future<void> _refreshAll() async {
    final stats = await widget.repository.computeStats();
    final announcements = await widget.repository.loadAnnouncements();
    final promotions = await widget.repository.loadPromotions();
    final users =
        await widget.repository.communityRepository.loadAllProfilesForAdmin();
    final reports = await widget.repository.loadReports();
    if (!mounted) return;
    setState(() {
      _stats = stats;
      _announcements = announcements;
      _promotions = promotions;
      _users = users;
      _reports = reports;
      _loading = false;
    });
  }

  Future<void> _openCreateAnnouncementSheet() async {
    final created = await showModalBottomSheet<GlobalAnnouncement>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => const _CreateAnnouncementSheet(),
    );

    if (created != null) {
      await widget.repository.saveAnnouncement(created);
      await _refreshAll();
    }
  }

  Future<void> _openCreatePromotionSheet() async {
    final created = await showModalBottomSheet<HealthPromotion>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _CreatePromotionSheet(
        uploadService: _uploadService,
        photoPicker: widget.photoPicker,
      ),
    );

    if (created != null) {
      await widget.repository.savePromotion(created);
      await _refreshAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pendingReports = _stats?.pendingReports ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminPanelTitle),
        actions: [
          IconButton(
            onPressed: _refreshAll,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            Tab(
              icon: const Icon(Icons.analytics_outlined, size: 18),
              text: l10n.adminTabStats,
            ),
            Tab(
              icon: const Icon(Icons.campaign_outlined, size: 18),
              text: l10n.adminTabAnnouncements,
            ),
            Tab(
              icon: const Icon(Icons.local_offer_outlined, size: 18),
              text: l10n.adminTabPromotions,
            ),
            Tab(
              icon: const Icon(Icons.people_outline_rounded, size: 18),
              text: '${l10n.adminTabUsers} (${_users.length})',
            ),
            Tab(
              icon: const Icon(Icons.flag_outlined, size: 18),
              text: pendingReports > 0
                  ? '${l10n.adminTabReports} ($pendingReports)'
                  : l10n.adminTabReports,
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildStatsTab(context),
                _buildAnnouncementsTab(context),
                _buildPromotionsTab(context),
                _buildUsersTab(context),
                _buildReportsTab(context),
              ],
            ),
    );
  }

  Widget _buildStatsTab(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final stats = _stats!;
    final sortedConditions = stats.conditionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxConditionCount = sortedConditions.isEmpty
        ? 1
        : sortedConditions.first.value.clamp(1, 999999);

    return ListView(
      key: const Key('admin_stats_list'),
      padding: const EdgeInsets.all(16),
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.55,
          children: [
            _AdminStatCard(
              label: l10n.adminStatOnline,
              value: '${stats.onlineMembers}',
              icon: Icons.circle,
              color: const Color(0xFF16A34A),
            ),
            _AdminStatCard(
              label: l10n.adminStatMembers,
              value: '${stats.totalMembers}',
              icon: Icons.groups_rounded,
              color: AppTheme.primaryTeal,
            ),
            _AdminStatCard(
              label: l10n.adminStatLikes,
              value: '${stats.totalLikes}',
              icon: Icons.favorite_rounded,
              color: const Color(0xFFE11D48),
            ),
            _AdminStatCard(
              label: l10n.adminStatChats,
              value: '${stats.totalConversations}',
              icon: Icons.forum_rounded,
              color: const Color(0xFF2563EB),
            ),
            _AdminStatCard(
              label: l10n.adminStatPendingReports,
              value: '${stats.pendingReports}',
              icon: Icons.flag_rounded,
              color: const Color(0xFFD97706),
            ),
            _AdminStatCard(
              label: l10n.adminStatActiveBanners,
              value: '${stats.activeAnnouncements + stats.activePromotions}',
              icon: Icons.campaign_rounded,
              color: const Color(0xFF7C3AED),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.adminConditionBreakdown,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                for (final entry in sortedConditions) ...[
                  Row(
                    children: [
                      Icon(entry.key.icon, size: 16, color: entry.key.accentColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.key.localizedLabel(l10n),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${entry.value}',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: entry.key.accentColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: entry.value / maxConditionCount,
                      minHeight: 7,
                      color: entry.key.accentColor,
                      backgroundColor:
                          entry.key.accentColor.withValues(alpha: 0.14),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnnouncementsTab(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const Key('admin_add_announcement_button'),
              onPressed: _openCreateAnnouncementSheet,
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.adminNewAnnouncement),
            ),
          ),
        ),
        Expanded(
          child: _announcements.isEmpty
              ? Center(child: Text(l10n.adminNoAnnouncements))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: _announcements.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final ann = _announcements[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              ann.type.accentColor.withValues(alpha: 0.15),
                          child: Icon(ann.type.icon, color: ann.type.accentColor),
                        ),
                        title: Text(
                          ann.title,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text(
                          ann.message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: ann.isActive,
                              onChanged: (v) async {
                                await widget.repository.saveAnnouncement(
                                  ann.copyWith(isActive: v),
                                );
                                await _refreshAll();
                              },
                            ),
                            IconButton(
                              onPressed: () async {
                                await widget.repository
                                    .deleteAnnouncement(ann.id);
                                await _refreshAll();
                              },
                              icon: Icon(
                                Icons.delete_outline_rounded,
                                color: theme.colorScheme.error,
                              ),
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

  Widget _buildPromotionsTab(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const Key('admin_add_promo_button'),
              onPressed: _openCreatePromotionSheet,
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.adminNewPromotion),
            ),
          ),
        ),
        Expanded(
          child: _promotions.isEmpty
              ? Center(child: Text(l10n.adminNoPromotions))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: _promotions.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final promo = _promotions[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Icon(
                            Icons.local_offer_rounded,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        title: Text(
                          promo.title,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text(
                          '${promo.placement.localizedLabel(l10n)}${promo.subtitle.isNotEmpty ? ' • ${promo.subtitle}' : ''}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: promo.isActive,
                              onChanged: (v) async {
                                await widget.repository.savePromotion(
                                  promo.copyWith(isActive: v),
                                );
                                await _refreshAll();
                              },
                            ),
                            IconButton(
                              onPressed: () async {
                                await widget.repository
                                    .deletePromotion(promo.id);
                                await _refreshAll();
                              },
                              icon: Icon(
                                Icons.delete_outline_rounded,
                                color: theme.colorScheme.error,
                              ),
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

  Widget _buildUsersTab(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final q = _userSearchController.text.trim().toLowerCase();
    final filtered = _users.where((u) {
      if (q.isEmpty) return true;
      final hay = [
        u.displayName,
        u.nickname,
        u.country.label,
        u.city,
        u.customChronicCondition,
        for (final c in u.chronicConditions) c.localizedLabel(l10n),
      ].join(' ').toLowerCase();
      return hay.contains(q);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _userSearchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: l10n.adminSearchUsersHint,
              prefixIcon: const Icon(Icons.search_rounded),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            itemCount: filtered.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final u = filtered[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CommunityAvatar(
                            initials: u.initials,
                            photoUrl: u.visiblePhotoUrl,
                            radius: 22,
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
                                        u.displayName,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    if (u.isVerified) ...[
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.verified_rounded,
                                        size: 16,
                                        color: Color(0xFF0284C7),
                                      ),
                                    ],
                                    if (u.isVisibleOnline) ...[
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.circle,
                                        size: 9,
                                        color: Color(0xFF16A34A),
                                      ),
                                    ],
                                  ],
                                ),
                                Text(
                                  '${u.country.flag} ${u.country.label} • ❤️ ${u.likesCount}${u.isSuspended ? ' • ${l10n.adminStatusSuspended}' : ''}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: u.isSuspended
                                        ? theme.colorScheme.error
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (u.hasAnyChronicCondition) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final c in u.chronicConditions)
                              Chip(
                                visualDensity: VisualDensity.compact,
                                label: Text(
                                  c.localizedLabel(l10n),
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          OutlinedButton.icon(
                            key: Key('admin_verify_${u.uid}'),
                            onPressed: () async {
                              await widget.repository.communityRepository
                                  .setProfileVerified(u.uid, !u.isVerified);
                              await _refreshAll();
                            },
                            icon: Icon(
                              u.isVerified
                                  ? Icons.verified_outlined
                                  : Icons.verified_rounded,
                              size: 16,
                            ),
                            label: Text(
                              u.isVerified
                                  ? l10n.adminActionUnverify
                                  : l10n.adminActionVerify,
                            ),
                          ),
                          OutlinedButton.icon(
                            key: Key('admin_suspend_${u.uid}'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: u.isSuspended
                                  ? const Color(0xFF16A34A)
                                  : theme.colorScheme.error,
                            ),
                            onPressed: () async {
                              await widget.repository.communityRepository
                                  .setProfileSuspended(u.uid, !u.isSuspended);
                              await _refreshAll();
                            },
                            icon: Icon(
                              u.isSuspended
                                  ? Icons.restore_rounded
                                  : Icons.block_rounded,
                              size: 16,
                            ),
                            label: Text(
                              u.isSuspended
                                  ? l10n.adminActionUnsuspend
                                  : l10n.adminActionSuspend,
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

  Widget _buildReportsTab(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    if (_reports.isEmpty) {
      return Center(child: Text(l10n.adminNoReports));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _reports.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final report = _reports[index];
        final isPending = report.status == 'pending';
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.flag_rounded,
                      size: 18,
                      color: isPending
                          ? theme.colorScheme.error
                          : const Color(0xFF16A34A),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${report.targetType.toUpperCase()} • ${report.reason}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Chip(
                      visualDensity: VisualDensity.compact,
                      label: Text(report.status),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Target: ${report.targetId}',
                  style: theme.textTheme.bodySmall,
                ),
                if (report.note.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(report.note),
                ],
                if (isPending) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      FilledButton.tonal(
                        key: Key('admin_resolve_${report.id}'),
                        onPressed: () async {
                          await widget.repository.updateReportStatus(
                            reportId: report.id,
                            status: 'resolved',
                          );
                          await _refreshAll();
                        },
                        child: Text(l10n.adminReportResolve),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () async {
                          await widget.repository.updateReportStatus(
                            reportId: report.id,
                            status: 'dismissed',
                          );
                          await _refreshAll();
                        },
                        child: Text(l10n.adminReportDismiss),
                      ),
                    ],
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

class _AdminStatCard extends StatelessWidget {
  const _AdminStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateAnnouncementSheet extends StatefulWidget {
  const _CreateAnnouncementSheet();

  @override
  State<_CreateAnnouncementSheet> createState() =>
      _CreateAnnouncementSheetState();
}

class _CreateAnnouncementSheetState extends State<_CreateAnnouncementSheet> {
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _msgCtrl = TextEditingController();
  final TextEditingController _linkCtrl = TextEditingController();
  AnnouncementType _type = AnnouncementType.info;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _msgCtrl.dispose();
    _linkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        4,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.adminNewAnnouncement,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in AnnouncementType.values)
                  ChoiceChip(
                    avatar: Icon(
                      t.icon,
                      size: 16,
                      color: _type == t ? Colors.white : t.accentColor,
                    ),
                    label: Text(t.localizedLabel(l10n)),
                    selected: _type == t,
                    selectedColor: t.accentColor,
                    labelStyle: TextStyle(
                      color: _type == t ? Colors.white : null,
                      fontWeight: FontWeight.w700,
                    ),
                    onSelected: (_) => setState(() => _type = t),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('admin_announcement_title_field'),
              controller: _titleCtrl,
              decoration: InputDecoration(
                labelText: l10n.adminFieldTitle,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('admin_announcement_message_field'),
              controller: _msgCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.adminFieldMessage,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _linkCtrl,
              decoration: InputDecoration(
                labelText: l10n.adminFieldLink,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const Key('admin_announcement_save_button'),
              onPressed: () {
                if (_titleCtrl.text.trim().isEmpty ||
                    _msgCtrl.text.trim().isEmpty) {
                  return;
                }
                Navigator.of(context).pop(
                  GlobalAnnouncement(
                    id: 'ann_${DateTime.now().microsecondsSinceEpoch}',
                    title: _titleCtrl.text.trim(),
                    message: _msgCtrl.text.trim(),
                    type: _type,
                    linkUrl: _linkCtrl.text.trim(),
                    isActive: true,
                    createdAt: DateTime.now(),
                  ),
                );
              },
              icon: const Icon(Icons.campaign_rounded),
              label: Text(l10n.adminNewAnnouncement),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreatePromotionSheet extends StatefulWidget {
  const _CreatePromotionSheet({
    required this.uploadService,
    this.photoPicker,
  });

  final CommunityImageUploadService uploadService;
  final CommunityPhotoPicker? photoPicker;

  @override
  State<_CreatePromotionSheet> createState() => _CreatePromotionSheetState();
}

class _CreatePromotionSheetState extends State<_CreatePromotionSheet> {
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _subtitleCtrl = TextEditingController();
  final TextEditingController _linkCtrl = TextEditingController();
  PromotionPlacement _placement = PromotionPlacement.homeTop;
  String? _uploadedImageUrl;
  String? _uploadedImageKey;
  bool _uploading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    _linkCtrl.dispose();
    super.dispose();
  }

  Future<void> _uploadBanner() async {
    setState(() => _uploading = true);
    try {
      Uint8List? bytes;
      if (widget.photoPicker != null) {
        bytes = await widget.photoPicker!(ImageSource.gallery);
      } else {
        final picker = ImagePicker();
        final file = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1600,
          imageQuality: 85,
        );
        if (file != null) bytes = await file.readAsBytes();
      }
      if (bytes != null) {
        final res = await widget.uploadService.uploadBytes(
          bytes,
          folder: 'community_chat',
        );
        if (!mounted) return;
        setState(() {
          _uploadedImageUrl = res.url;
          _uploadedImageKey = res.objectKey;
        });
      }
    } catch (_) {
      // Ignore user cancellation or transient upload errors.
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        4,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.adminNewPromotion,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<PromotionPlacement>(
              initialValue: _placement,
              decoration: InputDecoration(
                labelText: l10n.adminFieldPlacement,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              items: [
                for (final p in PromotionPlacement.values)
                  DropdownMenuItem(
                    value: p,
                    child: Text(p.localizedLabel(l10n)),
                  ),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _placement = v);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('admin_promo_title_field'),
              controller: _titleCtrl,
              decoration: InputDecoration(
                labelText: l10n.adminFieldTitle,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('admin_promo_subtitle_field'),
              controller: _subtitleCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: l10n.adminFieldMessage,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _linkCtrl,
              decoration: InputDecoration(
                labelText: l10n.adminFieldLink,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _uploading ? null : _uploadBanner,
              icon: _uploading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_photo_alternate_outlined),
              label: Text(
                _uploadedImageUrl != null
                    ? '✓ ${l10n.commUploadPhoto}'
                    : l10n.commUploadPhoto,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const Key('admin_promo_save_button'),
              onPressed: () {
                if (_titleCtrl.text.trim().isEmpty) return;
                Navigator.of(context).pop(
                  HealthPromotion(
                    id: 'promo_${DateTime.now().microsecondsSinceEpoch}',
                    title: _titleCtrl.text.trim(),
                    subtitle: _subtitleCtrl.text.trim(),
                    placement: _placement,
                    imageUrl: _uploadedImageUrl,
                    imageKey: _uploadedImageKey,
                    linkUrl: _linkCtrl.text.trim(),
                    isActive: true,
                    createdAt: DateTime.now(),
                  ),
                );
              },
              icon: const Icon(Icons.local_offer_rounded),
              label: Text(l10n.adminNewPromotion),
            ),
          ],
        ),
      ),
    );
  }
}

