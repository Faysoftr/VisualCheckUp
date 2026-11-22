import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:healthcheck/features/checkup/data/color_health_analyzer.dart';
import 'package:healthcheck/features/checkup/data/history_repository.dart';
import 'package:healthcheck/features/checkup/domain/analysis_result.dart';
import 'package:healthcheck/features/checkup/domain/check_category.dart';
import 'package:healthcheck/features/checkup/presentation/screens/result_screen.dart';
import 'package:image_picker/image_picker.dart';

class CameraCheckScreen extends StatefulWidget {
  const CameraCheckScreen({
    super.key,
    required this.category,
    required this.analyzer,
    required this.historyRepository,
  });

  final CheckCategory category;
  final ColorHealthAnalyzer analyzer;
  final HistoryRepository historyRepository;

  @override
  State<CameraCheckScreen> createState() => _CameraCheckScreenState();
}

class _CameraCheckScreenState extends State<CameraCheckScreen> {
  List<CameraDescription> _cameras = const [];
  CameraController? _controller;
  int _selectedCameraIndex = 0;
  bool _isInitializing = true;
  bool _isProcessing = false;
  String? _cameraError;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
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
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _cameraError =
            'Kamera başlatılamadı. İzinleri kontrol edin veya galeriden fotoğraf seçin.';
      });
    }
  }

  Future<void> _startController(int index) async {
    final previous = _controller;
    _controller = null;
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
    } catch (e) {
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
    } catch (e) {
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
      );
      await _openResult(result);
    } catch (e) {
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
        builder: (_) => ResultScreen(result: result),
      ),
    );
  }

  @override
  void dispose() {
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
          // Top guidance bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFF141A1A),
            child: Row(
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
          ),

          // Camera preview + framing reticle
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildPreviewArea(),
                if (_controller != null && _controller!.value.isInitialized)
                  IgnorePointer(
                    child: Center(
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.9),
                            width: 2.5,
                          ),
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
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
                            'Renk tonu analiz ediliyor...',
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.no_photography_outlined,
                color: Colors.white54,
                size: 56,
              ),
              const SizedBox(height: 16),
              Text(
                _cameraError ?? 'Kamera kullanılamıyor.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, height: 1.4),
              ),
              const SizedBox(height: 20),
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
