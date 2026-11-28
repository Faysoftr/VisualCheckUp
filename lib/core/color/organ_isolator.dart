import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:visualcheckup/features/checkup/domain/check_category.dart';
import 'package:visualcheckup/features/checkup/domain/health_analyzer.dart';

/// Result of isolating and magnifying the target anatomical structure (tongue,
/// nail plate, eye aperture, skin lesion, etc.) away from surrounding body
/// parts and background clutter.
class IsolatedOrganResult {
  const IsolatedOrganResult({
    required this.isolatedImageBytes,
    required this.zoomFactor,
    required this.organLabelTr,
    required this.organLabelEn,
  });

  /// High-resolution PNG bytes of the tightly cropped, background-masked organ.
  final Uint8List isolatedImageBytes;

  /// Effective macro magnification factor relative to the full input frame
  /// (e.g., `2.4` -> `2.4x Makro`).
  final double zoomFactor;

  final String organLabelTr;
  final String organLabelEn;
}

/// Pure-Dart on-device anatomical isolator that segments & tightly crops the
/// target organ (tongue without face/neck/teeth, nail without hand/fingers,
/// eye without face/forehead, lesion inside dermatoscope lens, etc.) onto a
/// clean dark clinical studio backdrop (`#080E12`).
class OrganIsolatorService {
  OrganIsolatorService._();

  static const int _bgR = 8;
  static const int _bgG = 14;
  static const int _bgB = 18;

  static IsolatedOrganResult isolate({
    required Uint8List imageBytes,
    required CheckCategory category,
    EyeScanMode eyeScanMode = EyeScanMode.sclera,
  }) {
    final decoded = img.decodeImage(imageBytes);
    if (decoded == null || decoded.width < 16 || decoded.height < 16) {
      return IsolatedOrganResult(
        isolatedImageBytes: imageBytes,
        zoomFactor: 1.0,
        organLabelTr: _labelTr(category, eyeScanMode),
        organLabelEn: _labelEn(category, eyeScanMode),
      );
    }

    final baked = img.bakeOrientation(decoded);
    switch (category) {
      case CheckCategory.tongue:
        return _isolateTongue(baked);
      case CheckCategory.nail:
        return _isolateNail(baked);
      case CheckCategory.eye:
        return _isolateEye(baked, eyeScanMode);
      case CheckCategory.skinCondition:
        return _isolateCircularLens(
          baked,
          cropFraction: 0.46,
          labelTr: _labelTr(category, eyeScanMode),
          labelEn: _labelEn(category, eyeScanMode),
        );
      case CheckCategory.face:
        return _isolateFaceOval(baked);
      case CheckCategory.urine:
      case CheckCategory.stool:
        return _isolateCircularLens(
          baked,
          cropFraction: 0.46,
          labelTr: _labelTr(category, eyeScanMode),
          labelEn: _labelEn(category, eyeScanMode),
        );
    }
  }

  static String _labelTr(CheckCategory category, EyeScanMode eyeScanMode) {
    return switch (category) {
      CheckCategory.tongue => 'Dil Dokusu İzole Edildi',
      CheckCategory.nail => 'Tırnak Plağı İzole Edildi',
      CheckCategory.eye => eyeScanMode == EyeScanMode.palpebralConjunctiva
          ? 'Alt Göz Kapağı Mukozası İzole Edildi'
          : 'Göz Bölgesi İzole Edildi',
      CheckCategory.skinCondition => 'Cilt Lezyonu Makro İzole Edildi',
      CheckCategory.face => 'Yüz Bölgesi İzole Edildi',
      CheckCategory.urine => 'Numune Odağı İzole Edildi',
      CheckCategory.stool => 'Numune Odağı İzole Edildi',
    };
  }

  static String _labelEn(CheckCategory category, EyeScanMode eyeScanMode) {
    return switch (category) {
      CheckCategory.tongue => 'Tongue Tissue Isolated',
      CheckCategory.nail => 'Nail Plate Isolated',
      CheckCategory.eye => eyeScanMode == EyeScanMode.palpebralConjunctiva
          ? 'Palpebral Conjunctiva Isolated'
          : 'Eye Region Isolated',
      CheckCategory.skinCondition => 'Skin Lesion Macro Isolated',
      CheckCategory.face => 'Facial Region Isolated',
      CheckCategory.urine => 'Sample Focus Isolated',
      CheckCategory.stool => 'Sample Focus Isolated',
    };
  }

  // ---------------------------------------------------------------------------
  // 1. TONGUE ISOLATION (Removes face, nose, cheeks, teeth, chin & neck)
  // ---------------------------------------------------------------------------

  static IsolatedOrganResult _isolateTongue(img.Image src) {
    const grid = 160;
    final small = img.copyResize(
      src,
      width: grid,
      height: grid,
      interpolation: img.Interpolation.average,
    );

    // 1. Detect upper teeth / dark oral-pharyngeal arch (y = 18..68) so upper
    //    lip, nose, and upper teeth are strictly above the tongue crop!
    var archBottomY = 26;
    for (var y = 18; y < 68; y++) {
      var teethOrDarkCols = 0;
      for (var x = 44; x < 116; x++) {
        final p = small.getPixel(x, y);
        final r = p.r.toDouble();
        final g = p.g.toDouble();
        final b = p.b.toDouble();
        final l = 0.299 * r + 0.587 * g + 0.114 * b;
        if (l < 75 || (l >= 185 && (r - g) < 20)) {
          teethOrDarkCols++;
        }
      }
      if (teethOrDarkCols >= 28) {
        archBottomY = y;
      }
    }

    final startTongueY = math.max(22, archBottomY - 8);
    final cand = List<bool>.filled(grid * grid, false);
    final isTeethOrOralShadow = List<bool>.filled(grid * grid, false);

    for (var y = startTongueY; y < grid - 6; y++) {
      for (var x = 28; x < grid - 28; x++) {
        final idx = y * grid + x;
        final p = small.getPixel(x, y);
        final r = p.r.toDouble();
        final g = p.g.toDouble();
        final b = p.b.toDouble();
        final l = 0.299 * r + 0.587 * g + 0.114 * b;
        final maxC = math.max(r, math.max(g, b));
        final minC = math.min(r, math.min(g, b));
        final sat = maxC > 0 ? (maxC - minC) / maxC : 0.0;
        final rg = r - g;
        final gb = g - b;

        // Dark oral/throat shadow or bright ivory upper teeth
        final isDarkShadow = l < 66;
        final isIvoryTooth = l >= 182 && rg < 19 && gb >= -4 && sat <= 0.24;
        if (isDarkShadow || isIvoryTooth) {
          isTeethOrOralShadow[idx] = true;
          continue;
        }

        // Epidermal facial/neck/chin skin has melanin + carotene (`G - B >= 10..45`),
        // whereas non-keratinized oral tongue mucosa has cool rose/magenta (`G - B <= 7.5`)!
        final isRoseTongue =
            l >= 70 && l <= 245 && r >= 108 && rg >= 16.0 && gb <= 7.5;
        final isPurpleBlueTongue =
            l >= 45 && l <= 215 && b >= g && (b - g) >= 8.0 && sat >= 0.14;
        final isCoatedCenter = x >= 50 &&
            x <= 110 &&
            y >= startTongueY + 6 &&
            y <= 132 &&
            l >= 150 &&
            l <= 242 &&
            gb <= 16.0;

        if (isRoseTongue || isPurpleBlueTongue || isCoatedCenter) {
          cand[idx] = true;
        }
      }
    }

    // 2px morphological erosion severs any thin lateral contact with the lips
    final eroded = _erodeMask(_erodeMask(cand, grid, grid), grid, grid);

    // Pick the connected component closest to the anatomical tongue center (0.50, 0.60)
    final mainComp = _selectCentralComponent(
      eroded,
      grid,
      grid,
      anchorX: (grid * 0.50).round(),
      anchorY: (grid * 0.60).round(),
    );

    List<bool> finalMask;
    int minX = (grid * 0.28).round();
    int maxX = (grid * 0.72).round();
    int minY = (grid * 0.26).round();
    int maxY = (grid * 0.84).round();

    if (mainComp.pixelCount >= 140 &&
        mainComp.pixelCount <= (grid * grid * 0.68).round()) {
      final dilated =
          _dilateMask(_dilateMask(mainComp.mask, grid, grid), grid, grid);
      for (var i = 0; i < grid * grid; i++) {
        if (isTeethOrOralShadow[i]) dilated[i] = false;
      }

      // Intersect with a clean U-shaped anatomical tongue contour centered on
      // the median X of the core tongue mass so lip/chin edges never leak in.
      final coreCols = <int>[];
      var topY = grid;
      var botY = 0;
      for (var y = 0; y < grid; y++) {
        for (var x = 0; x < grid; x++) {
          if (mainComp.mask[y * grid + x]) {
            coreCols.add(x);
            if (y < topY) topY = y;
            if (y > botY) botY = y;
          }
        }
      }
      coreCols.sort();
      final midX = coreCols.isNotEmpty
          ? coreCols[coreCols.length ~/ 2].toDouble()
          : grid * 0.5;
      const maxHalfW = 31.5;
      for (var y = 0; y < grid; y++) {
        if (y < topY || y > botY) {
          for (var x = 0; x < grid; x++) {
            dilated[y * grid + x] = false;
          }
          continue;
        }
        final t = (y - topY) / math.max(1, botY - topY);
        final taper = t < 0.42
            ? 1.0
            : math.cos(((t - 0.42) / 0.58) * (math.pi * 0.44)).clamp(0.22, 1.0);
        final allowedHalfW = maxHalfW * taper;
        for (var x = 0; x < grid; x++) {
          if ((x - midX).abs() > allowedHalfW) {
            dilated[y * grid + x] = false;
          }
        }
      }

      finalMask = _fillRowSpansSmooth(dilated, grid, grid);
      final bounds = _computeMaskBounds(finalMask, grid, grid);
      if (bounds != null) {
        minX = bounds.$1;
        minY = bounds.$2;
        maxX = bounds.$3;
        maxY = bounds.$4;
      }
    } else {
      finalMask = _buildTongueShieldMask(grid, grid);
      final bounds = _computeMaskBounds(finalMask, grid, grid)!;
      minX = bounds.$1;
      minY = bounds.$2;
      maxX = bounds.$3;
      maxY = bounds.$4;
    }

    return _renderMaskedCrop(
      src: src,
      mask: finalMask,
      maskW: grid,
      maskH: grid,
      minX: minX,
      minY: minY,
      maxX: maxX,
      maxY: maxY,
      padFraction: 0.05,
      labelTr: 'Dil Dokusu İzole Edildi',
      labelEn: 'Tongue Tissue Isolated',
    );
  }

  // ---------------------------------------------------------------------------
  // 2. NAIL ISOLATION (Removes hand, fingers, knuckles & background)
  // ---------------------------------------------------------------------------

  static IsolatedOrganResult _isolateNail(img.Image src) {
    const grid = 160;
    final small = img.copyResize(
      src,
      width: grid,
      height: grid,
      interpolation: img.Interpolation.average,
    );

    // Locate nail plate centroid inside central [0.22..0.78] reticle:
    // Nail keratin is brighter and less yellow-tan (`g - b` lower) than surrounding finger skin.
    final cand = List<bool>.filled(grid * grid, false);
    for (var y = 28; y < grid - 24; y++) {
      for (var x = 32; x < grid - 32; x++) {
        final p = small.getPixel(x, y);
        final r = p.r.toDouble();
        final g = p.g.toDouble();
        final b = p.b.toDouble();
        final l = 0.299 * r + 0.587 * g + 0.114 * b;
        final rg = r - g;
        final gb = g - b;
        // Keratin plate (pink, pale, white, bluish, or dark-banded inside plate) vs dark background & warm finger skin
        if (l >= 95 && l <= 248 && gb <= (rg * 0.72 + 14.0)) {
          cand[idxOf(x, y, grid)] = true;
        }
      }
    }

    var cx = grid * 0.50;
    var cy = grid * 0.50;
    final comp = _selectCentralComponent(
      cand,
      grid,
      grid,
      anchorX: grid ~/ 2,
      anchorY: grid ~/ 2,
    );
    if (comp.pixelCount >= 90 && comp.pixelCount <= (grid * grid * 0.36)) {
      final b = _computeMaskBounds(comp.mask, grid, grid);
      if (b != null) {
        cx = (b.$1 + b.$3) * 0.5;
        cy = (b.$2 + b.$4) * 0.5;
      }
    }

    // Build clean anatomical nail-plate arch mask (~38% width x 48% height -> ~2.4x macro zoom)
    final nailW = grid * 0.40;
    final nailH = grid * 0.50;
    final left = (cx - nailW * 0.5).round().clamp(8, grid - 40);
    final right = (cx + nailW * 0.5).round().clamp(left + 28, grid - 8);
    final top = (cy - nailH * 0.5).round().clamp(8, grid - 44);
    final bottom = (cy + nailH * 0.5).round().clamp(top + 32, grid - 8);

    final mask = List<bool>.filled(grid * grid, false);
    final rx = (right - left) * 0.5;
    final ry = (bottom - top) * 0.5;
    final mcx = (left + right) * 0.5;
    final mcy = (top + bottom) * 0.5;
    // Superellipse (squircle arch, n=2.8) closely matches a fingernail plate silhouette
    for (var y = top; y <= bottom; y++) {
      for (var x = left; x <= right; x++) {
        final nx = ((x - mcx) / math.max(1.0, rx)).abs();
        final ny = ((y - mcy) / math.max(1.0, ry)).abs();
        final superEllipse = math.pow(nx, 2.8) + math.pow(ny, 2.8);
        if (superEllipse <= 1.0) {
          mask[idxOf(x, y, grid)] = true;
        }
      }
    }

    return _renderMaskedCrop(
      src: src,
      mask: mask,
      maskW: grid,
      maskH: grid,
      minX: left,
      minY: top,
      maxX: right,
      maxY: bottom,
      padFraction: 0.08,
      labelTr: 'Tırnak Plağı İzole Edildi',
      labelEn: 'Nail Plate Isolated',
    );
  }

  // ---------------------------------------------------------------------------
  // 3. EYE ISOLATION (Removes forehead, nose, cheek, hair & face)
  // ---------------------------------------------------------------------------

  static IsolatedOrganResult _isolateEye(
    img.Image src,
    EyeScanMode eyeScanMode,
  ) {
    const grid = 160;
    final small = img.copyResize(
      src,
      width: grid,
      height: grid,
      interpolation: img.Interpolation.average,
    );

    // Locate sclera (bright low-saturation white) + iris/pupil contrast near center
    var sumX = 0.0;
    var sumY = 0.0;
    var hits = 0;
    for (var y = 32; y < grid - 32; y++) {
      for (var x = 24; x < grid - 24; x++) {
        final p = small.getPixel(x, y);
        final r = p.r.toDouble();
        final g = p.g.toDouble();
        final b = p.b.toDouble();
        final l = 0.299 * r + 0.587 * g + 0.114 * b;
        final maxC = math.max(r, math.max(g, b));
        final minC = math.min(r, math.min(g, b));
        final sat = maxC > 0 ? (maxC - minC) / maxC : 0.0;
        if (eyeScanMode == EyeScanMode.palpebralConjunctiva) {
          if (l >= 75 && l <= 220 && (r - g) >= 24) {
            sumX += x;
            sumY += y;
            hits++;
          }
        } else {
          if (l >= 165 && sat <= 0.20) {
            sumX += x;
            sumY += y;
            hits++;
          }
        }
      }
    }

    final cx = (hits >= 30 && hits <= grid * grid * 0.30)
        ? (sumX / hits).clamp(grid * 0.36, grid * 0.64)
        : grid * 0.50;
    final cy = (hits >= 30 && hits <= grid * grid * 0.30)
        ? (sumY / hits).clamp(grid * 0.36, grid * 0.64)
        : grid * 0.50;

    final halfW = grid * 0.28; // 56% width
    final halfH = grid * 0.18; // 36% height -> almond eye aperture
    final left = (cx - halfW).round().clamp(6, grid - 6);
    final right = (cx + halfW).round().clamp(left + 24, grid - 6);
    final top = (cy - halfH).round().clamp(6, grid - 6);
    final bottom = (cy + halfH).round().clamp(top + 18, grid - 6);

    final mask = List<bool>.filled(grid * grid, false);
    for (var y = top; y <= bottom; y++) {
      for (var x = left; x <= right; x++) {
        final nx = (x - cx) / math.max(1.0, halfW); // -1..1
        if (nx.abs() > 1.0) continue;
        // Parabolic almond eyelid envelope: max height at center (nx=0), tapering at canthi (nx=±1)
        final lidHalfH = halfH * (1.0 - 0.72 * nx * nx);
        if ((y - cy).abs() <= lidHalfH) {
          mask[idxOf(x, y, grid)] = true;
        }
      }
    }

    return _renderMaskedCrop(
      src: src,
      mask: mask,
      maskW: grid,
      maskH: grid,
      minX: left,
      minY: top,
      maxX: right,
      maxY: bottom,
      padFraction: 0.08,
      labelTr: _labelTr(CheckCategory.eye, eyeScanMode),
      labelEn: _labelEn(CheckCategory.eye, eyeScanMode),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. SKIN LESION / SPECIMEN CIRCULAR MACRO LENS & FACE OVAL
  // ---------------------------------------------------------------------------

  static IsolatedOrganResult _isolateCircularLens(
    img.Image src, {
    required double cropFraction,
    required String labelTr,
    required String labelEn,
  }) {
    const grid = 160;
    final radius = (grid * cropFraction * 0.5);
    const cx = grid * 0.5;
    const cy = grid * 0.5;
    final left = (cx - radius).round().clamp(4, grid - 4);
    final right = (cx + radius).round().clamp(left + 16, grid - 4);
    final top = (cy - radius).round().clamp(4, grid - 4);
    final bottom = (cy + radius).round().clamp(top + 16, grid - 4);

    final mask = List<bool>.filled(grid * grid, false);
    for (var y = top; y <= bottom; y++) {
      for (var x = left; x <= right; x++) {
        final dx = x - cx;
        final dy = y - cy;
        if (dx * dx + dy * dy <= radius * radius) {
          mask[idxOf(x, y, grid)] = true;
        }
      }
    }

    return _renderMaskedCrop(
      src: src,
      mask: mask,
      maskW: grid,
      maskH: grid,
      minX: left,
      minY: top,
      maxX: right,
      maxY: bottom,
      padFraction: 0.06,
      labelTr: labelTr,
      labelEn: labelEn,
    );
  }

  static IsolatedOrganResult _isolateFaceOval(img.Image src) {
    const grid = 160;
    const cx = grid * 0.5;
    const cy = grid * 0.48;
    const rx = grid * 0.30;
    const ry = grid * 0.37;
    final left = (cx - rx).round();
    final right = (cx + rx).round();
    final top = (cy - ry).round();
    final bottom = (cy + ry).round();

    final mask = List<bool>.filled(grid * grid, false);
    for (var y = top; y <= bottom; y++) {
      for (var x = left; x <= right; x++) {
        final nx = (x - cx) / rx;
        final ny = (y - cy) / ry;
        if (nx * nx + ny * ny <= 1.0) {
          mask[idxOf(x, y, grid)] = true;
        }
      }
    }

    return _renderMaskedCrop(
      src: src,
      mask: mask,
      maskW: grid,
      maskH: grid,
      minX: left,
      minY: top,
      maxX: right,
      maxY: bottom,
      padFraction: 0.06,
      labelTr: 'Yüz Bölgesi İzole Edildi',
      labelEn: 'Facial Region Isolated',
    );
  }

  // ---------------------------------------------------------------------------
  // High-Resolution Cropping + Soft Feathered Silhouette Mask Renderer
  // ---------------------------------------------------------------------------

  static IsolatedOrganResult _renderMaskedCrop({
    required img.Image src,
    required List<bool> mask,
    required int maskW,
    required int maskH,
    required int minX,
    required int minY,
    required int maxX,
    required int maxY,
    required double padFraction,
    required String labelTr,
    required String labelEn,
  }) {
    final spanW = math.max(16, maxX - minX + 1);
    final spanH = math.max(16, maxY - minY + 1);
    final padX = (spanW * padFraction).round().clamp(2, 16);
    final padY = (spanH * padFraction).round().clamp(2, 16);

    final gLeft = (minX - padX).clamp(0, maskW - 1);
    final gTop = (minY - padY).clamp(0, maskH - 1);
    final gRight = (maxX + padX).clamp(gLeft + 1, maskW - 1);
    final gBottom = (maxY + padY).clamp(gTop + 1, maskH - 1);

    // Compute smooth [0..1] alpha map on the 160x160 grid with a 3-pass box blur
    // along the mask edge so the isolated organ has natural feathered borders.
    var alphaGrid =
        List<double>.generate(maskW * maskH, (i) => mask[i] ? 1.0 : 0.0);
    alphaGrid = _boxBlurAlpha(alphaGrid, maskW, maskH);
    alphaGrid = _boxBlurAlpha(alphaGrid, maskW, maskH);
    // Boost interior opacity so interior pixels remain 100% crisp & unaltered
    for (var i = 0; i < alphaGrid.length; i++) {
      if (mask[i]) {
        alphaGrid[i] = (alphaGrid[i] * 1.35).clamp(0.0, 1.0);
      } else {
        alphaGrid[i] = (alphaGrid[i] * 0.55).clamp(0.0, 1.0);
      }
    }

    // Map crop bounds to full-resolution source image
    final srcX0 = ((gLeft / maskW) * src.width).round().clamp(0, src.width - 2);
    final srcY0 = ((gTop / maskH) * src.height).round().clamp(0, src.height - 2);
    final srcX1 =
        (((gRight + 1) / maskW) * src.width).round().clamp(srcX0 + 2, src.width);
    final srcY1 = (((gBottom + 1) / maskH) * src.height)
        .round()
        .clamp(srcY0 + 2, src.height);

    final cropW = srcX1 - srcX0;
    final cropH = srcY1 - srcY0;
    var cropped = img.copyCrop(
      src,
      x: srcX0,
      y: srcY0,
      width: cropW,
      height: cropH,
    );

    // Cap output dimension to 640px max side for fast UI rendering & storage
    const maxOutSide = 640;
    if (cropped.width > maxOutSide || cropped.height > maxOutSide) {
      cropped = cropped.width >= cropped.height
          ? img.copyResize(
              cropped,
              width: maxOutSide,
              interpolation: img.Interpolation.linear,
            )
          : img.copyResize(
              cropped,
              height: maxOutSide,
              interpolation: img.Interpolation.linear,
            );
    }

    final outW = cropped.width;
    final outH = cropped.height;
    final gSpanW = (gRight - gLeft + 1).toDouble();
    final gSpanH = (gBottom - gTop + 1).toDouble();

    for (var y = 0; y < outH; y++) {
      final gy = gTop + (y + 0.5) / outH * gSpanH - 0.5;
      for (var x = 0; x < outW; x++) {
        final gx = gLeft + (x + 0.5) / outW * gSpanW - 0.5;
        final a = _sampleBilinear(alphaGrid, maskW, maskH, gx, gy);
        if (a >= 0.995) continue;
        if (a <= 0.005) {
          cropped.setPixelRgb(x, y, _bgR, _bgG, _bgB);
          continue;
        }
        final p = cropped.getPixel(x, y);
        final nr = (p.r * a + _bgR * (1.0 - a)).round().clamp(0, 255);
        final ng = (p.g * a + _bgG * (1.0 - a)).round().clamp(0, 255);
        final nb = (p.b * a + _bgB * (1.0 - a)).round().clamp(0, 255);
        cropped.setPixelRgb(x, y, nr, ng, nb);
      }
    }

    final areaFraction =
        ((cropW * cropH) / math.max(1, src.width * src.height)).clamp(0.04, 1.0);
    final zoomFactor = (1.0 / math.sqrt(areaFraction)).clamp(1.15, 4.0);

    return IsolatedOrganResult(
      isolatedImageBytes: Uint8List.fromList(img.encodePng(cropped)),
      zoomFactor: zoomFactor,
      organLabelTr: labelTr,
      organLabelEn: labelEn,
    );
  }

  // ---------------------------------------------------------------------------
  // Mask Utilities
  // ---------------------------------------------------------------------------

  static int idxOf(int x, int y, int w) => y * w + x;

  static List<bool> _erodeMask(List<bool> m, int w, int h) {
    final out = List<bool>.filled(w * h, false);
    for (var y = 1; y < h - 1; y++) {
      for (var x = 1; x < w - 1; x++) {
        final i = y * w + x;
        if (m[i] && m[i - 1] && m[i + 1] && m[i - w] && m[i + w]) {
          out[i] = true;
        }
      }
    }
    return out;
  }

  static List<bool> _dilateMask(List<bool> m, int w, int h) {
    final out = List<bool>.filled(w * h, false);
    for (var y = 1; y < h - 1; y++) {
      for (var x = 1; x < w - 1; x++) {
        final i = y * w + x;
        if (m[i] || m[i - 1] || m[i + 1] || m[i - w] || m[i + w]) {
          out[i] = true;
        }
      }
    }
    return out;
  }

  static ({List<bool> mask, int pixelCount}) _selectCentralComponent(
    List<bool> m,
    int w,
    int h, {
    required int anchorX,
    required int anchorY,
  }) {
    final visited = List<bool>.filled(w * h, false);
    List<int>? bestComp;
    var bestScore = -1e9;

    for (var i = 0; i < w * h; i++) {
      if (!m[i] || visited[i]) continue;
      final comp = <int>[i];
      visited[i] = true;
      var head = 0;
      var sumX = 0.0;
      var sumY = 0.0;
      while (head < comp.length) {
        final cur = comp[head++];
        final cx = cur % w;
        final cy = cur ~/ w;
        sumX += cx;
        sumY += cy;
        for (var dy = -1; dy <= 1; dy++) {
          for (var dx = -1; dx <= 1; dx++) {
            if (dx == 0 && dy == 0) continue;
            final nx = cx + dx;
            final ny = cy + dy;
            if (nx < 0 || nx >= w || ny < 0 || ny >= h) continue;
            final ni = ny * w + nx;
            if (m[ni] && !visited[ni]) {
              visited[ni] = true;
              comp.add(ni);
            }
          }
        }
      }
      if (comp.length < 40) continue;
      final meanX = sumX / comp.length;
      final meanY = sumY / comp.length;
      final dist = math.sqrt(
        (meanX - anchorX) * (meanX - anchorX) +
            (meanY - anchorY) * (meanY - anchorY),
      );
      // Favor large central organ clusters near the reticle
      final score = comp.length - dist * 18.0;
      if (score > bestScore) {
        bestScore = score;
        bestComp = comp;
      }
    }

    final mask = List<bool>.filled(w * h, false);
    if (bestComp == null) return (mask: mask, pixelCount: 0);
    for (final idx in bestComp) {
      mask[idx] = true;
    }
    return (mask: mask, pixelCount: bestComp.length);
  }

  /// Fills interior holes on each horizontal scanline of the tongue and smooths
  /// row left/right contours with a 5-row median filter for a clean silhouette.
  static List<bool> _fillRowSpansSmooth(List<bool> m, int w, int h) {
    final rawLeft = List<int>.filled(h, -1);
    final rawRight = List<int>.filled(h, -1);
    for (var y = 0; y < h; y++) {
      var l = -1;
      var r = -1;
      for (var x = 0; x < w; x++) {
        if (m[y * w + x]) {
          if (l == -1) l = x;
          r = x;
        }
      }
      if (l != -1 && (r - l) >= 6) {
        rawLeft[y] = l;
        rawRight[y] = r;
      }
    }

    final out = List<bool>.filled(w * h, false);
    for (var y = 0; y < h; y++) {
      final ls = <int>[];
      final rs = <int>[];
      for (var dy = -2; dy <= 2; dy++) {
        final ny = y + dy;
        if (ny >= 0 && ny < h && rawLeft[ny] != -1) {
          ls.add(rawLeft[ny]);
          rs.add(rawRight[ny]);
        }
      }
      if (ls.length < 2) continue;
      ls.sort();
      rs.sort();
      final smoothL = ls[ls.length ~/ 2];
      final smoothR = rs[rs.length ~/ 2];
      for (var x = smoothL; x <= smoothR; x++) {
        out[y * w + x] = true;
      }
    }
    return out;
  }

  static List<bool> _buildTongueShieldMask(int w, int h) {
    final out = List<bool>.filled(w * h, false);
    final top = (h * 0.22).round();
    final bottom = (h * 0.84).round();
    final cx = w * 0.5;
    final maxHalfW = w * 0.27;
    for (var y = top; y <= bottom; y++) {
      final t = (y - top) / math.max(1, bottom - top); // 0..1
      // U-shaped tongue contour: gently rounded top, tapering smoothly to tip
      final profile = t < 0.25
          ? math.sin((t / 0.25) * (math.pi * 0.5)) * 0.96 + 0.04
          : math.cos(((t - 0.25) / 0.75) * (math.pi * 0.46));
      final hw = maxHalfW * profile.clamp(0.15, 1.0);
      for (var x = (cx - hw).round(); x <= (cx + hw).round(); x++) {
        if (x >= 0 && x < w) out[y * w + x] = true;
      }
    }
    return out;
  }

  static (int, int, int, int)? _computeMaskBounds(List<bool> m, int w, int h) {
    var minX = w;
    var minY = h;
    var maxX = -1;
    var maxY = -1;
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        if (m[y * w + x]) {
          if (x < minX) minX = x;
          if (x > maxX) maxX = x;
          if (y < minY) minY = y;
          if (y > maxY) maxY = y;
        }
      }
    }
    if (maxX < minX || maxY < minY) return null;
    return (minX, minY, maxX, maxY);
  }

  static List<double> _boxBlurAlpha(List<double> src, int w, int h) {
    final out = List<double>.filled(w * h, 0.0);
    for (var y = 1; y < h - 1; y++) {
      for (var x = 1; x < w - 1; x++) {
        var sum = 0.0;
        for (var dy = -1; dy <= 1; dy++) {
          for (var dx = -1; dx <= 1; dx++) {
            sum += src[(y + dy) * w + (x + dx)];
          }
        }
        out[y * w + x] = sum / 9.0;
      }
    }
    return out;
  }

  static double _sampleBilinear(
    List<double> grid,
    int w,
    int h,
    double gx,
    double gy,
  ) {
    final cx = gx.clamp(0.0, (w - 1).toDouble());
    final cy = gy.clamp(0.0, (h - 1).toDouble());
    final x0 = cx.floor();
    final y0 = cy.floor();
    final x1 = (x0 + 1).clamp(0, w - 1);
    final y1 = (y0 + 1).clamp(0, h - 1);
    final fx = cx - x0;
    final fy = cy - y0;
    final v00 = grid[y0 * w + x0];
    final v10 = grid[y0 * w + x1];
    final v01 = grid[y1 * w + x0];
    final v11 = grid[y1 * w + x1];
    final top = v00 * (1.0 - fx) + v10 * fx;
    final bot = v01 * (1.0 - fx) + v11 * fx;
    return top * (1.0 - fy) + bot * fy;
  }
}
