import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:visualcheckup/core/theme/app_theme.dart';

/// Screen displayed when a user account has been suspended by an administrator.
/// Allows the user to view the suspension reason and submit a formal appeal
/// (synchronized with the Social Formul Bank ban appeal system).
class BannedScreen extends StatefulWidget {
  const BannedScreen({
    super.key,
    required this.reason,
    this.until,
    this.onSubmitAppeal,
    this.onSignOut,
    this.initialHasAppealed = false,
    this.initialAppealText,
  });

  final String reason;
  final DateTime? until;
  final Future<bool> Function(String appealText)? onSubmitAppeal;
  final VoidCallback? onSignOut;
  final bool initialHasAppealed;
  final String? initialAppealText;

  @override
  State<BannedScreen> createState() => _BannedScreenState();
}

class _BannedScreenState extends State<BannedScreen> {
  final TextEditingController _appealController = TextEditingController();
  bool _isSubmitting = false;
  late bool _hasAppealed;

  @override
  void initState() {
    super.initState();
    _hasAppealed = widget.initialHasAppealed;
    if (widget.initialAppealText != null) {
      _appealController.text = widget.initialAppealText!;
    }
  }

  @override
  void dispose() {
    _appealController.dispose();
    super.dispose();
  }

  Future<void> _submitAppeal() async {
    final text = _appealController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen itiraz açıklamanızı yazınız.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      if (widget.onSubmitAppeal != null) {
        final success = await widget.onSubmitAppeal!(text);
        if (success && mounted) {
          setState(() => _hasAppealed = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ İtirazınız yöneticiye iletildi. İncelenecektir.'),
              backgroundColor: Color(0xFF16A34A),
            ),
          );
        }
      } else {
        setState(() => _hasAppealed = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final untilStr = widget.until != null
        ? DateFormat('dd.MM.yyyy HH:mm').format(widget.until!)
        : 'Süresiz (Yönetici İncelemesi)';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Hesap Durumu'),
        automaticallyImplyLeading: false,
        actions: [
          if (widget.onSignOut != null)
            IconButton(
              key: const Key('banned_sign_out_button'),
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'Çıkış Yap',
              onPressed: widget.onSignOut,
            ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: colorScheme.error.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.gavel_rounded,
                    color: colorScheme.error,
                    size: 46,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Hesabınız Askıya Alındı',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Topluluk kurallarımız veya içerik güvenliği ihlali nedeniyle hesabınıza geçici/kalıcı kısıtlama uygulanmıştır.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Reason & Duration Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E1F2A)
                        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline_rounded,
                              size: 18, color: colorScheme.error),
                          const SizedBox(width: 8),
                          Text(
                            'Gerekçe:',
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.reason.isNotEmpty
                            ? widget.reason
                            : 'Topluluk güvenliği kurallarına aykırı davranış.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Divider(height: 20),
                      Row(
                        children: [
                          Icon(Icons.schedule_rounded,
                              size: 18, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Kısıtlama Bitiş:',
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              untilStr,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Appeal Form or Submitted Banner
                if (_hasAppealed)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF16A34A).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.mark_email_read_rounded,
                          color: Color(0xFF16A34A),
                          size: 36,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'İtirazınız İnceleniyor',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Yönetici ekibimiz itirazınızı en kısa sürede değerlendirip hesabınızı yeniden inceleyecektir.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.35,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.rate_review_outlined,
                                color: AppTheme.primaryTeal, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Karara İtiraz Et',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Bir yanlışlık olduğunu düşünüyorsanız durumu açıklayınız:',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          key: const Key('banned_appeal_text_field'),
                          controller: _appealController,
                          maxLines: 4,
                          maxLength: 500,
                          decoration: InputDecoration(
                            hintText: 'Açıklamanızı buraya yazınız...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          key: const Key('banned_appeal_submit_button'),
                          onPressed: _isSubmitting ? null : _submitAppeal,
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.send_rounded),
                          label: const Text('İtirazımı Gönder'),
                        ),
                      ],
                    ),
                  ),

                if (widget.onSignOut != null) ...[
                  const SizedBox(height: 20),
                  TextButton.icon(
                    onPressed: widget.onSignOut,
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text('Farklı Bir Hesapla Giriş Yap'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
