import 'package:flutter/services.dart';
import 'package:visualcheckup/features/medications/domain/medication_reminder.dart';

/// Abstraction for playing alarm ringtones (both looping on the full-screen
/// alarm overlay and short previews inside the alarm sound picker).
abstract class MedicationAlarmAudioPlayer {
  Future<void> play(
    MedicationAlarmSound sound, {
    bool loop = false,
  });

  Future<void> stop();

  Future<String?> getSystemAlarmUri();
}

/// Safe no-op player used in unit/widget tests or unsupported runtimes.
class NoopMedicationAlarmAudioPlayer implements MedicationAlarmAudioPlayer {
  const NoopMedicationAlarmAudioPlayer();

  @override
  Future<void> play(
    MedicationAlarmSound sound, {
    bool loop = false,
  }) async {}

  @override
  Future<void> stop() async {}

  @override
  Future<String?> getSystemAlarmUri() async => null;
}

/// Native platform player backed by `com.faysoft.visualcheckup/alarm_audio`:
/// - Android: `MediaPlayer` on `AudioAttributes.USAGE_ALARM` (alarm stream).
/// - iOS: `AVAudioPlayer` with `.playback` audio session category.
class PlatformMedicationAlarmAudioPlayer implements MedicationAlarmAudioPlayer {
  PlatformMedicationAlarmAudioPlayer._();

  static final PlatformMedicationAlarmAudioPlayer instance =
      PlatformMedicationAlarmAudioPlayer._();

  static const MethodChannel _channel =
      MethodChannel('com.faysoft.visualcheckup/alarm_audio');

  @override
  Future<void> play(
    MedicationAlarmSound sound, {
    bool loop = false,
  }) async {
    try {
      await _channel.invokeMethod<bool>('play', <String, Object>{
        'soundKey': sound.rawResourceName,
        'loop': loop,
      });
    } catch (_) {
      // Gracefully ignore on desktop/test hosts without native audio channel.
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _channel.invokeMethod<bool>('stop');
    } catch (_) {
      // Ignore on unsupported hosts.
    }
  }

  @override
  Future<String?> getSystemAlarmUri() async {
    try {
      final uri = await _channel.invokeMethod<String>('getSystemAlarmUri');
      if (uri == null || uri.trim().isEmpty) return null;
      return uri.trim();
    } catch (_) {
      return null;
    }
  }
}
