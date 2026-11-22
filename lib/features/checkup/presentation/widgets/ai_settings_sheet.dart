import 'package:flutter/material.dart';
import 'package:visualcheckup/features/checkup/data/history_repository.dart';

/// Bottom sheet allowing users to opt in/out of cloud Vision AI (Gemini via
/// Firebase AI Logic) and inspect active token-saving privacy controls.
class AiSettingsSheet extends StatefulWidget {
  const AiSettingsSheet({
    super.key,
    required this.historyRepository,
    this.isAiBackendConnected = false,
  });

  final HistoryRepository historyRepository;
  final bool isAiBackendConnected;

  static Future<void> show(
    BuildContext context, {
    required HistoryRepository historyRepository,
    bool isAiBackendConnected = false,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => AiSettingsSheet(
        historyRepository: historyRepository,
        isAiBackendConnected: isAiBackendConnected,
      ),
    );
  }

  @override
  State<AiSettingsSheet> createState() => _AiSettingsSheetState();
}

class _AiSettingsSheetState extends State<AiSettingsSheet> {
  bool _cloudAiEnabled = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final enabled = await widget.historyRepository.isCloudAiEnabled();
    if (!mounted) return;
    setState(() {
      _cloudAiEnabled = enabled;
      _loading = false;
    });
  }

  Future<void> _toggleCloudAi(bool value) async {
    await widget.historyRepository.setCloudAiEnabled(value);
    if (!mounted) return;
    setState(() => _cloudAiEnabled = value);
  }

  Future<void> _clearCache() async {
    await widget.historyRepository.clearAiCache();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Yapay zeka önbelleği temizlendi.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_outlined, color: colorScheme.primary),
              const SizedBox(width: 10),
              Text(
                'Yapay Zeka & Gizlilik Ayarları',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile(
              title: const Text(
                'Bulut Yapay Zeka (Gemini) Analizi',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                _cloudAiEnabled
                    ? 'Açık: Net ve kaliteli fotoğraflar küçültülerek anlık görsel analiz için güvenli bağlantıdan işlenir. İnternet yoksa cihaz içi analiz çalışır.'
                    : 'Kapalı (0 Token): Tüm analizler yalnızca cihazınızda yapılır; hiçbir fotoğraf dışarı gönderilmez.',
              ),
              value: _cloudAiEnabled,
              onChanged: _loading ? null : _toggleCloudAi,
            ),
          ),
          if (!widget.isAiBackendConnected) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.cloud_off_outlined,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Firebase AI Logic / Gemini bağlantısı eklendiğinde bulut analizi bu tercihe göre otomatik devreye girer; şu an cihaz içi motor aktiftir.',
                      style: theme.textTheme.bodySmall?.copyWith(height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          Text(
            'Aktif Token & Veri Tasarrufu Kontrolleri',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const _OptimizationRow(
            icon: Icons.center_focus_strong_outlined,
            text: '0-token bulanıklık, karanlık ve parlama kalite kapısı',
          ),
          const _OptimizationRow(
            icon: Icons.photo_size_select_large_outlined,
            text: 'Otomatik kırpma + 512px / 768px JPEG (%80) sıkıştırma',
          ),
          const _OptimizationRow(
            icon: Icons.bolt_outlined,
            text: 'Akıllı model seçimi (Flash-Lite / Flash) & düşük thinking',
          ),
          const _OptimizationRow(
            icon: Icons.cached_rounded,
            text: 'Aynı fotoğraf için cihaz içi hash önbelleği (0 token)',
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _clearCache,
              icon: const Icon(Icons.delete_sweep_outlined, size: 18),
              label: const Text('AI Önbelleğini Temizle'),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptimizationRow extends StatelessWidget {
  const _OptimizationRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
