package com.example.expense_tracker

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews

class ExpenseWidget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            // Χρησιμοποιούμε το android.R.id.background ή το root layout
            val views = RemoteViews(context.packageName, R.layout.widget_layout)

            val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            // Σύνδεση της ενέργειας κλικ στο κουμπί του widget
            views.setOnClickPendingIntent(R.id.widget_add_btn, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}