import 'package:flutter/material.dart';
import 'package:visualcheckup/features/widgets_hub/data/quick_widgets_preferences.dart';

class WidgetsManagerScreen extends StatefulWidget {
  const WidgetsManagerScreen({super.key});

  @override
  State<WidgetsManagerScreen> createState() => _WidgetsManagerScreenState();
}

class _WidgetsManagerScreenState extends State<WidgetsManagerScreen> {
  bool _hubVisible = true;
  List<QuickWidgetType> _enabled = List<QuickWidgetType>.from(
    QuickWidgetsPreferences.defaultEnabled,
  );
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final visible = await QuickWidgetsPreferences.isHubVisible();
    final enabled = await QuickWidgetsPreferences.loadEnabledWidgets();
    if (!mounted) return;
    setState(() {
      _hubVisible = visible;
      _enabled = enabled;
      _loading = false;
    });
  }

  Future<void> _pinToAndroid(String widgetType, String label) async {
    final pinned = await QuickWidgetsPreferences.requestPinNativeHomeWidget(
      widgetType: widgetType,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          pinned
              ? '📱 "$label" Android ana ekranına eklenmek üzere gönderildi! Açılan sistem penceresinden onaylayın.'
              : 'Android telefonunuzun ana ekranına basılı tutup "Widget’lar > VisualCheckUp" altından "$label" widget’ını sürükleyip ekleyebilirsiniz.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Widget Merkezi (Android & Uygulama)'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                // 1. Android Home Screen Native Widgets Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF0F766E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.android_rounded,
                            color: Color(0xFF5EEAD4),
                            size: 24,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Android Telefon Ana Ekran Widget’ları',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Aşağıdaki butonlarla istediğiniz takip widget’ını doğrudan Android telefonunuzun ana ekranına ekleyebilirsiniz. (Kaldırmak istediğinizde telefon ana ekranında widget’a basılı tutup "Kaldır" demeniz yeterlidir.)',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.88),
                          fontSize: 12.5,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _AndroidWidgetPinTile(
                        key: const Key('android_pin_all_btn'),
                        title: 'VisualCheckUp • Tümü Bir Arada (4’lü Özet)',
                        subtitle:
                            'Yürüyüş, Bırakma Kazancı, Tansiyon/Şeker ve Alarm tek kartta',
                        icon: Icons.dashboard_customize_rounded,
                        accent: const Color(0xFF2DD4BF),
                        onPin: () => _pinToAndroid(
                          'all',
                          'VisualCheckUp • Tümü Bir Arada',
                        ),
                      ),
                      const SizedBox(height: 8),
                      _AndroidWidgetPinTile(
                        key: const Key('android_pin_pedometer_btn'),
                        title: 'VisualCheckUp • Adım Sayar & Yürüyüş',
                        subtitle: 'Günlük adım sayısı, hedef ve yürüyüş modu',
                        icon: Icons.directions_walk_rounded,
                        accent: const Color(0xFF38BDF8),
                        onPin: () => _pinToAndroid(
                          'pedometer',
                          'VisualCheckUp • Adım Sayar',
                        ),
                      ),
                      const SizedBox(height: 8),
                      _AndroidWidgetPinTile(
                        key: const Key('android_pin_sobriety_btn'),
                        title: 'VisualCheckUp • Sigara & Alkol Bırakma',
                        subtitle: 'Kaçıncı gün, bugünkü kazanç ve kazanılan ömür',
                        icon: Icons.smoke_free_rounded,
                        accent: const Color(0xFF4ADE80),
                        onPin: () => _pinToAndroid(
                          'sobriety',
                          'VisualCheckUp • Sigara & Alkol Bırakma',
                        ),
                      ),
                      const SizedBox(height: 8),
                      _AndroidWidgetPinTile(
                        key: const Key('android_pin_vitals_btn'),
                        title: 'VisualCheckUp • Şeker & Tansiyon',
                        subtitle: 'Son tansiyon (mmHg) ve kan şekeri (mg/dL)',
                        icon: Icons.monitor_heart_rounded,
                        accent: const Color(0xFFFB7185),
                        onPin: () => _pinToAndroid(
                          'vitals',
                          'VisualCheckUp • Şeker & Tansiyon',
                        ),
                      ),
                      const SizedBox(height: 8),
                      _AndroidWidgetPinTile(
                        key: const Key('android_pin_alarms_btn'),
                        title: 'VisualCheckUp • İlaç & Su Alarmı',
                        subtitle: 'Sıradaki aktif ilaç veya su hatırlatıcısı',
                        icon: Icons.alarm_on_rounded,
                        accent: const Color(0xFFFBBF24),
                        onPin: () => _pinToAndroid(
                          'alarms',
                          'VisualCheckUp • İlaç & Su Alarmı',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 2. In-App Home Screen Widgets Toggle & Close Section
                Text(
                  'Uygulama İçi Ana Sayfa Widget Paneli',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Card(
                  margin: EdgeInsets.zero,
                  child: Column(
                    children: [
                      SwitchListTile(
                        key: const Key('manager_hub_master_switch'),
                        secondary: Icon(
                          _hubVisible
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_outlined,
                          color: colorScheme.primary,
                        ),
                        title: const Text(
                          'Ana Sayfada Widget Panelini Göster',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text(
                          _hubVisible
                              ? 'Açık: Seçili hızlı takip widget’ları uygulama ana sayfasında görünür.'
                              : 'Kapalı: Ana sayfadaki tüm hızlı widget alanı tamamen gizlendi.',
                        ),
                        value: _hubVisible,
                        onChanged: (v) async {
                          setState(() => _hubVisible = v);
                          await QuickWidgetsPreferences.setHubVisible(v);
                        },
                      ),
                      const Divider(height: 1),
                      for (final type in QuickWidgetType.values)
                        SwitchListTile(
                          key: Key('manager_toggle_${type.name}'),
                          dense: true,
                          secondary: CircleAvatar(
                            radius: 16,
                            backgroundColor:
                                type.accentColor.withValues(alpha: 0.14),
                            child: Icon(
                              type.icon,
                              size: 17,
                              color: type.accentColor,
                            ),
                          ),
                          title: Text(
                            type.title,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(type.subtitle),
                          value: _enabled.contains(type),
                          onChanged: !_hubVisible
                              ? null
                              : (checked) async {
                                  final updated =
                                      List<QuickWidgetType>.from(_enabled);
                                  if (checked) {
                                    if (!updated.contains(type)) {
                                      updated.add(type);
                                    }
                                  } else {
                                    updated.remove(type);
                                  }
                                  setState(() => _enabled = updated);
                                  await QuickWidgetsPreferences
                                      .saveEnabledWidgets(updated);
                                },
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _AndroidWidgetPinTile extends StatelessWidget {
  const _AndroidWidgetPinTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onPin,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onPin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: accent.withValues(alpha: 0.2),
            child: Icon(icon, color: accent, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.tonalIcon(
            style: FilledButton.styleFrom(
              visualDensity: VisualDensity.compact,
              backgroundColor: accent,
              foregroundColor: const Color(0xFF0F172A),
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
            onPressed: onPin,
            icon: const Icon(Icons.add_rounded, size: 17),
            label: const Text(
              'Ekle',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
