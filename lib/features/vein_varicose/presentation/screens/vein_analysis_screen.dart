import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:visualcheckup/core/services/camera_permission_service.dart';
import 'package:visualcheckup/core/theme/app_theme.dart';
import 'package:visualcheckup/features/vein_varicose/data/vein_repository.dart';
import 'package:visualcheckup/features/vein_varicose/data/vein_visual_analyzer.dart';
import 'package:visualcheckup/features/vein_varicose/domain/vein_models.dart';

class VeinAnalysisScreen extends StatefulWidget {
  const VeinAnalysisScreen({
    super.key,
    this.repository,
    this.visualAnalyzer,
    this.imageBytesPickerOverride,
    this.permissionService = const PermissionHandlerCameraService(),
  });

  final VeinRepository? repository;
  final VeinVisualAnalyzer? visualAnalyzer;
  final Future<Uint8List?> Function(ImageSource source)? imageBytesPickerOverride;
  final CameraPermissionService permissionService;

  @override
  State<VeinAnalysisScreen> createState() => _VeinAnalysisScreenState();
}

class _VeinAnalysisScreenState extends State<VeinAnalysisScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final VeinRepository _repository = widget.repository ?? VeinRepository();
  late final VeinVisualAnalyzer _visualAnalyzer =
      widget.visualAnalyzer ?? VeinVisualAnalyzer();

  CeapStage _selectedStage = CeapStage.c1;
  bool _heavyLegs = false;
  bool _nightCramps = false;
  bool _itching = false;
  bool _standsLongHours = false;
  bool _familyHistory = false;
  bool _ankleSwelling = false;
  bool _dvtSuddenPain = false;

  Uint8List? _capturedPhotoBytes;
  VeinVisualScanResult? _visualScanResult;
  bool _isScanningPhoto = false;

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

  Future<void> _startCameraCapture() async {
    if (widget.imageBytesPickerOverride != null) {
      final bytes = await widget.imageBytesPickerOverride!(ImageSource.camera);
      if (bytes != null) {
        await _analyzeCapturedBytes(bytes);
      }
      return;
    }

    final capturedBytes = await Navigator.of(context).push<Uint8List>(
      MaterialPageRoute<Uint8List>(
        builder: (_) => _VeinLiveCameraScreen(
          permissionService: widget.permissionService,
        ),
      ),
    );
    if (capturedBytes != null && mounted) {
      await _analyzeCapturedBytes(capturedBytes);
    }
  }

  Future<void> _pickFromGallery() async {
    Uint8List? bytes;
    if (widget.imageBytesPickerOverride != null) {
      bytes = await widget.imageBytesPickerOverride!(ImageSource.gallery);
    } else {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 88,
      );
      if (picked != null) {
        bytes = await picked.readAsBytes();
      }
    }

    if (bytes != null && mounted) {
      await _analyzeCapturedBytes(bytes);
    }
  }

  Future<void> _analyzeCapturedBytes(Uint8List bytes) async {
    setState(() {
      _capturedPhotoBytes = bytes;
      _isScanningPhoto = true;
    });

    final scanResult = await _visualAnalyzer.analyzePhoto(bytes);
    if (!mounted) return;

    setState(() {
      _visualScanResult = scanResult;
      _selectedStage = scanResult.suggestedStage;
      _isScanningPhoto = false;
    });

    _calculateAndSaveEvaluation(fromCameraScan: true);
  }

  void _clearCapturedPhoto() {
    setState(() {
      _capturedPhotoBytes = null;
      _visualScanResult = null;
    });
  }

  Future<void> _calculateAndSaveEvaluation({bool fromCameraScan = false}) async {
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
      notes: fromCameraScan ? _visualScanResult?.summaryTitle : null,
    );

    await _repository.saveRecord(record);
    final updated = await _repository.loadRecords();

    if (mounted) {
      setState(() {
        _evaluation = eval;
        _history = updated;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            fromCameraScan
                ? 'Kamera görüntüsü analiz edildi ve CEAP evresi güncellendi!'
                : 'Venöz Sağlık Değerlendirmeniz Hazırlandı!',
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
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
              icon: Icon(Icons.camera_enhance_outlined, size: 20),
              text: 'Kamera & CEAP Analizi',
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
          // 1. Camera & AI Visual Vein Scanner Card
          _buildCameraScannerCard(isDark),
          const SizedBox(height: 16),

          // Visual Scan Result Card (when a photo is scanned)
          if (_isScanningPhoto) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCanvas : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                ),
              ),
              child: const Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.6),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Kılcal damar ağı, mavi-yeşil ven kontrastı ve CEAP evresi analiz ediliyor...',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ] else if (_visualScanResult != null) ...[
            _buildVisualScanResultCard(_visualScanResult!, isDark),
            const SizedBox(height: 18),
          ],

          // 2. CEAP Stage Selector Cards
          const Text(
            '1. Bacaklarınızdaki Görsel Durumu Seçin veya Doğrulayın (CEAP):',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 10),
          for (final stage in CeapStage.values) ...[
            _buildStageChoiceCard(stage, isDark),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 16),

          // 3. Symptoms Questionnaire
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
            color:
                const Color(0xFFEF4444).withValues(alpha: isDark ? 0.2 : 0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: const Color(0xFFEF4444).withValues(alpha: 0.4),
              ),
            ),
            child: CheckboxListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
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
            onPressed: () => _calculateAndSaveEvaluation(),
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

  Widget _buildCameraScannerCard(bool isDark) {
    return Container(
      key: const Key('vein_camera_scan_card'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0284C7), Color(0xFF0D9488)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.25),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kamera ile Görsel Damar & Varis Taraması',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Bacak veya bilek bölgesinin fotoğrafını çekin; kılcal damar ağı, yüzeyel varis kontrastı ve CEAP ön evresini otomatik analiz edelim.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: FilledButton.icon(
                  key: const Key('vein_camera_capture_btn'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0284C7),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _isScanningPhoto ? null : _startCameraCapture,
                  icon: const Icon(Icons.photo_camera_rounded, size: 19),
                  label: const Text(
                    'Kamera ile Tara',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  key: const Key('vein_gallery_pick_btn'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.72),
                      width: 1.3,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _isScanningPhoto ? null : _pickFromGallery,
                  icon: const Icon(Icons.photo_library_outlined, size: 18),
                  label: const Text(
                    'Galeri',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVisualScanResultCard(VeinVisualScanResult scan, bool isDark) {
    final stageColor = scan.suggestedStage.color;

    return Container(
      key: const Key('vein_visual_scan_result_card'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCanvas : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: stageColor.withValues(alpha: 0.55),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: stageColor.withValues(alpha: isDark ? 0.18 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_capturedPhotoBytes != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    _capturedPhotoBytes!,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 64,
                      height: 64,
                      color: stageColor.withValues(alpha: 0.15),
                      child: Icon(Icons.image_outlined, color: stageColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: stageColor.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Önerilen Evre: ${scan.suggestedStage.code}',
                            style: TextStyle(
                              color: stageColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 11.5,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            scan.usedCloudAi
                                ? 'AI + Piksel Analizi'
                                : 'Görsel Damar Analizi',
                            style: const TextStyle(
                              color: Color(0xFF0284C7),
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      scan.summaryTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Fotoğrafı Temizle',
                onPressed: _clearCapturedPhoto,
                icon: const Icon(Icons.close_rounded, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            scan.summaryDetail,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricChip(
                  label: 'Kılcal Ağ',
                  value: '%${scan.capillaryDensityPercent}',
                  color: const Color(0xFF06B6D4),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricChip(
                  label: 'Ven Kontrastı',
                  value: '%${scan.prominentVeinContrastPercent}',
                  color: const Color(0xFFF59E0B),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricChip(
                  label: 'Pigmentasyon',
                  value: '%${scan.pigmentationChangePercent}',
                  color: const Color(0xFFEF4444),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          if (scan.visualFindings.isNotEmpty) ...[
            const SizedBox(height: 10),
            for (final f in scan.visualFindings)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lens, size: 7, color: stageColor),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        f,
                        style: const TextStyle(fontSize: 12, height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricChip({
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13.5,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
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
            color: isSelected
                ? color
                : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.stage.code} — Skor: ${item.symptomScore}',
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      if (item.notes != null && item.notes!.isNotEmpty)
                        Text(
                          item.notes!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF0284C7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
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
      separatorBuilder: (_, _) => const SizedBox(height: 12),
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
                    child:
                        Icon(ex.icon, color: const Color(0xFF0284C7), size: 22),
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
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : const Color(0xFFF8FAFC),
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

/// Dedicated live camera preview screen with a leg/calf framing guide,
/// torch control, lens switcher, and gallery fallback.
class _VeinLiveCameraScreen extends StatefulWidget {
  const _VeinLiveCameraScreen({
    required this.permissionService,
  });

  final CameraPermissionService permissionService;

  @override
  State<_VeinLiveCameraScreen> createState() => _VeinLiveCameraScreenState();
}

class _VeinLiveCameraScreenState extends State<_VeinLiveCameraScreen> {
  List<CameraDescription> _cameras = const [];
  CameraController? _controller;
  int _cameraIndex = 0;
  bool _isInitializing = true;
  bool _hasError = false;
  bool _torchOn = false;
  bool _isTakingPicture = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    setState(() {
      _isInitializing = true;
      _hasError = false;
    });

    var perm = await widget.permissionService.checkCamera();
    if (perm == CameraPermissionState.denied) {
      perm = await widget.permissionService.requestCamera();
    }
    if (!mounted) return;
    if (perm != CameraPermissionState.granted) {
      setState(() {
        _isInitializing = false;
        _hasError = true;
      });
      return;
    }

    try {
      final cams = await availableCameras();
      if (!mounted) return;
      if (cams.isEmpty) {
        setState(() {
          _isInitializing = false;
          _hasError = true;
        });
        return;
      }
      var backIdx = cams.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
      );
      if (backIdx == -1) backIdx = 0;
      _cameras = cams;
      await _startController(backIdx);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _hasError = true;
      });
    }
  }

  Future<void> _startController(int index) async {
    final prev = _controller;
    if (prev != null) {
      await prev.dispose();
    }
    final ctrl = CameraController(
      _cameras[index],
      ResolutionPreset.high,
      enableAudio: false,
    );
    try {
      await ctrl.initialize();
      if (!mounted) {
        await ctrl.dispose();
        return;
      }
      setState(() {
        _controller = ctrl;
        _cameraIndex = index;
        _isInitializing = false;
        _torchOn = false;
      });
    } catch (_) {
      await ctrl.dispose();
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _hasError = true;
      });
    }
  }

  Future<void> _toggleTorch() async {
    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    try {
      final next = !_torchOn;
      await ctrl.setFlashMode(next ? FlashMode.torch : FlashMode.off);
      if (mounted) setState(() => _torchOn = next);
    } catch (_) {}
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    final nextIdx = (_cameraIndex + 1) % _cameras.length;
    await _startController(nextIdx);
  }

  Future<void> _capturePhoto() async {
    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized || _isTakingPicture) return;
    setState(() => _isTakingPicture = true);
    try {
      final file = await ctrl.takePicture();
      final bytes = await file.readAsBytes();
      if (mounted) {
        Navigator.of(context).pop(bytes);
      }
    } catch (_) {
      if (mounted) setState(() => _isTakingPicture = false);
    }
  }

  Future<void> _pickGalleryFallback() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 88,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      if (mounted) Navigator.of(context).pop(bytes);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = _controller;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          'Damar & Varis Kamera Taraması',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          if (ctrl != null && ctrl.value.isInitialized) ...[
            IconButton(
              onPressed: _toggleTorch,
              icon: Icon(
                _torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                color: _torchOn ? Colors.amber : Colors.white,
              ),
            ),
            if (_cameras.length > 1)
              IconButton(
                onPressed: _switchCamera,
                icon: const Icon(Icons.cameraswitch_rounded),
              ),
          ],
        ],
      ),
      body: _isInitializing
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : (_hasError || ctrl == null || !ctrl.value.isInitialized)
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.videocam_off_outlined,
                        color: Colors.white70,
                        size: 54,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Kamera erişimi sağlanamadı veya cihazda aktif kamera bulunamadı.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: _pickGalleryFallback,
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Galeriden Fotoğraf Seç'),
                      ),
                    ],
                  ),
                )
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    Center(child: CameraPreview(ctrl)),
                    // Leg / Calf Framing Overlay Guide
                    IgnorePointer(
                      child: Center(
                        child: Container(
                          width: 260,
                          height: 360,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: const Color(0xFF38BDF8),
                              width: 2.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 16,
                      left: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text(
                          'Ayakta dururken gün ışığında bacak/bilek damar bölgesini mavi çerçeveye hizalayın (20-30 cm mesafe).',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 24,
                      right: 24,
                      bottom: 32,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton.filledTonal(
                            onPressed: _pickGalleryFallback,
                            icon: const Icon(Icons.photo_library_rounded),
                          ),
                          GestureDetector(
                            onTap: _isTakingPicture ? null : _capturePhoto,
                            child: Container(
                              width: 74,
                              height: 74,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                                color: const Color(0xFF0284C7),
                              ),
                              child: _isTakingPicture
                                  ? const Padding(
                                      padding: EdgeInsets.all(20),
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.camera_alt_rounded,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
