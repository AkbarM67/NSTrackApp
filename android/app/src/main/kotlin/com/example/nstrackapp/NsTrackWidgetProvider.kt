package com.example.nstrackapp

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import android.app.PendingIntent
import android.content.Intent
import android.net.Uri
import es.antonborri.home_widget.HomeWidgetPlugin

class NsTrackWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val widgetData = HomeWidgetPlugin.getData(context)
        val views = RemoteViews(context.packageName, R.layout.nstrack_widget)

        // Get data (sudah formatted dengan titik) dengan default value
        val balance = widgetData.getString("balance", null) ?: "0"
        val income = widgetData.getString("income", null) ?: "0"
        val expense = widgetData.getString("expense", null) ?: "0"
        val hideAmount = widgetData.getBoolean("hide_amount", false)

        // Hide logic: Rp 5.xxx.xxx (cuma digit depan)
        if (hideAmount) {
            views.setTextViewText(R.id.balance_text, "Rp " + hideNumber(balance))
            views.setTextViewText(R.id.income_text, "Rp " + hideNumber(income))
            views.setTextViewText(R.id.expense_text, "Rp " + hideNumber(expense))
        } else {
            views.setTextViewText(R.id.balance_text, "Rp $balance")
            views.setTextViewText(R.id.income_text, "Rp $income")
            views.setTextViewText(R.id.expense_text, "Rp $expense")
        }

        // Toggle Hide Button
        val toggleIntent = Intent(context, MainActivity::class.java).apply {
            data = Uri.parse("nstrackapp://togglehide")
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val togglePendingIntent = PendingIntent.getActivity(
            context, 99, toggleIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.btn_toggle_hide, togglePendingIntent)

        // Add Transaction Button
        val addIntent = Intent(context, MainActivity::class.java).apply {
            data = Uri.parse("nstrackapp://addtransaction")
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val addPendingIntent = PendingIntent.getActivity(
            context, 0, addIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.add_transaction_button, addPendingIntent)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    // Hide number: 5.000.000 -> 5.xxx.xxx
    private fun hideNumber(number: String): String {
        if (number.isEmpty() || number == "0") return "xxx"
        
        val parts = number.split(".")
        if (parts.isEmpty()) return "xxx"
        
        // Ambil digit pertama, sisanya jadi xxx
        val firstPart = parts[0]
        val hiddenParts = parts.drop(1).map { "xxx" }
        
        return (listOf(firstPart) + hiddenParts).joinToString(".")
    }
}
