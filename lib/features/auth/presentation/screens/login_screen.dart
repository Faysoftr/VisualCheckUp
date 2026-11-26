import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/core/l10n/l10n_extensions.dart';
import 'package:visualcheckup/core/l10n/locale_controller.dart';
import 'package:visualcheckup/core/theme/app_theme.dart';
import 'package:visualcheckup/features/auth/data/auth_service.dart';
import 'package:visualcheckup/features/auth/domain/auth_user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.authService,
    required this.onAuthenticated,
    this.localeController,
  });

  final AuthService authService;
  final ValueChanged<AuthUser> onAuthenticated;
  final LocaleController? localeController;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const String _termsAcceptedKey = 'visualcheckup_terms_accepted_v1';

  AuthProviderType? _loadingProvider;
  bool _termsAccepted = false;
  bool _showTermsError = false;

  bool get _isLoading => _loadingProvider != null;

  @override
  void initState() {
    super.initState();
    _loadTermsState();
  }

  Future<void> _loadTermsState() async {
    final prefs = await SharedPreferences.getInstance();
    final accepted = prefs.getBool(_termsAcceptedKey) ?? false;
    if (!mounted) return;
    if (accepted) {
      setState(() => _termsAccepted = true);
    }
  }

  Future<void> _setTermsAccepted(bool value) async {
    setState(() {
      _termsAccepted = value;
      if (value) _showTermsError = false;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_termsAcceptedKey, value);
  }

  Future<void> _showTermsDialog() async {
    final l10n = context.l10n;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.health_and_safety_outlined,
              color: Theme.of(dialogContext).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.loginTermsTitle,
                style: Theme.of(dialogContext).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            l10n.loginTermsModalBody,
            style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                  height: 1.45,
                ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.loginTermsAcceptBtn),
          ),
        ],
      ),
    );
    if (accepted == true && mounted) {
      await _setTermsAccepted(true);
    }
  }

  Future<void> _handleSignIn(
    AuthProviderType provider,
    Future<AuthUser> Function() action,
  ) async {
    if (_isLoading) return;
    if (!_termsAccepted) {
      setState(() => _showTermsError = true);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(context.l10n.loginTermsRequiredMsg),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }
    setState(() => _loadingProvider = provider);
    try {
      final user = await action();
      if (!mounted) return;
      widget.onAuthenticated(user);
    } on AuthCancelledException {
      // User dismissed the native account picker; stay quietly on LoginScreen.
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.signInFailed(error.toString())),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loadingProvider = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final l10n = context.l10n;
    final activeLangCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/app_bg.jpg',
            fit: BoxFit.cover,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        const Color(0xFF0E2222).withValues(alpha: 0.90),
                        AppTheme.darkCanvas.withValues(alpha: 0.94),
                      ]
                    : [
                        AppTheme.softMintTint.withValues(alpha: 0.50),
                        AppTheme.lightCanvas.withValues(alpha: 0.60),
                      ],
                stops: const [0.0, 0.55],
              ),
            ),
          ),
          SafeArea(
            child: Stack(
              children: [
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),
                          Center(
                            child: Container(
                              width: 92,
                              height: 92,
                              padding: const EdgeInsets.all(2.5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(26),
                                border: Border.all(
                                  color: const Color(0xFF2EFFD6).withValues(
                                    alpha: isDark ? 0.65 : 0.45,
                                  ),
                                  width: 1.6,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF17A398).withValues(
                                      alpha: isDark ? 0.45 : 0.30,
                                    ),
                                    blurRadius: 24,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(23),
                                child: Image.asset(
                                  'assets/images/app_logo.jpg',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 22),
                        Text(
                          l10n.appTitle,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.loginTagline,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _FeaturePill(
                              icon: Icons.tune_rounded,
                              label: l10n.featureColorCalibration,
                            ),
                            _FeaturePill(
                              icon: Icons.lock_outline_rounded,
                              label: l10n.featurePrivacyFirst,
                            ),
                            _FeaturePill(
                              icon: Icons.auto_awesome_outlined,
                              label: l10n.featureOptionalAi,
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  l10n.loginCardTitle,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.loginCardSubtitle,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    height: 1.35,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Material(
                                  color: _showTermsError
                                      ? colorScheme.errorContainer
                                          .withValues(alpha: 0.35)
                                      : colorScheme.surfaceContainerHighest
                                          .withValues(alpha: 0.45),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    side: BorderSide(
                                      color: _showTermsError
                                          ? colorScheme.error
                                          : (_termsAccepted
                                              ? colorScheme.primary
                                                  .withValues(alpha: 0.5)
                                              : colorScheme.outlineVariant),
                                      width: _showTermsError ? 1.5 : 1.0,
                                    ),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      CheckboxListTile(
                                        key: const Key('login_terms_checkbox'),
                                        value: _termsAccepted,
                                        onChanged: _isLoading
                                            ? null
                                            : (v) => _setTermsAccepted(
                                                  v ?? false,
                                                ),
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        contentPadding:
                                            const EdgeInsets.fromLTRB(
                                          8,
                                          4,
                                          12,
                                          0,
                                        ),
                                        dense: true,
                                        title: Text(
                                          l10n.loginTermsCheckbox,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            height: 1.35,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment:
                                            AlignmentDirectional.centerEnd,
                                        child: Padding(
                                          padding: const EdgeInsetsDirectional
                                              .only(
                                            end: 8,
                                            bottom: 4,
                                          ),
                                          child: TextButton.icon(
                                            onPressed: _showTermsDialog,
                                            style: TextButton.styleFrom(
                                              visualDensity:
                                                  VisualDensity.compact,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                            ),
                                            icon: const Icon(
                                              Icons.description_outlined,
                                              size: 15,
                                            ),
                                            label: Text(
                                              l10n.loginTermsReadMore,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _AppleSignInButton(
                                  label: l10n.continueWithApple,
                                  isLoading: _loadingProvider ==
                                      AuthProviderType.apple,
                                  disabled: _isLoading,
                                  onPressed: () => _handleSignIn(
                                    AuthProviderType.apple,
                                    widget.authService.signInWithApple,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _GoogleSignInButton(
                                  label: l10n.continueWithGoogle,
                                  isLoading: _loadingProvider ==
                                      AuthProviderType.google,
                                  disabled: _isLoading,
                                  onPressed: () => _handleSignIn(
                                    AuthProviderType.google,
                                    widget.authService.signInWithGoogle,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: colorScheme.outlineVariant,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Text(
                                        l10n.orDivider,
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: colorScheme.outlineVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                TextButton.icon(
                                  onPressed: _isLoading
                                      ? null
                                      : () => _handleSignIn(
                                            AuthProviderType.guest,
                                            widget.authService.continueAsGuest,
                                          ),
                                  icon:
                                      _loadingProvider == AuthProviderType.guest
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.person_outline_rounded,
                                            ),
                                  label: Text(l10n.continueAsGuest),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 16,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                l10n.disclaimerShort,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  height: 1.35,
                                  fontSize: 11.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (widget.localeController != null)
                PositionedDirectional(
                  top: 8,
                  end: 12,
                  child: ActionChip(
                    avatar: Icon(
                      Icons.language_rounded,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    label: Text(
                      activeLangCode.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    onPressed: () => LanguagePickerSheet.show(
                      context,
                      localeController: widget.localeController!,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.primary),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _AppleSignInButton extends StatelessWidget {
  const _AppleSignInButton({
    required this.label,
    required this.isLoading,
    required this.disabled,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final bool disabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? Colors.white : const Color(0xFF111616);
    final fg = isDark ? const Color(0xFF111616) : Colors.white;

    return FilledButton(
      onPressed: disabled ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: fg,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.apple, size: 22),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({
    required this.label,
    required this.isLoading,
    required this.disabled,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final bool disabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return OutlinedButton(
      onPressed: disabled ? null : onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        minimumSize: const Size.fromHeight(52),
        side: BorderSide(color: colorScheme.outlineVariant),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: colorScheme.primary,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4285F4).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    'G',
                    style: TextStyle(
                      color: Color(0xFF4285F4),
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
  }
}
