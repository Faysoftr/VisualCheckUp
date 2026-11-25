import 'package:flutter/material.dart';
import 'package:visualcheckup/core/l10n/l10n_extensions.dart';
import 'package:visualcheckup/core/safety/content_safety_service.dart';
import 'package:visualcheckup/core/theme/app_theme.dart';
import 'package:visualcheckup/features/auth/domain/auth_user.dart';
import 'package:visualcheckup/features/community/data/community_image_upload_service.dart';
import 'package:visualcheckup/features/community/domain/health_community_models.dart';
import 'package:visualcheckup/features/community/presentation/widgets/community_avatar_and_report.dart';
import 'package:visualcheckup/features/doctors/data/doctor_repository.dart';
import 'package:visualcheckup/features/doctors/domain/doctor_models.dart';
import 'package:visualcheckup/features/doctors/presentation/screens/doctor_application_screen.dart';

/// Worldwide Verified Doctors Directory filterable by Country, Medical
/// Specialty, Patient Follow-Up availability, and search query.
class DoctorSearchScreen extends StatefulWidget {
  const DoctorSearchScreen({
    super.key,
    required this.currentUser,
    required this.repository,
    this.uploadService,
    this.initialCountryCode = 'ALL',
  });

  final AuthUser currentUser;
  final DoctorRepository repository;
  final CommunityImageUploadService? uploadService;
  final String initialCountryCode;

  @override
  State<DoctorSearchScreen> createState() => _DoctorSearchScreenState();
}

class _DoctorSearchScreenState extends State<DoctorSearchScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  late String _countryFilter;
  DoctorSpecialty? _specialtyFilter;
  bool _followUpOnly = false;
  bool _loading = true;
  List<DoctorProfile> _doctors = const [];

  @override
  void initState() {
    super.initState();
    _countryFilter = widget.initialCountryCode;
    _refresh();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final list = await widget.repository.searchDoctors(
      countryCode: _countryFilter,
      specialty: _specialtyFilter,
      followUpOnly: _followUpOnly,
      searchQuery: _searchCtrl.text,
    );
    if (!mounted) return;
    setState(() {
      _doctors = list;
      _loading = false;
    });
  }

  Future<void> _openDoctorApplication() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => DoctorApplicationScreen(
          currentUser: widget.currentUser,
          repository: widget.repository,
          uploadService: widget.uploadService,
        ),
      ),
    );
    await _refresh();
  }

  Future<void> _openFollowUpDialog(DoctorProfile doctor) async {
    final note = await showDialog<String>(
      context: context,
      builder: (_) => _FollowUpNoteDialog(doctorName: doctor.displayTitleName),
    );
    if (note == null || !mounted) return;

    final safety = ContentSafetyService.checkText(note);
    if (!safety.isSafe) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.safetyContentBlocked)),
      );
      return;
    }

    await widget.repository.requestPatientFollowUp(
      doctor: doctor,
      patientUid: widget.currentUser.id,
      patientName: widget.currentUser.displayName,
      note: note,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.doctorFollowUpSent)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    const featuredCountries = ['ALL', 'TR', 'DE', 'SE', 'ES', 'US', 'GB', 'FR'];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.doctorSearchTitle),
        actions: [
          TextButton.icon(
            key: const Key('doctor_search_apply_action'),
            onPressed: _openDoctorApplication,
            icon: const Icon(Icons.medical_information_outlined, size: 18),
            label: Text(l10n.doctorApplyCta),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search + Full Country Dropdown
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('doctor_search_field'),
                    controller: _searchCtrl,
                    onChanged: (_) => _refresh(),
                    decoration: InputDecoration(
                      hintText: l10n.doctorSearchHint,
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      isDense: true,
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.45),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      key: const Key('doctor_country_dropdown'),
                      value: _countryFilter,
                      isDense: true,
                      items: [
                        DropdownMenuItem(
                          value: 'ALL',
                          child: Text('🌍 ${l10n.commFilterAllCountries}'),
                        ),
                        for (final c in CommunityCountryOption.all)
                          if (c.code != 'GLOBAL')
                            DropdownMenuItem(
                              value: c.code,
                              child: Text('${c.flag} ${c.code}'),
                            ),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _countryFilter = v);
                        _refresh();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Quick Country Chips
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              children: [
                for (final code in featuredCountries)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      key: Key('doctor_country_chip_$code'),
                      label: Text(
                        code == 'ALL'
                            ? '🌍 ${l10n.commFilterAllCountries}'
                            : '${CommunityCountryOption.byCode(code).flag} $code',
                      ),
                      selected: _countryFilter == code,
                      onSelected: (_) {
                        setState(() => _countryFilter = code);
                        _refresh();
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Follow-Up Toggle + Specialty Chips
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    key: const Key('doctor_filter_followup'),
                    avatar: const Icon(Icons.assignment_turned_in_outlined,
                        size: 16),
                    label: Text(l10n.doctorFilterFollowUpOnly),
                    selected: _followUpOnly,
                    onSelected: (v) {
                      setState(() => _followUpOnly = v);
                      _refresh();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(l10n.doctorFilterAllSpecialties),
                    selected: _specialtyFilter == null,
                    onSelected: (_) {
                      setState(() => _specialtyFilter = null);
                      _refresh();
                    },
                  ),
                ),
                for (final spec in DoctorSpecialty.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      key: Key('doctor_spec_${spec.name}'),
                      avatar: Icon(
                        spec.icon,
                        size: 15,
                        color: _specialtyFilter == spec
                            ? Colors.white
                            : spec.accentColor,
                      ),
                      label: Text(spec.localizedLabel(l10n)),
                      selected: _specialtyFilter == spec,
                      selectedColor: spec.accentColor,
                      labelStyle: TextStyle(
                        color: _specialtyFilter == spec ? Colors.white : null,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) {
                        setState(
                          () => _specialtyFilter =
                              _specialtyFilter == spec ? null : spec,
                        );
                        _refresh();
                      },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Verified Doctors List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _doctors.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            l10n.doctorEmptyResults,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
                        itemCount: _doctors.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (ctx, i) {
                          final doc = _doctors[i];
                          return _DoctorCard(
                            doctor: doc,
                            onRequestFollowUp: doc.acceptsPatientFollowUp
                                ? () => _openFollowUpDialog(doc)
                                : null,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({
    required this.doctor,
    this.onRequestFollowUp,
  });

  final DoctorProfile doctor;
  final VoidCallback? onRequestFollowUp;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent = doctor.specialty.accentColor;

    return Card(
      key: Key('doctor_card_${doctor.uid}'),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CommunityAvatar(
                  initials: doctor.initials,
                  photoUrl: doctor.photoUrl,
                  radius: 26,
                  accentColor: accent,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              doctor.displayTitleName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (doctor.isVerified) ...[
                            const SizedBox(width: 5),
                            const Icon(
                              Icons.verified_rounded,
                              size: 17,
                              color: Color(0xFF0284C7),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${doctor.country.flag} ${doctor.city.isNotEmpty ? '${doctor.city}, ' : ''}${doctor.country.label} • ${l10n.doctorExperienceYears(doctor.yearsExperience)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (doctor.hospitalOrClinic.isNotEmpty)
                        Text(
                          doctor.hospitalOrClinic,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(doctor.specialty.icon, size: 13, color: accent),
                      const SizedBox(width: 4),
                      Text(
                        doctor.specialty.localizedLabel(l10n),
                        style: TextStyle(
                          color: accent,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                if (doctor.acceptsPatientFollowUp)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A).withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '🩺 ${l10n.doctorFollowUpBadge}',
                      style: const TextStyle(
                        color: Color(0xFF16A34A),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                if (doctor.isOnline)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '🟢 ${l10n.commOnlineNow}',
                      style: const TextStyle(
                        color: AppTheme.primaryTeal,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
            if (doctor.bio.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                doctor.bio.trim(),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
              ),
            ],
            if (onRequestFollowUp != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  key: Key('doctor_followup_btn_${doctor.uid}'),
                  onPressed: onRequestFollowUp,
                  icon: const Icon(Icons.assignment_ind_outlined, size: 18),
                  label: Text(l10n.doctorRequestFollowUpBtn),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FollowUpNoteDialog extends StatefulWidget {
  const _FollowUpNoteDialog({required this.doctorName});

  final String doctorName;

  @override
  State<_FollowUpNoteDialog> createState() => _FollowUpNoteDialogState();
}

class _FollowUpNoteDialogState extends State<_FollowUpNoteDialog> {
  final TextEditingController _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text('${l10n.doctorFollowUpDialogTitle}\n${widget.doctorName}'),
      content: TextField(
        key: const Key('doctor_followup_note_field'),
        controller: _noteCtrl,
        maxLines: 3,
        maxLength: 300,
        decoration: InputDecoration(
          hintText: l10n.doctorFollowUpNoteHint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          key: const Key('doctor_followup_submit_btn'),
          onPressed: () => Navigator.of(context).pop(_noteCtrl.text.trim()),
          child: Text(l10n.doctorRequestFollowUpBtn),
        ),
      ],
    );
  }
}
