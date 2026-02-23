import 'package:home_widget/home_widget.dart';

class HomeWidgetService {
  static const String _androidProviderName = 'NsTrackWidgetProvider';

  static Future<void> initialize() async {
    await HomeWidget.setAppGroupId('group.nstrackapp');
    await HomeWidget.registerBackgroundCallback(backgroundCallback);
  }

  static String _formatRupiah(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  static Future<void> updateWidget({
    required double balance,
    required double income,
    required double expense,
  }) async {
    await HomeWidget.saveWidgetData('balance', _formatRupiah(balance));
    await HomeWidget.saveWidgetData('income', _formatRupiah(income));
    await HomeWidget.saveWidgetData('expense', _formatRupiah(expense));
    await HomeWidget.updateWidget(
      name: _androidProviderName,
      androidName: _androidProviderName,
    );
  }

  @pragma('vm:entry-point')
  static Future<void> backgroundCallback(Uri? uri) async {
    if (uri == null) return;
    
    if (uri.host == 'togglehide') {
      await _toggleHideAmount();
    }
  }

  static Future<void> _toggleHideAmount() async {
    final currentState = await HomeWidget.getWidgetData<bool>('hide_amount', defaultValue: false);
    await HomeWidget.saveWidgetData('hide_amount', !currentState!);
    await HomeWidget.updateWidget(androidName: _androidProviderName);
  }
}
