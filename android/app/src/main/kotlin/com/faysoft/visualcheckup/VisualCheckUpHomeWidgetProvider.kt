package com.faysoft.visualcheckup

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.widget.RemoteViews

open class VisualCheckUpHomeWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        for (widgetId in appWidgetIds) {
            updateAllInOneWidget(context, appWidgetManager, widgetId)
        }
    }

    companion object {
        const val EXTRA_WIDGET_TARGET = "widget_target"
        private const val FLUTTER_PREFS = "FlutterSharedPreferences"

        fun refreshAllWidgets(context: Context) {
            val manager = AppWidgetManager.getInstance(context)

            val allIds = manager.getAppWidgetIds(
                ComponentName(context, VisualCheckUpHomeWidgetProvider::class.java),
            )
            allIds?.forEach { updateAllInOneWidget(context, manager, it) }

            val pedIds = manager.getAppWidgetIds(
                ComponentName(context, PedometerHomeWidgetProvider::class.java),
            )
            pedIds?.forEach { updateSingleModuleWidget(context, manager, it, "pedometer") }

            val sobIds = manager.getAppWidgetIds(
                ComponentName(context, SobrietyHomeWidgetProvider::class.java),
            )
            sobIds?.forEach { updateSingleModuleWidget(context, manager, it, "sobriety") }

            val vitIds = manager.getAppWidgetIds(
                ComponentName(context, VitalsHomeWidgetProvider::class.java),
            )
            vitIds?.forEach { updateSingleModuleWidget(context, manager, it, "vitals") }

            val almIds = manager.getAppWidgetIds(
                ComponentName(context, AlarmHomeWidgetProvider::class.java),
            )
            almIds?.forEach { updateSingleModuleWidget(context, manager, it, "alarms") }
        }

        internal fun readIntSafe(map: Map<String, *>, key: String, fallback: Int): Int {
            val raw = map["flutter.$key"]
            return when (raw) {
                is Number -> raw.toInt()
                is String -> raw.toIntOrNull() ?: fallback
                else -> fallback
            }
        }

        internal fun readStringSafe(map: Map<String, *>, key: String, fallback: String): String {
            val raw = map["flutter.$key"]
            return if (raw is String && raw.isNotBlank()) raw else fallback
        }

        internal fun readBoolSafe(map: Map<String, *>, key: String, fallback: Boolean): Boolean {
            val raw = map["flutter.$key"]
            return if (raw is Boolean) raw else fallback
        }

        internal fun buildLaunchPendingIntent(
            context: Context,
            requestCode: Int,
            target: String?,
        ): PendingIntent {
            val launchIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                if (target != null) {
                    putExtra(EXTRA_WIDGET_TARGET, target)
                }
            }
            val pendingFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }
            return PendingIntent.getActivity(context, requestCode, launchIntent, pendingFlags)
        }

        internal fun updateAllInOneWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int,
        ) {
            val prefs = context.getSharedPreferences(FLUTTER_PREFS, Context.MODE_PRIVATE)
            val all = prefs.all

            val stepsToday = readIntSafe(all, "vcu_widget_steps_today", 0)
            val stepsGoal = readIntSafe(all, "vcu_widget_steps_goal", 10000)
            val stepsMode = readStringSafe(all, "vcu_widget_steps_mode", "Hazır")

            val sobrietyActive = readBoolSafe(all, "vcu_widget_sobriety_active", false)
            val sobrietyDays = readIntSafe(all, "vcu_widget_sobriety_days", 0)
            val sobrietyTodayTry = readStringSafe(all, "vcu_widget_sobriety_today_try", "₺0")
            val sobrietyLife = readStringSafe(all, "vcu_widget_sobriety_life", "0 dk")

            val vitalsSummary = readStringSafe(
                all,
                "vcu_widget_vitals_summary",
                "Tansiyon: --/-- | Şeker: --",
            )
            val alarmSummary = readStringSafe(
                all,
                "vcu_widget_alarm_summary",
                "Aktif hatırlatıcı yok",
            )

            val views = RemoteViews(context.packageName, R.layout.visualcheckup_home_widget)
            views.setTextViewText(
                R.id.widget_steps_line,
                "🚶 Yürüyüş: $stepsToday / $stepsGoal Adım ($stepsMode)",
            )
            views.setTextViewText(
                R.id.widget_sobriety_line,
                if (sobrietyActive) {
                    "🚭 Gün $sobrietyDays • Bugün $sobrietyTodayTry • +$sobrietyLife"
                } else {
                    "🚭 Sigara/Alkol Bırakma: Başlatmak için dokunun"
                },
            )
            views.setTextViewText(R.id.widget_vitals_line, "🩸 $vitalsSummary")
            views.setTextViewText(R.id.widget_alarm_line, "⏰ Alarm: $alarmSummary")

            views.setOnClickPendingIntent(
                R.id.widget_root,
                buildLaunchPendingIntent(context, 100, null),
            )
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        internal fun updateSingleModuleWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int,
            moduleKey: String,
        ) {
            val prefs = context.getSharedPreferences(FLUTTER_PREFS, Context.MODE_PRIVATE)
            val all = prefs.all
            val views = RemoteViews(context.packageName, R.layout.visualcheckup_single_widget)

            when (moduleKey) {
                "pedometer" -> {
                    val stepsToday = readIntSafe(all, "vcu_widget_steps_today", 0)
                    val stepsGoal = readIntSafe(all, "vcu_widget_steps_goal", 10000)
                    val stepsMode = readStringSafe(all, "vcu_widget_steps_mode", "Hazır")
                    views.setTextViewText(R.id.single_widget_title, "🚶 Adım Sayar & Yürüyüş")
                    views.setTextViewText(R.id.single_widget_primary, "$stepsToday / $stepsGoal Adım")
                    views.setTextViewText(R.id.single_widget_secondary, "Durum: $stepsMode")
                    views.setOnClickPendingIntent(
                        R.id.single_widget_root,
                        buildLaunchPendingIntent(context, 101, "pedometer"),
                    )
                }

                "sobriety" -> {
                    val active = readBoolSafe(all, "vcu_widget_sobriety_active", false)
                    val days = readIntSafe(all, "vcu_widget_sobriety_days", 0)
                    val todayTry = readStringSafe(all, "vcu_widget_sobriety_today_try", "₺0")
                    val life = readStringSafe(all, "vcu_widget_sobriety_life", "0 dk")
                    views.setTextViewText(R.id.single_widget_title, "🚭 Sigara & Alkol Bırakma")
                    views.setTextViewText(
                        R.id.single_widget_primary,
                        if (active) "Gün $days • Bugün $todayTry" else "Yolculuğu Başlat",
                    )
                    views.setTextViewText(
                        R.id.single_widget_secondary,
                        if (active) "Kazanılan Ömür: +$life" else "Kazanılan para & ömür sayacı",
                    )
                    views.setOnClickPendingIntent(
                        R.id.single_widget_root,
                        buildLaunchPendingIntent(context, 102, "sobriety"),
                    )
                }

                "vitals" -> {
                    val vitalsSummary = readStringSafe(
                        all,
                        "vcu_widget_vitals_summary",
                        "Tansiyon: --/-- | Şeker: --",
                    )
                    views.setTextViewText(R.id.single_widget_title, "🩸 Şeker & Tansiyon Takibi")
                    views.setTextViewText(R.id.single_widget_primary, vitalsSummary)
                    views.setTextViewText(
                        R.id.single_widget_secondary,
                        "Yeni ölçüm kaydetmek için dokunun",
                    )
                    views.setOnClickPendingIntent(
                        R.id.single_widget_root,
                        buildLaunchPendingIntent(context, 103, "vitals"),
                    )
                }

                "alarms" -> {
                    val alarmSummary = readStringSafe(
                        all,
                        "vcu_widget_alarm_summary",
                        "Aktif hatırlatıcı yok",
                    )
                    views.setTextViewText(R.id.single_widget_title, "⏰ İlaç & Su Alarmı")
                    views.setTextViewText(R.id.single_widget_primary, alarmSummary)
                    views.setTextViewText(
                        R.id.single_widget_secondary,
                        "Alarmları yönetmek için dokunun",
                    )
                    views.setOnClickPendingIntent(
                        R.id.single_widget_root,
                        buildLaunchPendingIntent(context, 104, "alarms"),
                    )
                }
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}

class PedometerHomeWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (id in appWidgetIds) {
            VisualCheckUpHomeWidgetProvider.updateSingleModuleWidget(context, appWidgetManager, id, "pedometer")
        }
    }
}

class SobrietyHomeWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (id in appWidgetIds) {
            VisualCheckUpHomeWidgetProvider.updateSingleModuleWidget(context, appWidgetManager, id, "sobriety")
        }
    }
}

class VitalsHomeWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (id in appWidgetIds) {
            VisualCheckUpHomeWidgetProvider.updateSingleModuleWidget(context, appWidgetManager, id, "vitals")
        }
    }
}

class AlarmHomeWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (id in appWidgetIds) {
            VisualCheckUpHomeWidgetProvider.updateSingleModuleWidget(context, appWidgetManager, id, "alarms")
        }
    }
}
