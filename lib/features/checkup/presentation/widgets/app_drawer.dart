import 'package:flutter/material.dart';
import 'package:visualcheckup/core/theme/app_theme.dart';
import 'package:visualcheckup/core/theme/theme_controller.dart';
import 'package:visualcheckup/features/auth/domain/auth_user.dart';

/// Main side navigation drawer for VisualCheckUp.
///
/// Houses secondary navigation (history, reference guide, AI/privacy settings,
/// live theme selector, medical disclaimer, and account management) so the
/// main home screen stays calm and focused on the 7 checkup modules.
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
    this.onOpenFollowUpPlan,
    this.onOpenQuickColorCard,
    this.onOpenLabReports,
    this.onOpenVitalsTracker,
  });

  final AuthUser currentUser;
  final ThemeController themeController;
  final VoidCallback onOpenSkinModule;
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hesabı ve Yerel Verileri Sil'),
        content: const Text(
          'Oturumunuz kapatılacak ve bu cihazdaki kontrol geçmişiniz ile kişisel renk referanslarınız kalıcı olarak silinecek. Devam etmek istiyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Hesabı Sil'),
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

    return Drawer(
      child: SafeArea(
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
                            currentUser.email ?? 'Yalnızca bu cihazda kayıtlı',
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
                                Text(
                                  '${currentUser.provider.label} Hesabı',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
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
                  const _DrawerSectionLabel('MODÜLLER & TAKİP'),
                  _DrawerTile(
                    icon: Icons.grid_view_rounded,
                    label: 'Ana Ekran',
                    selected: true,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  _DrawerTile(
                    icon: Icons.healing_rounded,
                    label: 'Cilt & Ben Takibi',
                    onTap: () => _closeAndRun(context, onOpenSkinModule),
                  ),
                  if (onOpenLabReports != null)
                    _DrawerTile(
                      icon: Icons.biotech_outlined,
                      label: 'Tahlil & Hastane Raporları',
                      onTap: () => _closeAndRun(context, onOpenLabReports!),
                    ),
                  if (onOpenVitalsTracker != null)
                    _DrawerTile(
                      icon: Icons.monitor_heart_outlined,
                      label: 'Tansiyon & Şeker Takibi',
                      onTap: () => _closeAndRun(context, onOpenVitalsTracker!),
                    ),
                  if (onOpenQuickColorCard != null)
                    _DrawerTile(
                      icon: Icons.palette_outlined,
                      label: 'Kamerasız Renk Kartı',
                      onTap: () => _closeAndRun(context, onOpenQuickColorCard!),
                    ),
                  if (onOpenFollowUpPlan != null)
                    _DrawerTile(
                      icon: Icons.event_repeat_rounded,
                      label: 'Kişisel Takip Planı',
                      onTap: () => _closeAndRun(context, onOpenFollowUpPlan!),
                    ),
                  _DrawerTile(
                    icon: Icons.history_rounded,
                    label: 'Kontrol Geçmişi',
                    onTap: () => _closeAndRun(context, onOpenHistory),
                  ),
                  _DrawerTile(
                    icon: Icons.menu_book_rounded,
                    label: 'Görsel Referans Rehberi',
                    onTap: () => _closeAndRun(context, onOpenReferenceGuide),
                  ),
                  const SizedBox(height: 8),
                  const Divider(indent: 12, endIndent: 12),
                  const _DrawerSectionLabel('AYARLAR & GİZLİLİK'),
                  _DrawerTile(
                    icon: Icons.auto_awesome_outlined,
                    label: 'Yapay Zeka & Gizlilik',
                    onTap: () => _closeAndRun(context, onOpenAiSettings),
                  ),
                  _DrawerTile(
                    icon: Icons.info_outline_rounded,
                    label: 'Tıbbi Bilgilendirme',
                    onTap: () => _closeAndRun(context, onOpenDisclaimer),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Görünüm Teması',
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
                                segments: const [
                                  ButtonSegment<ThemeMode>(
                                    value: ThemeMode.system,
                                    label: Text('Sistem'),
                                  ),
                                  ButtonSegment<ThemeMode>(
                                    value: ThemeMode.light,
                                    label: Text('Açık'),
                                  ),
                                  ButtonSegment<ThemeMode>(
                                    value: ThemeMode.dark,
                                    label: Text('Koyu'),
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
                      label: 'Google veya Apple ile Giriş Yap',
                      accentColor: colorScheme.primary,
                      onTap: () => _closeAndRun(context, onSignOut),
                    )
                  else ...[
                    _DrawerTile(
                      icon: Icons.logout_rounded,
                      label: 'Çıkış Yap',
                      onTap: () => _closeAndRun(context, onSignOut),
                    ),
                    _DrawerTile(
                      icon: Icons.delete_outline_rounded,
                      label: 'Hesabı Sil',
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
