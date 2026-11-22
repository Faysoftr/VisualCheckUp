import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:visualcheckup/core/services/camera_permission_service.dart';
import 'package:visualcheckup/features/checkup/data/history_repository.dart';
import 'package:visualcheckup/features/checkup/domain/analysis_result.dart';
import 'package:visualcheckup/features/checkup/domain/category_baseline.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';
import 'package:visualcheckup/features/checkup/domain/health_analyzer.dart';
import 'package:visualcheckup/features/checkup/presentation/screens/result_screen.dart';

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
  String? _cameraError;

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
        _cameraError = null;
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
        _cameraError = permission == CameraPermissionState.permanentlyDenied ||
                permission == CameraPermissionState.restricted
            ? 'Kamera izni cihaz ayarlarından kapatılmış. Ayarlardan VisualCheckUp için kamera iznini açabilir veya galeriden fotoğraf seçebilirsiniz.'
            : 'Görsel ön kontrol yapabilmek için kamera izni gerekiyor. Görüntüler yalnızca cihazınızda işlenir ve sunucuya gönderilmez.';
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
          _cameraError =
              'Bu cihazda kullanılabilir kamera bulunamadı. Galeriden fotoğraf seçebilirsiniz.';
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
        _cameraError =
            'Kamera başlatılamadı. İzinleri kontrol edin veya galeriden fotoğraf seçin.';
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
        _cameraError =
            'Kamera erişimi cihaz ayarlarından engellenmiş. Ayarları açıp VisualCheckUp için kamera iznini etkinleştirin.';
      });
      return;
    }
    if (code.contains('accessdenied')) {
      setState(() {
        _permissionState = CameraPermissionState.denied;
        _isInitializing = false;
        _cameraError =
            'Kamera izni verilmedi. Devam etmek için kamera izni verebilir veya galeriden fotoğraf seçebilirsiniz.';
      });
      return;
    }
    setState(() {
      _isInitializing = false;
      _cameraError =
          'Kamera erişimi sağlanamadı. Galeriden fotoğraf seçebilirsiniz.';
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
        const SnackBar(
          content: Text(
            'Uygulama ayarları açılamadı. Lütfen cihaz ayarlarından kamera iznini manuel etkinleştirin.',
          ),
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
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _selectedCameraIndex = index;
        _isInitializing = false;
        _cameraError = null;
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
        _cameraError =
            'Kamera erişimi sağlanamadı. Galeriden fotoğraf seçebilirsiniz.';
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
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bu kamerada ışık/flaş açılamadı.')),
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
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fotoğraf çekilirken bir hata oluştu.')),
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
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fotoğraf seçilemedi.')),
      );
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _processBytes(Uint8List bytes) async {
    try {
      final result = await widget.analyzer.analyzeImage(
        category: widget.category,
        imageBytes: bytes,
        options: AnalysisOptions(
          useWhiteReference: _useWhiteReference,
          baseline: _baseline,
        ),
      );
      await _openResult(result);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Görüntü analiz edilemedi. Lütfen tekrar deneyin.'),
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${widget.category.title} Kontrolü'),
        actions: [
          if (_supportsTorch)
            IconButton(
              onPressed: _toggleTorch,
              tooltip: _torchEnabled ? 'Işığı Kapat' : 'Işığı Aç',
              icon: Icon(
                _torchEnabled
                    ? Icons.flash_on_rounded
                    : Icons.flash_off_rounded,
              ),
            ),
          if (_cameras.length > 1)
            IconButton(
              onPressed: _switchCamera,
              tooltip: 'Kamerayı Değiştir',
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
                        widget.category.captureGuide,
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
                                  ? 'Beyaz Referans: Açık'
                                  : 'Beyaz Referans: Kapalı',
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
                            const Text(
                              'Kişisel Normal Aktif',
                              style: TextStyle(
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

          // Camera preview + framing reticles
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildPreviewArea(),
                if (_controller != null && _controller!.value.isInitialized)
                  IgnorePointer(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final h = constraints.maxHeight;
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
                                top: h * 0.74,
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
                                    child: const Text(
                                      'Beyaz Referans\n(Kağıt / Beyaz Zemin)',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
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
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 12),
                          Text(
                            'Renk kalibrasyonu ve analiz yapılıyor...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
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
                    tooltip: 'Galeriden Seç',
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
    if (_isInitializing) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_cameraError != null || _controller == null) {
      final isPermanentlyDenied =
          _permissionState == CameraPermissionState.permanentlyDenied ||
              _permissionState == CameraPermissionState.restricted;
      final isDenied = _permissionState == CameraPermissionState.denied;

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
                _cameraError ?? 'Kamera kullanılamıyor.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, height: 1.45),
              ),
              const SizedBox(height: 20),
              if (isPermanentlyDenied)
                FilledButton.icon(
                  onPressed: _openAppSettings,
                  icon: const Icon(Icons.settings_outlined),
                  label: const Text('Ayarları Aç'),
                )
              else if (isDenied)
                FilledButton.icon(
                  onPressed: _requestPermissionAgain,
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Kamera İzni Ver'),
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
                  label: const Text('Galeriden Fotoğraf Seç'),
                )
              else
                FilledButton.icon(
                  onPressed: _pickFromGallery,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Galeriden Fotoğraf Seç'),
                ),
            ],
          ),
        ),
      );
    }

    return Center(child: CameraPreview(_controller!));
  }
}
