package com.nooralhoda.official.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent

class NoorAlHodaCompactWidgetProvider : AppWidgetProvider() {

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        val action = intent.action
        if (action == AppWidgetManager.ACTION_APPWIDGET_UPDATE || 
            action == "es.antonborri.home_widget.action.UPDATE") {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val componentName = ComponentName(context, NoorAlHodaCompactWidgetProvider::class.java)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)
            if (appWidgetIds != null && appWidgetIds.isNotEmpty()) {
                onUpdate(context, appWidgetManager, appWidgetIds)
            }
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val legacyPrefs = context.getSharedPreferences(context.packageName + "_preferences", Context.MODE_PRIVATE)

        val now = System.currentTimeMillis()

        var calculatedName: String? = null
        var calculatedTime: String? = null
        var calculatedHours = 0L
        var calculatedMins = 0L
        var hasCalculated = false

        val prayerKeys = listOf("fajr", "dhuhr", "asr", "maghrib", "isha", "tomorrow_fajr")
        val prayerArabicNames = mapOf(
            "fajr" to "الفجر",
            "dhuhr" to "الظهر",
            "asr" to "العصر",
            "maghrib" to "المغرب",
            "isha" to "العشاء",
            "tomorrow_fajr" to "الفجر (غداً)"
        )

        for (key in prayerKeys) {
            val timeMs = prefs.getLong("${key}_ms", 0L)
            if (timeMs > now) {
                calculatedName = prayerArabicNames[key]
                calculatedTime = prefs.getString("${key}_formatted", null)
                val diffMs = timeMs - now
                calculatedHours = diffMs / (1000 * 60 * 60)
                calculatedMins = (diffMs / (1000 * 60)) % 60
                hasCalculated = true
                break
            }
        }

        val name = if (hasCalculated && calculatedName != null) {
            calculatedName
        } else {
            prefs.getString("next_prayer_name", null)
                ?: legacyPrefs.getString("next_prayer_name", "الفجر") ?: "الفجر"
        }

        val time = if (hasCalculated && calculatedTime != null) {
            calculatedTime
        } else {
            prefs.getString("next_prayer_time", null)
                ?: legacyPrefs.getString("next_prayer_time", "--:--") ?: "--:--"
        }

        val hoursStr = if (hasCalculated) {
            String.format("%02d", calculatedHours)
        } else {
            prefs.getString("countdown_hours", null)
                ?: legacyPrefs.getString("countdown_hours", "00") ?: "00"
        }

        val minsStr = if (hasCalculated) {
            String.format("%02d", calculatedMins)
        } else {
            prefs.getString("countdown_minutes", null)
                ?: legacyPrefs.getString("countdown_minutes", "00") ?: "00"
        }

        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.noor_al_hoda_compact_widget)

            views.setTextViewText(R.id.widget_title, "✨ سكن الروح")
            views.setTextViewText(R.id.widget_prayer_name, "الصلاة القادمة: $name")
            views.setTextViewText(R.id.widget_prayer_time, "الوقت: $time")
            views.setTextViewText(R.id.widget_countdown, "باقي: $hoursStr س و $minsStr د")

            try {
                val launchIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
                views.setOnClickPendingIntent(R.id.widget_root, launchIntent)
            } catch (_: Exception) {
                val intent = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                val pendingIntent = PendingIntent.getActivity(
                    context, 0, intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
