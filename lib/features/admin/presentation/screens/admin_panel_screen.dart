import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:visualcheckup/core/l10n/l10n_extensions.dart';
import 'package:visualcheckup/core/theme/app_theme.dart';
import 'package:visualcheckup/core/theme/visual_announcement_effect_service.dart';
import 'package:visualcheckup/features/admin/data/admin_repository.dart';
import 'package:visualcheckup/features/admin/domain/admin_models.dart';
import 'package:visualcheckup/features/community/data/community_image_upload_service.dart';
import 'package:visualcheckup/features/community/domain/health_community_models.dart';
import 'package:visualcheckup/features/community/presentation/screens/health_chat_screen.dart';
import 'package:visualcheckup/features/community/presentation/widgets/community_avatar_and_report.dart';
import 'package:visualcheckup/core/ads/app_open_ad_manager.dart';
import 'package:visualcheckup/features/doctors/data/doctor_repository.dart';
import 'package:visualcheckup/features/doctors/domain/doctor_models.dart';

/// VisualCheckUp Admin Control Panel (health-community native; no student/exam
/// sections). Manages live statistics, global announcements, ads/banners,
/// community users, safety reports, and verified doctor applications.
class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({
    super.key,
    required this.repository,
    this.doctorRepository,
    this.uploadService,
    this.photoPicker,
    this.initialTabIndex = 0,
  });

  final AdminRepository repository;
  final DoctorRepository? doctorRepository;
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
  late final DoctorRepository _doctorRepository;
  final TextEditingController _userSearchController = TextEditingController();

  bool _loading = true;
  AdminDashboardStats? _stats;
  List<GlobalAnnouncement> _announcements = const [];
  List<HealthPromotion> _promotions = const [];
  List<HealthCommunityProfile> _users = const [];
  List<AdminReportItem> _reports = const [];
  List<DoctorProfile> _doctorApps = const [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 6,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 5),
    );
    _uploadService =
        widget.uploadService ?? R2CommunityImageUploadService.instance;
    _doctorRepository = widget.doctorRepository ??
        DoctorRepository(useFirebase: widget.repository.useFirebase);
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
    final doctorApps = await _doctorRepository.loadApplicationsForAdmin();
    if (!mounted) return;
    setState(() {
      _stats = stats;
      _announcements = announcements;
      _promotions = promotions;
      _users = users;
      _reports = reports;
      _doctorApps = doctorApps;
      _loading = false;
    });
  }

  Future<void> _openAnnouncementSheet({GlobalAnnouncement? existing}) async {
    final saved = await showModalBottomSheet<GlobalAnnouncement>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _CreateAnnouncementSheet(initialAnnouncement: existing),
    );

    if (saved != null) {
      await widget.repository.saveAnnouncement(saved);
      await _refreshAll();
    }
  }

  Future<void> _openCreateAnnouncementSheet() => _openAnnouncementSheet();

  Future<void> _openPromotionSheet({HealthPromotion? existing}) async {
    final saved = await showModalBottomSheet<HealthPromotion>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _CreatePromotionSheet(
        uploadService: _uploadService,
        photoPicker: widget.photoPicker,
        initialPromotion: existing,
      ),
    );

    if (saved != null) {
      await widget.repository.savePromotion(saved);
      await _refreshAll();
    }
  }

  Future<void> _openCreatePromotionSheet() => _openPromotionSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pendingReports = _stats?.pendingReports ?? 0;
    final pendingDoctors = _doctorApps
        .where((d) => d.status == DoctorApplicationStatus.pending)
        .length;

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
            Tab(
              icon: const Icon(Icons.medical_services_outlined, size: 18),
              text: pendingDoctors > 0
                  ? '${l10n.adminTabDoctors} ($pendingDoctors)'
                  : l10n.adminTabDoctors,
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
                _buildDoctorsTab(context),
              ],
            ),
    );
  }

  Widget _buildDoctorsTab(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_doctorApps.isEmpty) {
      return Center(
        child: Text(
          l10n.adminNoDoctorApps,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _doctorApps.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) {
        final doc = _doctorApps[i];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        doc.displayTitleName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Chip(
                      visualDensity: VisualDensity.compact,
                      label: Text(doc.status.name.toUpperCase()),
                    ),
                  ],
                ),
                Text(
                  '${doc.country.flag} ${doc.city}, ${doc.country.label} • ${doc.specialty.localizedLabel(l10n)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (doc.licenseNumber.isNotEmpty)
                  Text(
                    '${l10n.doctorFieldLicense}: ${doc.licenseNumber}',
                    style: theme.textTheme.labelSmall,
                  ),
                if (doc.hospitalOrClinic.isNotEmpty)
                  Text(
                    doc.hospitalOrClinic,
                    style: theme.textTheme.labelSmall,
                  ),

                // AI Document Verification Result
                if (doc.aiVerificationStatus == 'suspicious_ai')
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFEF4444)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                color: Color(0xFFEF4444), size: 18),
                            const SizedBox(width: 6),
                            Text(
                              '🚨 DİKKAT: Yapay Zeka / Sahte Belge Şüphesi! (%${(doc.aiConfidence * 100).round()} Risk)',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFB91C1C),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          doc.aiNotes.isNotEmpty
                              ? doc.aiNotes
                              : 'Belgede yapay zeka difüzyon modeli veya sentetik doku tespit edildi. Manuel inceleme önerilir.',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF7F1D1D),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (doc.aiVerificationStatus == 'original')
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF10B981)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_rounded,
                            color: Color(0xFF10B981), size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '✓ AI Doğrulama: Belge Orijinal Görünüyor (%${(doc.aiConfidence * 100).round()} Güven)',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF047857),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Payment / Document links
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (doc.isPaid)
                      Chip(
                        visualDensity: VisualDensity.compact,
                        avatar: const Icon(Icons.check_circle_rounded,
                            size: 14, color: Color(0xFF16A34A)),
                        label: const Text('Google Play ile Ödendi',
                            style: TextStyle(fontSize: 11)),
                      ),
                    if (doc.documentUrl != null && doc.documentUrl!.isNotEmpty)
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (dlgCtx) => Dialog(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Yüklenen Hekimlik Belgesi',
                                        style: theme.textTheme.titleMedium),
                                    const SizedBox(height: 12),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        doc.documentUrl!,
                                        errorBuilder: (_, __, ___) =>
                                            const Text('Belge görseli açılamadı.'),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextButton(
                                      onPressed: () => Navigator.of(dlgCtx).pop(),
                                      child: const Text('Kapat'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.description_outlined, size: 15),
                        label: const Text('Belgeyi İncele',
                            style: TextStyle(fontSize: 11.5)),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    FilledButton.tonalIcon(
                      key: Key('admin_approve_doc_${doc.uid}'),
                      onPressed: doc.status == DoctorApplicationStatus.approved
                          ? null
                          : () async {
                              await _doctorRepository.reviewApplication(
                                doctorUid: doc.uid,
                                approve: true,
                              );
                              await _refreshAll();
                            },
                      icon: const Icon(Icons.verified_rounded, size: 17),
                      label: Text(l10n.adminApproveDoctor),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      key: Key('admin_reject_doc_${doc.uid}'),
                      onPressed: doc.status == DoctorApplicationStatus.rejected
                          ? null
                          : () async {
                              await _doctorRepository.reviewApplication(
                                doctorUid: doc.uid,
                                approve: false,
                              );
                              await _refreshAll();
                            },
                      icon: const Icon(Icons.close_rounded, size: 17),
                      label: Text(l10n.adminRejectDoctor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
    final colorScheme = theme.colorScheme;

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
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                ann.title,
                                style: const TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: ann.type.accentColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${GlobalAnnouncement.shapeEmoji(ann.effectShape)} ${ann.effectShape}',
                                style: TextStyle(
                                  color: ann.type.accentColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
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
                            IconButton(
                              key: Key('admin_edit_announcement_${ann.id}'),
                              tooltip: 'Duyuruyu Düzenle',
                              onPressed: () =>
                                  _openAnnouncementSheet(existing: ann),
                              icon: Icon(
                                Icons.edit_outlined,
                                color: colorScheme.primary,
                              ),
                            ),
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
    final colorScheme = theme.colorScheme;
    final adManager = AppOpenAdManager();

    return Column(
      children: [
        // App Open Ad Global Switch & Interval Card (Synchronized from Social Formul Bank)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.ad_units_rounded,
                        color: AppTheme.primaryTeal, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Açılış Reklamı (App Open Ad)',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Switch(
                      key: const Key('admin_app_open_ad_switch'),
                      value: adManager.isEnabled,
                      onChanged: (val) async {
                        await adManager.setEnabled(val);
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(val
                                ? '✓ Uygulama açılış reklamı aktif edildi.'
                                : 'Açılış reklamı kapatıldı.'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                Text(
                  'Uygulama açılırken ve arka plandan dönüldüğünde tam sayfa reklam gösterimi.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Sıklık Sınırı:',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    DropdownButton<int>(
                      value: adManager.intervalMinutes,
                      isDense: true,
                      items: const [
                        DropdownMenuItem(value: 5, child: Text('5 Dakika')),
                        DropdownMenuItem(value: 15, child: Text('15 Dakika (Varsayılan)')),
                        DropdownMenuItem(value: 30, child: Text('30 Dakika')),
                        DropdownMenuItem(value: 60, child: Text('60 Dakika')),
                      ],
                      onChanged: (newVal) async {
                        if (newVal != null) {
                          await adManager.setIntervalMinutes(newVal);
                          setState(() {});
                        }
                      },
                    ),
                    const Spacer(),
                    TextButton.icon(
                      key: const Key('admin_test_app_open_ad_btn'),
                      onPressed: () {
                        final shown = adManager.showAdIfAvailable(ignoreCooldown: true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(shown
                                ? '✓ Açılış reklamı tetiklendi (Test Başarılı).'
                                : 'Reklam tetiklenemedi.'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_arrow_rounded, size: 16),
                      label: const Text('Test Et', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
                const Divider(height: 14),
                Row(
                  children: [
                    const Icon(Icons.verified_user_outlined,
                        size: 14, color: Color(0xFF16A34A)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '🛡️ PRO Üyeler ve Admin için tüm reklamlar (%100) otomatik engellenir.',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF16A34A),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
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
                            IconButton(
                              key: Key('admin_edit_promo_${promo.id}'),
                              tooltip: 'Reklamı Düzenle',
                              onPressed: () =>
                                  _openPromotionSheet(existing: promo),
                              icon: Icon(
                                Icons.edit_outlined,
                                color: colorScheme.primary,
                              ),
                            ),
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
                      if (u.hasAppealed &&
                          u.appealText != null &&
                          u.appealText!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFF59E0B)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.gavel_rounded,
                                      size: 16, color: Color(0xFFB45309)),
                                  SizedBox(width: 6),
                                  Text(
                                    '⚖️ Kullanıcı Ban İtirazı:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFB45309),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                u.appealText!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF78350F),
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  FilledButton.tonal(
                                    key: Key('admin_accept_appeal_${u.uid}'),
                                    style: FilledButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    onPressed: () async {
                                      await widget.repository.communityRepository
                                          .saveMyProfile(
                                        u.copyWith(
                                          isSuspended: false,
                                          hasAppealed: false,
                                        ),
                                      );
                                      await _refreshAll();
                                    },
                                    child: const Text('İtirazı Onayla (Banı Kaldır)'),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton(
                                    key: Key('admin_reject_appeal_${u.uid}'),
                                    style: OutlinedButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    onPressed: () async {
                                      await widget.repository.communityRepository
                                          .saveMyProfile(
                                        u.copyWith(hasAppealed: false),
                                      );
                                      await _refreshAll();
                                    },
                                    child: const Text('İtirazı Reddet'),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
  const _CreateAnnouncementSheet({this.initialAnnouncement});

  final GlobalAnnouncement? initialAnnouncement;

  @override
  State<_CreateAnnouncementSheet> createState() =>
      _CreateAnnouncementSheetState();
}

class _CreateAnnouncementSheetState extends State<_CreateAnnouncementSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _msgCtrl;
  late final TextEditingController _linkCtrl;
  late AnnouncementType _type;
  late String _effectShape;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialAnnouncement;
    _titleCtrl = TextEditingController(text: initial?.title ?? '');
    _msgCtrl = TextEditingController(text: initial?.message ?? '');
    _linkCtrl = TextEditingController(text: initial?.linkUrl ?? '');
    _type = initial?.type ?? AnnouncementType.info;
    _effectShape = initial?.effectShape ?? 'Konfeti';
  }

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
    final isEditing = widget.initialAnnouncement != null;
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
              isEditing ? 'Duyuruyu Düzenle' : l10n.adminNewAnnouncement,
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
            DropdownButtonFormField<String>(
              key: const Key('admin_announcement_shape_dropdown'),
              value: GlobalAnnouncement.availableEffectShapes
                      .contains(_effectShape)
                  ? _effectShape
                  : 'Konfeti',
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Akacak Şekil (Ekran Yağmuru / Efekt)',
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    GlobalAnnouncement.shapeEmoji(_effectShape),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 44, minHeight: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              items: [
                for (final shape in GlobalAnnouncement.availableEffectShapes)
                  DropdownMenuItem(
                    value: shape,
                    child: Text(
                      GlobalAnnouncement.shapeLabel(shape),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _effectShape = val);
              },
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              key: const Key('admin_test_announcement_effect_button'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onPressed: () {
                VisualAnnouncementEffectService.showEffect(
                  context,
                  type: _type.name,
                  shape: _effectShape,
                );
              },
              icon: const Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFFFF2A8D),
                size: 19,
              ),
              label: Text(
                'Efekti Canlı Test Et (${GlobalAnnouncement.shapeEmoji(_effectShape)} $_effectShape)',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
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
                final existing = widget.initialAnnouncement;
                Navigator.of(context).pop(
                  existing != null
                      ? existing.copyWith(
                          title: _titleCtrl.text.trim(),
                          message: _msgCtrl.text.trim(),
                          type: _type,
                          effectShape: _effectShape,
                          linkUrl: _linkCtrl.text.trim(),
                        )
                      : GlobalAnnouncement(
                          id: 'ann_${DateTime.now().microsecondsSinceEpoch}',
                          title: _titleCtrl.text.trim(),
                          message: _msgCtrl.text.trim(),
                          type: _type,
                          effectShape: _effectShape,
                          linkUrl: _linkCtrl.text.trim(),
                          isActive: true,
                          createdAt: DateTime.now(),
                        ),
                );
              },
              icon: Icon(
                isEditing ? Icons.save_rounded : Icons.campaign_rounded,
              ),
              label: Text(
                isEditing ? 'Değişiklikleri Kaydet' : l10n.adminNewAnnouncement,
              ),
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
    this.initialPromotion,
  });

  final CommunityImageUploadService uploadService;
  final CommunityPhotoPicker? photoPicker;
  final HealthPromotion? initialPromotion;

  @override
  State<_CreatePromotionSheet> createState() => _CreatePromotionSheetState();
}

class _CreatePromotionSheetState extends State<_CreatePromotionSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _subtitleCtrl;
  late final TextEditingController _linkCtrl;
  late PromotionPlacement _placement;
  String? _uploadedImageUrl;
  String? _uploadedImageKey;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialPromotion;
    _titleCtrl = TextEditingController(text: initial?.title ?? '');
    _subtitleCtrl = TextEditingController(text: initial?.subtitle ?? '');
    _linkCtrl = TextEditingController(text: initial?.linkUrl ?? '');
    _placement = initial?.placement ?? PromotionPlacement.homeTop;
    _uploadedImageUrl = initial?.imageUrl;
    _uploadedImageKey = initial?.imageKey;
  }

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
    final isEditing = widget.initialPromotion != null;
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
              isEditing ? 'Reklamı / Kampanyayı Düzenle' : l10n.adminNewPromotion,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<PromotionPlacement>(
              value: _placement,
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
                final existing = widget.initialPromotion;
                Navigator.of(context).pop(
                  existing != null
                      ? existing.copyWith(
                          title: _titleCtrl.text.trim(),
                          subtitle: _subtitleCtrl.text.trim(),
                          placement: _placement,
                          imageUrl: _uploadedImageUrl,
                          imageKey: _uploadedImageKey,
                          linkUrl: _linkCtrl.text.trim(),
                        )
                      : HealthPromotion(
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
              icon: Icon(
                isEditing ? Icons.save_rounded : Icons.local_offer_rounded,
              ),
              label: Text(
                isEditing ? 'Değişiklikleri Kaydet' : l10n.adminNewPromotion,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

