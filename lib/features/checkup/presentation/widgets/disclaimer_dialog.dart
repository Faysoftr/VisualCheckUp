import 'package:flutter/material.dart';
import 'package:visualcheckup/core/l10n/l10n_extensions.dart';

class DisclaimerDialog extends StatelessWidget {
  const DisclaimerDialog({super.key});

  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const DisclaimerDialog(),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      icon: Icon(
        Icons.health_and_safety_outlined,
        size: 36,
        color: colorScheme.primary,
      ),
      title: Text(
        l10n.disclaimerTitle,
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Text(
          l10n.disclaimerFull,
          style: const TextStyle(height: 1.45),
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.disclaimerAccept),
        ),
      ],
    );
  }
}
