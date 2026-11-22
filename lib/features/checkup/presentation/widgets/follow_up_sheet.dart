import 'package:flutter/material.dart';
import 'package:visualcheckup/features/checkup/data/history_repository.dart';
import 'package:visualcheckup/features/checkup/domain/analysis_result.dart';
import 'package:visualcheckup/features/checkup/domain/follow_up_plan.dart';

/// Bottom sheet allowing users to configure recurring visual-wellness follow-up
/// routines (monthly skin/mole tracking, daily hydration, weekly nail/tongue).
class FollowUpSheet extends StatefulWidget {
  const FollowUpSheet({
    super.key,
    required this.historyRepository,
    required this.history,
    required this.onStartTrack,
  });

  final HistoryRepository historyRepository;
  final List<AnalysisResult> history;
  final ValueChanged<FollowUpTrack> onStartTrack;

  static Future<void> show(
    BuildContext context, {
    required HistoryRepository historyRepository,
    required List<AnalysisResult> history,
    required ValueChanged<FollowUpTrack> onStartTrack,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => FollowUpSheet(
        historyRepository: historyRepository,
        history: history,
        onStartTrack: onStartTrack,
      ),
    );
  }

  @override
  State<FollowUpSheet> createState() => _FollowUpSheetState();
}

class _FollowUpSheetState extends State<FollowUpSheet> {
  Set<FollowUpTrack> _enabled = FollowUpTrackX.defaultEnabled();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loaded = await widget.historyRepository.loadFollowUpTracks();
    if (!mounted) return;
    setState(() {
      _enabled = loaded;
      _loading = false;
    });
  }

  Future<void> _toggleTrack(FollowUpTrack track, bool value) async {
    final updated = Set<FollowUpTrack>.from(_enabled);
    if (value) {
      updated.add(track);
    } else {
      updated.remove(track);
    }
    setState(() => _enabled = updated);
    await widget.historyRepository.saveFollowUpTracks(updated);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statuses = FollowUpEvaluator.evaluate(
      enabledTracks: _enabled,
      history: widget.history,
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kişisel Takip Planı',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tek seferlik bakış yerine zaman içi değişimleri takip etmek için rutinlerini seç.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 14),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              for (final status in statuses)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 10, 10, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: colorScheme.primaryContainer,
                                child: Icon(
                                  status.track.icon,
                                  size: 18,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      status.track.title,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      status.track.subtitle,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: status.enabled,
                                onChanged: (v) =>
                                    _toggleTrack(status.track, v),
                              ),
                            ],
                          ),
                          if (status.enabled) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  status.isDueNow
                                      ? Icons.schedule_rounded
                                      : Icons.check_circle_outline_rounded,
                                  size: 16,
                                  color: status.isDueNow
                                      ? colorScheme.primary
                                      : const Color(0xFF1B8A5A),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    status.statusLabel,
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                      color: status.isDueNow
                                          ? colorScheme.primary
                                          : const Color(0xFF1B8A5A),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    widget.onStartTrack(status.track);
                                  },
                                  child: const Text('Şimdi Kontrol Et'),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
