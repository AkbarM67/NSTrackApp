package com.example.nstrackapp

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class SimpleWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.simple_widget)
            val widgetData = HomeWidgetPlugin.getData(context)
            
            val balance = widgetData.getString("balance", "0")
            val income = widgetData.getString("income", "0")
            val expense = widgetData.getString("expense", "0")
            
            views.setTextViewText(R.id.widget_balance, "Rp $balance")
            views.setTextViewText(R.id.widget_income, "Rp $income")
            views.setTextViewText(R.id.widget_expense, "Rp $expense")
            
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
