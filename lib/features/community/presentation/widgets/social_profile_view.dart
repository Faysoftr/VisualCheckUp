import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visualcheckup/core/l10n/l10n_extensions.dart';
import 'package:visualcheckup/core/l10n/locale_controller.dart';
import 'package:visualcheckup/core/safety/content_safety_service.dart';
import 'package:visualcheckup/core/theme/app_theme.dart';
import 'package:visualcheckup/features/admin/domain/admin_models.dart';
import 'package:visualcheckup/features/auth/domain/auth_user.dart';
import 'package:visualcheckup/features/checkup/presentation/widgets/home_social_showcase.dart';
import 'package:visualcheckup/features/community/data/community_image_upload_service.dart';
import 'package:visualcheckup/features/community/data/health_community_repository.dart';
import 'package:visualcheckup/features/community/domain/health_community_models.dart';
import 'package:visualcheckup/features/community/presentation/screens/health_chat_screen.dart';
import 'package:visualcheckup/features/community/presentation/screens/health_profile_detail_screen.dart';
import 'package:visualcheckup/features/community/presentation/widgets/community_avatar_and_report.dart';
import 'package:visualcheckup/features/community/presentation/widgets/profile_wellness_cards.dart';
import 'package:visualcheckup/features/pedometer/data/pedometer_service.dart';
import 'package:visualcheckup/features/pedometer/presentation/screens/step_counter_screen.dart';
import 'package:visualcheckup/features/sobriety/data/sobriety_repository.dart';
import 'package:visualcheckup/features/sobriety/domain/sobriety_models.dart';
import 'package:visualcheckup/features/sobriety/presentation/screens/sobriety_tracker_screen.dart';
import 'package:visualcheckup/features/wellness_extras/daily_health_tip_and_birthday.dart';

/// Social Formula Bank-inspired My Profile view used both inside the standalone
/// [MyHealthProfileScreen] (launched from the top of AppDrawer) and inside the
/// "My Profile" tab of [HealthCommunityHubScreen].
class SocialProfileView extends StatefulWidget {
  const SocialProfileView({
    super.key,
    required this.currentUser,
    required this.repository,
    this.uploadService,
    this.photoPicker,
    this.urlLauncher,
    this.onProfileChanged,
    this.onOpenAdminPanel,
  });

  final AuthUser currentUser;
  final HealthCommunityRepository repository;
  final CommunityImageUploadService? uploadService;
  final CommunityPhotoPicker? photoPicker;
  final CommunityUrlLauncher? urlLauncher;
  final VoidCallback? onProfileChanged;
  final VoidCallback? onOpenAdminPanel;

  @override
  State<SocialProfileView> createState() => _SocialProfileViewState();
}

class _SocialProfileViewState extends State<SocialProfileView> {
  late final CommunityImageUploadService _uploadService;
  final SobrietyRepository _sobrietyRepo = SobrietyRepository();
  final PedometerService _pedometerService = PedometerService.instance;

  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _dailyFocusController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _mottoController = TextEditingController();
  final TextEditingController _customConditionController =
      TextEditingController();
  final TextEditingController _musicTitleController = TextEditingController();
  final TextEditingController _musicUrlController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _twitterXController = TextEditingController();
  final TextEditingController _tiktokController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _snapchatController = TextEditingController();

  bool _loading = true;
  bool _savingProfile = false;
  bool _uploadingAvatar = false;
  bool _creatingProfile = false;
  bool _editingProfile = false;

  HealthCommunityProfile? _myProfile;
  SobrietyState _localSobriety = const SobrietyState();
  List<MusicListenerRecord> _myMusicListeners = const [];
  List<FriendshipRecord> _friendships = const [];

  // Social Formül Bank Identity, Age, Gender & Quota State
  String _initialRealName = '';
  String _initialNickname = '';
  int _nameChangeCount = 0;
  int _nicknameChangeCount = 0;
  DateTime? _birthDate;
  bool _birthDateFromLogin = false;
  bool _showBirthDate = true;
  String? _gender;
  bool _showGender = true;

  Timer? _nickDebounce;
  bool _checkingNickname = false;
  bool? _isNicknameAvailable;
  List<String> _nicknameSuggestions = const [];

  String? _photoUrl;
  String? _photoKey;
  String _countryCode = 'TR';
  String _languageCode = 'tr';
  Set<HealthGoalTag> _selectedGoals = {HealthGoalTag.healthyLiving};
  Set<ChronicCondition> _selectedConditions = {};
  HealthMood? _selectedMood;
  bool _showChronicConditions = true;
  bool _showOnlineStatus = true;
  bool _showSocials = true;
  bool _showBio = true;
  bool _showMotto = true;
  bool _showSobrietyOnProfile = true;
  bool _showStepsOnProfile = true;
  bool _discoverable = true;
  bool _hideRealName = false;
  bool _hidePhoto = false;
  bool _allowMessages = true;
  bool _requireMessageApproval = true;
  bool _onlyFriendsCanMessage = false;

  String get _myUid => widget.currentUser.id;

  bool get _isAdmin => AdminUtils.isAdmin(
        email: widget.currentUser.email,
        uid: widget.currentUser.id,
      );

  bool get _isRealNameLocked =>
      !_isAdmin &&
      _myProfile != null &&
      _initialRealName.isNotEmpty &&
      _nameChangeCount >= HealthCommunityProfile.maxNameChanges;

  bool get _isNicknameLocked =>
      !_isAdmin &&
      _myProfile != null &&
      _initialNickname.isNotEmpty &&
      _nicknameChangeCount >= HealthCommunityProfile.maxNicknameChanges;

  int get _remainingNameChanges =>
      (HealthCommunityProfile.maxNameChanges - _nameChangeCount)
          .clamp(0, HealthCommunityProfile.maxNameChanges);

  int get _remainingNicknameChanges =>
      (HealthCommunityProfile.maxNicknameChanges - _nicknameChangeCount)
          .clamp(0, HealthCommunityProfile.maxNicknameChanges);

  static DateTime? _parseBirthDateString(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final parts = raw.trim().split(RegExp(r'[-/.]'));
    if (parts.length != 3) return null;
    final p0 = int.tryParse(parts[0]);
    final p1 = int.tryParse(parts[1]);
    final p2 = int.tryParse(parts[2]);
    if (p0 == null || p1 == null || p2 == null) return null;
    if (p2 > 1900) {
      return DateTime(p2, p1.clamp(1, 12), p0.clamp(1, 31));
    }
    if (p0 > 1900) {
      return DateTime(p0, p1.clamp(1, 12), p2.clamp(1, 31));
    }
    return null;
  }

  static String _formatBirthDate(DateTime dt) {
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    return '$dd-$mm-${dt.year}';
  }

  int? get _calculatedAge {
    final dt = _birthDate;
    if (dt == null) return null;
    final now = DateTime.now();
    int age = now.year - dt.year;
    if (now.month < dt.month || (now.month == dt.month && now.day < dt.day)) {
      age--;
    }
    return age >= 0 && age <= 125 ? age : null;
  }

  @override
  void initState() {
    super.initState();
    _uploadService =
        widget.uploadService ?? R2CommunityImageUploadService.instance;
    _pedometerService.addListener(_onWellnessChanged);
    SobrietyRepository.revisionNotifier.addListener(_reloadSobriety);
    _pedometerService.ensureLoaded();
    _loadProfileData();
  }

  @override
  void dispose() {
    _nickDebounce?.cancel();
    _pedometerService.removeListener(_onWellnessChanged);
    SobrietyRepository.revisionNotifier.removeListener(_reloadSobriety);
    _displayNameController.dispose();
    _nicknameController.dispose();
    _birthDateController.dispose();
    _cityController.dispose();
    _dailyFocusController.dispose();
    _bioController.dispose();
    _mottoController.dispose();
    _customConditionController.dispose();
    _musicTitleController.dispose();
    _musicUrlController.dispose();
    _instagramController.dispose();
    _twitterXController.dispose();
    _tiktokController.dispose();
    _facebookController.dispose();
    _snapchatController.dispose();
    super.dispose();
  }

  void _onWellnessChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _reloadSobriety() async {
    final loaded = await _sobrietyRepo.loadState();
    if (!mounted) return;
    setState(() => _localSobriety = loaded);
  }

  void _onNicknameChanged(String raw) {
    _nickDebounce?.cancel();
    final clean = HealthCommunityProfile.sanitizeNickname(raw);
    if (clean.isEmpty || clean == _initialNickname) {
      setState(() {
        _checkingNickname = false;
        _isNicknameAvailable = null;
        _nicknameSuggestions = const [];
      });
      return;
    }
    if (clean.length < 3) {
      setState(() {
        _checkingNickname = false;
        _isNicknameAvailable = false;
        _nicknameSuggestions = const [];
      });
      return;
    }

    setState(() {
      _checkingNickname = true;
      _isNicknameAvailable = null;
      _nicknameSuggestions = const [];
    });

    _nickDebounce = Timer(const Duration(milliseconds: 400), () async {
      final taken = await widget.repository.isNicknameTaken(
        clean,
        excludeUid: _myUid,
      );
      List<String> suggestions = const [];
      if (taken) {
        suggestions = await widget.repository.generateNicknameSuggestions(
          clean,
          excludeUid: _myUid,
        );
      }
      if (!mounted) return;
      final latestClean = HealthCommunityProfile.sanitizeNickname(
        _nicknameController.text,
      );
      if (latestClean != clean) return;
      setState(() {
        _checkingNickname = false;
        _isNicknameAvailable = !taken;
        _nicknameSuggestions = suggestions;
      });
    });
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final initial = _birthDate ?? DateTime(now.year - 28, 6, 15);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(now) ? now : initial,
      firstDate: DateTime(1920, 1, 1),
      lastDate: now,
      helpText: 'Doğum Tarihinizi Seçin',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _birthDate = picked;
      _birthDateFromLogin = false;
      _birthDateController.text = _formatBirthDate(picked);
    });
  }

  void _syncFormFromProfile(HealthCommunityProfile? profile) {
    _nickDebounce?.cancel();
    _checkingNickname = false;
    _isNicknameAvailable = null;
    _nicknameSuggestions = const [];

    if (profile == null) {
      _initialRealName = '';
      _initialNickname = '';
      _nameChangeCount = 0;
      _nicknameChangeCount = 0;
      _displayNameController.text = widget.currentUser.displayName;
      var defaultNick = HealthCommunityProfile.sanitizeNickname(
        widget.currentUser.displayName,
      );
      if (defaultNick.isNotEmpty && defaultNick.length < 3) {
        defaultNick = '${defaultNick}_vc';
      }
      _nicknameController.text = defaultNick;

      final loginBirth = _parseBirthDateString(widget.currentUser.birthDate);
      _birthDate = loginBirth;
      _birthDateFromLogin = loginBirth != null;
      _birthDateController.text =
          loginBirth != null ? _formatBirthDate(loginBirth) : '';
      _showBirthDate = true;
      _gender = widget.currentUser.gender;
      _showGender = true;

      _cityController.text = '';
      _dailyFocusController.text = '';
      _bioController.text = '';
      _mottoController.text = HealthyLivingMottos.presets.first;
      _customConditionController.text = '';
      _musicTitleController.text = '';
      _musicUrlController.text = '';
      _instagramController.text = '';
      _twitterXController.text = '';
      _tiktokController.text = '';
      _facebookController.text = '';
      _snapchatController.text = '';
      _photoUrl = null;
      _photoKey = null;
      _countryCode = 'TR';
      _languageCode = 'tr';
      _selectedGoals = {HealthGoalTag.healthyLiving};
      _selectedConditions = {};
      _selectedMood = null;
      _showChronicConditions = true;
      _showOnlineStatus = true;
      _showSocials = true;
      _showBio = true;
      _showMotto = true;
      _showSobrietyOnProfile = true;
      _showStepsOnProfile = true;
      _discoverable = true;
      _hideRealName = false;
      _hidePhoto = false;
      _allowMessages = true;
      _requireMessageApproval = true;
      _onlyFriendsCanMessage = false;
      return;
    }

    _initialRealName = profile.displayName.trim();
    _initialNickname = HealthCommunityProfile.sanitizeNickname(profile.nickname);
    _nameChangeCount = profile.nameChangeCount;
    _nicknameChangeCount = profile.nicknameChangeCount;

    _displayNameController.text = profile.displayName;
    _nicknameController.text = profile.nickname;

    DateTime? resolvedBirth = _parseBirthDateString(profile.birthDate);
    bool fromLogin = false;
    if (resolvedBirth == null && profile.birthYear != null) {
      resolvedBirth = DateTime(
        profile.birthYear!,
        profile.birthMonth ?? 1,
        profile.birthDay ?? 1,
      );
    }
    if (resolvedBirth == null) {
      final loginBirth = _parseBirthDateString(widget.currentUser.birthDate);
      if (loginBirth != null) {
        resolvedBirth = loginBirth;
        fromLogin = true;
      }
    }
    _birthDate = resolvedBirth;
    _birthDateFromLogin = fromLogin;
    _birthDateController.text =
        resolvedBirth != null ? _formatBirthDate(resolvedBirth) : '';
    _showBirthDate = profile.showBirthDate;
    _gender = profile.gender ?? widget.currentUser.gender;
    _showGender = profile.showGender;

    _cityController.text = profile.city;
    _dailyFocusController.text = profile.dailyFocus;
    _bioController.text = profile.bio;
    _mottoController.text = profile.motto;
    _customConditionController.text = profile.customChronicCondition;
    _musicTitleController.text = profile.currentMusicTitle;
    _musicUrlController.text = profile.currentMusicUrl;
    _instagramController.text = profile.instagram;
    _twitterXController.text = profile.twitterX;
    _tiktokController.text = profile.tiktok;
    _facebookController.text = profile.facebook;
    _snapchatController.text = profile.snapchat;
    _photoUrl = profile.photoUrl;
    _photoKey = profile.photoKey;
    _countryCode = profile.countryCode;
    _languageCode = profile.languageCode;
    _selectedGoals = Set<HealthGoalTag>.from(profile.healthGoals);
    _selectedConditions = Set<ChronicCondition>.from(profile.chronicConditions);
    _selectedMood = profile.mood;
    _showChronicConditions = profile.showChronicConditions;
    _showOnlineStatus = profile.showOnlineStatus;
    _showSocials = profile.showSocials;
    _showBio = profile.showBio;
    _showMotto = profile.showMotto;
    _showSobrietyOnProfile = profile.showSobrietyOnProfile;
    _showStepsOnProfile = profile.showStepsOnProfile;
    _discoverable = profile.discoverable;
    _hideRealName = profile.hideRealName;
    _hidePhoto = profile.hidePhoto;
    _allowMessages = profile.allowMessages;
    _requireMessageApproval = profile.requireMessageApproval;
    _onlyFriendsCanMessage = profile.onlyFriendsCanMessage;
  }

  Future<void> _loadProfileData() async {
    final myProfile = await widget.repository.loadMyProfile(_myUid);
    final sobriety = await _sobrietyRepo.loadState();
    final listeners = myProfile != null
        ? await widget.repository.loadMusicListeners(_myUid)
        : const <MusicListenerRecord>[];
    final friendships = await widget.repository.loadFriendships(_myUid);
    String? nonCollidingInitialNick;
    if (myProfile == null) {
      final candidate = HealthCommunityProfile.sanitizeNickname(
        widget.currentUser.displayName,
      );
      if (candidate.isNotEmpty) {
        final taken = await widget.repository.isNicknameTaken(
          candidate,
          excludeUid: _myUid,
        );
        if (taken) {
          final suggestions = await widget.repository
              .generateNicknameSuggestions(candidate, excludeUid: _myUid);
          if (suggestions.isNotEmpty) {
            nonCollidingInitialNick = suggestions.first;
          }
        }
      }
    }
    if (!mounted) return;
    setState(() {
      _myProfile = myProfile;
      _localSobriety = sobriety;
      _myMusicListeners = listeners;
      _friendships = friendships;
      if (myProfile != null) {
        _creatingProfile = false;
      }
      _syncFormFromProfile(myProfile);
      if (myProfile == null && nonCollidingInitialNick != null) {
        _nicknameController.text = nonCollidingInitialNick;
      }
      _loading = false;
    });
  }

  Future<void> _uploadProfileAvatar() async {
    if (_uploadingAvatar) return;
    setState(() => _uploadingAvatar = true);
    try {
      Uint8List? bytes;
      if (widget.photoPicker != null) {
        bytes = await widget.photoPicker!(ImageSource.gallery);
      } else {
        final picker = ImagePicker();
        final file = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1024,
          imageQuality: 85,
        );
        if (file != null) {
          bytes = await file.readAsBytes();
        }
      }
      if (bytes == null || !mounted) return;

      final result = await _uploadService.uploadBytes(
        bytes,
        folder: 'community_avatars',
      );
      if (!mounted) return;
      setState(() {
        _photoUrl = result.url;
        _photoKey = result.objectKey;
      });
    } on CommunityUploadException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (_) {
      // Ignore cancellation.
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Future<void> _updateQuickMood(HealthMood? mood) async {
    final nextMood = _myProfile?.mood == mood ? null : mood;
    final updated = await widget.repository.updateMood(_myUid, nextMood);
    if (!mounted || updated == null) return;
    setState(() {
      _myProfile = updated;
      _selectedMood = updated.mood;
    });
    widget.onProfileChanged?.call();
  }

  void _showMoodSelectionModal() {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Nasıl Hissediyorsun?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.primaryTeal,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        ActionChip(
                          key: const Key('comm_mood_chip_clear'),
                          label: Text(
                            'Temizle',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                          backgroundColor: Colors.grey.withValues(alpha: 0.2),
                          onPressed: () {
                            _updateQuickMood(null);
                            Navigator.pop(ctx);
                          },
                        ),
                        for (final mood in HealthMood.values)
                          ActionChip(
                            key: Key('comm_mood_chip_${mood.name}'),
                            label: Text(
                              '${mood.emoji} ${mood.localizedLabel(l10n)}',
                              style: TextStyle(
                                color: mood.accentColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            backgroundColor:
                                mood.accentColor.withValues(alpha: 0.12),
                            side: BorderSide(
                              color: mood.accentColor.withValues(alpha: 0.35),
                            ),
                            onPressed: () {
                              _updateQuickMood(mood);
                              Navigator.pop(ctx);
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _quickPatchMyProfile(
    HealthCommunityProfile Function(HealthCommunityProfile current) updater,
  ) async {
    final current = _myProfile;
    if (current == null) return;
    final next = updater(current).copyWith(updatedAt: DateTime.now());
    final saved = await widget.repository.saveMyProfile(next);
    if (!mounted) return;
    setState(() {
      _myProfile = saved;
      _syncFormFromProfile(saved);
    });
    widget.onProfileChanged?.call();
  }

  Future<void> _saveMyProfile() async {
    if (_savingProfile) return;
    final l10n = context.l10n;
    final name = _displayNameController.text.trim();
    if (name.isEmpty) return;

    final cleanNick = HealthCommunityProfile.sanitizeNickname(
      _nicknameController.text,
    );
    if (cleanNick.isNotEmpty && cleanNick.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kullanıcı adı en az 3 karakter olmalıdır.'),
        ),
      );
      return;
    }

    final profileTextCheck = ContentSafetyService.checkText(
      '$name $cleanNick ${_bioController.text} ${_mottoController.text} ${_dailyFocusController.text} ${_customConditionController.text}',
    );
    if (!profileTextCheck.isSafe) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.safetyContentBlocked)),
      );
      return;
    }

    final musicUrl = _musicUrlController.text.trim();
    if (!MusicLinkHelper.isSupportedMusicUrl(musicUrl)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.commMusicInvalidUrl)),
      );
      return;
    }

    if (cleanNick.isNotEmpty) {
      final taken = await widget.repository.isNicknameTaken(
        cleanNick,
        excludeUid: _myUid,
      );
      if (taken) {
        final suggestions = await widget.repository.generateNicknameSuggestions(
          cleanNick,
          excludeUid: _myUid,
        );
        if (!mounted) return;
        setState(() {
          _checkingNickname = false;
          _isNicknameAvailable = false;
          _nicknameSuggestions = suggestions;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Bu kullanıcı adı (@$cleanNick) başka bir üye tarafından kullanılıyor.',
            ),
          ),
        );
        return;
      }
    }

    final bool isExistingProfile = _myProfile != null;
    final bool isNameModified = isExistingProfile &&
        _initialRealName.isNotEmpty &&
        name != _initialRealName;
    final bool isNickModified = isExistingProfile &&
        _initialNickname.isNotEmpty &&
        cleanNick != _initialNickname;

    if (!_isAdmin &&
        isNameModified &&
        _nameChangeCount >= HealthCommunityProfile.maxNameChanges) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔒 Ad Soyad değiştirme hakkınız (2/2) dolmuştur.'),
        ),
      );
      return;
    }

    if (!_isAdmin &&
        isNickModified &&
        _nicknameChangeCount >= HealthCommunityProfile.maxNicknameChanges) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '🔒 Kullanıcı adı değiştirme hakkınız (3/3) dolmuştur.',
          ),
        ),
      );
      return;
    }

    if (!_isAdmin && (isNameModified || isNickModified)) {
      if (!mounted) return;
      final remainingNameAfter =
          (HealthCommunityProfile.maxNameChanges - (_nameChangeCount + 1))
              .clamp(0, HealthCommunityProfile.maxNameChanges);
      final remainingNickAfter = (HealthCommunityProfile.maxNicknameChanges -
              (_nicknameChangeCount + 1))
          .clamp(0, HealthCommunityProfile.maxNicknameChanges);

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.shield_outlined, color: AppTheme.primaryTeal),
              SizedBox(width: 8),
              Expanded(child: Text('Profil Değişikliği Onayı')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isNameModified) ...[
                Text(
                  'Ad Soyad: "$_initialRealName" → "$name"',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bu işlemden sonra $remainingNameAfter / ${HealthCommunityProfile.maxNameChanges} ad değiştirme hakkınız kalacaktır.',
                  style: const TextStyle(fontSize: 12.5),
                ),
                const SizedBox(height: 10),
              ],
              if (isNickModified) ...[
                Text(
                  'Kullanıcı Adı: "@$_initialNickname" → "@$cleanNick"',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bu işlemden sonra $remainingNickAfter / ${HealthCommunityProfile.maxNicknameChanges} kullanıcı adı değiştirme hakkınız kalacaktır.',
                  style: const TextStyle(fontSize: 12.5),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              key: const Key('confirm_profile_quota_change_btn'),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Onayla ve Kaydet'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    final int nextNameChangeCount =
        (!_isAdmin && isNameModified) ? _nameChangeCount + 1 : _nameChangeCount;
    final int nextNicknameChangeCount = (!_isAdmin && isNickModified)
        ? _nicknameChangeCount + 1
        : _nicknameChangeCount;

    setState(() => _savingProfile = true);
    final now = DateTime.now();
    final pedState = _pedometerService.state;
    final resolvedBirth = _birthDate;
    final profile = HealthCommunityProfile(
      uid: _myUid,
      displayName: name,
      nickname: cleanNick,
      photoUrl: _photoUrl,
      photoKey: _photoKey,
      countryCode: _countryCode,
      city: _cityController.text.trim(),
      languageCode: _languageCode,
      healthGoals: _selectedGoals.isEmpty
          ? const [HealthGoalTag.healthyLiving]
          : _selectedGoals.toList(),
      chronicConditions: _selectedConditions.toList(),
      customChronicCondition: _customConditionController.text.trim(),
      showChronicConditions: _showChronicConditions,
      currentMusicUrl: musicUrl,
      currentMusicTitle: _musicTitleController.text.trim(),
      musicLikedBy: _myProfile?.musicLikedBy ?? const [],
      showSocials: _showSocials,
      instagram: _instagramController.text.trim(),
      twitterX: _twitterXController.text.trim(),
      tiktok: _tiktokController.text.trim(),
      facebook: _facebookController.text.trim(),
      snapchat: _snapchatController.text.trim(),
      isOnline: true,
      showOnlineStatus: _showOnlineStatus,
      lastActiveAt: now,
      isVerified: _myProfile?.isVerified ?? false,
      isSuspended: _myProfile?.isSuspended ?? false,
      bio: _bioController.text.trim(),
      motto: _mottoController.text.trim(),
      showMotto: _showMotto,
      dailyFocus: _dailyFocusController.text.trim(),
      mood: _selectedMood,
      streakDays: _myProfile?.streakDays ?? 1,
      birthYear: resolvedBirth?.year,
      birthMonth: resolvedBirth?.month ?? _myProfile?.birthMonth,
      birthDay: resolvedBirth?.day ?? _myProfile?.birthDay,
      birthDate:
          resolvedBirth != null ? _formatBirthDate(resolvedBirth) : null,
      showBirthDate: _showBirthDate,
      gender: _gender,
      showGender: _showGender,
      nameChangeCount: nextNameChangeCount,
      nicknameChangeCount: nextNicknameChangeCount,
      hideRealName: _hideRealName,
      hidePhoto: _hidePhoto,
      showBio: _showBio,
      showSobrietyOnProfile: _showSobrietyOnProfile,
      smokeQuitAt: _localSobriety.smokeQuitAt,
      alcoholQuitAt: _localSobriety.alcoholQuitAt,
      dailySmokeCostTry: _localSobriety.dailySmokeSpendTry,
      dailyCigarettesCount: _localSobriety.dailyCigarettes,
      dailyAlcoholCostTry: _localSobriety.dailyAlcoholCostTry,
      showStepsOnProfile: _showStepsOnProfile,
      todayStepsCount: pedState.todayStepsAt(now),
      weekStepsCount: pedState.thisWeekStepsAt(now),
      monthStepsCount: pedState.thisMonthStepsAt(now),
      dailyStepGoal: pedState.dailyStepGoal,
      discoverable: _discoverable,
      allowMessages: _allowMessages,
      requireMessageApproval: _requireMessageApproval,
      onlyFriendsCanMessage: _onlyFriendsCanMessage,
      likedBy: _myProfile?.likedBy ?? const [],
      updatedAt: now,
    );

    final saved = await widget.repository.saveMyProfile(profile);
    unawaited(
      _sobrietyRepo.saveState(
        _localSobriety.copyWith(showOnProfile: _showSobrietyOnProfile),
      ),
    );
    unawaited(_pedometerService.setShowOnProfile(_showStepsOnProfile));
    if (resolvedBirth != null) {
      unawaited(
        SharedPreferences.getInstance().then((prefs) async {
          await prefs.setInt('vcu_user_birth_month', resolvedBirth.month);
          await prefs.setInt('vcu_user_birth_day', resolvedBirth.day);
        }),
      );
    }

    if (!mounted) return;
    setState(() {
      _myProfile = saved;
      _syncFormFromProfile(saved);
      _creatingProfile = false;
      _editingProfile = false;
      _savingProfile = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.commProfileSaved)),
    );
    widget.onProfileChanged?.call();
  }

  Future<void> _leaveCommunity() async {
    final l10n = context.l10n;
    await widget.repository.leaveCommunity(_myUid);
    if (!mounted) return;
    setState(() {
      _myProfile = null;
      _creatingProfile = false;
      _editingProfile = false;
      _syncFormFromProfile(null);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.commLeftCommunity)),
    );
    widget.onProfileChanged?.call();
  }

  Future<void> _openPreview() async {
    final profile = _myProfile;
    if (profile == null) return;
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => HealthProfileDetailScreen(
          profile: profile,
          myUid: _myUid,
          myDisplayName: profile.visibleName,
          myNickname: profile.nickname,
          myPhotoUrl: profile.visiblePhotoUrl,
          repository: widget.repository,
          uploadService: _uploadService,
          photoPicker: widget.photoPicker,
          urlLauncher: widget.urlLauncher,
        ),
      ),
    );
    await _loadProfileData();
  }

  Future<void> _openLikersSheet() async {
    final likers = await widget.repository.loadProfileLikers(_myUid);
    if (!mounted) return;
    await showProfileLikersSheet(context: context, likers: likers);
  }

  Future<void> _openListenersSheet() async {
    final listeners = await widget.repository.loadMusicListeners(_myUid);
    if (!mounted) return;
    setState(() => _myMusicListeners = listeners);
    await showMusicListenersSheet(
      context: context,
      listeners: listeners,
      musicLikedBy: _myProfile?.musicLikedBy ?? const [],
    );
  }

  Future<void> _openFriendsSheet() async {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final latest = await widget.repository.loadFriendships(_myUid);
    if (!mounted) return;
    setState(() => _friendships = latest);

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final accepted = _friendships
                .where((f) => f.status == FriendshipStatus.accepted)
                .toList();
            final pendingIncoming = _friendships
                .where(
                  (f) =>
                      f.status == FriendshipStatus.pending &&
                      f.requesterId != _myUid,
                )
                .toList();
            final pendingOutgoing = _friendships
                .where(
                  (f) =>
                      f.status == FriendshipStatus.pending &&
                      f.requesterId == _myUid,
                )
                .toList();

            Future<void> reload() async {
              final refreshed =
                  await widget.repository.loadFriendships(_myUid);
              if (!mounted) return;
              setState(() => _friendships = refreshed);
              setSheetState(() {});
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.people_alt_rounded,
                          color: AppTheme.primaryTeal,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${l10n.commFriendsSheetTitle} (${accepted.length})',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_friendships.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 28),
                        child: Center(
                          child: Text(
                            l10n.commFriendsEmpty,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      )
                    else
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 400),
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            for (final req in pendingIncoming)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CommunityAvatar(
                                  initials: req.peerNameFor(_myUid).isNotEmpty
                                      ? req
                                          .peerNameFor(_myUid)
                                          .substring(0, 1)
                                          .toUpperCase()
                                      : '?',
                                  radius: 20,
                                ),
                                title: Text(
                                  req.peerNameFor(_myUid),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                subtitle: Text(l10n.commFriendPending),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: l10n.commRequestAccept,
                                      icon: const Icon(
                                        Icons.check_circle_rounded,
                                        color: Color(0xFF16A34A),
                                      ),
                                      onPressed: () async {
                                        await widget.repository
                                            .respondFriendRequest(
                                          pairId: req.pairId,
                                          accept: true,
                                        );
                                        await reload();
                                      },
                                    ),
                                    IconButton(
                                      tooltip: l10n.commRequestDecline,
                                      icon: Icon(
                                        Icons.cancel_rounded,
                                        color: colorScheme.error,
                                      ),
                                      onPressed: () async {
                                        await widget.repository
                                            .respondFriendRequest(
                                          pairId: req.pairId,
                                          accept: false,
                                        );
                                        await reload();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            for (final friend in accepted)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CommunityAvatar(
                                  initials:
                                      friend.peerNameFor(_myUid).isNotEmpty
                                          ? friend
                                              .peerNameFor(_myUid)
                                              .substring(0, 1)
                                              .toUpperCase()
                                          : '?',
                                  radius: 20,
                                ),
                                title: Text(
                                  friend.peerNameFor(_myUid),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                subtitle: Text(l10n.commFriendsConnected),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.person_remove_outlined,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  onPressed: () async {
                                    await widget.repository
                                        .removeFriend(friend.pairId);
                                    await reload();
                                  },
                                ),
                              ),
                            for (final out in pendingOutgoing)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CommunityAvatar(
                                  initials: out.peerNameFor(_myUid).isNotEmpty
                                      ? out
                                          .peerNameFor(_myUid)
                                          .substring(0, 1)
                                          .toUpperCase()
                                      : '?',
                                  radius: 20,
                                ),
                                title: Text(
                                  out.peerNameFor(_myUid),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(l10n.commFriendPending),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _launchExternalUrl(String rawUrl) async {
    final uri = Uri.tryParse(rawUrl);
    if (uri == null) return;
    if (widget.urlLauncher != null) {
      await widget.urlLauncher!(uri);
      return;
    }
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final Widget content;
    if (_loading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (_myProfile == null && !_creatingProfile) {
      // 1. Not opted in yet -> Clean Social Onboarding Hero
      content = _buildOptInHero(context);
    } else if (_creatingProfile || _editingProfile) {
      // 2. Creating or Editing -> Structured Edit Form
      content = _buildEditForm(context);
    } else {
      // 3. Opted in -> Sleek Social Formula Bank-style Profile Showcase!
      content = _buildProfileShowcase(context, _myProfile!);
    }

    return ProfileAmbientBackground(child: content);
  }

  Widget _buildOptInHero(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return ListView(
      key: const Key('comm_my_profile_list'),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
      children: [
        // Compact Account Header Card (Social Formula Bank Hero Style)
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [Color(0xFF103737), Color(0xFF0B2223)]
                  : const [AppTheme.primaryTeal, AppTheme.secondaryMint],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryTeal.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white.withValues(alpha: 0.22),
                child: Text(
                  widget.currentUser.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.currentUser.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                    if (widget.currentUser.email != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.currentUser.email!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ProfileThemedCard(
          accentColor: AppTheme.primaryTeal,
          watermarkIcon: Icons.diversity_1_rounded,
          borderRadius: 22,
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.65),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.diversity_1_rounded,
                  size: 32,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.commOptInTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.commOptInBody,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  key: const Key('comm_opt_in_button'),
                  onPressed: () => setState(() => _creatingProfile = true),
                  icon: const Icon(Icons.add_reaction_outlined),
                  label: Text(l10n.commOptInButton),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        BirthdayCelebrationCard(displayName: widget.currentUser.displayName),
        const DailyHealthTipCard(),
      ],
    );
  }

  Widget _buildProfileShowcase(
    BuildContext context,
    HealthCommunityProfile profile,
  ) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isAdmin = AdminUtils.isAdmin(
      email: widget.currentUser.email,
      uid: widget.currentUser.id,
    );
    final acceptedFriends = _friendships
        .where((f) => f.status == FriendshipStatus.accepted)
        .toList();
    final acceptedFriendsCount = acceptedFriends.length;
    final pendingIncomingCount = _friendships
        .where(
          (f) =>
              f.status == FriendshipStatus.pending && f.requesterId != _myUid,
        )
        .length;

    return ListView(
      key: const Key('comm_my_profile_showcase_list'),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
      children: [
        // 1. Social Formula Bank Top Identity Card (Glowing Gradient Border!)
        SfbGradientBorderCard(
          gradientColors: const [
            Color(0xFFFACC15),
            Color(0xFF14B8A6),
            Color(0xFF38BDF8),
          ],
          glowColor: const Color(0xFF14B8A6),
          borderRadius: 24,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Gradient-ring avatar + quick preview & online pills
                  Column(
                    children: [
                      SfbGradientRingAvatar(
                        initials: profile.initials,
                        photoUrl: profile.visiblePhotoUrl,
                        radius: 36,
                        ringWidth: 3,
                        ringColors: const [
                          Color(0xFFF59E0B),
                          Color(0xFF10B981),
                          Color(0xFF06B6D4),
                        ],
                        isOnline: profile.isVisibleOnline,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            key: const Key('comm_preview_my_profile_btn'),
                            borderRadius: BorderRadius.circular(14),
                            onTap: _openPreview,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.75),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: colorScheme.outlineVariant,
                                ),
                              ),
                              child: Icon(
                                Icons.visibility_outlined,
                                size: 15,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E)
                                  .withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFF22C55E)
                                    .withValues(alpha: 0.45),
                              ),
                            ),
                            child: const Icon(
                              Icons.circle,
                              size: 10,
                              color: Color(0xFF22C55E),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  // Right: Name, @nickname, ADMIN badge, Mood pill & Stats pills
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                profile.visibleName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                            if (profile.isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified_rounded,
                                color: Color(0xFF0284C7),
                                size: 18,
                              ),
                            ],
                          ],
                        ),
                        Text(
                          [
                            if (profile.nickname.isNotEmpty)
                              '(@${profile.nickname})',
                            '${profile.country.flag} ${profile.city.isNotEmpty ? profile.city : profile.country.label}',
                          ].join(' • '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Row 1: ADMIN badge + Mood ("Enerjik hissediyor") side-by-side on the same line!
                        Row(
                          children: [
                            if (isAdmin) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2.5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF59E0B),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.verified_user_rounded,
                                      size: 12.5,
                                      color: Colors.black87,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      l10n.sfbAdminBadge,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Flexible(
                              child: profile.mood != null
                                  ? GestureDetector(
                                      key: const Key('comm_mood_pill_trigger'),
                                      onTap: _showMoodSelectionModal,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2.5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: profile.mood!.accentColor
                                              .withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: profile.mood!.accentColor
                                                .withValues(alpha: 0.35),
                                            width: 0.9,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              profile.mood!.emoji,
                                              style: const TextStyle(
                                                fontSize: 12.5,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                '${profile.mood!.localizedLabel(l10n)} hissediyor',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: colorScheme.onSurface
                                                      .withValues(alpha: 0.9),
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : GestureDetector(
                                      key: const Key('comm_mood_pill_trigger'),
                                      onTap: _showMoodSelectionModal,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 7,
                                          vertical: 2.5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryTeal
                                              .withValues(alpha: 0.10),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: AppTheme.primaryTeal
                                                .withValues(alpha: 0.30),
                                          ),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.add_reaction_outlined,
                                              size: 13,
                                              color: AppTheme.primaryTeal,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Mod Seç',
                                              style: TextStyle(
                                                color: AppTheme.primaryTeal,
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                        // Row 2: Optional Age & Gender badges
                        if ((profile.showBirthDate && profile.age != null) ||
                            (profile.showGender &&
                                profile.localizedGenderLabel != null)) ...[
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              if (profile.showBirthDate && profile.age != null)
                                Container(
                                  key: const Key('profile_showcase_age_badge'),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0EA5E9)
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFF0EA5E9)
                                          .withValues(alpha: 0.35),
                                    ),
                                  ),
                                  child: Text(
                                    '🎂 ${profile.age} Yaş',
                                    style: const TextStyle(
                                      color: Color(0xFF0284C7),
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              if (profile.showGender &&
                                  profile.localizedGenderLabel != null)
                                Container(
                                  key:
                                      const Key('profile_showcase_gender_badge'),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (profile.gender == 'Female'
                                            ? const Color(0xFFEC4899)
                                            : const Color(0xFF6366F1))
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: (profile.gender == 'Female'
                                              ? const Color(0xFFEC4899)
                                              : const Color(0xFF6366F1))
                                          .withValues(alpha: 0.35),
                                    ),
                                  ),
                                  child: Text(
                                    profile.localizedGenderLabel!,
                                    style: TextStyle(
                                      color: profile.gender == 'Female'
                                          ? const Color(0xFFDB2777)
                                          : const Color(0xFF4F46E5),
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Full-width Side-by-Side Stat Pills Row: Beğeni · Arkadaş · Dinleme
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      key: const Key('comm_my_profile_likers_btn'),
                      borderRadius: BorderRadius.circular(14),
                      onTap: _openLikersSheet,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFE11D48).withValues(alpha: 0.09),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color:
                                const Color(0xFFE11D48).withValues(alpha: 0.28),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '❤️ ${l10n.commLikesCount(profile.likesCount)}',
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      key: const Key('comm_my_profile_friends_btn'),
                      borderRadius: BorderRadius.circular(14),
                      onTap: _openFriendsSheet,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryTeal.withValues(alpha: 0.09),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppTheme.primaryTeal.withValues(alpha: 0.28),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            pendingIncomingCount > 0
                                ? '👥 $acceptedFriendsCount (+$pendingIncomingCount)'
                                : '👥 $acceptedFriendsCount ${l10n.commFriendsStat}',
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      key: const Key('comm_my_profile_listeners_btn'),
                      borderRadius: BorderRadius.circular(14),
                      onTap: _openListenersSheet,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF7C3AED).withValues(alpha: 0.09),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color:
                                const Color(0xFF7C3AED).withValues(alpha: 0.28),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '🎧 ${_myMusicListeners.length} Dinleme',
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (profile.dailyFocus.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.wb_sunny_outlined,
                        size: 15,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          profile.dailyFocus.trim(),
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Hakkımda (Bio) Card - Rich background & watermark
        ProfileThemedCard(
          key: const Key('profile_bio_card'),
          accentColor: AppTheme.primaryTeal,
          watermarkIcon: Icons.format_quote_rounded,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.format_quote_rounded,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.commFieldBio,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (!profile.showBio)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Gizli',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: profile.showBio
                        ? 'Hakkımda Yazısını Gizle'
                        : 'Hakkımda Yazısını Göster',
                    onPressed: () => _quickPatchMyProfile(
                      (c) => c.copyWith(showBio: !c.showBio),
                    ),
                    icon: Icon(
                      profile.showBio
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_outlined,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                  ),
                  if (profile.bio.trim().isEmpty)
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      onPressed: () => setState(() => _editingProfile = true),
                      icon: const Icon(Icons.edit_note_rounded, size: 16),
                      label: const Text(
                        'Biyografi Ekle',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                profile.bio.trim().isNotEmpty
                    ? profile.bio.trim()
                    : 'Henüz bir biyografi eklemediniz. Kendinizden, sağlık yolculuğunuzdan ve hedeflerinizden bahsedebilirsiniz.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.45,
                  fontStyle:
                      profile.bio.trim().isEmpty ? FontStyle.italic : null,
                  color: profile.bio.trim().isEmpty
                      ? colorScheme.onSurfaceVariant.withValues(alpha: 0.7)
                      : null,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Sağlıklı Yaşam Mottosu Kartı (Göster / Gizle & Hazır Motto Seçimi)
        ProfileMottoCard(
          profile: profile,
          isOwner: true,
          onToggleVisibility: (show) =>
              _quickPatchMyProfile((c) => c.copyWith(showMotto: show)),
          onPickOrEditMotto: (newMotto) => _quickPatchMyProfile(
            (c) => c.copyWith(motto: newMotto, showMotto: true),
          ),
        ),
        const SizedBox(height: 12),

        // Sigara & Alkol Bırakma Takip Kartı (Göster / Gizle & Detay Ekranı)
        ProfileSobrietyShowcaseCard(
          profile: profile,
          isOwner: true,
          localOverrideState: _localSobriety,
          onToggleVisibility: (show) async {
            final updatedSob = _localSobriety.copyWith(showOnProfile: show);
            setState(() => _localSobriety = updatedSob);
            await _sobrietyRepo.saveState(updatedSob);
            await _quickPatchMyProfile(
              (c) => c.copyWith(showSobrietyOnProfile: show),
            );
          },
          onOpenTracker: () async {
            await Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => SobrietyTrackerScreen(
                  repository: _sobrietyRepo,
                  communityRepository: widget.repository,
                  currentUserId: _myUid,
                  currentUserDisplayName: widget.currentUser.displayName,
                ),
              ),
            );
            await _loadProfileData();
          },
        ),
        const SizedBox(height: 12),

        // Adım Sayar Özeti Kartı (Bugün / Bu Hafta / Bu Ay & Göster / Gizle)
        ProfileStepCounterShowcaseCard(
          profile: profile,
          isOwner: true,
          localPedometerState: _pedometerService.state,
          onToggleVisibility: (show) async {
            await _pedometerService.setShowOnProfile(show);
            await _quickPatchMyProfile(
              (c) => c.copyWith(showStepsOnProfile: show),
            );
          },
          onOpenStepCounter: () async {
            await Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => StepCounterScreen(
                  service: _pedometerService,
                  communityRepository: widget.repository,
                  currentUserId: _myUid,
                  currentUserDisplayName: widget.currentUser.displayName,
                ),
              ),
            );
            await _loadProfileData();
          },
        ),
        const SizedBox(height: 12),



        // 5. Chronic Conditions & Health Goals Showcase
        if (profile.hasAnyChronicCondition || profile.healthGoals.isNotEmpty)
          ProfileThemedCard(
            accentColor: const Color(0xFF7C3AED),
            watermarkIcon: Icons.favorite_border_rounded,
            borderRadius: 20,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (profile.hasAnyChronicCondition) ...[
                  Text(
                    l10n.commFieldChronicConditions,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final cond in profile.chronicConditions)
                        Chip(
                          avatar: Icon(
                            cond.icon,
                            size: 15,
                            color: cond.accentColor,
                          ),
                          label: Text(cond.localizedLabel(l10n)),
                          visualDensity: VisualDensity.compact,
                        ),
                      if (profile.customChronicCondition.trim().isNotEmpty)
                        Chip(
                          label: Text(
                            '🩺 ${profile.customChronicCondition.trim()}',
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  l10n.commFieldGoals,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final goal in profile.healthGoals)
                      Chip(
                        avatar: Icon(
                          goal.icon,
                          size: 15,
                          color: goal.accentColor,
                        ),
                        label: Text(goal.localizedLabel(l10n)),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),

        // 3. Motivasyon Müziği Card (Social Formul Bank Style!)
        _buildMotivationMusicCard(context, profile),
        const SizedBox(height: 12),

        // 4. Arkadaşlarım Dedicated Card (Social Formul Bank Style!)
        _buildFriendsCard(
          context: context,
          acceptedFriends: acceptedFriends,
          pendingIncomingCount: pendingIncomingCount,
        ),
        const SizedBox(height: 12),

        // 5. Social Media Links Card
        if (profile.allSocialHandles.isNotEmpty) ...[
          ProfileThemedCard(
            accentColor: const Color(0xFFEC4899),
            watermarkIcon: Icons.share_outlined,
            borderRadius: 20,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      l10n.commSocialsSectionTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    if (!profile.showSocials)
                      Text(
                        l10n.commSocialsHiddenHint,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final entry in profile.allSocialHandles.entries)
                      ActionChip(
                        label: Text('${entry.key}: @${entry.value}'),
                        onPressed: () {
                          final url = SocialLinksHelper.buildProfileUrl(
                            entry.key,
                            entry.value,
                          );
                          if (url != null) _launchExternalUrl(url);
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        BirthdayCelebrationCard(displayName: profile.displayName),
        const DailyHealthTipCard(),
        const SizedBox(height: 16),

        // 6. EN ALTTA: Profili Düzenle Butonu (Social Formul Bank Stili)
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.icon(
            key: const Key('comm_edit_profile_toggle_btn'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primaryTeal,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () => setState(() => _editingProfile = true),
            icon: const Icon(Icons.edit_note_rounded, size: 20),
            label: Text(
              l10n.commEditProfile,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          key: const Key('comm_leave_community_button'),
          style: TextButton.styleFrom(foregroundColor: colorScheme.error),
          onPressed: _leaveCommunity,
          icon: const Icon(Icons.logout_rounded, size: 18),
          label: Text(l10n.commLeaveCommunity),
        ),
      ],
    );
  }

  Widget _buildMotivationMusicCard(
    BuildContext context,
    HealthCommunityProfile profile,
  ) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    const neonPink = Color(0xFFFF007F);
    final musicAccent = profile.hasMusic
        ? MusicLinkHelper.detectPlatformColor(profile.currentMusicUrl)
        : neonPink;
    final platformName = profile.hasMusic
        ? MusicLinkHelper.detectPlatformName(profile.currentMusicUrl)
        : '';
    final totalPlays = _myMusicListeners.fold<int>(
      0,
      (sum, r) => sum + r.listenCount,
    );

    return ProfileThemedCard(
      key: const Key('profile_motivation_music_card'),
      accentColor: musicAccent,
      watermarkIcon: Icons.music_note_rounded,
      borderRadius: 22,
      padding: const EdgeInsets.all(16),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Music Note + Motivasyon Müziği Title + Kimler Dinledi Button
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: musicAccent.withValues(alpha: isDark ? 0.22 : 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.music_note_rounded,
                    size: 19,
                    color: musicAccent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Motivasyon Müziği',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      if (profile.hasMusic)
                        Text(
                          platformName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: musicAccent,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
                TextButton.icon(
                  key: const Key('comm_my_profile_music_listeners_btn'),
                  onPressed: _openListenersSheet,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    backgroundColor: musicAccent.withValues(alpha: 0.12),
                    foregroundColor: musicAccent,
                  ),
                  icon: const Icon(Icons.headphones_rounded, size: 14),
                  label: Text(
                    'Kimler Dinledi? (${_myMusicListeners.length})',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (!profile.hasMusic)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Henüz bir motivasyon müziği veya çalma listesi eklemedin.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 10),
                    FilledButton.tonalIcon(
                      onPressed: () => setState(() => _editingProfile = true),
                      icon: const Icon(Icons.queue_music_rounded, size: 16),
                      label: const Text('Müzik Ekle 🎵'),
                    ),
                  ],
                ),
              )
            else ...[
              // Active Music Player Box (SFB Style)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      musicAccent.withValues(alpha: isDark ? 0.20 : 0.08),
                      musicAccent.withValues(alpha: isDark ? 0.08 : 0.03),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: musicAccent.withValues(alpha: isDark ? 0.35 : 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        widget.repository.recordMusicListen(
                          targetUid: profile.uid,
                          listenerUid: _myUid,
                          listenerName: widget.currentUser.displayName,
                          listenerNickname: profile.nickname,
                          listenerPhotoUrl: _photoUrl,
                          musicUrl: profile.currentMusicUrl,
                        );
                        _launchExternalUrl(profile.currentMusicUrl);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: musicAccent,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: musicAccent.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.currentMusicTitle.trim().isNotEmpty
                                ? profile.currentMusicTitle.trim()
                                : platformName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 13.5,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            profile.currentMusicUrl.trim(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.tonal(
                      onPressed: () {
                        widget.repository.recordMusicListen(
                          targetUid: profile.uid,
                          listenerUid: _myUid,
                          listenerName: widget.currentUser.displayName,
                          listenerNickname: profile.nickname,
                          listenerPhotoUrl: _photoUrl,
                          musicUrl: profile.currentMusicUrl,
                        );
                        _launchExternalUrl(profile.currentMusicUrl);
                      },
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        backgroundColor: musicAccent.withValues(alpha: 0.16),
                        foregroundColor: musicAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.commMusicListenAction,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.open_in_new_rounded, size: 14),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Interactive Social Formula Bank Stat Row
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  InkWell(
                    onTap: _openListenersSheet,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: neonPink.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: neonPink.withValues(alpha: 0.30),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.people_alt_rounded,
                            size: 13,
                            color: neonPink,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${_myMusicListeners.length} Kişi Dinledi',
                            style: const TextStyle(
                              color: neonPink,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _openListenersSheet,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: musicAccent.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: musicAccent.withValues(alpha: 0.30),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.play_circle_outline_rounded,
                            size: 14,
                            color: musicAccent,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '$totalPlays Kez Dinlendi',
                            style: TextStyle(
                              color: musicAccent,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE11D48).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFE11D48).withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.favorite_rounded,
                          size: 13,
                          color: Color(0xFFE11D48),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${profile.musicLikesCount} Beğeni',
                          style: const TextStyle(
                            color: Color(0xFFE11D48),
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
    );
  }

  Widget _buildFriendsCard({
    required BuildContext context,
    required List<FriendshipRecord> acceptedFriends,
    required int pendingIncomingCount,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return ProfileThemedCard(
      key: const Key('profile_friends_card'),
      accentColor: const Color(0xFF06B6D4),
      watermarkIcon: Icons.people_alt_rounded,
      borderRadius: 22,
      padding: const EdgeInsets.all(16),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Icon + Title + Count Badge + Manage Button
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF06B6D4)
                        .withValues(alpha: isDark ? 0.22 : 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.people_alt_rounded,
                    size: 18,
                    color: Color(0xFF06B6D4),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        'Arkadaşlarım',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF06B6D4)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF06B6D4)
                                .withValues(alpha: 0.35),
                          ),
                        ),
                        child: Text(
                          '${acceptedFriends.length}',
                          style: const TextStyle(
                            color: Color(0xFF0891B2),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  key: const Key('profile_friends_manage_btn'),
                  onPressed: _openFriendsSheet,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
                  icon: const Icon(Icons.people_outline_rounded, size: 15),
                  label: const Text(
                    'Yönet',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            // Pending request alert notification banner
            if (pendingIncomingCount > 0) ...[
              const SizedBox(height: 12),
              InkWell(
                onTap: _openFriendsSheet,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B)
                        .withValues(alpha: isDark ? 0.20 : 0.10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.mark_email_unread_rounded,
                        size: 16,
                        color: Color(0xFFD97706),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '$pendingIncomingCount yeni arkadaşlık isteği bekliyor!',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFD97706),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: Color(0xFFD97706),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 14),

            // Friends Avatars / List
            if (acceptedFriends.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.person_add_alt_1_outlined,
                      size: 28,
                      color: colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.7),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Henüz hiç sağlık arkadaşın yok.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Sağlık Topluluğu\'ndan üyeleri keşfedip arkadaş olabilirsin.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                height: 94,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: acceptedFriends.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 14),
                  itemBuilder: (context, idx) {
                    final friend = acceptedFriends[idx];
                    final friendName = friend.peerNameFor(_myUid);
                    final friendUid = friend.peerIdFor(_myUid);
                    final initial = friendName.isNotEmpty
                        ? friendName[0].toUpperCase()
                        : '?';

                    return FutureBuilder<HealthCommunityProfile?>(
                      future: widget.repository.getProfile(friendUid),
                      builder: (ctx, snapshot) {
                        final peerProfile = snapshot.data;
                        final photoUrl = peerProfile?.photoUrl;
                        final displayName =
                            peerProfile?.displayName ?? friendName;
                        final isOnline = peerProfile?.isVisibleOnline ?? false;

                        return InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            if (peerProfile != null) {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => HealthProfileDetailScreen(
                                    profile: peerProfile,
                                    myUid: _myUid,
                                    myDisplayName:
                                        widget.currentUser.displayName,
                                    myPhotoUrl: _photoUrl,
                                    repository: widget.repository,
                                    uploadService: _uploadService,
                                    photoPicker: widget.photoPicker,
                                    urlLauncher: widget.urlLauncher,
                                  ),
                                ),
                              );
                            } else {
                              _openFriendsSheet();
                            }
                          },
                          child: Container(
                            width: 68,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 4,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    CommunityAvatar(
                                      initials: initial,
                                      photoUrl: photoUrl,
                                      radius: 24,
                                    ),
                                    if (isOnline)
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF10B981),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: theme.cardColor,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
    );
  }

  Widget _buildEditForm(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView(
      key: const Key('comm_my_profile_list'),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 36),
      children: [
        if (_myProfile != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Text(
                  l10n.commEditProfile,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    _syncFormFromProfile(_myProfile);
                    setState(() => _editingProfile = false);
                  },
                  child: Text(l10n.commDoneEditing),
                ),
              ],
            ),
          ),

        // Avatar Upload & Quick Stats Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CommunityAvatar(
                  initials: widget.currentUser.initials,
                  photoUrl: _hidePhoto ? null : _photoUrl,
                  radius: 34,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      FilledButton.tonalIcon(
                        key: const Key('comm_upload_avatar_button'),
                        onPressed:
                            _uploadingAvatar ? null : _uploadProfileAvatar,
                        icon: _uploadingAvatar
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.photo_camera_outlined, size: 18),
                        label: Text(l10n.commUploadPhoto),
                      ),
                      if (_photoUrl != null && _photoUrl!.isNotEmpty)
                        TextButton(
                          onPressed: () => setState(() {
                            _photoUrl = null;
                            _photoKey = null;
                          }),
                          child: Text(l10n.commRemovePhoto),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Identity Fields (Social Formül Bank Quota & Uniqueness System)
        TextField(
          key: const Key('comm_profile_name_field'),
          controller: _displayNameController,
          readOnly: _isRealNameLocked,
          decoration: InputDecoration(
            labelText: l10n.commFieldDisplayName,
            prefixIcon: Icon(
              _isRealNameLocked ? Icons.lock_outline_rounded : Icons.badge_outlined,
            ),
            suffixIcon: _isRealNameLocked
                ? const Tooltip(
                    message: 'Ad Soyad değiştirme hakkınız dolmuştur',
                    child: Icon(Icons.lock_rounded, size: 18),
                  )
                : null,
            helperText: _isAdmin
                ? '👑 Yönetici hesabı: Sınırsız değişiklik hakkı'
                : _isRealNameLocked
                    ? '🔒 Ad Soyad değiştirme hakkınız (2/2) dolmuştur.'
                    : _myProfile == null
                        ? 'İlk kayıt ücretsizdir • Sonrasında toplam ${HealthCommunityProfile.maxNameChanges} değişiklik hakkınız vardır.'
                        : 'Kalan Ad Soyad Değişiklik Hakkı: $_remainingNameChanges / ${HealthCommunityProfile.maxNameChanges}',
            helperMaxLines: 2,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('comm_profile_nickname_field'),
          controller: _nicknameController,
          readOnly: _isNicknameLocked,
          onChanged: _isNicknameLocked ? null : _onNicknameChanged,
          decoration: InputDecoration(
            labelText: l10n.commFieldNickname,
            prefixText: '@',
            prefixIcon: Icon(
              _isNicknameLocked
                  ? Icons.lock_outline_rounded
                  : Icons.alternate_email_rounded,
            ),
            suffixIcon: _isNicknameLocked
                ? const Icon(Icons.lock_rounded, size: 18)
                : _checkingNickname
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : _isNicknameAvailable == true
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF16A34A),
                          )
                        : _isNicknameAvailable == false
                            ? Icon(
                                Icons.error_outline_rounded,
                                color: colorScheme.error,
                              )
                            : null,
            helperText: _isAdmin
                ? '👑 Yönetici hesabı: Sınırsız kullanıcı adı hakkı'
                : _isNicknameLocked
                    ? '🔒 Kullanıcı adı değiştirme hakkınız (3/3) dolmuştur.'
                    : _myProfile == null
                        ? 'Benzersiz olmalıdır • Sonrasında toplam ${HealthCommunityProfile.maxNicknameChanges} değişiklik hakkınız vardır.'
                        : 'Kalan Kullanıcı Adı Değişiklik Hakkı: $_remainingNicknameChanges / ${HealthCommunityProfile.maxNicknameChanges}',
            helperMaxLines: 2,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        if (_checkingNickname || _isNicknameAvailable != null) ...[
          const SizedBox(height: 6),
          Builder(
            builder: (context) {
              final clean = HealthCommunityProfile.sanitizeNickname(
                _nicknameController.text,
              );
              if (_checkingNickname) {
                return Text(
                  '⏳ @$clean uygunluğu kontrol ediliyor...',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                );
              }
              if (clean.length < 3) {
                return Text(
                  '⚠️ Kullanıcı adı en az 3 karakter olmalıdır.',
                  key: const Key('comm_nickname_status_short'),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                );
              }
              if (_isNicknameAvailable == true) {
                return Text(
                  '✅ @$clean kullanıcı adı uygun!',
                  key: const Key('comm_nickname_status_available'),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF16A34A),
                    fontWeight: FontWeight.w800,
                  ),
                );
              }
              return Column(
                key: const Key('comm_nickname_status_taken'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '❌ @$clean başka bir üye tarafından alınmış! Önerilenler:',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.error,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (_nicknameSuggestions.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        for (final sug in _nicknameSuggestions)
                          ActionChip(
                            key: Key('comm_nick_suggestion_$sug'),
                            visualDensity: VisualDensity.compact,
                            label: Text(
                              '@$sug',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _nicknameController.text = sug;
                                _isNicknameAvailable = true;
                                _nicknameSuggestions = const [];
                              });
                            },
                          ),
                      ],
                    ),
                  ],
                ],
              );
            },
          ),
        ],
        const SizedBox(height: 12),

        // Birth Date & Live Age + Gender (Login Synced + Manual Editable)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                key: const Key('comm_profile_birthdate_field'),
                controller: _birthDateController,
                readOnly: true,
                onTap: _pickBirthDate,
                decoration: InputDecoration(
                  labelText: 'Doğum Tarihi & Yaş',
                  hintText: 'GG-AA-YYYY seçin',
                  prefixIcon: const Icon(Icons.cake_outlined),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_calculatedAge != null)
                        Container(
                          key: const Key('comm_form_live_age_pill'),
                          margin: const EdgeInsets.only(right: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryTeal.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$_calculatedAge Yaş',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryTeal,
                            ),
                          ),
                        ),
                      if (_birthDate != null)
                        IconButton(
                          key: const Key('comm_clear_birthdate_btn'),
                          tooltip: 'Temizle',
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: () => setState(() {
                            _birthDate = null;
                            _birthDateFromLogin = false;
                            _birthDateController.clear();
                          }),
                        )
                      else
                        const Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Icon(Icons.calendar_month_rounded, size: 18),
                        ),
                    ],
                  ),
                  helperText: _birthDateFromLogin
                      ? '✨ Giriş hesabınızdan otomatik çekildi (dokunarak değiştirebilirsiniz)'
                      : 'Dokunarak doğum tarihinizi seçebilir veya güncelleyebilirsiniz',
                  helperMaxLines: 2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Cinsiyet:',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            ChoiceChip(
              key: const Key('comm_gender_chip_male'),
              label: const Text('Erkek ♂'),
              selected: _gender == 'Male',
              onSelected: (_) => setState(() => _gender = 'Male'),
            ),
            ChoiceChip(
              key: const Key('comm_gender_chip_female'),
              label: const Text('Kadın ♀'),
              selected: _gender == 'Female',
              onSelected: (_) => setState(() => _gender = 'Female'),
            ),
            ChoiceChip(
              key: const Key('comm_gender_chip_none'),
              label: const Text('Belirtilmedi'),
              selected: _gender == null || _gender!.trim().isEmpty,
              onSelected: (_) => setState(() => _gender = null),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _countryCode,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.commFieldCountry,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                items: [
                  for (final c in CommunityCountryOption.all)
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
              child: DropdownButtonFormField<String>(
                initialValue: _languageCode,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.commFieldLanguage,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                items: [
                  for (final lang in LocaleController.supportedLanguages)
                    DropdownMenuItem(
                      value: lang.code,
                      child: Text(
                        lang.nativeName,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _languageCode = v);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _cityController,
          decoration: InputDecoration(
            labelText: l10n.commFieldCity,
            prefixIcon: const Icon(Icons.location_city_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 16),

        // Chronic Conditions multi-select
        Text(
          l10n.commFieldChronicConditions,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final cond in ChronicCondition.values)
              FilterChip(
                key: Key('comm_profile_condition_${cond.name}'),
                avatar: Icon(cond.icon, size: 16, color: cond.accentColor),
                label: Text(cond.localizedLabel(l10n)),
                selected: _selectedConditions.contains(cond),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedConditions.add(cond);
                    } else {
                      _selectedConditions.remove(cond);
                    }
                  });
                },
              ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('comm_profile_custom_condition_field'),
          controller: _customConditionController,
          maxLength: 80,
          decoration: InputDecoration(
            labelText: l10n.commFieldCustomCondition,
            hintText: l10n.commFieldCustomConditionHint,
            prefixIcon: const Icon(Icons.medical_information_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 10),

        // Health Goals multi-select
        Text(
          l10n.commFieldGoals,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final goal in HealthGoalTag.values)
              FilterChip(
                key: Key('comm_profile_goal_${goal.name}'),
                avatar: Icon(goal.icon, size: 16, color: goal.accentColor),
                label: Text(goal.localizedLabel(l10n)),
                selected: _selectedGoals.contains(goal),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedGoals.add(goal);
                    } else if (_selectedGoals.length > 1) {
                      _selectedGoals.remove(goal);
                    }
                  });
                },
              ),
          ],
        ),
        const SizedBox(height: 14),

        TextField(
          controller: _dailyFocusController,
          maxLength: 120,
          decoration: InputDecoration(
            labelText: l10n.commFieldDailyFocus,
            prefixIcon: const Icon(Icons.wb_sunny_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          key: const Key('comm_profile_bio_field'),
          controller: _bioController,
          maxLines: 3,
          maxLength: 300,
          decoration: InputDecoration(
            labelText: l10n.commFieldBio,
            alignLabelWithHint: true,
            prefixIcon: const Icon(Icons.format_quote_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 10),

        // Healthy Living Motto Section (ComboBox + Custom Input + Show/Hide)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  key: const Key('comm_toggle_show_motto'),
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Sağlıklı Yaşam Mottosu (Profilde Göster)',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0D9488),
                    ),
                  ),
                  value: _showMotto,
                  onChanged: (v) => setState(() => _showMotto = v),
                ),
                DropdownButtonFormField<String>(
                  key: const Key('comm_profile_motto_dropdown'),
                  isExpanded: true,
                  hint: const Text(
                    'Listeden motto seçin...',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.5),
                  ),
                  decoration: InputDecoration(
                    labelText: 'Hazır Sağlıklı Yaşam Mottosu Seçin',
                    prefixIcon: const Icon(Icons.auto_awesome_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  items: [
                    for (final m in HealthyLivingMottos.presets)
                      DropdownMenuItem<String>(
                        value: m,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 260),
                          child: Text(
                            m,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                  ],
                  onChanged: (selected) {
                    if (selected != null) {
                      setState(() => _mottoController.text = selected);
                    }
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  key: const Key('comm_profile_motto_field'),
                  controller: _mottoController,
                  maxLines: 2,
                  maxLength: 160,
                  decoration: InputDecoration(
                    labelText: 'Özel Mottonuz',
                    hintText: 'Kendi sağlıklı yaşam mottonuzu yazabilirsiniz...',
                    prefixIcon: const Icon(Icons.edit_note_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Concentration Music Section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.music_note_rounded,
                      size: 19,
                      color: Color(0xFFE11D48),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.commMusicSectionTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFE11D48),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  key: const Key('comm_profile_music_title_field'),
                  controller: _musicTitleController,
                  maxLength: 100,
                  decoration: InputDecoration(
                    labelText: l10n.commMusicTitleField,
                    prefixIcon: const Icon(Icons.queue_music_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  key: const Key('comm_profile_music_url_field'),
                  controller: _musicUrlController,
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(
                    labelText: l10n.commMusicUrlField,
                    hintText: 'https://www.youtube.com/watch?v=...',
                    prefixIcon: const Icon(Icons.link_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Social Media Accounts & Show/Hide Toggle
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  key: const Key('comm_toggle_show_socials'),
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    l10n.commToggleShowSocials,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                  subtitle: !_showSocials
                      ? Text(
                          l10n.commSocialsHiddenHint,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.error,
                          ),
                        )
                      : null,
                  value: _showSocials,
                  onChanged: (v) => setState(() => _showSocials = v),
                ),
                const SizedBox(height: 6),
                TextField(
                  key: const Key('comm_profile_instagram_field'),
                  controller: _instagramController,
                  decoration: InputDecoration(
                    labelText: 'Instagram',
                    prefixText: '@',
                    prefixIcon: const Icon(
                      Icons.camera_alt_outlined,
                      color: Color(0xFFE4405F),
                    ),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: const Key('comm_profile_x_field'),
                        controller: _twitterXController,
                        decoration: InputDecoration(
                          labelText: 'X (Twitter)',
                          prefixText: '@',
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        key: const Key('comm_profile_tiktok_field'),
                        controller: _tiktokController,
                        decoration: InputDecoration(
                          labelText: 'TikTok',
                          prefixText: '@',
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: const Key('comm_profile_facebook_field'),
                        controller: _facebookController,
                        decoration: InputDecoration(
                          labelText: 'Facebook',
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        key: const Key('comm_profile_snapchat_field'),
                        controller: _snapchatController,
                        decoration: InputDecoration(
                          labelText: 'Snapchat',
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Privacy & Messaging Controls
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                child: Text(
                  l10n.commPrivacySection,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryTeal,
                  ),
                ),
              ),
              SwitchListTile(
                title: Text(l10n.commToggleDiscoverable),
                value: _discoverable,
                onChanged: (v) => setState(() => _discoverable = v),
              ),
              SwitchListTile(
                title: const Text('Hakkımda Yazısını Profilde Göster'),
                value: _showBio,
                onChanged: (v) => setState(() => _showBio = v),
              ),
              SwitchListTile(
                title: const Text('Sağlıklı Yaşam Mottomu Göster'),
                value: _showMotto,
                onChanged: (v) => setState(() => _showMotto = v),
              ),
              SwitchListTile(
                title: const Text('Sigara & Alkol Bırakma Kartımı Göster'),
                value: _showSobrietyOnProfile,
                onChanged: (v) => setState(() => _showSobrietyOnProfile = v),
              ),
              SwitchListTile(
                title: const Text('Adım Sayar Özeti Kartımı Göster'),
                value: _showStepsOnProfile,
                onChanged: (v) => setState(() => _showStepsOnProfile = v),
              ),
              SwitchListTile(
                key: const Key('comm_toggle_show_birthdate'),
                title: const Text('Doğum Tarihi ve Yaşımı Profilde Göster'),
                value: _showBirthDate,
                onChanged: (v) => setState(() => _showBirthDate = v),
              ),
              SwitchListTile(
                key: const Key('comm_toggle_show_gender'),
                title: const Text('Cinsiyetimi Profilde Göster'),
                value: _showGender,
                onChanged: (v) => setState(() => _showGender = v),
              ),
              SwitchListTile(
                title: Text(l10n.commToggleShowConditions),
                value: _showChronicConditions,
                onChanged: (v) => setState(() => _showChronicConditions = v),
              ),
              SwitchListTile(
                title: Text(l10n.commToggleShowOnline),
                value: _showOnlineStatus,
                onChanged: (v) => setState(() => _showOnlineStatus = v),
              ),
              SwitchListTile(
                title: Text(l10n.commToggleHideRealName),
                value: _hideRealName,
                onChanged: (v) => setState(() => _hideRealName = v),
              ),
              SwitchListTile(
                title: Text(l10n.commToggleHidePhoto),
                value: _hidePhoto,
                onChanged: (v) => setState(() => _hidePhoto = v),
              ),
              SwitchListTile(
                title: Text(l10n.commToggleAllowMessages),
                value: _allowMessages,
                onChanged: (v) => setState(() => _allowMessages = v),
              ),
              SwitchListTile(
                title: Text(l10n.commToggleRequireApproval),
                value: _requireMessageApproval,
                onChanged: (v) => setState(() => _requireMessageApproval = v),
              ),
              SwitchListTile(
                title: Text(l10n.commToggleOnlyFriendsMsg),
                value: _onlyFriendsCanMessage,
                onChanged: (v) => setState(() => _onlyFriendsCanMessage = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Save Button
        SizedBox(
          width: double.infinity,
          height: 54,
          child: FilledButton.icon(
            key: const Key('comm_save_profile_button'),
            onPressed: _savingProfile ? null : _saveMyProfile,
            icon: const Icon(Icons.check_rounded),
            label: Text(l10n.commSaveProfile),
          ),
        ),
      ],
    );
  }
}
