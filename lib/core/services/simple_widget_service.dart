import 'package:home_widget/home_widget.dart';

class SimpleWidgetService {
  static Future<void> updateWidget(double balance, double income, double expense) async {
    await HomeWidget.saveWidgetData('balance', balance.toStringAsFixed(0));
    await HomeWidget.saveWidgetData('income', income.toStringAsFixed(0));
    await HomeWidget.saveWidgetData('expense', expense.toStringAsFixed(0));
    await HomeWidget.updateWidget(
      name: 'SimpleWidgetProvider',
      androidName: 'SimpleWidgetProvider',
    );
  }
}
