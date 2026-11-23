import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

class CameraCheckScreen extends StatefulWidget {
  const CameraCheckScreen({
    super.key,
    required this.category,
    required this.analyzer,
    required this.historyRepository,
    this.permissionService = const PermissionHandlerCameraService(),
  });

  final CheckCategory category;
  final HealthAnalyzer analyzer;
  final HistoryRepository historyRepository;
  final CameraPermissionService permissionService;

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

  @override
  void initState() {
    super.initState();
    _useWhiteReference = widget.category.recommendsWhiteReference;
    WidgetsBinding.instance.addObserver(this);
    _loadBaseline();
    _initCamera();
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

    final controller = CameraController(
      _cameras[index],
      ResolutionPreset.medium,
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
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
      );
      if (picked == null) {
        if (mounted) setState(() => _isProcessing = false);
        return;
      }
      final bytes = await picked.readAsBytes();
      await _processBytes(bytes);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.cameraAnalysisFailed(e.toString()))),
      );
      setState(() => _isProcessing = false);
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
      final allowCloudAi = await widget.historyRepository.isCloudAiEnabled();
      final langCode =
          mounted ? Localizations.localeOf(context).languageCode : 'tr';
      final analyzed = await widget.analyzer.analyzeImage(
        category: widget.category,
        imageBytes: bytes,
        options: AnalysisOptions(
          useWhiteReference: _useWhiteReference,
          baseline: _baseline,
          allowCloudAi: allowCloudAi,
          languageCode: langCode,
        ),
      );
      final savedPhotoPath = await CheckupPhotoStorage.savePhoto(
        resultId: analyzed.id,
        imageBytes: bytes,
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
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _openResult(AnalysisResult result) async {
    await widget.historyRepository.saveResult(result);
    if (!mounted) return;
    setState(() => _isProcessing = false);
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ResultScreen(
          result: result,
          historyRepository: widget.historyRepository,
        ),
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
      body: Column(
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
                                child: Container(
                                  width: 210,
                                  height: 210,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      width: 2.5,
                                    ),
                                    borderRadius: BorderRadius.circular(28),
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
