import 'package:flutter/material.dart';
import 'package:visualcheckup/core/theme/app_theme.dart';
import 'package:visualcheckup/features/vein_varicose/data/vein_repository.dart';
import 'package:visualcheckup/features/vein_varicose/domain/vein_models.dart';

class VeinAnalysisScreen extends StatefulWidget {
  const VeinAnalysisScreen({
    super.key,
    this.repository,
  });

  final VeinRepository? repository;

  @override
  State<VeinAnalysisScreen> createState() => _VeinAnalysisScreenState();
}

class _VeinAnalysisScreenState extends State<VeinAnalysisScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final VeinRepository _repository = widget.repository ?? VeinRepository();

  CeapStage _selectedStage = CeapStage.c1;
  bool _heavyLegs = false;
  bool _nightCramps = false;
  bool _itching = false;
  bool _standsLongHours = false;
  bool _familyHistory = false;
  bool _ankleSwelling = false;
  bool _dvtSuddenPain = false;

  VeinHealthEvaluation? _evaluation;
  List<VeinCheckRecord> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final records = await _repository.loadRecords();
    if (mounted) {
      setState(() {
        _history = records;
        _isLoading = false;
        if (records.isNotEmpty) {
          final latest = records.first;
          _selectedStage = latest.stage;
          _evaluation = evaluateVeinHealth(
            stage: latest.stage,
            symptoms: VeinSymptomAssessment(
              hasHeavyLegsEvening: latest.symptomScore > 10,
              hasAnkleSwelling: latest.stage.index >= CeapStage.c3.index,
            ),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _calculateAndSaveEvaluation() async {
    final symptoms = VeinSymptomAssessment(
      hasHeavyLegsEvening: _heavyLegs,
      hasNightCramps: _nightCramps,
      hasItchingOrBurning: _itching,
      standsOrSitsLongHours: _standsLongHours,
      hasFamilyHistory: _familyHistory,
      hasAnkleSwelling: _ankleSwelling,
      hasSuddenPainOrAsymmetricSwelling: _dvtSuddenPain,
    );

    final eval = evaluateVeinHealth(
      stage: _selectedStage,
      symptoms: symptoms,
    );

    final record = VeinCheckRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      recordedAt: DateTime.now(),
      stage: _selectedStage,
      symptomScore: symptoms.riskScore,
    );

    await _repository.saveRecord(record);
    final updated = await _repository.loadRecords();

    if (mounted) {
      setState(() {
        _evaluation = eval;
        _history = updated;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Venöz Sağlık Değerlendirmeniz Hazırlandı!'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.airline_seat_legroom_extra_rounded,
                color: Color(0xFF0284C7), size: 24),
            SizedBox(width: 8),
            Text(
              'Damar & Varis Taraması',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF0284C7),
          labelColor: const Color(0xFF0284C7),
          unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
          tabs: const [
            Tab(
              icon: Icon(Icons.analytics_outlined, size: 20),
              text: 'Damar & Varis Testi',
            ),
            Tab(
              icon: Icon(Icons.fitness_center_rounded, size: 20),
              text: 'Koruyucu Egzersizler',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAnalysisTab(isDark),
                _buildExercisesTab(isDark),
              ],
            ),
    );
  }

  Widget _buildAnalysisTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0284C7), Color(0xFF0D9488)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: Colors.white, size: 22),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Uluslararası CEAP Kılavuzuna göre bacak damarlarınızın durumunu ve venöz riskinizi belirleyin.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // CEAP Stage Selector Cards
          const Text(
            '1. Bacaklarınızdaki Görsel Durumu Seçin (CEAP):',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 10),
          for (final stage in CeapStage.values) ...[
            _buildStageChoiceCard(stage, isDark),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 16),

          // Symptoms Questionnaire
          const Text(
            '2. Günlük Bacak Şikayetleriniz (Semptom Skoru):',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          _buildSymptomCheckbox(
            title: 'Akşamları bacaklarda ağırlık, yorgunluk veya yanma',
            value: _heavyLegs,
            onChanged: (v) => setState(() => _heavyLegs = v ?? false),
            isDark: isDark,
          ),
          _buildSymptomCheckbox(
            title: 'Geceleri baldır krampları',
            value: _nightCramps,
            onChanged: (v) => setState(() => _nightCramps = v ?? false),
            isDark: isDark,
          ),
          _buildSymptomCheckbox(
            title: 'Ayak bileklerinde gün sonu şişlik / ödem',
            value: _ankleSwelling,
            onChanged: (v) => setState(() => _ankleSwelling = v ?? false),
            isDark: isDark,
          ),
          _buildSymptomCheckbox(
            title: 'Damarlar üzerinde kaşıntı veya zonklama',
            value: _itching,
            onChanged: (v) => setState(() => _itching = v ?? false),
            isDark: isDark,
          ),
          _buildSymptomCheckbox(
            title: 'İş gereği günde >4 saat ayakta kalma veya oturma',
            value: _standsLongHours,
            onChanged: (v) => setState(() => _standsLongHours = v ?? false),
            isDark: isDark,
          ),
          _buildSymptomCheckbox(
            title: 'Ailede varis veya venöz yetmezlik öyküsü',
            value: _familyHistory,
            onChanged: (v) => setState(() => _familyHistory = v ?? false),
            isDark: isDark,
          ),
          const SizedBox(height: 8),

          // DVT Alert Checkbox
          Material(
            color: const Color(0xFFEF4444).withValues(alpha: isDark ? 0.2 : 0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: const Color(0xFFEF4444).withValues(alpha: 0.4),
              ),
            ),
            child: CheckboxListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              activeColor: const Color(0xFFEF4444),
              title: const Text(
                '⚠️ Tek bacakta ANİ gelişen şiddetli ağrı ve belirgin şişlik var mı?',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEF4444),
                ),
              ),
              subtitle: const Text(
                'DVT (Derin Ven Trombozu / pıhtı) acil kontrolü gerektirebilir.',
                style: TextStyle(fontSize: 11),
              ),
              value: _dvtSuddenPain,
              onChanged: (v) => setState(() => _dvtSuddenPain = v ?? false),
            ),
          ),
          const SizedBox(height: 18),

          // Evaluate Button
          FilledButton.icon(
            key: const Key('vein_submit_btn'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.check_circle_outline_rounded, size: 22),
            label: const Text(
              'Damar Durumunu Değerlendir & Raporla',
              style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
            ),
            onPressed: _calculateAndSaveEvaluation,
          ),
          const SizedBox(height: 20),

          // Report Card
          if (_evaluation != null) ...[
            _buildReportCard(_evaluation!, isDark),
            const SizedBox(height: 20),
          ],

          // History Section
          if (_history.isNotEmpty) _buildHistoryList(isDark),
        ],
      ),
    );
  }

  Widget _buildStageChoiceCard(CeapStage stage, bool isDark) {
    final isSelected = _selectedStage == stage;
    final color = stage.color;

    return InkWell(
      key: Key('ceap_stage_${stage.name}'),
      onTap: () => setState(() => _selectedStage = stage),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: isDark ? 0.2 : 0.1)
              : (isDark ? AppTheme.darkCanvas : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(stage.icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stage.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                      color: isSelected ? color : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stage.shortDescription,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark ? Colors.white70 : Colors.black87,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: color, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomCheckbox({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: isDark ? AppTheme.darkCanvas : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
          ),
        ),
        child: CheckboxListTile(
          dense: true,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(title, style: const TextStyle(fontSize: 12.5)),
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF0284C7),
        ),
      ),
    );
  }

  Widget _buildReportCard(VeinHealthEvaluation eval, bool isDark) {
    final color = eval.stage.color;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCanvas : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.2 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(eval.stage.icon, color: color, size: 24),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eval.riskLevel,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'Semptom Skoru: ${eval.symptomScore} / 100',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            eval.clinicalSummary,
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
          if (eval.isDvtWarning && eval.dvtEmergencyNotice != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEF4444)),
              ),
              child: Text(
                eval.dvtEmergencyNotice!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEF4444),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 6),
          const Text(
            'Damar Sağlığı & Önlem Önerileri:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 6),
          for (final rec in eval.recommendations) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline_rounded,
                      color: Color(0xFF0284C7), size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      rec,
                      style: const TextStyle(fontSize: 12, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0284C7).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.medical_services_outlined,
                    color: Color(0xFF0284C7), size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Önerilen Uzmanlık: ${eval.recommendedSpecialty}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0284C7),
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

  Widget _buildHistoryList(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Geçmiş Taramalar',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        for (final item in _history.take(4)) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCanvas : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                Icon(item.stage.icon, color: item.stage.color, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${item.stage.code} — Skor: ${item.symptomScore}',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  '${item.recordedAt.day}.${item.recordedAt.month}.${item.recordedAt.year}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildExercisesTab(bool isDark) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      itemCount: kVeinExercises.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) {
        final ex = kVeinExercises[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCanvas : Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(ex.icon, color: const Color(0xFF0284C7), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ex.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          ex.subtitle,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${ex.durationSec} sn',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5,
                        color: Color(0xFF0284C7),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                ex.instruction,
                style: const TextStyle(fontSize: 12.5, height: 1.4),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline_rounded,
                        color: Color(0xFFF59E0B), size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        ex.benefit,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
