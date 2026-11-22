import 'package:flutter/material.dart';
import 'package:visualcheckup/core/l10n/l10n_extensions.dart';
import 'package:visualcheckup/features/checkup/data/history_repository.dart';
import 'package:visualcheckup/features/checkup/domain/analysis_result.dart';
import 'package:visualcheckup/features/checkup/domain/follow_up_plan.dart';
import 'package:visualcheckup/features/labs_vitals/domain/lab_models.dart';
import 'package:visualcheckup/features/labs_vitals/domain/vital_models.dart';

/// Bottom sheet allowing users to configure recurring holistic follow-up
/// routines across all visual modules (eye, tongue, nail, face, skin, urine,
/// stool), blood pressure, blood sugar, and hospital lab reports.
class FollowUpSheet extends StatefulWidget {
  const FollowUpSheet({
    super.key,
    required this.historyRepository,
    required this.history,
    required this.onStartTrack,
    this.bloodPressureReadings = const [],
    this.bloodSugarReadings = const [],
    this.labReports = const [],
  });

  final HistoryRepository historyRepository;
  final List<AnalysisResult> history;
  final List<BloodPressureReading> bloodPressureReadings;
  final List<BloodSugarReading> bloodSugarReadings;
  final List<LabReportRecord> labReports;
  final ValueChanged<FollowUpTrack> onStartTrack;

  static Future<void> show(
    BuildContext context, {
    required HistoryRepository historyRepository,
    required List<AnalysisResult> history,
    required ValueChanged<FollowUpTrack> onStartTrack,
    List<BloodPressureReading> bloodPressureReadings = const [],
    List<BloodSugarReading> bloodSugarReadings = const [],
    List<LabReportRecord> labReports = const [],
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => FollowUpSheet(
          historyRepository: historyRepository,
          history: history,
          bloodPressureReadings: bloodPressureReadings,
          bloodSugarReadings: bloodSugarReadings,
          labReports: labReports,
          onStartTrack: onStartTrack,
        ),
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
      bloodPressureReadings: widget.bloodPressureReadings,
      bloodSugarReadings: widget.bloodSugarReadings,
      labReports: widget.labReports,
    );

    final activeStatuses = statuses.where((s) => s.enabled).toList();
    final completedCount = activeStatuses.where((s) => !s.isDueNow).length;
    final dueCount = activeStatuses.where((s) => s.isDueNow).length;
    final l10n = context.l10n;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        child: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.event_repeat_rounded,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.followUpCardTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.followUpSheetSubtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                if (!_loading)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(
                        alpha: 0.4,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.insights_rounded,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.followUpSummaryCounts(
                              activeStatuses.length,
                              completedCount,
                              dueCount,
                            ),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  for (int i = 0; i < statuses.length; i++) ...[
                    if (i > 0) const Divider(height: 16),
                    _FollowUpTrackTile(
                      status: statuses[i],
                      onToggle: (v) => _toggleTrack(statuses[i].track, v),
                      onStart: () {
                        Navigator.of(context).pop();
                        widget.onStartTrack(statuses[i].track);
                      },
                    ),
                  ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FollowUpTrackTile extends StatelessWidget {
  const _FollowUpTrackTile({
    required this.status,
    required this.onToggle,
    required this.onStart,
  });

  final FollowUpTrackStatus status;
  final ValueChanged<bool> onToggle;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
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
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    status.track.subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: status.enabled,
              onChanged: onToggle,
            ),
          ],
        ),
        if (status.latestValueSummary != null) ...[
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              status.latestValueSummary!,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        if (status.enabled) ...[
          const SizedBox(height: 6),
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
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: status.isDueNow
                        ? colorScheme.primary
                        : const Color(0xFF1B8A5A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: onStart,
                child: Text(status.track.actionButtonLabel),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
