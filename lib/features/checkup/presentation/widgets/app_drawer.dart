import 'package:flutter/material.dart';
import 'package:visualcheckup/core/l10n/l10n_extensions.dart';
import 'package:visualcheckup/core/l10n/locale_controller.dart';
import 'package:visualcheckup/core/theme/app_theme.dart';
import 'package:visualcheckup/core/theme/theme_controller.dart';
import 'package:visualcheckup/features/auth/domain/auth_user.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';
import 'package:visualcheckup/features/skin/domain/skin_check_context.dart';

/// Main side navigation drawer for VisualCheckUp.
class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.currentUser,
    required this.themeController,
    required this.onOpenSkinModule,
    required this.onOpenHistory,
    required this.onOpenReferenceGuide,
    required this.onOpenAiSettings,
    required this.onOpenDisclaimer,
    required this.onSignOut,
    required this.onDeleteAccount,
    this.localeController,
    this.onOpenSettings,
    this.onOpenCategory,
    this.onOpenSkinConcern,
    this.onOpenFollowUpPlan,
    this.onOpenQuickColorCard,
    this.onOpenLabReports,
    this.onOpenVitalsTracker,
  });

  final AuthUser currentUser;
  final ThemeController themeController;
  final LocaleController? localeController;
  final VoidCallback? onOpenSettings;
  final VoidCallback onOpenSkinModule;
  final ValueChanged<CheckCategory>? onOpenCategory;
  final ValueChanged<SkinConcernType>? onOpenSkinConcern;
  final VoidCallback onOpenHistory;
  final VoidCallback onOpenReferenceGuide;
  final VoidCallback onOpenAiSettings;
  final VoidCallback onOpenDisclaimer;
  final VoidCallback onSignOut;
  final VoidCallback onDeleteAccount;
  final VoidCallback? onOpenFollowUpPlan;
  final VoidCallback? onOpenQuickColorCard;
  final VoidCallback? onOpenLabReports;
  final VoidCallback? onOpenVitalsTracker;

  void _closeAndRun(BuildContext context, VoidCallback action) {
    Navigator.of(context).pop();
    action();
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteAccountTitle),
        content: Text(l10n.deleteAccountBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.deleteAccount),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      Navigator.of(context).pop();
      onDeleteAccount();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final l10n = context.l10n;

    const nonSkinCategories = [
      CheckCategory.eye,
      CheckCategory.tongue,
      CheckCategory.nail,
      CheckCategory.face,
      CheckCategory.urine,
      CheckCategory.stool,
    ];

    final activeLangLabel = localeController?.value == null
        ? l10n.languageSystem
        : LocaleController.optionForCode(
            localeController!.value!.languageCode,
          ).nativeName;

    return Drawer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/app_bg.jpg',
            fit: BoxFit.cover,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.darkCanvas.withValues(alpha: 0.90)
                  : Colors.white.withValues(alpha: 0.42),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? const [Color(0xFF133333), Color(0xFF0E2323)]
                        : const [AppTheme.primaryTeal, AppTheme.secondaryMint],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: Text(
                        currentUser.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentUser.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            currentUser.email ?? l10n.localOnlyLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _providerIcon(currentUser.provider),
                                  size: 12,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    l10n.accountTypeLabel(
                                      currentUser.provider.localizedLabel(l10n),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                children: [
                  _DrawerTile(
                    icon: Icons.grid_view_rounded,
                    label: l10n.menuHome,
                    selected: true,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  _DrawerSectionLabel(l10n.menuSectionVisualChecks),
                  for (final category in nonSkinCategories)
                    if (onOpenCategory != null)
                      _DrawerTile(
                        icon: category.icon,
                        label: category.localizedTitle(l10n),
                        accentColor: category.accentColor,
                        onTap: () => _closeAndRun(
                          context,
                          () => onOpenCategory!(category),
                        ),
                      ),
                  Theme(
                    data: theme.copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                      childrenPadding:
                          const EdgeInsetsDirectional.only(start: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      collapsedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      leading: Icon(
                        Icons.healing_rounded,
                        color: CheckCategory.skinCondition.accentColor,
                        size: 21,
                      ),
                      title: Text(
                        l10n.menuSkinGroup,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      children: [
                        _DrawerTile(
                          icon: Icons.dashboard_customize_outlined,
                          label: l10n.menuSkinGeneral,
                          onTap: () => _closeAndRun(context, onOpenSkinModule),
                        ),
                        if (onOpenSkinConcern != null)
                          for (final concern
                              in SkinConcernTypeX.featuredSubModules)
                            _DrawerTile(
                              icon: concern.icon,
                              label: concern.localizedLabel(l10n),
                              accentColor: concern.accentColor,
                              onTap: () => _closeAndRun(
                                context,
                                () => onOpenSkinConcern!(concern),
                              ),
                            ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Divider(indent: 12, endIndent: 12),
                  _DrawerSectionLabel(l10n.menuSectionTracking),
                  if (onOpenFollowUpPlan != null)
                    _DrawerTile(
                      icon: Icons.event_repeat_rounded,
                      label: l10n.menuFollowUpPlan,
                      onTap: () => _closeAndRun(context, onOpenFollowUpPlan!),
                    ),
                  if (onOpenVitalsTracker != null)
                    _DrawerTile(
                      icon: Icons.monitor_heart_outlined,
                      label: l10n.menuVitalsTracker,
                      onTap: () => _closeAndRun(context, onOpenVitalsTracker!),
                    ),
                  if (onOpenLabReports != null)
                    _DrawerTile(
                      icon: Icons.biotech_outlined,
                      label: l10n.menuLabReports,
                      onTap: () => _closeAndRun(context, onOpenLabReports!),
                    ),
                  if (onOpenQuickColorCard != null)
                    _DrawerTile(
                      icon: Icons.palette_outlined,
                      label: l10n.menuQuickColorCard,
                      onTap: () => _closeAndRun(context, onOpenQuickColorCard!),
                    ),
                  _DrawerTile(
                    icon: Icons.history_rounded,
                    label: l10n.menuHistory,
                    onTap: () => _closeAndRun(context, onOpenHistory),
                  ),
                  _DrawerTile(
                    icon: Icons.menu_book_rounded,
                    label: l10n.menuReferenceGuide,
                    onTap: () => _closeAndRun(context, onOpenReferenceGuide),
                  ),
                  const SizedBox(height: 8),
                  const Divider(indent: 12, endIndent: 12),
                  _DrawerSectionLabel(l10n.menuSectionSettings),
                  if (onOpenSettings != null)
                    _DrawerTile(
                      icon: Icons.settings_outlined,
                      label: l10n.menuSettings,
                      onTap: () => _closeAndRun(context, onOpenSettings!),
                    ),
                  if (localeController != null)
                    ListTile(
                      dense: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      leading: const Icon(Icons.language_rounded, size: 21),
                      title: Text(
                        l10n.menuLanguage,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      trailing: Text(
                        activeLangLabel,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onTap: () => LanguagePickerSheet.show(
                        context,
                        localeController: localeController!,
                      ),
                    ),
                  _DrawerTile(
                    icon: Icons.auto_awesome_outlined,
                    label: l10n.menuAiSettings,
                    onTap: () => _closeAndRun(context, onOpenAiSettings),
                  ),
                  _DrawerTile(
                    icon: Icons.info_outline_rounded,
                    label: l10n.menuDisclaimer,
                    onTap: () => _closeAndRun(context, onOpenDisclaimer),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.menuTheme,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ValueListenableBuilder<ThemeMode>(
                          valueListenable: themeController,
                          builder: (context, mode, _) {
                            return SizedBox(
                              width: double.infinity,
                              child: SegmentedButton<ThemeMode>(
                                showSelectedIcon: false,
                                style: const ButtonStyle(
                                  visualDensity: VisualDensity.compact,
                                ),
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
                                    themeController.setThemeMode(
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
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
              child: Column(
                children: [
                  if (currentUser.isGuest)
                    _DrawerTile(
                      icon: Icons.login_rounded,
                      label: l10n.signInGoogleOrApple,
                      accentColor: colorScheme.primary,
                      onTap: () => _closeAndRun(context, onSignOut),
                    )
                  else ...[
                    _DrawerTile(
                      icon: Icons.logout_rounded,
                      label: l10n.signOut,
                      onTap: () => _closeAndRun(context, onSignOut),
                    ),
                    _DrawerTile(
                      icon: Icons.delete_outline_rounded,
                      label: l10n.deleteAccount,
                      accentColor: colorScheme.error,
                      onTap: () => _confirmDeleteAccount(context),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
        ],
      ),
    );
  }

  IconData _providerIcon(AuthProviderType provider) {
    switch (provider) {
      case AuthProviderType.apple:
        return Icons.apple;
      case AuthProviderType.google:
        return Icons.g_mobiledata_rounded;
      case AuthProviderType.guest:
        return Icons.person_outline_rounded;
    }
  }
}

class _DrawerSectionLabel extends StatelessWidget {
  const _DrawerSectionLabel(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.accentColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foreground = accentColor ??
        (selected ? colorScheme.primary : colorScheme.onSurface);

    return ListTile(
      dense: true,
      selected: selected,
      selectedTileColor: colorScheme.primaryContainer.withValues(alpha: 0.45),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      leading: Icon(icon, color: foreground, size: 21),
      title: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 14,
        ),
      ),
      onTap: onTap,
    );
  }
}
