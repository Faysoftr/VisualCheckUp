import 'package:flutter/material.dart';
import 'package:healthcheck/core/constants/medical_disclaimer.dart';

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

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      icon: Icon(
        Icons.health_and_safety_outlined,
        size: 36,
        color: colorScheme.primary,
      ),
      title: const Text(
        'Önemli Tıbbi Bilgilendirme',
        textAlign: TextAlign.center,
      ),
      content: const SingleChildScrollView(
        child: Text(
          MedicalDisclaimer.fullText,
          style: TextStyle(height: 1.45),
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Okudum, Anladım'),
        ),
      ],
    );
  }
}
