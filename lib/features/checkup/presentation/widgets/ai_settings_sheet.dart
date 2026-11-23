import 'package:flutter/material.dart';
import 'package:visualcheckup/core/l10n/l10n_extensions.dart';
import 'package:visualcheckup/features/checkup/data/history_repository.dart';

/// Bottom sheet allowing users to opt in/out of cloud Vision AI (Gemini via
/// Firebase AI Logic) and inspect active token-saving privacy controls.
class AiSettingsSheet extends StatefulWidget {
  const AiSettingsSheet({
    super.key,
    required this.historyRepository,
    this.isAiBackendConnected = false,
  });

  final HistoryRepository historyRepository;
  final bool isAiBackendConnected;

  static Future<void> show(
    BuildContext context, {
    required HistoryRepository historyRepository,
    bool isAiBackendConnected = false,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => AiSettingsSheet(
        historyRepository: historyRepository,
        isAiBackendConnected: isAiBackendConnected,
      ),
    );
  }

  @override
  State<AiSettingsSheet> createState() => _AiSettingsSheetState();
}

class _AiSettingsSheetState extends State<AiSettingsSheet> {
  bool _cloudAiEnabled = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final enabled = await widget.historyRepository.isCloudAiEnabled();
    if (!mounted) return;
    setState(() {
      _cloudAiEnabled = enabled;
      _loading = false;
    });
  }

  Future<void> _toggleCloudAi(bool value) async {
    await widget.historyRepository.setCloudAiEnabled(value);
    if (!mounted) return;
    setState(() => _cloudAiEnabled = value);
  }

  Future<void> _clearCache() async {
    final l10n = context.l10n;
    await widget.historyRepository.clearAiCache();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.aiCacheCleared)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_outlined, color: colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.aiSettingsTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile(
              title: Text(
                l10n.aiCloudToggleTitle,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                _cloudAiEnabled ? l10n.aiCloudOnDesc : l10n.aiCloudOffDesc,
              ),
              value: _cloudAiEnabled,
              onChanged: _loading ? null : _toggleCloudAi,
            ),
          ),
          if (!widget.isAiBackendConnected) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.cloud_off_outlined,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.aiBackendOfflineNote,
                      style: theme.textTheme.bodySmall?.copyWith(height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          Text(
            l10n.aiOptimizationsTitle,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          _OptimizationRow(
            icon: Icons.center_focus_strong_outlined,
            text: l10n.aiOptQualityGate,
          ),
          _OptimizationRow(
            icon: Icons.photo_size_select_large_outlined,
            text: l10n.aiOptCompression,
          ),
          _OptimizationRow(
            icon: Icons.bolt_outlined,
            text: l10n.aiOptTieredModel,
          ),
          _OptimizationRow(
            icon: Icons.cached_rounded,
            text: l10n.aiOptHashCache,
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _clearCache,
              icon: const Icon(Icons.delete_sweep_outlined, size: 18),
              label: Text(l10n.aiClearCacheBtn),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptimizationRow extends StatelessWidget {
  const _OptimizationRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
