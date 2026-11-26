import 'dart:io';

import 'package:flutter/material.dart';
import 'package:visualcheckup/core/l10n/l10n_extensions.dart';

/// Full-screen pinch-to-zoom viewer for captured checkup photos (eye, tongue,
/// nail, skin, face, etc.) so users and doctors can inspect fine visual detail.
class PhotoZoomViewer extends StatefulWidget {
  const PhotoZoomViewer({
    super.key,
    required this.imagePath,
    this.title,
    this.subtitle,
  });

  final String imagePath;
  final String? title;
  final String? subtitle;

  static Future<void> show(
    BuildContext context, {
    required String imagePath,
    String? title,
    String? subtitle,
  }) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => PhotoZoomViewer(
          imagePath: imagePath,
          title: title,
          subtitle: subtitle,
        ),
      ),
    );
  }

  @override
  State<PhotoZoomViewer> createState() => _PhotoZoomViewerState();
}

class _PhotoZoomViewerState extends State<PhotoZoomViewer> {
  final TransformationController _controller = TransformationController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _controller.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title ?? l10n.photoZoomTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (widget.subtitle != null)
              Text(
                widget.subtitle!,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _resetZoom,
            tooltip: '1x',
            icon: const Icon(Icons.fit_screen_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: GestureDetector(
          onDoubleTap: _resetZoom,
          child: Center(
            child: InteractiveViewer(
              transformationController: _controller,
              minScale: 1.0,
              maxScale: 5.0,
              child: Image.file(
                File(widget.imagePath),
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white54,
                    size: 56,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
