import 'dart:async';

import 'package:flutter/material.dart';
import 'package:visualcheckup/features/community/data/health_community_repository.dart';
import 'package:visualcheckup/features/sobriety/data/sobriety_repository.dart';
import 'package:visualcheckup/features/sobriety/domain/sobriety_models.dart';
import 'package:visualcheckup/features/widgets_hub/data/quick_widgets_preferences.dart';

class SobrietyTrackerScreen extends StatefulWidget {
  const SobrietyTrackerScreen({
    super.key,
    this.repository,
    this.communityRepository,
    this.currentUserId,
    this.currentUserDisplayName,
  });

  final SobrietyRepository? repository;
  final HealthCommunityRepository? communityRepository;
  final String? currentUserId;
  final String? currentUserDisplayName;

  @override
  State<SobrietyTrackerScreen> createState() => _SobrietyTrackerScreenState();
}

class _SobrietyTrackerScreenState extends State<SobrietyTrackerScreen>
    with SingleTickerProviderStateMixin {
  late final SobrietyRepository _repo;
  late final TabController _tabController;
  SobrietyState _state = const SobrietyState();
  bool _loading = true;
  Timer? _liveTicker;

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? SobrietyRepository();
    _tabController = TabController(length: 3, vsync: this);
    _load();
    _liveTicker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted && _state.isAnyActive) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _liveTicker?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final loaded = await _repo.loadState();
    if (!mounted) return;
    setState(() {
      _state = loaded;
      _loading = false;
    });
  }

  Future<void> _persistAndSync(SobrietyState next) async {
    setState(() => _state = next);
    await _repo.saveState(next);

    final commRepo = widget.communityRepository;
    final uid = widget.currentUserId;
    if (commRepo != null && uid != null && uid.isNotEmpty) {
      try {
        final existing = await commRepo.loadMyProfile(uid);
        if (existing != null) {
          final updatedProfile = existing.copyWith(
            showSobrietyOnProfile: next.showOnProfile,
            smokeQuitAt: next.smokeQuitAt,
            clearSmokeQuitAt: next.smokeQuitAt == null,
            alcoholQuitAt: next.alcoholQuitAt,
            clearAlcoholQuitAt: next.alcoholQuitAt == null,
            dailySmokeCostTry: next.dailySmokeSpendTry,
            dailyCigarettesCount: next.dailyCigarettes,
            dailyAlcoholCostTry: next.dailyAlcoholCostTry,
            updatedAt: DateTime.now(),
          );
          await commRepo.saveMyProfile(updatedProfile);
        }
      } catch (_) {}
    }
  }

  Future<void> _startNow(SobrietyTrackType type) async {
    final now = DateTime.now();
    final next = type == SobrietyTrackType.smoking
        ? _state.copyWith(smokeQuitAt: now)
        : _state.copyWith(alcoholQuitAt: now);
    await _persistAndSync(next);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🎉 ${type.title} başlatıldı! Gün 1 değişimleri kartın içinde açıldı.',
        ),
      ),
    );
  }

  Future<void> _pickCustomQuitDate(SobrietyTrackType type) async {
    final now = DateTime.now();
    final initial = (type == SobrietyTrackType.smoking
            ? _state.smokeQuitAt
            : _state.alcoholQuitAt) ??
        now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(now) ? now : initial,
      firstDate: DateTime(now.year - 15),
      lastDate: now,
    );
    if (picked == null || !mounted) return;
    final chosen = DateTime(picked.year, picked.month, picked.day, 9, 0);
    final next = type == SobrietyTrackType.smoking
        ? _state.copyWith(smokeQuitAt: chosen)
        : _state.copyWith(alcoholQuitAt: chosen);
    await _persistAndSync(next);
  }

  Future<void> _resetTrack(SobrietyTrackType type) async {
    final next = type == SobrietyTrackType.smoking
        ? _state.copyWith(clearSmoke: true)
        : _state.copyWith(clearAlcohol: true);
    await _persistAndSync(next);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${type.title} sayacı sıfırlandı.')),
    );
  }

  Future<void> _pinSobrietyAndroidWidget() async {
    final pinned = await QuickWidgetsPreferences.requestPinNativeHomeWidget(
      widgetType: 'sobriety',
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          pinned
              ? '📱 Sigara & Alkol Bırakma widget’ı Android ana ekranına gönderildi!'
              : 'Telefon ana ekranına basılı tutup Widget’lar menüsünden "VisualCheckUp • Sigara & Alkol Bırakma" widget’ını ekleyebilirsiniz.',
        ),
      ),
    );
  }

  Future<void> _openCostEditorSheet() async {
    final cigsCtrl =
        TextEditingController(text: _state.dailyCigarettes.toString());
    final packCtrl =
        TextEditingController(text: _state.packPriceTry.toStringAsFixed(0));
    final alcCtrl = TextEditingController(
      text: _state.dailyAlcoholCostTry.toStringAsFixed(0),
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 8,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ortalama Tüketim & Harcama Ayarları',
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Günlük ve aylık kazanılan para ile geri kazanılan ömür bu ortalamalara göre hesaplanır.',
                  style: Theme.of(ctx).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                TextField(
                  key: const Key('sobriety_cigs_field'),
                  controller: cigsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Günlük İçilen Ortalama Sigara (Dal)',
                    helperText: '1 paket = 20 dal (Varsayılan: 20)',
                    prefixIcon: Icon(Icons.smoking_rooms_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('sobriety_pack_price_field'),
                  controller: packCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: '1 Paket Sigara Ortalama Fiyatı (₺)',
                    helperText: 'Varsayılan ortalama: ₺75',
                    prefixIcon: Icon(Icons.payments_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('sobriety_alcohol_cost_field'),
                  controller: alcCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Alkol İçin Günlük Ortalama Harcama Karşılığı (₺)',
                    helperText:
                        'Aylık harcamanızı 30’a bölerek girebilirsiniz (Varsayılan: ₺120/gün • ₺3.600/ay)',
                    prefixIcon: Icon(Icons.local_bar_rounded),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    key: const Key('sobriety_save_costs_btn'),
                    onPressed: () {
                      final cigs =
                          (int.tryParse(cigsCtrl.text.trim()) ?? 20).clamp(1, 100);
                      final pack = (double.tryParse(
                                packCtrl.text.trim().replaceAll(',', '.'),
                              ) ??
                              75.0)
                          .clamp(0.0, 5000.0);
                      final alc = (double.tryParse(
                                alcCtrl.text.trim().replaceAll(',', '.'),
                              ) ??
                              120.0)
                          .clamp(0.0, 10000.0);
                      Navigator.of(ctx).pop();
                      _persistAndSync(
                        _state.copyWith(
                          dailyCigarettes: cigs,
                          packPriceTry: pack,
                          dailyAlcoholCostTry: alc,
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Hesaplamayı Güncelle'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sigara & Alkol Bırakma'),
        actions: [
          IconButton(
            key: const Key('sobriety_pin_android_widget_btn'),
            tooltip: 'Android Ana Ekrana Widget Ekle',
            onPressed: _pinSobrietyAndroidWidget,
            icon: const Icon(Icons.add_to_home_screen_rounded),
          ),
          IconButton(
            tooltip: 'Harcama Ortalamasını Düzenle',
            onPressed: _openCostEditorSheet,
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(
              key: Key('sobriety_tab_timeline'),
              icon: Icon(Icons.bolt_rounded, size: 18),
              text: 'Takip & Günlük Değişim',
            ),
            Tab(
              key: Key('sobriety_tab_harms'),
              icon: Icon(Icons.health_and_safety_outlined, size: 18),
              text: 'Zararları',
            ),
            Tab(
              key: Key('sobriety_tab_tips'),
              icon: Icon(Icons.tips_and_updates_outlined, size: 18),
              text: 'Öneriler & Destek',
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMainTrackerAndProgressiveCardsTab(
                  context,
                  now,
                  theme,
                  colorScheme,
                ),
                _buildHarmsTab(context, theme),
                _buildTipsTab(context, theme),
              ],
            ),
    );
  }

  Widget _buildMainTrackerAndProgressiveCardsTab(
    BuildContext context,
    DateTime now,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
      children: [
        _buildFinancialAndLongevityHero(context, now, theme, colorScheme),
        const SizedBox(height: 12),
        _SingleTrackActionCard(
          key: const Key('sobriety_smoking_card'),
          type: SobrietyTrackType.smoking,
          isActive: _state.isSmokingActive,
          dayNumber: _state.smokeCurrentDayNumber(now),
          elapsed: _state.smokeElapsedAt(now),
          savedTry: _state.smokeMoneySavedAt(now),
          dailyAvgTry: _state.dailySmokeSpendTry,
          monthlyAvgTry: _state.monthlySmokeSpendTry,
          onStartNow: () => _startNow(SobrietyTrackType.smoking),
          onPickDate: () => _pickCustomQuitDate(SobrietyTrackType.smoking),
          onReset: () => _resetTrack(SobrietyTrackType.smoking),
        ),
        const SizedBox(height: 12),
        _SingleTrackActionCard(
          key: const Key('sobriety_alcohol_card'),
          type: SobrietyTrackType.alcohol,
          isActive: _state.isAlcoholActive,
          dayNumber: _state.alcoholCurrentDayNumber(now),
          elapsed: _state.alcoholElapsedAt(now),
          savedTry: _state.alcoholMoneySavedAt(now),
          dailyAvgTry: _state.dailyAlcoholCostTry,
          monthlyAvgTry: _state.monthlyAlcoholSpendTry,
          onStartNow: () => _startNow(SobrietyTrackType.alcohol),
          onPickDate: () => _pickCustomQuitDate(SobrietyTrackType.alcohol),
          onReset: () => _resetTrack(SobrietyTrackType.alcohol),
        ),
        const SizedBox(height: 12),
        Card(
          margin: EdgeInsets.zero,
          child: SwitchListTile(
            key: const Key('sobriety_profile_visibility_switch'),
            dense: true,
            secondary: Icon(
              _state.showOnProfile
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_outlined,
              color: colorScheme.primary,
            ),
            title: const Text(
              'Profil Kartımda Göster',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              _state.showOnProfile
                  ? 'Bulunduğunuz günün vücut değişimi, kazancınız ve kazanılan ömür profilinizde görünür.'
                  : 'Gizli: Yalnızca siz bu ekranda görebilirsiniz.',
              style: theme.textTheme.bodySmall,
            ),
            value: _state.showOnProfile,
            onChanged: (val) => _persistAndSync(
              _state.copyWith(showOnProfile: val),
            ),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _pinSobrietyAndroidWidget,
          icon: const Icon(Icons.add_to_home_screen_rounded),
          label: const Text('Sigara & Alkol Widget’ını Android Ana Ekrana Ekle'),
        ),
      ],
    );
  }

  Widget _buildFinancialAndLongevityHero(
    BuildContext context,
    DateTime now,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final todaySaved = _state.todayMoneySavedAt(now);
    final totalSaved = _state.totalMoneySavedAt(now);
    final lifeRegained = _state.lifeRegainedAt(now);
    final cigsAvoided = _state.unsmokedCigarettesAt(now);

    return Container(
      key: const Key('sobriety_hero_card'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF115E59), Color(0xFF134E4A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F766E).withValues(alpha: 0.24),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.savings_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _state.isAnyActive
                          ? 'Bugün ${SobrietyState.formatTry(todaySaved)} Kazandınız! 🎉'
                          : 'Ortalama Harcama & Kazanç Hesabı',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Sigara Ort: ${SobrietyState.formatTry(_state.dailySmokeSpendTry)}/gün (${SobrietyState.formatTry(_state.monthlySmokeSpendTry)}/ay) • '
                      'Alkol Ort: ${SobrietyState.formatTry(_state.dailyAlcoholCostTry)}/gün (${SobrietyState.formatTry(_state.monthlyAlcoholSpendTry)}/ay)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.88),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: _openCostEditorSheet,
                icon: const Icon(
                  Icons.edit_outlined,
                  color: Colors.white,
                  size: 18,
                ),
                tooltip: 'Ortalamayı Düzenle',
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _HeroMetricTile(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Toplam Kazanılan Para',
                  value: _state.isAnyActive
                      ? SobrietyState.formatTry(totalSaved)
                      : '${SobrietyState.formatTry(_state.combinedMonthlySpendTry)}/ay potansiyel',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeroMetricTile(
                  icon: Icons.favorite_rounded,
                  label: 'Kazanılan Ömür',
                  value: _state.isAnyActive
                      ? '+${SobrietyState.formatLifeRegained(lifeRegained)}'
                      : '+3s 40dk / gün',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _HeroMetricTile(
                  icon: Icons.smoke_free_rounded,
                  label: 'İçilmeyen Sigara',
                  value: '$cigsAvoided Dal',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeroMetricTile(
                  icon: Icons.emoji_events_rounded,
                  label: 'Aktif Özgürlük Günü',
                  value: _state.isAnyActive
                      ? 'Gün ${_state.maxActiveDayNumber(now)}'
                      : 'Henüz Başlamadı',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHarmsTab(BuildContext context, ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        Text(
          '🚭 Sigaranın Vücuda Verdiği Zararlar',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        for (final item in SobrietyKnowledgeBase.smokingHarms) ...[
          _HarmCard(item: item),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 16),
        Text(
          '🍷 Alkolün Vücuda Verdiği Zararlar',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        for (final item in SobrietyKnowledgeBase.alcoholHarms) ...[
          _HarmCard(item: item),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildTipsTab(BuildContext context, ThemeData theme) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      itemCount: SobrietyKnowledgeBase.recommendations.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final tip = SobrietyKnowledgeBase.recommendations[index];
        return Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: tip.accentColor.withValues(alpha: 0.14),
                  child: Icon(tip.icon, color: tip.accentColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tip.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tip.body,
                        style: theme.textTheme.bodySmall?.copyWith(height: 1.45),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeroMetricTile extends StatelessWidget {
  const _HeroMetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.amberAccent, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SingleTrackActionCard extends StatefulWidget {
  const _SingleTrackActionCard({
    super.key,
    required this.type,
    required this.isActive,
    required this.dayNumber,
    required this.elapsed,
    required this.savedTry,
    required this.dailyAvgTry,
    required this.monthlyAvgTry,
    required this.onStartNow,
    required this.onPickDate,
    required this.onReset,
  });

  final SobrietyTrackType type;
  final bool isActive;
  final int dayNumber;
  final Duration elapsed;
  final double savedTry;
  final double dailyAvgTry;
  final double monthlyAvgTry;
  final VoidCallback onStartNow;
  final VoidCallback onPickDate;
  final VoidCallback onReset;

  @override
  State<_SingleTrackActionCard> createState() => _SingleTrackActionCardState();
}

class _SingleTrackActionCardState extends State<_SingleTrackActionCard> {
  bool _showPastDays = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = widget.type.accentColor;
    final unlockedFeed = widget.isActive
        ? SobrietyKnowledgeBase.unlockedDailyFeed(widget.dayNumber)
        : const <BodyRecoveryMilestone>[];
    final todayEntry = unlockedFeed.isNotEmpty ? unlockedFeed.first : null;
    final previousEntries = unlockedFeed.length > 1
        ? unlockedFeed.sublist(1)
        : const <BodyRecoveryMilestone>[];

    String changeTextFor(BodyRecoveryMilestone m) =>
        widget.type == SobrietyTrackType.smoking
            ? m.smokingChange
            : m.alcoholChange;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: widget.isActive
              ? accent.withValues(alpha: 0.55)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: widget.isActive ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 19,
                  backgroundColor: accent.withValues(alpha: 0.14),
                  child: Icon(widget.type.icon, color: accent, size: 21),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.type.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        widget.isActive
                            ? 'Gün ${widget.dayNumber} (${widget.elapsed.inDays}g ${widget.elapsed.inHours % 24}s) • Kazanç: ${SobrietyState.formatTry(widget.savedTry)}'
                            : 'Ort. Harcama: ${SobrietyState.formatTry(widget.dailyAvgTry)}/gün • ${SobrietyState.formatTry(widget.monthlyAvgTry)}/ay',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: widget.isActive
                              ? accent
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: widget.isActive
                              ? FontWeight.w700
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Progressive Day-by-Day Change INSIDE THE CARD (ONLY shows unlocked days!)
            if (!widget.isActive)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'Başlattığınızda geçen her gün vücudunuzda gerçekleşen değişimler ("Gün 1: ...", "Gün 2: ...") gün geçtikçe bu kartın içinde yazacaktır.',
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                ),
              )
            else if (todayEntry != null) ...[
              Container(
                key: Key('sobriety_live_day_box_${widget.type.name}'),
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: accent.withValues(alpha: 0.32)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Gün ${todayEntry.dayNumber}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            todayEntry.title,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'Gün ${todayEntry.dayNumber}: ${changeTextFor(todayEntry)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '⏳ Gün ${widget.dayNumber + 1} değişimi bir sonraki gün tamamlandığında açılacak.',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              if (previousEntries.isNotEmpty) ...[
                const SizedBox(height: 6),
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => setState(() => _showPastDays = !_showPastDays),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 4,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _showPastDays
                              ? Icons.expand_less_rounded
                              : Icons.history_rounded,
                          size: 16,
                          color: accent,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _showPastDays
                              ? 'Geçmiş Günleri Gizle'
                              : 'Geride Kalan Günlerin Değişimleri (${previousEntries.length} gün)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_showPastDays) ...[
                  const SizedBox(height: 6),
                  for (final past in previousEntries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '✓ Gün ${past.dayNumber}: ${changeTextFor(past)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            height: 1.38,
                          ),
                        ),
                      ),
                    ),
                ],
              ],
            ],

            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (!widget.isActive)
                  FilledButton.icon(
                    key: Key('sobriety_start_${widget.type.name}_btn'),
                    style: FilledButton.styleFrom(
                      backgroundColor: accent,
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: widget.onStartNow,
                    icon: const Icon(Icons.play_arrow_rounded, size: 18),
                    label: const Text('Başlat'),
                  ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: widget.onPickDate,
                  icon: const Icon(Icons.calendar_month_rounded, size: 16),
                  label: Text(
                    widget.isActive
                        ? 'Bırakma Tarihini Değiştir'
                        : 'Geçmiş Tarih Seç',
                  ),
                ),
                if (widget.isActive)
                  TextButton.icon(
                    key: Key('sobriety_reset_${widget.type.name}_btn'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: widget.onReset,
                    icon: const Icon(Icons.restart_alt_rounded, size: 16),
                    label: const Text('Sıfırla'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HarmCard extends StatelessWidget {
  const _HarmCard({required this.item});

  final HarmInfoItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: item.color.withValues(alpha: 0.14),
              child: Icon(item.icon, color: item.color, size: 19),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.organTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
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
