import 'dart:io';

import 'package:flutter/material.dart';
import 'package:visualcheckup/core/l10n/l10n_extensions.dart';
import 'package:visualcheckup/core/theme/app_theme.dart';
import 'package:visualcheckup/features/community/data/health_community_repository.dart';
import 'package:visualcheckup/features/community/domain/health_community_models.dart';

/// Renders a community member's avatar supporting remote Cloudflare R2 URLs,
/// local file paths (offline fallback), or clean colored initials.
class CommunityAvatar extends StatelessWidget {
  const CommunityAvatar({
    super.key,
    required this.initials,
    this.photoUrl,
    this.radius = 24,
    this.accentColor = AppTheme.primaryTeal,
  });

  final String initials;
  final String? photoUrl;
  final double radius;
  final Color accentColor;

  ImageProvider<Object>? _resolveImage() {
    final url = photoUrl?.trim();
    if (url == null || url.isEmpty || url.startsWith('memory://')) return null;
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return NetworkImage(url);
    }
    final file = File(url);
    if (file.existsSync()) {
      return FileImage(file);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = _resolveImage();
    return CircleAvatar(
      radius: radius,
      backgroundColor: accentColor.withValues(alpha: 0.16),
      backgroundImage: imageProvider,
      onBackgroundImageError: imageProvider == null ? null : (_, _) {},
      child: imageProvider == null
          ? Text(
              initials,
              style: TextStyle(
                color: accentColor,
                fontWeight: FontWeight.w800,
                fontSize: radius * 0.68,
              ),
            )
          : null,
    );
  }
}

/// Renders an uploaded chat image bubble supporting both remote R2 URLs and
/// local file paths.
class CommunityImagePreview extends StatelessWidget {
  const CommunityImagePreview({
    super.key,
    required this.imageUrl,
    this.height = 180,
    this.width = 220,
  });

  final String imageUrl;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final trimmed = imageUrl.trim();

    Widget fallback() => Container(
          width: width,
          height: height * 0.6,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(
              Icons.image_outlined,
              size: 36,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        );

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          trimmed,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => fallback(),
        ),
      );
    }

    if (!trimmed.startsWith('memory://')) {
      final file = File(trimmed);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            file,
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => fallback(),
          ),
        );
      }
    }

    return fallback();
  }
}

/// Reusable App Store / Google Play compliant report dialog for community
/// profiles and chat messages.
Future<bool> showCommunityReportDialog({
  required BuildContext context,
  required HealthCommunityRepository repository,
  required String reporterUid,
  required String targetType,
  required String targetId,
}) async {
  final l10n = context.l10n;
  CommunityReportReason? selectedReason;
  final noteController = TextEditingController();

  final submitted = await showDialog<bool>(
    context: context,
    builder: (dialogCtx) {
      return StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.flag_outlined,
                  color: Theme.of(ctx).colorScheme.error,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(l10n.commReportTitle)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final reason in CommunityReportReason.values)
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => setDialogState(() => selectedReason = reason),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Icon(
                              selectedReason == reason
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_off_rounded,
                              size: 20,
                              color: selectedReason == reason
                                  ? Theme.of(ctx).colorScheme.error
                                  : Theme.of(ctx).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                reason.localizedLabel(l10n),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: noteController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: l10n.commReportNoteHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                key: const Key('comm_report_submit_button'),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(ctx).colorScheme.error,
                  foregroundColor: Theme.of(ctx).colorScheme.onError,
                ),
                onPressed: selectedReason == null
                    ? null
                    : () => Navigator.of(dialogCtx).pop(true),
                child: Text(l10n.commReportSubmit),
              ),
            ],
          );
        },
      );
    },
  );

  final note = noteController.text.trim();
  noteController.dispose();

  if (submitted == true && selectedReason != null) {
    await repository.submitReport(
      reporterUid: reporterUid,
      targetType: targetType,
      targetId: targetId,
      reason: selectedReason!,
      note: note,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.commReportSent)),
      );
    }
    return true;
  }
  return false;
}
