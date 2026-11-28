import 'dart:async';
import 'package:flutter/material.dart';
import 'package:visualcheckup/core/theme/app_theme.dart';
import 'package:visualcheckup/features/auth/domain/auth_user.dart';
import 'package:visualcheckup/features/breath_lung/data/breath_lung_repository.dart';
import 'package:visualcheckup/features/breath_lung/domain/breath_lung_models.dart';

class BreathLungScreen extends StatefulWidget {
  const BreathLungScreen({
    super.key,
    this.currentUser,
    this.initialAge,
    this.repository,
  });

  final AuthUser? currentUser;
  final int? initialAge;
  final BreathLungRepository? repository;

  @override
  State<BreathLungScreen> createState() => _BreathLungScreenState();
}

class _BreathLungScreenState extends State<BreathLungScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Age state
  int _currentAge = 30;

  // Breath Test state
  BreathTestMode _testMode = BreathTestMode.inspiratoryCapacity;
  bool _isHolding = false;
  Stopwatch _stopwatch = Stopwatch();
  Timer? _tickerTimer;
  double _elapsedSeconds = 0.0;
  LungHealthEvaluation? _lastEvaluation;
  List<BreathHoldRecord> _history = [];
  bool _isLoading = true;

  // Guided Exercise state
  late GuidedBreathingExercise _selectedExercise;
  bool _isExercising = false;
  int _currentPhaseIndex = 0;
  int _remainingPhaseSeconds = 0;
  int _currentCycle = 1;
  Timer? _exerciseTimer;
  int _totalCompletedExercises = 0;

  late final BreathLungRepository _repository =
      widget.repository ?? BreathLungRepository();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedExercise = kGuidedBreathingExercises.first;
    _initData();
  }

  Future<void> _initData() async {
    final cachedAge = await _repository.getLastAge();
    final resolvedAge = widget.initialAge ??
        _repository.resolveInitialAge(
          birthDate: widget.currentUser?.birthDate,
          cachedAge: cachedAge,
        );
    final records = await _repository.loadRecords();
    final exerciseCount = await _repository.getExerciseCompletedCount();

    if (mounted) {
      setState(() {
        _currentAge = resolvedAge;
        _history = records;
        _totalCompletedExercises = exerciseCount;
        _isLoading = false;
        if (records.isNotEmpty) {
          final latest = records.first;
          _lastEvaluation = evaluateBreathHoldByAge(
            age: latest.age,
            holdSeconds: latest.holdSeconds,
            mode: latest.mode,
            gender: widget.currentUser?.gender,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    _exerciseTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // BREATH TEST ACTIONS
  // ---------------------------------------------------------------------------

  void _startBreathTest() {
    setState(() {
      _isHolding = true;
      _elapsedSeconds = 0.0;
      _stopwatch = Stopwatch()..start();
    });

    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _elapsedSeconds = _stopwatch.elapsedMilliseconds / 1000.0;
      });
    });
  }

  Future<void> _stopBreathTest() async {
    _stopwatch.stop();
    _tickerTimer?.cancel();
    final holdSec = _stopwatch.elapsedMilliseconds / 1000.0;

    final eval = evaluateBreathHoldByAge(
      age: _currentAge,
      holdSeconds: holdSec,
      mode: _testMode,
      gender: widget.currentUser?.gender,
    );

    final record = BreathHoldRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      recordedAt: DateTime.now(),
      age: _currentAge,
      holdSeconds: holdSec,
      mode: _testMode,
      score: eval.score,
      level: eval.level,
    );

    await _repository.saveRecord(record);
    final updatedHistory = await _repository.loadRecords();

    if (mounted) {
      setState(() {
        _isHolding = false;
        _elapsedSeconds = holdSec;
        _lastEvaluation = eval;
        _history = updatedHistory;
      });
    }
  }

  void _resetBreathTest() {
    _stopwatch.reset();
    _tickerTimer?.cancel();
    setState(() {
      _isHolding = false;
      _elapsedSeconds = 0.0;
    });
  }

  Future<void> _showManualInputDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.edit_calendar_rounded, color: Color(0xFF0D9488)),
            SizedBox(width: 8),
            Text('Süreyi Elle Gir', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$_currentAge Yaşında kronometreyle ölçtüğünüz süreyi saniye cinsinden giriniz:',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('manual_seconds_input'),
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Örn: 48.5',
                suffixText: 'saniye',
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('İptal'),
          ),
          FilledButton(
            key: const Key('manual_seconds_save_btn'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final parsed = double.tryParse(controller.text.replaceAll(',', '.'));
              if (parsed != null && parsed >= 0) {
                Navigator.of(ctx).pop(parsed);
              }
            },
            child: const Text('Değerlendir'),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      final eval = evaluateBreathHoldByAge(
        age: _currentAge,
        holdSeconds: result,
        mode: _testMode,
        gender: widget.currentUser?.gender,
      );

      final record = BreathHoldRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        recordedAt: DateTime.now(),
        age: _currentAge,
        holdSeconds: result,
        mode: _testMode,
        score: eval.score,
        level: eval.level,
      );

      await _repository.saveRecord(record);
      final updated = await _repository.loadRecords();

      setState(() {
        _elapsedSeconds = result;
        _lastEvaluation = eval;
        _history = updated;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // GUIDED EXERCISE ACTIONS
  // ---------------------------------------------------------------------------

  void _startExercise() {
    if (_selectedExercise.phases.isEmpty) return;

    setState(() {
      _isExercising = true;
      _currentPhaseIndex = 0;
      _remainingPhaseSeconds = _selectedExercise.phases[0].durationSeconds;
      _currentCycle = 1;
    });

    _exerciseTimer?.cancel();
    _exerciseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_remainingPhaseSeconds > 1) {
          _remainingPhaseSeconds--;
        } else {
          // Advance phase
          if (_currentPhaseIndex < _selectedExercise.phases.length - 1) {
            _currentPhaseIndex++;
            _remainingPhaseSeconds =
                _selectedExercise.phases[_currentPhaseIndex].durationSeconds;
          } else {
            // Completed one full cycle
            if (_currentCycle < _selectedExercise.recommendedCycles) {
              _currentCycle++;
              _currentPhaseIndex = 0;
              _remainingPhaseSeconds =
                  _selectedExercise.phases[0].durationSeconds;
            } else {
              // Finished all cycles!
              _stopExercise(completed: true);
            }
          }
        }
      });
    });
  }

  void _stopExercise({bool completed = false}) {
    _exerciseTimer?.cancel();
    setState(() {
      _isExercising = false;
      _currentPhaseIndex = 0;
      _remainingPhaseSeconds = 0;
      _currentCycle = 1;
    });

    if (completed) {
      _repository.incrementExerciseCompletedCount().then((cnt) {
        if (mounted) {
          setState(() => _totalCompletedExercises = cnt);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tebrikler! ${_selectedExercise.title} başarıyla tamamlandı. Akciğerlerin rahatladı!',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      });
    }
  }

  // ---------------------------------------------------------------------------
  // BUILD METHOD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.air_rounded, color: Color(0xFF0D9488), size: 24),
            SizedBox(width: 8),
            Text(
              'Nefes & Akciğer Sağlığı',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF0D9488),
          labelColor: const Color(0xFF0D9488),
          unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
          tabs: const [
            Tab(
              icon: Icon(Icons.timer_outlined, size: 20),
              text: 'Akciğer Testi',
            ),
            Tab(
              icon: Icon(Icons.self_improvement_rounded, size: 20),
              text: 'Nefes Egzersizleri',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTestTab(isDark),
                _buildExercisesTab(isDark),
              ],
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1: AKCİĞER NEFES TESTİ
  // ---------------------------------------------------------------------------

  Widget _buildTestTab(bool isDark) {
    final currentNorm = _testMode == BreathTestMode.controlPause
        ? kButeykoControlPauseNorm
        : kAgeBreathNorms.firstWhere(
            (n) => n.containsAge(_currentAge),
            orElse: () => kAgeBreathNorms[1],
          );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Safety warning banner
          _buildSafetyBanner(isDark),
          const SizedBox(height: 12),

          // Age & Norm Info Card
          _buildAgeAndNormCard(isDark, currentNorm),
          const SizedBox(height: 12),

          // Test Mode Selector
          _buildModeSelector(isDark),
          const SizedBox(height: 16),

          // Stopwatch & Lung Interactive Ring
          _buildStopwatchCircle(isDark, currentNorm),
          const SizedBox(height: 16),

          // Evaluation Report Card (if present)
          if (_lastEvaluation != null) ...[
            _buildEvaluationReportCard(isDark, _lastEvaluation!),
            const SizedBox(height: 16),
          ],

          // History Section
          _buildHistorySection(isDark),
        ],
      ),
    );
  }

  Widget _buildSafetyBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFEF4444).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.health_and_safety_rounded,
            color: Color(0xFFEF4444),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Güvenlik Notu: Kendinizi asla bayılacak veya başınız dönecek kadar zorlamayınız. Su içinde asla nefes tutma testi yapmayınız. Rahatsızlık hissederseniz testi anında durdurun.',
              style: TextStyle(
                fontSize: 11.5,
                color: isDark ? Colors.red.shade200 : Colors.red.shade900,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeAndNormCard(bool isDark, AgeBreathNorm currentNorm) {
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_pin_rounded,
                  color: Color(0xFF0D9488),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Yaşa Göre Akciğer Kapasitesi',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                      ),
                    ),
                    Text(
                      'Hesaplanan Yaşınız: $_currentAge',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              // Minus button
              IconButton.filledTonal(
                key: const Key('age_decrement_btn'),
                icon: const Icon(Icons.remove, size: 18),
                onPressed: _currentAge > 10
                    ? () {
                        setState(() => _currentAge--);
                        _repository.saveLastAge(_currentAge);
                      }
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  '$_currentAge',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              // Plus button
              IconButton.filledTonal(
                key: const Key('age_increment_btn'),
                icon: const Icon(Icons.add, size: 18),
                onPressed: _currentAge < 95
                    ? () {
                        setState(() => _currentAge++);
                        _repository.saveLastAge(_currentAge);
                      }
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Live Expected Standard Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0D9488).withValues(alpha: isDark ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.analytics_rounded,
                  color: Color(0xFF0D9488),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      children: [
                        TextSpan(
                          text: '${currentNorm.ageLabel} Normu: ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              'Sağlıklı hedef ${currentNorm.normalMinSec.toStringAsFixed(0)}–${currentNorm.goodMinSec.toStringAsFixed(0)} sn (Ortalama: ~${currentNorm.averageExpectedSec.toStringAsFixed(0)} sn)',
                        ),
                      ],
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

  Widget _buildModeSelector(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: ChoiceChip(
            key: const Key('mode_inspiratory_chip'),
            label: const Center(
              child: Text(
                'Derin Nefes (Kapasite)',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ),
            selected: _testMode == BreathTestMode.inspiratoryCapacity,
            selectedColor: const Color(0xFF0D9488).withValues(alpha: 0.2),
            onSelected: (val) {
              if (val) setState(() => _testMode = BreathTestMode.inspiratoryCapacity);
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ChoiceChip(
            key: const Key('mode_control_pause_chip'),
            label: const Center(
              child: Text(
                'Buteyko CP (Verme)',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ),
            selected: _testMode == BreathTestMode.controlPause,
            selectedColor: const Color(0xFF0D9488).withValues(alpha: 0.2),
            onSelected: (val) {
              if (val) setState(() => _testMode = BreathTestMode.controlPause);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStopwatchCircle(bool isDark, AgeBreathNorm norm) {
    final double progress = (_elapsedSeconds / (norm.goodMinSec * 1.2)).clamp(0.0, 1.0);

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
          // Circular Progress & Timer
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 190,
                height: 190,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 10,
                  backgroundColor: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _isHolding
                        ? const Color(0xFF0D9488)
                        : (_elapsedSeconds > 0
                            ? const Color(0xFF10B981)
                            : Colors.grey.shade400),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.air_rounded,
                    size: 32,
                    color: _isHolding ? const Color(0xFF0D9488) : Colors.grey,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _elapsedSeconds.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  const Text(
                    'saniye',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Status caption
          Text(
            _isHolding
                ? '🫁 Nefesinizi Tutuyorsunuz... (Sakin kalın)'
                : (_elapsedSeconds > 0
                    ? 'Test Tamamlandı! Raporu aşağıdan inceleyin.'
                    : _testMode.guidance),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: _isHolding ? FontWeight.bold : FontWeight.w500,
              color: _isHolding
                  ? const Color(0xFF0D9488)
                  : (isDark ? Colors.white70 : Colors.black87),
            ),
          ),
          const SizedBox(height: 20),

          // Main Action Buttons
          if (!_isHolding) ...[
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    key: const Key('breath_test_start_btn'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded, size: 24),
                    label: const Text(
                      'Testi Başlat',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    onPressed: _startBreathTest,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  key: const Key('breath_test_manual_btn'),
                  icon: const Icon(Icons.edit_note_rounded, size: 18),
                  label: const Text('Süreyi Elle Gir'),
                  onPressed: _showManualInputDialog,
                ),
                if (_elapsedSeconds > 0) ...[
                  const SizedBox(width: 8),
                  TextButton.icon(
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Sıfırla'),
                    onPressed: _resetBreathTest,
                  ),
                ],
              ],
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    key: const Key('breath_test_stop_btn'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.stop_rounded, size: 24),
                    label: const Text(
                      'Nefesimi Bıraktım (Bitir)',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    onPressed: _stopBreathTest,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEvaluationReportCard(bool isDark, LungHealthEvaluation eval) {
    final level = eval.level;
    final levelColor = level.color;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCanvas : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: levelColor.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: levelColor.withValues(alpha: isDark ? 0.2 : 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: levelColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(level.icon, color: levelColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level.label,
                      style: TextStyle(
                        color: levelColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      eval.headline,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              // Score badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: levelColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Text(
                      '${eval.score}',
                      style: TextStyle(
                        color: levelColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      'Puan',
                      style: TextStyle(
                        color: levelColor,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Summary Text
          Text(
            eval.summary,
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
            ),
          ),

          // Clinical Warning if present
          if (eval.hasClinicalWarning && eval.clinicalWarning != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.4)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      eval.clinicalWarning!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.red.shade200 : Colors.red.shade900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 8),

          // Actionable recommendations
          const Text(
            'Akciğer Kapasitesini Güçlendirme Önerileri:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          for (final rec in eval.recommendations) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_rounded, color: Color(0xFF0D9488), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rec,
                      style: const TextStyle(fontSize: 12.5, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          // Disclaimer footer
          Text(
            eval.medicalDisclaimer,
            style: TextStyle(
              fontSize: 10.5,
              color: isDark ? Colors.white38 : Colors.black38,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(bool isDark) {
    if (_history.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Ölçüm Geçmişi',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Text(
              '${_history.length} Test',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _history.length > 5 ? 5 : _history.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (ctx, index) {
            final rec = _history[index];
            final color = rec.level.color;
            final dateStr =
                '${rec.recordedAt.day.toString().padLeft(2, '0')}.${rec.recordedAt.month.toString().padLeft(2, '0')}.${rec.recordedAt.year} ${rec.recordedAt.hour.toString().padLeft(2, '0')}:${rec.recordedAt.minute.toString().padLeft(2, '0')}';

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCanvas : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: color.withValues(alpha: 0.15),
                    child: Icon(rec.level.icon, color: color, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${rec.holdSeconds.toStringAsFixed(1)} sn',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${rec.age} Yaş - ${rec.mode.shortLabel})',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          dateStr,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${rec.score} Puan',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    color: Colors.grey,
                    onPressed: () async {
                      await _repository.deleteRecord(rec.id);
                      final updated = await _repository.loadRecords();
                      setState(() => _history = updated);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2: NEFES EGZERSİZLERİ
  // ---------------------------------------------------------------------------

  Widget _buildExercisesTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Total completed badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D9488), Color(0xFF06B6D4)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Düzenli Nefes & Akciğer Güçlendirme',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                        ),
                      ),
                      Text(
                        'Toplam Tamamlanan Seans: $_totalCompletedExercises',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Exercise Selector Horizontal Cards
          const Text(
            'Egzersiz Tekniği Seçin:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: kGuidedBreathingExercises.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (ctx, i) {
                final ex = kGuidedBreathingExercises[i];
                final isSelected = ex.id == _selectedExercise.id;
                return InkWell(
                  onTap: _isExercising
                      ? null
                      : () {
                          setState(() {
                            _selectedExercise = ex;
                            _currentPhaseIndex = 0;
                            _remainingPhaseSeconds = 0;
                          });
                        },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 170,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkCanvas : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? ex.accentColor : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(ex.icon, color: ex.accentColor, size: 20),
                            const Spacer(),
                            if (isSelected)
                              Icon(Icons.check_circle_rounded, color: ex.accentColor, size: 16),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          ex.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: isSelected ? ex.accentColor : null,
                          ),
                        ),
                        Text(
                          ex.badge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Visual Guided Breathing Pacer
          _buildInteractivePacer(isDark),
          const SizedBox(height: 16),

          // Clinical Details Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCanvas : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.medical_services_outlined, color: _selectedExercise.accentColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${_selectedExercise.title} Faydaları',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _selectedExercise.purpose,
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 6),
                Text(
                  _selectedExercise.clinicalBenefit,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractivePacer(bool isDark) {
    final currentPhase = _isExercising && _currentPhaseIndex < _selectedExercise.phases.length
        ? _selectedExercise.phases[_currentPhaseIndex]
        : null;

    final phaseColor = currentPhase?.type.color ?? _selectedExercise.accentColor;
    final phaseLabel = currentPhase != null
        ? currentPhase.type.labelTr
        : 'Hazır mısınız?';
    final phaseInstruction = currentPhase != null
        ? currentPhase.instruction
        : _selectedExercise.purpose;

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
          // Cycle Indicator
          if (_isExercising) ...[
            Text(
              'Döngü $_currentCycle / ${_selectedExercise.recommendedCycles}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: _selectedExercise.accentColor,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Animated Pacer Circle
          Container(
            width: 170,
            height: 170,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: phaseColor.withValues(alpha: 0.12),
              border: Border.all(
                color: phaseColor,
                width: 4,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  currentPhase?.type == BreathPhaseType.inhale
                      ? Icons.arrow_upward_rounded
                      : (currentPhase?.type == BreathPhaseType.exhale
                          ? Icons.arrow_downward_rounded
                          : Icons.pause_rounded),
                  color: phaseColor,
                  size: 28,
                ),
                const SizedBox(height: 4),
                Text(
                  phaseLabel,
                  style: TextStyle(
                    color: phaseColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (_isExercising) ...[
                  const SizedBox(height: 4),
                  Text(
                    '$_remainingPhaseSeconds sn',
                    style: TextStyle(
                      color: phaseColor,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Phase Instruction
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              phaseInstruction,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Start / Stop Exercise Button
          FilledButton.icon(
            key: const Key('breath_exercise_toggle_btn'),
            style: FilledButton.styleFrom(
              backgroundColor: _isExercising ? const Color(0xFFEF4444) : _selectedExercise.accentColor,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: Icon(
              _isExercising ? Icons.stop_rounded : Icons.play_arrow_rounded,
              size: 22,
            ),
            label: Text(
              _isExercising ? 'Egzersizi Durdur' : 'Egzersizi Başlat',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
            ),
            onPressed: () {
              if (_isExercising) {
                _stopExercise();
              } else {
                _startExercise();
              }
            },
          ),
        ],
      ),
    );
  }
}
