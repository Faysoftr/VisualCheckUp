import 'package:flutter/material.dart';
import 'package:visualcheckup/core/l10n/locale_controller.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';
import 'package:visualcheckup/l10n/generated/app_localizations.dart';

extension BuildContextL10n on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension CheckCategoryL10n on CheckCategory {
  String localizedTitle(AppLocalizations l10n) {
    switch (this) {
      case CheckCategory.eye:
        return l10n.catEyeTitle;
      case CheckCategory.nail:
        return l10n.catNailTitle;
      case CheckCategory.tongue:
        return l10n.catTongueTitle;
      case CheckCategory.face:
        return l10n.catFaceTitle;
      case CheckCategory.skinCondition:
        return l10n.catSkinTitle;
      case CheckCategory.urine:
        return l10n.catUrineTitle;
      case CheckCategory.stool:
        return l10n.catStoolTitle;
    }
  }

  String localizedSubtitle(AppLocalizations l10n) {
    switch (this) {
      case CheckCategory.eye:
        return l10n.catEyeSubtitle;
      case CheckCategory.nail:
        return l10n.catNailSubtitle;
      case CheckCategory.tongue:
        return l10n.catTongueSubtitle;
      case CheckCategory.face:
        return l10n.catFaceSubtitle;
      case CheckCategory.skinCondition:
        return l10n.catSkinSubtitle;
      case CheckCategory.urine:
        return l10n.catUrineSubtitle;
      case CheckCategory.stool:
        return l10n.catStoolSubtitle;
    }
  }
}

/// Modal bottom sheet for selecting any of the 11 supported languages
/// (10 most spoken global languages + Turkish) or System Default.
class LanguagePickerSheet extends StatelessWidget {
  const LanguagePickerSheet({
    super.key,
    required this.localeController,
  });

  final LocaleController localeController;

  static Future<void> show(
    BuildContext context, {
    required LocaleController localeController,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.72,
        minChildSize: 0.45,
        maxChildSize: 0.9,
        builder: (_, scrollController) => LanguagePickerSheet(
          localeController: localeController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final current = localeController.value;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Row(
            children: [
              Icon(Icons.language_rounded, color: colorScheme.primary),
              const SizedBox(width: 10),
              Text(
                l10n.menuLanguage,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            selected: current == null,
            selectedTileColor:
                colorScheme.primaryContainer.withValues(alpha: 0.45),
            leading: const Icon(Icons.phonelink_setup_rounded),
            title: Text(
              l10n.languageSystem,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: current == null
                ? Icon(Icons.check_circle_rounded, color: colorScheme.primary)
                : null,
            onTap: () {
              localeController.setLocale(null);
              Navigator.of(context).pop();
            },
          ),
          const Divider(height: 16),
          for (final lang in LocaleController.supportedLanguages)
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              selected: current?.languageCode == lang.code,
              selectedTileColor:
                  colorScheme.primaryContainer.withValues(alpha: 0.45),
              leading: CircleAvatar(
                radius: 16,
                backgroundColor:
                    colorScheme.primaryContainer.withValues(alpha: 0.6),
                child: Text(
                  lang.code.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              title: Text(
                lang.nativeName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                lang.isRtl ? '${lang.englishName} • RTL' : lang.englishName,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: current?.languageCode == lang.code
                  ? Icon(Icons.check_circle_rounded, color: colorScheme.primary)
                  : null,
              onTap: () {
                localeController.setLocale(lang.locale);
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }
}
