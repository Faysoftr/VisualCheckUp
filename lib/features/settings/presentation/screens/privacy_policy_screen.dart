import 'package:flutter/material.dart';

/// In-app KVKK, GDPR, and Medical Privacy Policy screen required for
/// Google Play & Apple App Store Health category compliance.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const PrivacyPolicyScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gizlilik Politikası & KVKK'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Card(
            color: colorScheme.primaryContainer.withValues(alpha: 0.35),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.verified_user_outlined, color: colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'VisualCheckUp gizlilik odaklı (Local-First) tasarlanmıştır. Sağlık verileriniz varsayılan olarak yalnızca sizin cihazınızda saklanır ve üçüncü taraflarla paylaşılmaz.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const _PolicySection(
            title: '1. Cihaz İçi Veri Saklama (Varsayılan)',
            body:
                'Kan tahlili sonuçları, tansiyon ve şeker ölçümleri, görsel kontrol geçmişi ve çekilen kontrol fotoğrafları varsayılan olarak yalnızca telefonunuzdaki özel uygulama alanında saklanır. Fotoğraflar cihaz galerisine otomatik eklenmez.',
          ),
          const _PolicySection(
            title: '2. İsteğe Bağlı Bulut Yedekleme (Firebase)',
            body:
                'Ayarlar menüsünden açık rızanızla Bulut Yedeklemeyi etkinleştirirseniz, verileriniz yalnızca kendi Google/Apple hesabınıza özel Firebase Firestore alanında saklanır. Güvenlik kuralları (firestore.rules) gereği hesabınız dışındaki hiçbir kullanıcı bu verilere erişemez.',
          ),
          const _PolicySection(
            title: '3. İsteğe Bağlı Yapay Zeka (Gemini Vision) Analizi',
            body:
                'Varsayılan analiz 0 maliyetle cihaz içinde çalışır. İsteğe bağlı Bulut Yapay Zeka açık olduğunda yalnızca analiz için seçtiğiniz fotoğraf veya belge geçici olarak değerlendirilir; reklam veya profilleme amacıyla kullanılmaz.',
          ),
          const _PolicySection(
            title: '4. KVKK & GDPR Haklarınız (Veri Silme)',
            body:
                'Yan menüdeki "Hesabı Sil" seçeneği ile hem cihazınızdaki hem de (etkinse) Firebase bulutundaki tüm sağlık kayıtlarınızı, fotoğraflarınızı ve oturum bilgilerinizi tek dokunuşla kalıcı olarak silebilirsiniz.',
          ),
          const _PolicySection(
            title: '5. Tıbbi Sorumluluk Reddi',
            body:
                'VisualCheckUp tıbbi bir cihaz değildir; kesin tanı koymaz veya tedavi önermez. Tüm görsel ve tahlil özetleri yalnızca kişisel farkındalık ve doktor muayenesine hazırlık amaçlıdır. Acil belirtilerde 112’ye veya en yakın sağlık kuruluşuna başvurun.',
          ),
        ],
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  const _PolicySection({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                body,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.45,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
