package com.faysoft.visualcheckup

import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val ALARM_AUDIO_CHANNEL = "com.faysoft.visualcheckup/alarm_audio"
    }

    private var alarmPlayer: MediaPlayer? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            ALARM_AUDIO_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "play" -> {
                    val soundKey = call.argument<String>("soundKey") ?: "alarm_classic"
                    val loop = call.argument<Boolean>("loop") ?: false
                    val started = playAlarmSound(soundKey, loop)
                    result.success(started)
                }

                "stop" -> {
                    stopAlarmSound()
                    result.success(true)
                }

                "getSystemAlarmUri" -> {
                    val uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
                    result.success(uri?.toString())
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun resolveAlarmUri(soundKey: String): Uri? {
        if (soundKey == "system_alarm") {
            val systemUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
            if (systemUri != null) {
                return systemUri
            }
        }

        val safeName = if (soundKey == "system_alarm") "alarm_classic" else soundKey
        var resId = resources.getIdentifier(safeName, "raw", packageName)
        if (resId == 0) {
            resId = resources.getIdentifier("alarm_classic", "raw", packageName)
        }
        return if (resId != 0) {
            Uri.parse("android.resource://$packageName/$resId")
        } else {
            RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
        }
    }

    private fun playAlarmSound(soundKey: String, loop: Boolean): Boolean {
        stopAlarmSound()
        val uri = resolveAlarmUri(soundKey) ?: return false
        return try {
            val player = MediaPlayer().apply {
                setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .build(),
                )
                setDataSource(applicationContext, uri)
                isLooping = loop
                setOnCompletionListener { mp ->
                    if (!mp.isLooping) {
                        stopAlarmSound()
                    }
                }
                setOnErrorListener { _, _, _ ->
                    stopAlarmSound()
                    true
                }
                prepare()
                start()
            }
            alarmPlayer = player
            true
        } catch (_: Exception) {
            stopAlarmSound()
            false
        }
    }

    private fun stopAlarmSound() {
        val player = alarmPlayer ?: return
        alarmPlayer = null
        try {
            if (player.isPlaying) {
                player.stop()
            }
        } catch (_: Exception) {
            // Ignore state exceptions on teardown.
        }
        try {
            player.reset()
            player.release()
        } catch (_: Exception) {
            // Ignore release errors.
        }
    }

    override fun onDestroy() {
        stopAlarmSound()
        super.onDestroy()
    }
}
