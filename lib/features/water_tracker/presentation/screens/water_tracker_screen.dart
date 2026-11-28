import 'package:flutter/material.dart';
import 'package:visualcheckup/core/theme/app_theme.dart';
import 'package:visualcheckup/features/water_tracker/data/water_repository.dart';
import 'package:visualcheckup/features/water_tracker/domain/water_models.dart';

class WaterTrackerScreen extends StatefulWidget {
  const WaterTrackerScreen({
    super.key,
    this.repository,
  });

  final WaterRepository? repository;

  @override
  State<WaterTrackerScreen> createState() => _WaterTrackerScreenState();
}

class _WaterTrackerScreenState extends State<WaterTrackerScreen> {
  late final WaterRepository _repository = widget.repository ?? WaterRepository();

  DailyWaterSummary? _todaySummary;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final summary = await _repository.getTodaySummary();
    if (mounted) {
      setState(() {
        _todaySummary = summary;
        _isLoading = false;
      });
    }
  }

  Future<void> _addWater(int amountMl) async {
    await _repository.logWater(amountMl);
    await _loadData();
  }

  Future<void> _showCustomAmountDialog() async {
    final controller = TextEditingController(text: '250');
    final amount = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Özel Su Miktarı Ekle'),
        content: TextField(
          key: const Key('custom_water_input'),
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            suffixText: 'ml',
            hintText: 'Örn: 250',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('İptal'),
          ),
          FilledButton(
            key: const Key('custom_water_save_btn'),
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null && val > 0) {
                Navigator.of(ctx).pop(val);
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );

    if (amount != null && mounted) {
      await _addWater(amount);
    }
  }

  Future<void> _showEditTargetDialog() async {
    if (_todaySummary == null) return;
    final controller =
        TextEditingController(text: _todaySummary!.targetMl.toString());

    final newTarget = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Günlük Su Hedefini Ayarla'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            suffixText: 'ml',
            helperText: 'Yetişkinler için önerilen: 2000 – 3500 ml',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null && val >= 1000) {
                Navigator.of(ctx).pop(val);
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );

    if (newTarget != null && mounted) {
      await _repository.setDailyTarget(newTarget);
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final summary = _todaySummary ??
        DailyWaterSummary(
          date: DateTime.now(),
          consumedMl: 0,
          targetMl: 2500,
          entries: const [],
        );

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.water_drop_rounded, color: Color(0xFF0284C7), size: 24),
            SizedBox(width: 8),
            Text(
              'Su Takibi & Hidrasyon',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Hedefi Düzenle',
            icon: const Icon(Icons.tune_rounded),
            onPressed: _showEditTargetDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Main Visual Hydration Gauge Card
                  _buildGaugeCard(summary, isDark),
                  const SizedBox(height: 20),

                  // Quick Add Buttons Row
                  const Text(
                    'Hızlı Su Ekle:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickAddButton(
                          key: const Key('water_add_200'),
                          label: '+200 ml',
                          subtitle: 'Bardak',
                          icon: Icons.local_cafe_rounded,
                          amount: 200,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildQuickAddButton(
                          key: const Key('water_add_330'),
                          label: '+330 ml',
                          subtitle: 'Küçük Şişe',
                          icon: Icons.local_drink_rounded,
                          amount: 330,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildQuickAddButton(
                          key: const Key('water_add_500'),
                          label: '+500 ml',
                          subtitle: 'Büyük Şişe',
                          icon: Icons.water_drop_rounded,
                          amount: 500,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    key: const Key('water_add_custom'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: const Text('Farklı Miktar Ekle'),
                    onPressed: _showCustomAmountDialog,
                  ),
                  const SizedBox(height: 24),

                  // Today's Logs List
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Bugünkü Kayıtlar',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      if (summary.entries.isNotEmpty)
                        TextButton(
                          onPressed: () async {
                            await _repository.resetToday();
                            await _loadData();
                          },
                          child: const Text('Bugünü Sıfırla'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (summary.entries.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkCanvas : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.opacity_rounded,
                              size: 32, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'Henüz bugün için su girişi yapmadınız.',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Güne bir bardak taze su ile başlamak metabolizmayı canlandırır!',
                            style: TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: summary.entries.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 6),
                      itemBuilder: (ctx, idx) {
                        final entry = summary.entries[idx];
                        final timeStr =
                            '${entry.timestamp.hour.toString().padLeft(2, '0')}:${entry.timestamp.minute.toString().padLeft(2, '0')}';

                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.darkCanvas : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white10
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.water_drop_rounded,
                                  color: Color(0xFF0284C7), size: 18),
                              const SizedBox(width: 10),
                              Text(
                                '+${entry.amountMl} ml',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                timeStr,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.close_rounded,
                                    size: 16, color: Colors.grey),
                                onPressed: () async {
                                  await _repository.removeEntry(entry.id);
                                  await _loadData();
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 24),
                  // Healthy hydration tips
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7).withValues(alpha: isDark ? 0.15 : 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.tips_and_updates_rounded,
                            color: Color(0xFF0284C7), size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'İpucu: Yeterli hidrasyon kanın viskozitesini (koyuluğunu) düşürerek damar içi pıhtılaşma ve varis riskini azaltır, böbreklerin toksin filtreleme kapasitesini destekler.',
                            style: TextStyle(fontSize: 11.5, height: 1.4),
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

  Widget _buildGaugeCard(DailyWaterSummary summary, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCanvas : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 170,
                height: 170,
                child: CircularProgressIndicator(
                  value: summary.progressRatio,
                  strokeWidth: 12,
                  backgroundColor:
                      isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF0284C7),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.water_drop_rounded,
                      size: 28, color: Color(0xFF0284C7)),
                  const SizedBox(height: 4),
                  Text(
                    '${summary.consumedMl}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    '/ ${summary.targetMl} ml',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '%${summary.progressPercent}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0284C7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            summary.isGoalAchieved
                ? '🎉 Tebrikler! Günlük su hedefinize ulaştınız.'
                : 'Hedefe kalan: ${summary.remainingMl} ml',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13.5,
              color: summary.isGoalAchieved
                  ? const Color(0xFF10B981)
                  : (isDark ? Colors.white70 : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddButton({
    required Key key,
    required String label,
    required String subtitle,
    required IconData icon,
    required int amount,
    required bool isDark,
  }) {
    return InkWell(
      key: key,
      onTap: () => _addWater(amount),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCanvas : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF0284C7), size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
