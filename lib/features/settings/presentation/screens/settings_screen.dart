import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:visualcheckup/core/cloud/cloud_backup_service.dart';
import 'package:visualcheckup/core/l10n/l10n_extensions.dart';
import 'package:visualcheckup/core/l10n/locale_controller.dart';
import 'package:visualcheckup/core/notifications/reminder_service.dart';
import 'package:visualcheckup/core/profile/family_profile_controller.dart';
import 'package:visualcheckup/core/theme/theme_controller.dart';
import 'package:visualcheckup/features/checkup/data/history_repository.dart';
import 'package:visualcheckup/features/checkup/presentation/widgets/ai_settings_sheet.dart';
import 'package:visualcheckup/features/checkup/presentation/widgets/disclaimer_dialog.dart';
import 'package:visualcheckup/features/growth/data/growth_repository.dart';
import 'package:visualcheckup/features/labs_vitals/data/lab_report_pdf_generator.dart';
import 'package:visualcheckup/features/labs_vitals/data/labs_vitals_repository.dart';
import 'package:visualcheckup/features/settings/presentation/screens/privacy_policy_screen.dart';

enum _PermUiState {
  checking,
  granted,
  denied,
  permanentlyDenied,
  unavailable,
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.themeController,
    required this.localeController,
    required this.historyRepository,
    this.labsVitalsRepository,
    this.profileController,
    this.cloudBackupService = const CloudBackupService(),
  });

  final ThemeController themeController;
  final LocaleController localeController;
  final HistoryRepository historyRepository;
  final LabsVitalsRepository? labsVitalsRepository;
  final FamilyProfileController? profileController;
  final CloudBackupService cloudBackupService;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  _PermUiState _cameraState = _PermUiState.checking;
  _PermUiState _photosState = _PermUiState.checking;
  bool _cloudBackupEnabled = false;
  DateTime? _lastCloudSync;
  bool _syncingCloud = false;
  ReminderConfig _reminderConfig = const ReminderConfig();
  final ReminderPreferencesService _reminderService =
      const ReminderPreferencesService();
  late final FamilyProfileController _profileController;
  late final bool _ownsProfileController;

  @override
  void initState() {
    super.initState();
    _ownsProfileController = widget.profileController == null;
    _profileController = widget.profileController ?? FamilyProfileController();
    WidgetsBinding.instance.addObserver(this);
    _refreshPermissions();
    _loadCloudState();
    _loadExtras();
  }

  Future<void> _loadExtras() async {
    final rem = await _reminderService.load();
    if (_ownsProfileController) {
      await _profileController.load();
    }
    if (!mounted) return;
    setState(() => _reminderConfig = rem);
  }

  Future<void> _toggleReminder(bool enabled) async {
    final updated = ReminderConfig(
      enabled: enabled,
      hour: _reminderConfig.hour,
      minute: _reminderConfig.minute,
    );
    await _reminderService.save(updated);
    if (!mounted) return;
    setState(() => _reminderConfig = updated);
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderConfig.timeOfDay,
    );
    if (picked == null || !mounted) return;
    final updated = ReminderConfig(
      enabled: true,
      hour: picked.hour,
      minute: picked.minute,
    );
    await _reminderService.save(updated);
    if (!mounted) return;
    setState(() => _reminderConfig = updated);
  }

  Future<void> _exportHolisticDoctorFile() async {
    try {
      final labsRepo = widget.labsVitalsRepository ?? LabsVitalsRepository();
      final labs = await labsRepo.loadLabReports();
      final bp = await labsRepo.loadBloodPressureReadings();
      final sugar = await labsRepo.loadBloodSugarReadings();
      final visuals = await widget.historyRepository.loadHistory();
      final adultBody = await GrowthRepository().loadAdultMeasurements();
      await LabReportPdfGenerator.saveAndShareHolisticDoctorPdf(
        profileName: _profileController.value.name,
        labReports: labs,
        bpReadings: bp,
        sugarReadings: sugar,
        visualChecks: visuals,
        adultBodyLogs: adultBody,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF oluşturulamadı: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _loadCloudState() async {
    final enabled = await widget.cloudBackupService.isEnabled();
    final last = await widget.cloudBackupService.getLastSyncTime();
    if (!mounted) return;
    setState(() {
      _cloudBackupEnabled = enabled;
      _lastCloudSync = last;
    });
  }

  Future<void> _toggleCloudBackup(bool value) async {
    final l10n = context.l10n;
    if (value) {
      final consented = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.cloudConsentTitle),
          content: Text(l10n.cloudConsentBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.cloudConsentConfirm),
            ),
          ],
        ),
      );
      if (consented != true || !mounted) return;
    }

    await widget.cloudBackupService.setEnabled(value);
    if (!mounted) return;
    setState(() => _cloudBackupEnabled = value);

    if (value && widget.cloudBackupService.canSyncNow) {
      await _runCloudBackup();
    } else if (!value) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.cloudBackupDisabledNotice),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _runCloudBackup() async {
    if (_syncingCloud) return;
    final l10n = context.l10n;
    setState(() => _syncingCloud = true);
    try {
      final summary = await widget.cloudBackupService.backupAll(
        labsVitalsRepository:
            widget.labsVitalsRepository ?? LabsVitalsRepository(),
        historyRepository: widget.historyRepository,
      );
      final last = await widget.cloudBackupService.getLastSyncTime();
      if (!mounted) return;
      setState(() => _lastCloudSync = last);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.cloudBackupSuccess(summary.totalCount)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.cloudBackupFailed(e.toString())),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _syncingCloud = false);
    }
  }

  Future<void> _runCloudRestore() async {
    if (_syncingCloud) return;
    final l10n = context.l10n;
    setState(() => _syncingCloud = true);
    try {
      final summary = await widget.cloudBackupService.restoreAll(
        labsVitalsRepository:
            widget.labsVitalsRepository ?? LabsVitalsRepository(),
        historyRepository: widget.historyRepository,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.cloudRestoreSuccess(summary.totalCount)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.cloudRestoreFailed(e.toString())),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _syncingCloud = false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_ownsProfileController) {
      _profileController.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshPermissions();
    }
  }

  Future<void> _refreshPermissions() async {
    final cam = await _checkPermission(Permission.camera);
    final photos = await _checkPermission(Permission.photos);
    if (!mounted) return;
    setState(() {
      _cameraState = cam;
      _photosState = photos;
    });
  }

  Future<_PermUiState> _checkPermission(Permission permission) async {
    try {
      final status = await permission.status;
      return _mapStatus(status);
    } on MissingPluginException {
      return _PermUiState.unavailable;
    } on UnsupportedError {
      return _PermUiState.unavailable;
    }
  }

  Future<void> _requestPermission(Permission permission) async {
    try {
      final status = await permission.request();
      final mapped = _mapStatus(status);
      if (mapped == _PermUiState.permanentlyDenied) {
        await openAppSettings();
      }
      await _refreshPermissions();
    } on MissingPluginException {
      if (!mounted) return;
      setState(() {
        if (permission == Permission.camera) {
          _cameraState = _PermUiState.unavailable;
        } else {
          _photosState = _PermUiState.unavailable;
        }
      });
    } on UnsupportedError {
      // Ignore on unsupported desktop hosts.
    }
  }

  Future<void> _openSystemSettings() async {
    try {
      await openAppSettings();
    } on MissingPluginException {
      // Ignore on test hosts.
    } on UnsupportedError {
      // Ignore on unsupported hosts.
    }
  }

  _PermUiState _mapStatus(PermissionStatus status) {
    if (status.isGranted || status.isLimited || status.isProvisional) {
      return _PermUiState.granted;
    }
    if (status.isPermanentlyDenied || status.isRestricted) {
      return _PermUiState.permanentlyDenied;
    }
    return _PermUiState.denied;
  }

  String _permLabel(_PermUiState state, BuildContext context) {
    final l10n = context.l10n;
    switch (state) {
      case _PermUiState.checking:
        return l10n.permChecking;
      case _PermUiState.granted:
        return l10n.permGranted;
      case _PermUiState.denied:
        return l10n.permDenied;
      case _PermUiState.permanentlyDenied:
        return l10n.permPermanent;
      case _PermUiState.unavailable:
        return l10n.permUnavailable;
    }
  }

  Color _permColor(_PermUiState state, ColorScheme scheme) {
    switch (state) {
      case _PermUiState.granted:
        return const Color(0xFF1B8A5A);
      case _PermUiState.denied:
        return const Color(0xFFD9822B);
      case _PermUiState.permanentlyDenied:
        return scheme.error;
      case _PermUiState.checking:
      case _PermUiState.unavailable:
        return scheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final resolvedCode = Localizations.localeOf(context).languageCode;
    final resolvedLang = LocaleController.optionForCode(resolvedCode);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // 1. Language Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.language_rounded, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        l10n.menuLanguage,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.settingsLanguageDesc,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<Locale?>(
                    valueListenable: widget.localeController,
                    builder: (context, selectedLocale, _) {
                      final isSystem = selectedLocale == null;
                      final subtitle = isSystem
                          ? '${l10n.languageSystem} (${resolvedLang.nativeName})'
                          : '${resolvedLang.nativeName} (${resolvedLang.englishName})';
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(color: colorScheme.outlineVariant),
                        ),
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor: colorScheme.primaryContainer,
                          child: Text(
                            resolvedCode.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                        title: Text(
                          l10n.menuLanguage,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(subtitle),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => LanguagePickerSheet.show(
                          context,
                          localeController: widget.localeController,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 2. Permissions Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.settingsPermissionsTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.settingsPermissionsDesc,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _PermissionRow(
                    icon: Icons.photo_camera_outlined,
                    title: l10n.settingsCameraPermission,
                    subtitle: l10n.settingsCameraPermissionDesc,
                    statusLabel: _permLabel(_cameraState, context),
                    statusColor: _permColor(_cameraState, colorScheme),
                    showAction: _cameraState == _PermUiState.denied ||
                        _cameraState == _PermUiState.permanentlyDenied,
                    actionLabel: _cameraState == _PermUiState.permanentlyDenied
                        ? l10n.permOpenSettingsBtn
                        : l10n.permGrantBtn,
                    onAction: () => _requestPermission(Permission.camera),
                  ),
                  const Divider(height: 20),
                  _PermissionRow(
                    icon: Icons.photo_library_outlined,
                    title: l10n.settingsPhotosPermission,
                    subtitle: l10n.settingsPhotosPermissionDesc,
                    statusLabel: _permLabel(_photosState, context),
                    statusColor: _permColor(_photosState, colorScheme),
                    showAction: _photosState == _PermUiState.denied ||
                        _photosState == _PermUiState.permanentlyDenied,
                    actionLabel: _photosState == _PermUiState.permanentlyDenied
                        ? l10n.permOpenSettingsBtn
                        : l10n.permGrantBtn,
                    onAction: () => _requestPermission(Permission.photos),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _openSystemSettings,
                      icon: const Icon(Icons.open_in_new_rounded, size: 18),
                      label: Text(l10n.settingsOpenSystemPermissions),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 3. Appearance Theme Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.palette_outlined, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        l10n.menuTheme,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<ThemeMode>(
                    valueListenable: widget.themeController,
                    builder: (context, mode, _) {
                      return SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<ThemeMode>(
                          showSelectedIcon: false,
                          segments: [
                            ButtonSegment<ThemeMode>(
                              value: ThemeMode.system,
                              label: Text(l10n.themeSystem),
                            ),
                            ButtonSegment<ThemeMode>(
                              value: ThemeMode.light,
                              label: Text(l10n.themeLight),
                            ),
                            ButtonSegment<ThemeMode>(
                              value: ThemeMode.dark,
                              label: Text(l10n.themeDark),
                            ),
                          ],
                          selected: {mode},
                          onSelectionChanged: (selection) {
                            if (selection.isNotEmpty) {
                              widget.themeController.setThemeMode(
                                selection.first,
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 4. Opt-In Firebase Cloud Backup Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.cloud_done_outlined,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.cloudBackupTitle,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.cloudBackupDesc,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      l10n.cloudBackupToggleTitle,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      _lastCloudSync != null
                          ? l10n.cloudBackupLastSync(
                              DateFormat('dd.MM.yyyy HH:mm')
                                  .format(_lastCloudSync!),
                            )
                          : (_cloudBackupEnabled
                              ? l10n.cloudBackupEnabledReady
                              : l10n.cloudBackupDisabledLocal),
                    ),
                    value: _cloudBackupEnabled,
                    onChanged: _syncingCloud ? null : _toggleCloudBackup,
                  ),
                  if (_syncingCloud) ...[
                    const SizedBox(height: 8),
                    const LinearProgressIndicator(),
                  ],
                  if (_cloudBackupEnabled) ...[
                    const SizedBox(height: 8),
                    if (!widget.cloudBackupService.canSyncNow)
                      Text(
                        l10n.cloudBackupSignInRequired,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilledButton.tonalIcon(
                            onPressed: _syncingCloud ? null : _runCloudBackup,
                            icon: const Icon(
                              Icons.cloud_upload_outlined,
                              size: 18,
                            ),
                            label: Text(l10n.cloudBackupNowBtn),
                          ),
                          OutlinedButton.icon(
                            onPressed: _syncingCloud ? null : _runCloudRestore,
                            icon: const Icon(
                              Icons.cloud_download_outlined,
                              size: 18,
                            ),
                            label: Text(l10n.cloudRestoreBtn),
                          ),
                        ],
                      ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 5. Family Profiles, Reminders & Holistic Doctor File
          Card(
            child: Column(
              children: [
                ValueListenableBuilder<FamilyProfile>(
                  valueListenable: _profileController,
                  builder: (context, activeProfile, _) {
                    return ListTile(
                      leading: Icon(
                        Icons.family_restroom_outlined,
                        color: colorScheme.primary,
                      ),
                      title: const Text(
                        'Aile Profilleri',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'Aktif profil: ${activeProfile.name} (${activeProfile.relation})',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => FamilyProfileSheet.show(
                        context,
                        controller: _profileController,
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: Icon(
                    Icons.notifications_active_outlined,
                    color: colorScheme.primary,
                  ),
                  title: const Text(
                    'Takip Planı Hatırlatıcısı',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    _reminderConfig.enabled
                        ? 'Aktif • Günlük saat ${_reminderConfig.formattedTime}'
                        : 'Kapalı • Kişisel takip planı hatırlatması',
                  ),
                  value: _reminderConfig.enabled,
                  onChanged: _toggleReminder,
                ),
                if (_reminderConfig.enabled)
                  ListTile(
                    dense: true,
                    leading: const SizedBox(width: 24),
                    title: const Text('Hatırlatma Saati'),
                    trailing: TextButton(
                      onPressed: _pickReminderTime,
                      child: Text(_reminderConfig.formattedTime),
                    ),
                  ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.picture_as_pdf_outlined,
                    color: colorScheme.primary,
                  ),
                  title: const Text(
                    'Bütüncül Doktor Dosyası PDF',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Son tahlil, tansiyon/şeker ve görsel kontroller tek PDF’te',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: _exportHolisticDoctorFile,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 6. Privacy & Medical Notice Card
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.auto_awesome_outlined,
                    color: colorScheme.primary,
                  ),
                  title: Text(l10n.menuAiSettings),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => AiSettingsSheet.show(
                    context,
                    historyRepository: widget.historyRepository,
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.privacy_tip_outlined,
                    color: colorScheme.primary,
                  ),
                  title: const Text('Gizlilik Politikası & KVKK'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => PrivacyPolicyScreen.open(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.info_outline_rounded,
                    color: colorScheme.primary,
                  ),
                  title: Text(l10n.menuDisclaimer),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => DisclaimerDialog.show(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.statusLabel,
    required this.statusColor,
    required this.showAction,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String statusLabel;
  final Color statusColor;
  final bool showAction;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: statusColor.withValues(alpha: 0.14),
          child: Icon(icon, size: 19, color: statusColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showAction)
          FilledButton.tonal(
            onPressed: onAction,
            style: FilledButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
            child: Text(actionLabel),
          ),
      ],
    );
  }
}
