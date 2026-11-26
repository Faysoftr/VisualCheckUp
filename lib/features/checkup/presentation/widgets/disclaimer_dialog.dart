import 'package:flutter/material.dart';
import 'package:visualcheckup/core/l10n/l10n_extensions.dart';
import 'package:visualcheckup/core/theme/app_theme.dart';

/// Comprehensive onboarding informational dialog covering:
/// 1. Tıbbi Sorumluluk Reddi (Medical Disclaimer)
/// 2. Gizlilik & KVKK / GDPR (Local-First Data Privacy)
/// 3. Güvenlik & Şifreleme (Data Security)
/// 4. Kullanım Şartları (Terms of Service)
///
/// Mandatory for new members upon first entry into VisualCheckUp.
class DisclaimerDialog extends StatefulWidget {
  const DisclaimerDialog({
    super.key,
    this.initiallyAgreed = false,
  });

  final bool initiallyAgreed;

  static Future<bool> show(
    BuildContext context, {
    bool initiallyAgreed = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DisclaimerDialog(initiallyAgreed: initiallyAgreed),
    );
    return result ?? false;
  }

  @override
  State<DisclaimerDialog> createState() => _DisclaimerDialogState();
}

class _DisclaimerDialogState extends State<DisclaimerDialog> {
  late bool _hasAgreed;

  @override
  void initState() {
    super.initState();
    _hasAgreed = widget.initiallyAgreed;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final l10n = context.l10n;

    return PopScope(
      canPop: false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Icon & Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal.withValues(
                          alpha: isDark ? 0.22 : 0.12,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.health_and_safety_rounded,
                        size: 28,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tıbbi Bilgilendirme & Kullanım',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: 16.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Gizlilik, Güvenlik ve Yasal Sorumluluk',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1),

                // Scrollable 4 Core Pillars
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionCard(
                          context,
                          icon: Icons.medical_services_outlined,
                          accentColor: const Color(0xFFEF4444),
                          title: '1. Tıbbi Sorumluluk Reddi',
                          body:
                              'VisualCheckUp, kamera ve tahlil verileri üzerinden ön farkındalık sunan bir sağlık asistanıdır. Kesinlikle tıbbi bir cihaz, tanı veya tedavi aracı değildir; uzman doktor muayenesi yerine geçmez.\n\n• Ortam aydınlatması, kamera sensörü ve ekran kalibrasyonu renk algısını doğrudan etkileyebilir.\n• Şiddetli göğüs/karın ağrısı, ani görme kaybı, yüksek ateş, nefes darlığı veya bilinç bulanıklığı gibi acil durumlarda derhal 112 Acil Servis’e başvurun.',
                        ),
                        const SizedBox(height: 10),
                        _buildSectionCard(
                          context,
                          icon: Icons.privacy_tip_outlined,
                          accentColor: AppTheme.primaryTeal,
                          title: '2. Gizlilik & KVKK / GDPR (Cihaz İçi Saklama)',
                          body:
                              'VisualCheckUp gizlilik odaklıdır (Local-First). Çektiğiniz kontrol fotoğrafları, tahlil dökümanları ve tansiyon/şeker geçmişiniz varsayılan olarak yalnızca sizin telefonunuzun yerel güvenli alanında saklanır.\n\n• Verileriniz asla üçüncü taraf reklam verenlerle veya profilleme şirketleriyle paylaşılmaz.\n• Fotoğraflar cihaz genel galerisine otomatik eklenmez.',
                        ),
                        const SizedBox(height: 10),
                        _buildSectionCard(
                          context,
                          icon: Icons.security_rounded,
                          accentColor: const Color(0xFF0284C7),
                          title: '3. Güvenlik & Veri Kontrolü',
                          body:
                              'Tüm yerel oturum ve sağlık girdileriniz şifreli mekanizmalarla korunur. Yan menüdeki "Hesabı Sil" seçeneği ile hem cihazınızdaki hem de (açıksa) buluttaki tüm verilerinizi ve fotoğraflarınızı tek dokunuşla kalıcı olarak silebilirsiniz.',
                        ),
                        const SizedBox(height: 10),
                        _buildSectionCard(
                          context,
                          icon: Icons.gavel_rounded,
                          accentColor: const Color(0xFF8B5CF6),
                          title: '4. Kullanım Şartları ve Üye Sorumluluğu',
                          body:
                              'VisualCheckUp’ı kullanan her birey, sunulan içeriklerin tavsiye ve farkındalık niteliğinde olduğunu kabul eder. Sağlık Topluluğu alanında diğer üyelerin mahremiyetine ve nezaket kurallarına uyulması zorunludur.',
                        ),
                      ],
                    ),
                  ),
                ),

                const Divider(height: 1),
                const SizedBox(height: 8),

                // Consent Checkbox
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    key: const Key('disclaimer_consent_checkbox'),
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setState(() => _hasAgreed = !_hasAgreed),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 4,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _hasAgreed,
                            activeColor: AppTheme.primaryTeal,
                            onChanged: (val) =>
                                setState(() => _hasAgreed = val ?? false),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                'Tıbbi Bilgilendirme, Gizlilik Politikası, Güvenlik İlkeleri ve Kullanım Şartları\'nı okudum, anladım ve kabul ediyorum.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Actions: Reject / Accept
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: OutlinedButton(
                        key: const Key('disclaimer_reject_button'),
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(l10n.cancel),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: FilledButton.icon(
                        key: const Key('disclaimer_accept_button'),
                        onPressed: _hasAgreed
                            ? () => Navigator.of(context).pop(true)
                            : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.primaryTeal,
                          disabledBackgroundColor:
                              AppTheme.primaryTeal.withValues(alpha: 0.38),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 18,
                        ),
                        label: Text(
                          l10n.disclaimerAccept, // 'Okudum, Anladım'
                          style: const TextStyle(fontWeight: FontWeight.w800),
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
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required IconData icon,
    required Color accentColor,
    required String title,
    required String body,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: isDark ? 0.12 : 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: isDark ? 0.28 : 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: accentColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: theme.textTheme.bodySmall?.copyWith(
              height: 1.42,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.90),
            ),
          ),
        ],
      ),
    );
  }
}
