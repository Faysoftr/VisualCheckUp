package com.faysoft.visualcheckup

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val ALARM_AUDIO_CHANNEL = "com.faysoft.visualcheckup/alarm_audio"
        private const val HOME_WIDGET_CHANNEL = "com.faysoft.visualcheckup/home_widget"
        private const val STEP_EVENTS_CHANNEL = "com.faysoft.visualcheckup/step_events"
    }

    private var alarmPlayer: MediaPlayer? = null
    private var sensorManager: SensorManager? = null
    private var stepListener: SensorEventListener? = null

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

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            HOME_WIDGET_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "refreshWidget" -> {
                    VisualCheckUpHomeWidgetProvider.refreshAllWidgets(applicationContext)
                    result.success(true)
                }

                "requestPinWidget" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        val appWidgetManager = AppWidgetManager.getInstance(applicationContext)
                        val provider = ComponentName(
                            applicationContext,
                            VisualCheckUpHomeWidgetProvider::class.java,
                        )
                        if (appWidgetManager.isRequestPinAppWidgetSupported) {
                            val pinned = appWidgetManager.requestPinAppWidget(provider, null, null)
                            result.success(pinned)
                        } else {
                            result.success(false)
                        }
                    } else {
                        result.success(false)
                    }
                }

                else -> result.notImplemented()
            }
        }

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            STEP_EVENTS_CHANNEL,
        ).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    startStepListening(events)
                }

                override fun onCancel(arguments: Any?) {
                    stopStepListening()
                }
            },
        )
    }

    private fun startStepListening(sink: EventChannel.EventSink?) {
        stopStepListening()
        val mgr = getSystemService(Context.SENSOR_SERVICE) as? SensorManager ?: return
        sensorManager = mgr
        val counterSensor = mgr.getDefaultSensor(Sensor.TYPE_STEP_COUNTER)
        val detectorSensor = mgr.getDefaultSensor(Sensor.TYPE_STEP_DETECTOR)

        if (counterSensor != null) {
            val listener = object : SensorEventListener {
                override fun onSensorChanged(event: SensorEvent?) {
                    val stepsSinceBoot = event?.values?.firstOrNull()?.toInt() ?: return
                    sink?.success(stepsSinceBoot)
                }

                override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
            }
            stepListener = listener
            mgr.registerListener(listener, counterSensor, SensorManager.SENSOR_DELAY_UI)
        } else if (detectorSensor != null) {
            val listener = object : SensorEventListener {
                override fun onSensorChanged(event: SensorEvent?) {
                    val detected = event?.values?.firstOrNull()?.toInt() ?: 1
                    if (detected > 0) {
                        sink?.success(mapOf("delta" to detected))
                    }
                }

                override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
            }
            stepListener = listener
            mgr.registerListener(listener, detectorSensor, SensorManager.SENSOR_DELAY_UI)
        }
    }

    private fun stopStepListening() {
        val listener = stepListener
        stepListener = null
        if (listener != null) {
            try {
                sensorManager?.unregisterListener(listener)
            } catch (_: Exception) {}
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
        stopStepListening()
        stopAlarmSound()
        super.onDestroy()
    }
}
