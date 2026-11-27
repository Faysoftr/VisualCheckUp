package com.faysoft.visualcheckup

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.widget.RemoteViews

class VisualCheckUpHomeWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        for (widgetId in appWidgetIds) {
            updateSingleWidget(context, appWidgetManager, widgetId)
        }
    }

    companion object {
        private const val FLUTTER_PREFS = "FlutterSharedPreferences"

        fun refreshAllWidgets(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val component = ComponentName(context, VisualCheckUpHomeWidgetProvider::class.java)
            val ids = manager.getAppWidgetIds(component)
            if (ids != null && ids.isNotEmpty()) {
                for (id in ids) {
                    updateSingleWidget(context, manager, id)
                }
            }
        }

        private fun readIntSafe(map: Map<String, *>, key: String, fallback: Int): Int {
            val raw = map["flutter.$key"]
            return when (raw) {
                is Number -> raw.toInt()
                is String -> raw.toIntOrNull() ?: fallback
                else -> fallback
            }
        }

        private fun readStringSafe(map: Map<String, *>, key: String, fallback: String): String {
            val raw = map["flutter.$key"]
            return if (raw is String && raw.isNotBlank()) raw else fallback
        }

        private fun readBoolSafe(map: Map<String, *>, key: String, fallback: Boolean): Boolean {
            val raw = map["flutter.$key"]
            return if (raw is Boolean) raw else fallback
        }

        private fun updateSingleWidget(
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

            val launchIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val pendingFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }
            val pendingIntent = PendingIntent.getActivity(context, 0, launchIntent, pendingFlags)
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
