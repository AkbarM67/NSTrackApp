import 'package:intl/intl.dart';

class CurrencyFormat {
  static String formatRupiah(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  static String hideRupiah(double amount) {
    final formatted = formatRupiah(amount);
    final parts = formatted.replaceAll('Rp ', '').split('.');
    if (parts.isEmpty) return 'Rp xxx';
    return 'Rp ${parts[0]}${parts.length > 1 ? '.xxx' * (parts.length - 1) : ''}';
  }
}