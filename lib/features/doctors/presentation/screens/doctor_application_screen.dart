import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:visualcheckup/core/l10n/l10n_extensions.dart';
import 'package:visualcheckup/core/safety/content_safety_service.dart';
import 'package:visualcheckup/core/theme/app_theme.dart';
import 'package:visualcheckup/features/auth/domain/auth_user.dart';
import 'package:visualcheckup/features/community/data/community_image_upload_service.dart';
import 'package:visualcheckup/features/community/domain/health_community_models.dart';
import 'package:visualcheckup/features/doctors/data/doctor_repository.dart';
import 'package:visualcheckup/features/doctors/domain/doctor_models.dart';

/// Verified Doctor Application screen replacing student/teacher concepts with
/// licensed physicians who can list by country and offer patient follow-ups.
class DoctorApplicationScreen extends StatefulWidget {
  const DoctorApplicationScreen({
    super.key,
    required this.currentUser,
    required this.repository,
    this.uploadService,
  });

  final AuthUser currentUser;
  final DoctorRepository repository;
  final CommunityImageUploadService? uploadService;

  @override
  State<DoctorApplicationScreen> createState() =>
      _DoctorApplicationScreenState();
}

class _DoctorApplicationScreenState extends State<DoctorApplicationScreen> {
  final TextEditingController _titleCtrl = TextEditingController(text: 'Dr.');
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _cityCtrl = TextEditingController();
  final TextEditingController _clinicCtrl = TextEditingController();
  final TextEditingController _licenseCtrl = TextEditingController();
  final TextEditingController _expCtrl = TextEditingController(text: '5');
  final TextEditingController _bioCtrl = TextEditingController();

  DoctorSpecialty _specialty = DoctorSpecialty.internalMedicine;
  String _countryCode = 'TR';
  bool _acceptsFollowUp = true;
  DoctorPlanTier _selectedPlan = DoctorPlanTier.proFollowUpYearly;
  String? _docUrl;
  String? _docKey;
  bool _uploadingDoc = false;
  bool _submitting = false;
  DoctorProfile? _existingApp;

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = widget.currentUser.displayName;
    _loadExisting();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _nameCtrl.dispose();
    _cityCtrl.dispose();
    _clinicCtrl.dispose();
    _licenseCtrl.dispose();
    _expCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    final existing =
        await widget.repository.loadMyApplication(widget.currentUser.id);
    if (!mounted || existing == null) return;
    setState(() {
      _existingApp = existing;
      _titleCtrl.text = existing.title;
      _nameCtrl.text = existing.fullName;
      _specialty = existing.specialty;
      _countryCode = existing.countryCode;
      _cityCtrl.text = existing.city;
      _clinicCtrl.text = existing.hospitalOrClinic;
      _licenseCtrl.text = existing.licenseNumber;
      _expCtrl.text = '${existing.yearsExperience}';
      _bioCtrl.text = existing.bio;
      _acceptsFollowUp = existing.acceptsPatientFollowUp;
      _selectedPlan = existing.planTier;
      _docUrl = existing.documentUrl;
      _docKey = existing.documentKey;
    });
  }

  Future<void> _uploadDocument() async {
    if (_uploadingDoc) return;
    setState(() => _uploadingDoc = true);
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (file == null) return;
      final Uint8List bytes = await file.readAsBytes();
      final imgSafety = ContentSafetyService.validateImageBytes(bytes);
      if (!imgSafety.isSafe) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.safetyImageBlocked)),
          );
        }
        return;
      }
      final uploader =
          widget.uploadService ?? R2CommunityImageUploadService.instance;
      final res = await uploader.uploadBytes(bytes, folder: 'doctor_docs');
      if (!mounted) return;
      setState(() {
        _docUrl = res.url;
        _docKey = res.objectKey;
      });
    } catch (_) {
    } finally {
      if (mounted) setState(() => _uploadingDoc = false);
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final l10n = context.l10n;
    final name = _nameCtrl.text.trim();
    final license = _licenseCtrl.text.trim();
    if (name.isEmpty || license.isEmpty) return;

    final combinedText =
        '${_titleCtrl.text} $name ${_clinicCtrl.text} ${_bioCtrl.text}';
    final safety = ContentSafetyService.checkText(combinedText);
    if (!safety.isSafe) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.safetyContentBlocked)),
      );
      return;
    }

    setState(() => _submitting = true);
    final exp = int.tryParse(_expCtrl.text.trim()) ?? 5;
    final app = DoctorProfile(
      uid: widget.currentUser.id,
      fullName: name,
      title: _titleCtrl.text.trim().isEmpty ? 'Dr.' : _titleCtrl.text.trim(),
      specialty: _specialty,
      countryCode: _countryCode,
      city: _cityCtrl.text.trim(),
      hospitalOrClinic: _clinicCtrl.text.trim(),
      licenseNumber: license,
      yearsExperience: exp.clamp(0, 70),
      spokenLanguages: [Localizations.localeOf(context).languageCode, 'en'],
      bio: _bioCtrl.text.trim(),
      documentUrl: _docUrl,
      documentKey: _docKey,
      acceptsPatientFollowUp: _acceptsFollowUp,
      planTier: _selectedPlan,
      status: DoctorApplicationStatus.pending,
      createdAt: DateTime.now(),
    );

    final saved = await widget.repository.submitApplication(app);
    if (!mounted) return;
    setState(() {
      _existingApp = saved;
      _submitting = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.doctorApplicationSubmitted)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final langCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.doctorApplicationTitle)),
      body: ListView(
        key: const Key('doctor_app_form_list'),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppTheme.primaryTeal.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.doctorApplicationSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                ),
                if (_existingApp != null) ...[
                  const SizedBox(height: 8),
                  Chip(
                    avatar: const Icon(Icons.hourglass_top_rounded, size: 16),
                    label: Text(
                      _existingApp!.status == DoctorApplicationStatus.approved
                          ? l10n.doctorVerifiedBadge
                          : l10n.doctorApplicationPendingBadge,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              SizedBox(
                width: 110,
                child: TextField(
                  key: const Key('doctor_app_title_field'),
                  controller: _titleCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.doctorFieldTitle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  key: const Key('doctor_app_name_field'),
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.doctorFieldFullName,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          DropdownButtonFormField<DoctorSpecialty>(
            key: const Key('doctor_app_specialty_field'),
            initialValue: _specialty,
            decoration: InputDecoration(
              labelText: l10n.doctorFieldSpecialty,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            items: [
              for (final s in DoctorSpecialty.values)
                DropdownMenuItem(
                  value: s,
                  child: Text(s.localizedLabel(l10n)),
                ),
            ],
            onChanged: (v) {
              if (v != null) setState(() => _specialty = v);
            },
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  key: const Key('doctor_app_country_field'),
                  initialValue: _countryCode,
                  decoration: InputDecoration(
                    labelText: l10n.commFieldCountry,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  items: [
                    for (final c in CommunityCountryOption.all)
                      if (c.code != 'GLOBAL')
                        DropdownMenuItem(
                          value: c.code,
                          child: Text(
                            '${c.flag} ${c.label}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _countryCode = v);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  key: const Key('doctor_app_city_field'),
                  controller: _cityCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.commFieldCity,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          TextField(
            key: const Key('doctor_app_clinic_field'),
            controller: _clinicCtrl,
            decoration: InputDecoration(
              labelText: l10n.doctorFieldClinic,
              prefixIcon: const Icon(Icons.local_hospital_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  key: const Key('doctor_app_license_field'),
                  controller: _licenseCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.doctorFieldLicense,
                    prefixIcon: const Icon(Icons.verified_user_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  key: const Key('doctor_app_exp_field'),
                  controller: _expCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.doctorFieldExperience,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          TextField(
            key: const Key('doctor_app_bio_field'),
            controller: _bioCtrl,
            maxLines: 3,
            maxLength: 350,
            decoration: InputDecoration(
              labelText: l10n.doctorFieldBio,
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 6),

          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.doctorToggleFollowUp),
            value: _acceptsFollowUp,
            onChanged: (v) => setState(() => _acceptsFollowUp = v),
          ),
          const SizedBox(height: 8),

          OutlinedButton.icon(
            onPressed: _uploadingDoc ? null : _uploadDocument,
            icon: _uploadingDoc
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.upload_file_outlined),
            label: Text(
              _docUrl != null
                  ? '✓ ${l10n.doctorUploadDocBtn}'
                  : l10n.doctorUploadDocBtn,
            ),
          ),
          const SizedBox(height: 16),

          // Doctor Listing Membership Pricing
          Text(
            l10n.doctorPlanSectionTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          _DoctorPlanCard(
            key: const Key('doctor_plan_yearly_card'),
            title: l10n.doctorPlanYearlyTitle,
            description: l10n.doctorPlanYearlyDesc,
            price:
                '${DoctorPlanTier.proFollowUpYearly.localizedPrice(langCode)} ${l10n.proPerYear}',
            selected: _selectedPlan == DoctorPlanTier.proFollowUpYearly,
            onTap: () => setState(
              () => _selectedPlan = DoctorPlanTier.proFollowUpYearly,
            ),
          ),
          const SizedBox(height: 8),
          _DoctorPlanCard(
            key: const Key('doctor_plan_monthly_card'),
            title: l10n.doctorPlanMonthlyTitle,
            description: l10n.doctorPlanMonthlyDesc,
            price:
                '${DoctorPlanTier.standardMonthly.localizedPrice(langCode)} ${l10n.proPerMonth}',
            selected: _selectedPlan == DoctorPlanTier.standardMonthly,
            onTap: () => setState(
              () => _selectedPlan = DoctorPlanTier.standardMonthly,
            ),
          ),
          const SizedBox(height: 20),

          SizedBox(
            height: 54,
            child: FilledButton.icon(
              key: const Key('doctor_app_submit_button'),
              onPressed: _submitting ? null : _submit,
              icon: const Icon(Icons.send_rounded),
              label: Text(
                l10n.doctorSubmitApplicationBtn,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.commSafetyBanner,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorPlanCard extends StatelessWidget {
  const _DoctorPlanCard({
    super.key,
    required this.title,
    required this.description,
    required this.price,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String description;
  final String price;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primaryTeal.withValues(alpha: 0.10)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            width: selected ? 2 : 1,
            color: selected ? AppTheme.primaryTeal : colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected
                  ? AppTheme.primaryTeal
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              price,
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppTheme.primaryTeal,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
