import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../models/transaction_model.dart';

class GoogleSheetsImportService {
  // Ganti dengan API Key BARU dari Google Cloud Console
  // JANGAN share API Key ini ke publik!
  static const _apiKey = 'AIzaSyARZEPwTzNiwKl1021b4H0OQ5-fqmQfYfo';
  
  static Future<List<Map<String, dynamic>>?> importFromSheet(String spreadsheetId, String sheetName) async {
    try {
      final url = Uri.parse(
        'https://sheets.googleapis.com/v4/spreadsheets/$spreadsheetId/values/$sheetName?key=$_apiKey',
      );

      final response = await http.get(url);
      
      if (response.statusCode != 200) {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }

      final data = jsonDecode(response.body);
      final rows = data['values'] as List?;
      
      print('Total rows: ${rows?.length ?? 0}');
      
      if (rows == null || rows.isEmpty) return null;

      final transactions = <Map<String, dynamic>>[];

      for (var i = 0; i < rows.length; i++) {
        final row = rows[i];
        
        if (row.length < 6) continue;
        
        // Data ada di kolom C, D, E, F (index 2, 3, 4, 5)
        final tanggal = row[2]?.toString() ?? '';
        final jenis = row[3]?.toString().toLowerCase() ?? '';
        final keterangan = row[4]?.toString() ?? '';
        final nominalStr = row[5]?.toString() ?? '';

        // Skip header, baris kosong, atau baris summary
        if (tanggal.toLowerCase().contains('tanggal') || 
            tanggal.toLowerCase().contains('bulan') ||
            tanggal.toLowerCase().contains('masuk') ||
            tanggal.toLowerCase().contains('sisa') ||
            jenis.toLowerCase().contains('jenis') ||
            tanggal.isEmpty ||
            jenis.isEmpty) continue;

        // Parse tanggal
        DateTime? date;
        try {
          // Format: 11/01/2026 atau 11/1/2026
          final parts = tanggal.split('/');
          if (parts.length == 3) {
            final day = int.parse(parts[0]);
            final month = int.parse(parts[1]);
            final year = int.parse(parts[2]);
            date = DateTime(year, month, day);
          }
        } catch (e) {
          date = DateTime.now();
        }

        // Parse nominal (hapus Rp, titik, koma)
        double amount = 0;
        try {
          final cleanAmount = nominalStr
              .replaceAll('Rp', '')
              .replaceAll('.', '')
              .replaceAll(',', '')
              .replaceAll(' ', '')
              .trim();
          amount = double.parse(cleanAmount);
        } catch (e) {
          continue;
        }

        if (amount <= 0) continue;

        // Tentukan tipe
        String type = 'expense';
        if (jenis.contains('masuk')) {
          type = 'income';
        }

        // Tentukan kategori dari keterangan
        String category = _categorizeFromDescription(keterangan, type);

        transactions.add({
          'date': date ?? DateTime.now(),
          'type': type,
          'category': category,
          'amount': amount,
          'description': keterangan,
        });
      }

      print('Total transactions parsed: ${transactions.length}');
      return transactions;
    } catch (e) {
      print('Import error: $e');
      return null;
    }
  }

  static String _categorizeFromDescription(String desc, String type) {
    final lower = desc.toLowerCase();
    
    if (type == 'income') {
      if (lower.contains('gaji')) return 'Gaji';
      if (lower.contains('bonus')) return 'Bonus';
      if (lower.contains('gojek') || lower.contains('ojek')) return 'Lainnya';
      return 'Lainnya';
    }

    // Expense categories
    if (lower.contains('makan') || lower.contains('jajan') || 
        lower.contains('sarapan') || lower.contains('martabak')) {
      return 'Makanan';
    }
    if (lower.contains('pp') || lower.contains('bensin') || 
        lower.contains('bengkel') || lower.contains('kantor')) {
      return 'Transport';
    }
    if (lower.contains('keyboard') || lower.contains('kouta') || 
        lower.contains('belanja')) {
      return 'Belanja';
    }
    if (lower.contains('nabung') || lower.contains('ajaib')) {
      return 'Nabung';
    }
    if (lower.contains('cicilan')) {
      return 'Lainnya';
    }
    
    return 'Lainnya';
  }
}
