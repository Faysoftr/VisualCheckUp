import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:visualcheckup/core/color/organ_isolator.dart';
import 'package:visualcheckup/core/l10n/l10n_extensions.dart';
import 'package:visualcheckup/core/services/camera_permission_service.dart';
import 'package:visualcheckup/core/storage/checkup_photo_storage.dart';
import 'package:visualcheckup/features/checkup/data/history_repository.dart';
import 'package:visualcheckup/features/checkup/domain/analysis_result.dart';
import 'package:visualcheckup/features/checkup/domain/category_baseline.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';
import 'package:visualcheckup/features/checkup/domain/health_analyzer.dart';
import 'package:visualcheckup/features/checkup/presentation/screens/quick_color_card_screen.dart';
import 'package:visualcheckup/features/checkup/presentation/screens/result_screen.dart';
import 'package:visualcheckup/features/checkup/presentation/widgets/module_reference_sheet.dart';
import 'package:visualcheckup/features/checkup/presentation/widgets/organ_scanner_overlay.dart';

class CameraCheckScreen extends StatefulWidget {
  const CameraCheckScreen({
    super.key,
    required this.category,
    required this.analyzer,
    required this.historyRepository,
    this.permissionService = const PermissionHandlerCameraService(),
    this.initialEyeScanMode = EyeScanMode.sclera,
    this.autoPickFromGallery = false,
    this.minScanDuration = const Duration(milliseconds: 2200),
    this.galleryImageBytesProvider,
  });

  final CheckCategory category;
  final HealthAnalyzer analyzer;
  final HistoryRepository historyRepository;
  final CameraPermissionService permissionService;
  final EyeScanMode initialEyeScanMode;
  final bool autoPickFromGallery;
  final Duration minScanDuration;
  final Future<Uint8List?> Function()? galleryImageBytesProvider;

  @override
  State<CameraCheckScreen> createState() => _CameraCheckScreenState();
}

class _CameraCheckScreenState extends State<CameraCheckScreen>
    with WidgetsBindingObserver {
  List<CameraDescription> _cameras = const [];
  CameraController? _controller;
  int _selectedCameraIndex = 0;
  bool _isInitializing = true;
  bool _isProcessing = false;
  IsolatedOrganResult? _isolatedScanPreview;
  bool _torchEnabled = false;
  bool _openedSettings = false;
  late bool _useWhiteReference;
  CategoryBaseline? _baseline;
  CameraPermissionState _permissionState = CameraPermissionState.granted;
  bool _hasCameraError = false;
  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  double _currentZoom = 1.0;
  Offset? _focusPoint;
  late EyeScanMode _eyeScanMode;

  @override
  void initState() {
    super.initState();
    _useWhiteReference = widget.category.recommendsWhiteReference;
    _eyeScanMode = widget.initialEyeScanMode;
    WidgetsBinding.instance.addObserver(this);
    _loadBaseline();
    _initCamera();
    if (widget.autoPickFromGallery) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _pickFromGallery();
      });
    }
  }

  Future<void> _loadBaseline() async {
    final saved = await widget.historyRepository.getBaseline(widget.category);
    if (!mounted) return;
    setState(() => _baseline = saved);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      if (controller != null && controller.value.isInitialized) {
        _controller = null;
        _torchEnabled = false;
        controller.dispose();
      }
      return;
    }

    if (state == AppLifecycleState.resumed) {
      if (_openedSettings) {
        _openedSettings = false;
        _initCamera(requestIfDenied: false);
      } else if (_permissionState == CameraPermissionState.granted &&
          _controller == null &&
          !_isInitializing) {
        _initCamera(requestIfDenied: false);
      }
    }
  }

  Future<void> _initCamera({bool requestIfDenied = true}) async {
    if (mounted) {
      setState(() {
        _isInitializing = true;
        _hasCameraError = false;
      });
    }

    var permission = await widget.permissionService.checkCamera();
    if (permission == CameraPermissionState.denied && requestIfDenied) {
      permission = await widget.permissionService.requestCamera();
    }

    if (!mounted) return;

    if (permission != CameraPermissionState.granted) {
      setState(() {
        _permissionState = permission;
        _isInitializing = false;
        _hasCameraError = true;
      });
      return;
    }

    _permissionState = CameraPermissionState.granted;

    try {
      final cameras = await availableCameras();
      if (!mounted) return;

      if (cameras.isEmpty) {
        setState(() {
          _isInitializing = false;
          _hasCameraError = true;
        });
        return;
      }

      final preferredLens = widget.category.prefersFrontCamera
          ? CameraLensDirection.front
          : CameraLensDirection.back;

      var index = cameras.indexWhere((c) => c.lensDirection == preferredLens);
      if (index == -1) index = 0;

      _cameras = cameras;
      await _startController(index);
    } on CameraException catch (e) {
      if (!mounted) return;
      _handleCameraException(e);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _hasCameraError = true;
      });
    }
  }

  void _handleCameraException(CameraException e) {
    final code = e.code.toLowerCase();
    if (code.contains('accessdeniedwithoutprompt') ||
        code.contains('restricted')) {
      setState(() {
        _permissionState = CameraPermissionState.permanentlyDenied;
        _isInitializing = false;
        _hasCameraError = true;
      });
      return;
    }
    if (code.contains('accessdenied')) {
      setState(() {
        _permissionState = CameraPermissionState.denied;
        _isInitializing = false;
        _hasCameraError = true;
      });
      return;
    }
    setState(() {
      _isInitializing = false;
      _hasCameraError = true;
    });
  }

  Future<void> _requestPermissionAgain() async {
    await _initCamera(requestIfDenied: true);
  }

  Future<void> _openAppSettings() async {
    _openedSettings = true;
    final opened = await widget.permissionService.openSettings();
    if (!opened && mounted) {
      _openedSettings = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.cameraPermPermanentMsg),
        ),
      );
    }
  }

  Future<void> _startController(int index) async {
    final previous = _controller;
    _controller = null;
    _torchEnabled = false;
    await previous?.dispose();

    final preset = switch (widget.category) {
      CheckCategory.skinCondition ||
      CheckCategory.nail ||
      CheckCategory.eye ||
      CheckCategory.tongue =>
        ResolutionPreset.high,
      CheckCategory.face ||
      CheckCategory.urine ||
      CheckCategory.stool =>
        ResolutionPreset.medium,
    };

    final controller = CameraController(
      _cameras[index],
      preset,
      enableAudio: false,
    );

    try {
      await controller.initialize();
      double minZ = 1.0;
      double maxZ = 1.0;
      try {
        minZ = await controller.getMinZoomLevel();
        maxZ = (await controller.getMaxZoomLevel()).clamp(minZ, 4.0);
      } catch (_) {}
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _selectedCameraIndex = index;
        _minZoom = minZ;
        _maxZoom = maxZ;
        _currentZoom = minZ;
        _isInitializing = false;
        _hasCameraError = false;
      });
    } on CameraException catch (e) {
      await controller.dispose();
      if (!mounted) return;
      _handleCameraException(e);
    } catch (_) {
      await controller.dispose();
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _hasCameraError = true;
      });
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 || _isProcessing) return;
    final nextIndex = (_selectedCameraIndex + 1) % _cameras.length;
    setState(() => _isInitializing = true);
    await _startController(nextIndex);
  }

  bool get _supportsTorch {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return false;
    if (_cameras.isEmpty) return false;
    return _cameras[_selectedCameraIndex].lensDirection ==
        CameraLensDirection.back;
  }

  Future<void> _toggleTorch() async {
    final controller = _controller;
    if (controller == null || !_supportsTorch || _isProcessing) return;
    final next = !_torchEnabled;
    try {
      await controller.setFlashMode(next ? FlashMode.torch : FlashMode.off);
      if (mounted) {
        setState(() => _torchEnabled = next);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.cameraAnalysisFailed(e.toString()))),
      );
    }
  }

  Future<void> _captureAndAnalyze() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _isProcessing) {
      return;
    }

    setState(() => _isProcessing = true);
    try {
      final file = await controller.takePicture();
      final bytes = await file.readAsBytes();
      await _processBytes(bytes);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.cameraAnalysisFailed(e.toString()))),
      );
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      Uint8List? bytes;
      if (widget.galleryImageBytesProvider != null) {
        bytes = await widget.galleryImageBytesProvider!();
      } else {
        final picker = ImagePicker();
        final picked = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1280,
        );
        if (picked != null) {
          bytes = await picked.readAsBytes();
        }
      }
      if (bytes == null) {
        if (mounted) {
          setState(() {
            _isProcessing = false;
            _isolatedScanPreview = null;
          });
        }
        return;
      }
      await _processBytes(bytes);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.cameraAnalysisFailed(e.toString()))),
      );
      setState(() {
        _isProcessing = false;
        _isolatedScanPreview = null;
      });
    }
  }

  Future<void> _setZoom(double value) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    final clamped = value.clamp(_minZoom, _maxZoom);
    try {
      await controller.setZoomLevel(clamped);
      if (mounted) {
        setState(() => _currentZoom = clamped);
      }
    } catch (_) {}
  }

  Future<void> _handleTapToFocus(
    TapDownDetails details,
    BoxConstraints constraints,
  ) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    final dx = (details.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
    final dy = (details.localPosition.dy / constraints.maxHeight).clamp(0.0, 1.0);
    final point = Offset(dx, dy);

    setState(() => _focusPoint = details.localPosition);
    try {
      await controller.setFocusPoint(point);
      await controller.setExposurePoint(point);
    } catch (_) {}

    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (mounted && _focusPoint == details.localPosition) {
        setState(() => _focusPoint = null);
      }
    });
  }

  Future<void> _processBytes(Uint8List bytes) async {
    try {
      // 1. Isolate & magnify ONLY the target organ (strip face/neck/hand/bg)
      final isolated = OrganIsolatorService.isolate(
        imageBytes: bytes,
        category: widget.category,
        eyeScanMode: _eyeScanMode,
      );
      if (mounted) {
        setState(() => _isolatedScanPreview = isolated);
      }

      final allowCloudAi = await widget.historyRepository.isCloudAiEnabled();
      final langCode =
          mounted ? Localizations.localeOf(context).languageCode : 'tr';

      // 2. Run clinical analysis concurrently with the up/down laser scan animation
      final results = await Future.wait<dynamic>([
        widget.analyzer.analyzeImage(
          category: widget.category,
          imageBytes: bytes,
          options: AnalysisOptions(
            useWhiteReference: _useWhiteReference,
            baseline: _baseline,
            allowCloudAi: allowCloudAi,
            languageCode: langCode,
            eyeScanMode: _eyeScanMode,
          ),
        ),
        if (widget.minScanDuration > Duration.zero)
          Future<void>.delayed(widget.minScanDuration),
      ]);
      final analyzed = results.first as AnalysisResult;

      // 3. Persist the isolated, body-free organ image for the report & history
      final savedPhotoPath = await CheckupPhotoStorage.savePhoto(
        resultId: analyzed.id,
        imageBytes: isolated.isolatedImageBytes,
      );
      final result = savedPhotoPath != null
          ? analyzed.copyWith(imagePath: savedPhotoPath)
          : analyzed;
      await _openResult(result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.cameraAnalysisFailed(e.toString())),
        ),
      );
      setState(() {
        _isProcessing = false;
        _isolatedScanPreview = null;
      });
    }
  }

  Future<void> _openResult(AnalysisResult result) async {
    await widget.historyRepository.saveResult(result);
    if (!mounted) return;
    setState(() {
      _isProcessing = false;
      _isolatedScanPreview = null;
    });
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ResultScreen(
          result: result,
          historyRepository: widget.historyRepository,
        ),
      ),
    );
  }

  void _showLightingAndColorGuide(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF141A1E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.45,
        maxChildSize: 0.90,
        expand: false,
        builder: (context, scrollCtrl) => ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.wb_sunny_rounded,
                    color: Color(0xFF34D399),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Işık & Renk Kalibrasyon Rehberi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'En doğru klinik renk ve analiz sonucu için ipuçları',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildGuideCard(
              icon: Icons.light_mode_outlined,
              iconColor: const Color(0xFF10B981),
              title: '1. Doğal Gün Işığı (Altın Standart)',
              desc:
                  'Mümkünse bir pencere kenarında, doğrudan gözü/cildi yakmayan aydınlık difüz gün ışığında çekim yapın. Bu, yapay ampul renk sapmalarını tamamen sıfırlar.',
            ),
            const SizedBox(height: 12),
            _buildGuideCard(
              icon: Icons.wb_auto_rounded,
              iconColor: const Color(0xFF38BDF8),
              title: '2. Beyaz Referans Kağıdı',
              desc:
                  'Sarı akkor veya sıcak ampul bulunan ortamlarda ekranın üzerindeki [Beyaz Referans] butonunu açın. Kadrajın altındaki işaretli kutuya küçük temiz bir beyaz kağıt yerleştirin. Uygulama Von Kries algoritmasıyla renkleri otomatik D65 nötr seviyesine çeker.',
            ),
            const SizedBox(height: 12),
            _buildGuideCard(
              icon: Icons.filter_tilt_shift_rounded,
              iconColor: const Color(0xFFF59E0B),
              title: '3. Parlama & Gölge Önleme',
              desc:
                  'Tırnak, göz veya nemli cilt yüzeylerinde doğrudan flaş açmak aşırı parlamaya yol açabilir. Kamerayı 45 derecelik hafif bir açıyla tutun. Algoritmamız %15 aşırı yansımayı otomatik filtreler.',
            ),
            const SizedBox(height: 12),
            _buildGuideCard(
              icon: Icons.verified_user_outlined,
              iconColor: const Color(0xFFA78BFA),
              title: '4. Yüksek Güvenilirlik Puanı',
              desc:
                  'Doğru ışık ve renk dengesi sağlandığında, görsel analiz ve CIE L*a*b* renk hassasiyeti maksimum güvenilirlikle (%92) çalışır.',
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text(
                  'Anladım, Hazırım',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.category.localizedTitle(l10n)),
        actions: [
          IconButton(
            onPressed: () => ModuleReferenceSheet.show(context, widget.category),
            tooltip: l10n.tooltipReferenceGuide,
            icon: const Icon(Icons.menu_book_outlined),
          ),
          if (_supportsTorch)
            IconButton(
              onPressed: _toggleTorch,
              icon: Icon(
                _torchEnabled
                    ? Icons.flash_on_rounded
                    : Icons.flash_off_rounded,
              ),
            ),
          if (_cameras.length > 1)
            IconButton(
              onPressed: _switchCamera,
              icon: const Icon(Icons.cameraswitch_outlined),
            ),
        ],
      ),
      body: _isProcessing && _isolatedScanPreview != null
          ? OrganScannerOverlay(
              category: widget.category,
              isolatedOrgan: _isolatedScanPreview!,
              isTurkish: Localizations.localeOf(context).languageCode == 'tr',
            )
          : Column(
        children: [
          // Top guidance & calibration bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            color: const Color(0xFF141A1A),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.wb_sunny_outlined,
                      size: 18,
                      color: widget.category.accentColor,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.category.localizedSubtitle(l10n),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _showLightingAndColorGuide(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF34D399).withValues(alpha: 0.5),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lightbulb_circle_outlined,
                              size: 14,
                              color: Color(0xFF34D399),
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Işık & Renk',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => setState(
                        () => _useWhiteReference = !_useWhiteReference,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _useWhiteReference
                              ? const Color(0xFF17A398).withValues(alpha: 0.25)
                              : Colors.white10,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _useWhiteReference
                                ? const Color(0xFF17A398)
                                : Colors.white24,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _useWhiteReference
                                  ? Icons.wb_auto_rounded
                                  : Icons.wb_auto_outlined,
                              size: 14,
                              color: _useWhiteReference
                                  ? const Color(0xFF5CE1D6)
                                  : Colors.white60,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _useWhiteReference
                                  ? l10n.cameraWhiteRefOn
                                  : l10n.cameraWhiteRefOff,
                              style: TextStyle(
                                color: _useWhiteReference
                                    ? Colors.white
                                    : Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (widget.category == CheckCategory.eye)
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => setState(() {
                          _eyeScanMode = _eyeScanMode == EyeScanMode.sclera
                              ? EyeScanMode.palpebralConjunctiva
                              : EyeScanMode.sclera;
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: _eyeScanMode ==
                                    EyeScanMode.palpebralConjunctiva
                                ? const Color(0xFFD65A6F)
                                    .withValues(alpha: 0.28)
                                : Colors.white10,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _eyeScanMode ==
                                      EyeScanMode.palpebralConjunctiva
                                  ? const Color(0xFFFF8FA2)
                                  : Colors.white24,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _eyeScanMode == EyeScanMode.palpebralConjunctiva
                                    ? Icons.bloodtype_outlined
                                    : Icons.visibility_outlined,
                                size: 14,
                                color: _eyeScanMode ==
                                        EyeScanMode.palpebralConjunctiva
                                    ? const Color(0xFFFFA6B5)
                                    : Colors.white70,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _eyeScanMode == EyeScanMode.palpebralConjunctiva
                                    ? l10n.cameraEyeModeConjunctiva
                                    : l10n.cameraEyeModeSclera,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => ModuleReferenceSheet.show(
                        context,
                        widget.category,
                        focusSelfTests: true,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.fact_check_outlined,
                              size: 14,
                              color: Color(0xFF5CE1D6),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              l10n.cameraClinicalAtlasChip,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (widget.category.supportsQuickColorCard)
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute<void>(
                              builder: (_) => QuickColorCardScreen(
                                category: widget.category,
                                historyRepository: widget.historyRepository,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.palette_outlined,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                l10n.menuQuickColorCard,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (_baseline != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: _baseline!.color,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white70),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              l10n.cameraBaselineActive,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
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

          // Camera preview + Tap-to-Focus + framing reticles + Zoom slider
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => Stack(
                fit: StackFit.expand,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (d) => _handleTapToFocus(d, constraints),
                    child: _buildPreviewArea(),
                  ),
                  if (_focusPoint != null)
                    Positioned(
                      left: (_focusPoint!.dx - 26).clamp(
                        0.0,
                        (constraints.maxWidth - 52).clamp(0.0, double.infinity),
                      ),
                      top: (_focusPoint!.dy - 26).clamp(
                        0.0,
                        (constraints.maxHeight - 52).clamp(0.0, double.infinity),
                      ),
                      child: IgnorePointer(
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFF5CE1D6),
                              width: 2.2,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  if (_controller != null &&
                      _controller!.value.isInitialized &&
                      _maxZoom > _minZoom + 0.1)
                    Positioned(
                      left: 24,
                      right: 24,
                      bottom: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.zoom_in_rounded,
                              color: Colors.white70,
                              size: 18,
                            ),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 2.5,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 7,
                                  ),
                                ),
                                child: Slider(
                                  value: _currentZoom.clamp(_minZoom, _maxZoom),
                                  min: _minZoom,
                                  max: _maxZoom,
                                  activeColor: const Color(0xFF5CE1D6),
                                  inactiveColor: Colors.white24,
                                  onChanged: _setZoom,
                                ),
                              ),
                            ),
                            Text(
                              '${_currentZoom.toStringAsFixed(1)}x',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (_controller != null && _controller!.value.isInitialized)
                    IgnorePointer(
                      child: LayoutBuilder(
                        builder: (context, innerConstraints) {
                          final h = innerConstraints.maxHeight;
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              Center(
                                child: SizedBox(
                                  width: 224,
                                  height: 224,
                                  child: CustomPaint(
                                    painter: _AnatomicalReticlePainter(
                                      category: widget.category,
                                      eyeScanMode: _eyeScanMode,
                                    ),
                                  ),
                                ),
                              ),
                              if (_useWhiteReference)
                                Positioned(
                                  top: h * 0.72,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: Container(
                                      width: 170,
                                      height: (h * 0.14).clamp(44.0, 76.0),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.white.withValues(alpha: 0.10),
                                        border: Border.all(
                                          color: const Color(0xFF5CE1D6),
                                          width: 1.8,
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      l10n.cameraWhiteRefOn,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black87,
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                if (_isProcessing)
                  Container(
                    color: Colors.black54,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(color: Colors.white),
                          const SizedBox(height: 12),
                          Text(
                            l10n.cameraAnalyzing,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            ),
          ),

          // Bottom controls
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              color: Colors.black,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton.filledTonal(
                    key: const Key('camera_pick_gallery_button'),
                    onPressed: _isProcessing ? null : _pickFromGallery,
                    tooltip: l10n.cameraPickGalleryBtn,
                    icon: const Icon(Icons.photo_library_outlined),
                  ),
                  GestureDetector(
                    onTap: _controller != null && !_isProcessing
                        ? _captureAndAnalyze
                        : null,
                    child: Container(
                      width: 74,
                      height: 74,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _controller != null
                              ? Colors.white
                              : Colors.white38,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewArea() {
    final l10n = context.l10n;
    if (_isInitializing) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_hasCameraError || _controller == null) {
      final isPermanentlyDenied =
          _permissionState == CameraPermissionState.permanentlyDenied ||
              _permissionState == CameraPermissionState.restricted;
      final isDenied = _permissionState == CameraPermissionState.denied;

      final errorMessage = isPermanentlyDenied
          ? l10n.cameraPermPermanentMsg
          : l10n.cameraPermRequiredMsg;

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPermanentlyDenied || isDenied
                    ? Icons.lock_outline_rounded
                    : Icons.no_photography_outlined,
                color: Colors.white54,
                size: 56,
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, height: 1.45),
              ),
              const SizedBox(height: 20),
              if (isPermanentlyDenied)
                FilledButton.icon(
                  onPressed: _openAppSettings,
                  icon: const Icon(Icons.settings_outlined),
                  label: Text(l10n.permOpenSettingsBtn),
                )
              else if (isDenied)
                FilledButton.icon(
                  onPressed: _requestPermissionAgain,
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: Text(l10n.cameraRequestPermBtn),
                ),
              if (isPermanentlyDenied || isDenied) const SizedBox(height: 10),
              if (isPermanentlyDenied || isDenied)
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white38),
                  ),
                  onPressed: _pickFromGallery,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(l10n.cameraPickGalleryBtn),
                )
              else
                FilledButton.icon(
                  onPressed: _pickFromGallery,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(l10n.cameraPickGalleryBtn),
                ),
            ],
          ),
        ),
      );
    }

    return Center(child: CameraPreview(_controller!));
  }
}

class _AnatomicalReticlePainter extends CustomPainter {
  const _AnatomicalReticlePainter({
    required this.category,
    required this.eyeScanMode,
  });

  final CheckCategory category;
  final EyeScanMode eyeScanMode;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final cy = h * 0.5;

    final framePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.90)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    final guidePaint = Paint()
      ..color = const Color(0xFF5CE1D6).withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    // Outer subtle rounded bounding frame
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(4, 4, w - 8, h - 8),
        const Radius.circular(28),
      ),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.42)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    switch (category) {
      case CheckCategory.eye:
        if (eyeScanMode == EyeScanMode.palpebralConjunctiva) {
          // Lower eyelid inner mucosa arc guide
          final arc = Path()
            ..moveTo(w * 0.14, h * 0.44)
            ..quadraticBezierTo(cx, h * 0.54, w * 0.86, h * 0.44)
            ..quadraticBezierTo(cx, h * 0.86, w * 0.14, h * 0.44);
          canvas.drawPath(arc, guidePaint..strokeWidth = 2.4);
          _drawLabel(canvas, 'Alt Göz Kapağı İçi', Offset(cx, h * 0.88));
        } else {
          final eye = Path()
            ..moveTo(w * 0.10, cy)
            ..quadraticBezierTo(cx, h * 0.22, w * 0.90, cy)
            ..quadraticBezierTo(cx, h * 0.78, w * 0.10, cy)
            ..close();
          canvas.drawPath(eye, framePaint);
          canvas.drawCircle(Offset(cx, cy), w * 0.14, guidePaint);
          _drawLabel(canvas, 'Göz Akını Ortala', Offset(cx, h * 0.86));
        }
      case CheckCategory.nail:
        // Fingernail plate arch + lunula marker
        final nail = RRect.fromLTRBAndCorners(
          w * 0.26,
          h * 0.14,
          w * 0.74,
          h * 0.82,
          topLeft: Radius.circular(w * 0.20),
          topRight: Radius.circular(w * 0.20),
          bottomLeft: Radius.circular(w * 0.14),
          bottomRight: Radius.circular(w * 0.14),
        );
        canvas.drawRRect(nail, framePaint);
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(cx, h * 0.82),
            width: w * 0.30,
            height: h * 0.16,
          ),
          3.14159,
          3.14159,
          false,
          guidePaint,
        );
        _drawLabel(canvas, 'Tırnak Plağı', Offset(cx, h * 0.90));
      case CheckCategory.tongue:
        final tongue = Path()
          ..moveTo(w * 0.22, h * 0.14)
          ..lineTo(w * 0.78, h * 0.14)
          ..quadraticBezierTo(w * 0.84, h * 0.64, cx, h * 0.86)
          ..quadraticBezierTo(w * 0.16, h * 0.64, w * 0.22, h * 0.14)
          ..close();
        canvas.drawPath(tongue, framePaint);
        canvas.drawLine(
          Offset(cx, h * 0.20),
          Offset(cx, h * 0.72),
          guidePaint,
        );
        _drawLabel(canvas, 'Dil Yüzeyi', Offset(cx, h * 0.92));
      case CheckCategory.skinCondition:
        // Outer healthy-skin ring + inner lesion target + 6mm reference guide
        canvas.drawCircle(Offset(cx, cy), w * 0.36, framePaint);
        canvas.drawCircle(Offset(cx, cy), w * 0.18, guidePaint..strokeWidth = 2.0);
        // Crosshair ticks
        canvas.drawLine(Offset(cx - 10, cy), Offset(cx + 10, cy), guidePaint);
        canvas.drawLine(Offset(cx, cy - 10), Offset(cx, cy + 10), guidePaint);
        _drawLabel(canvas, 'Lezyon + Çevre Deri (10-15 cm)', Offset(cx, h * 0.90));
      case CheckCategory.face:
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx, cy), width: w * 0.66, height: h * 0.82),
          framePaint,
        );
      case CheckCategory.urine:
      case CheckCategory.stool:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(cx, cy), width: w * 0.78, height: h * 0.78),
            const Radius.circular(24),
          ),
          framePaint,
        );
    }
  }

  void _drawLabel(Canvas canvas, String text, Offset center) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _AnatomicalReticlePainter oldDelegate) {
    return oldDelegate.category != category ||
        oldDelegate.eyeScanMode != eyeScanMode;
  }
}
