import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../models/transaction_model.dart';

class GoogleSheetsService {
  // Ganti dengan API Key BARU dari Google Cloud Console
  // JANGAN share API Key ini ke publik!
  static const _apiKey = 'AIzaSyARZEPwTzNiwKl1021b4H0OQ5-fqmQfYfo';
  static const _spreadsheetId = '1BMCUHvC8ToKxumkJ5Xa3VVtlvr1LUg5WHDNiBWz2Xz0';
  static const _sheetName = 'Transaksi';

  static Future<bool> addTransaction(TransactionModel transaction) async {
    try {
      final url = Uri.parse(
        'https://sheets.googleapis.com/v4/spreadsheets/$_spreadsheetId/values/$_sheetName:append?valueInputOption=RAW&key=$_apiKey',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'values': [
            [
              DateFormat('dd/MM/yyyy HH:mm').format(transaction.date),
              transaction.type == 'income' ? 'Pemasukan' : 'Pengeluaran',
              transaction.category,
              transaction.amount.toString(),
              transaction.description,
              transaction.userId,
            ]
          ]
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<void> init() async {
    // Optional: Create header row if needed
    try {
      final url = Uri.parse(
        'https://sheets.googleapis.com/v4/spreadsheets/$_spreadsheetId/values/$_sheetName!A1:F1?key=$_apiKey',
      );
      
      final response = await http.get(url);
      
      // If empty, add header
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['values'] == null || data['values'].isEmpty) {
          await http.put(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'values': [
                ['Tanggal', 'Tipe', 'Kategori', 'Jumlah', 'Deskripsi', 'User ID']
              ]
            }),
          );
        }
      }
    } catch (e) {
      // Ignore
    }
  }
}
