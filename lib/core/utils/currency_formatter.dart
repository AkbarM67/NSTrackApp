import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Hapus semua karakter non-digit
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Format dengan pemisah ribuan
    final formatter = NumberFormat('#,###', 'id_ID');
    String formatted = formatter.format(int.parse(digitsOnly));

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Helper untuk convert formatted string ke double
double parseCurrency(String formattedValue) {
  String digitsOnly = formattedValue.replaceAll(RegExp(r'[^\d]'), '');
  return digitsOnly.isEmpty ? 0 : double.parse(digitsOnly);
}
