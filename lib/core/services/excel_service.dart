import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../../models/transaction_model.dart';

class ExcelService {
  Future<String?> exportTransactions(List<TransactionModel> transactions) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Transaksi'];

      // Header
      sheet.appendRow([
        TextCellValue('Tanggal'),
        TextCellValue('Tipe'),
        TextCellValue('Kategori'),
        TextCellValue('Jumlah'),
        TextCellValue('Deskripsi'),
      ]);

      // Data
      for (var transaction in transactions) {
        sheet.appendRow([
          TextCellValue(DateFormat('dd/MM/yyyy HH:mm').format(transaction.date)),
          TextCellValue(transaction.type == 'income' ? 'Pemasukan' : 'Pengeluaran'),
          TextCellValue(transaction.category),
          DoubleCellValue(transaction.amount),
          TextCellValue(transaction.description),
        ]);
      }

      // Save file
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'Transaksi_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
      final filePath = '${directory.path}/$fileName';
      
      final fileBytes = excel.encode();
      if (fileBytes != null) {
        File(filePath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);
        return filePath;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> importTransactions() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result == null || result.files.single.path == null) return null;

      final file = File(result.files.single.path!);
      final bytes = file.readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);

      final sheet = excel.tables[excel.tables.keys.first];
      if (sheet == null) return null;

      final transactions = <Map<String, dynamic>>[];

      // Skip header row
      for (var i = 1; i < sheet.rows.length; i++) {
        final row = sheet.rows[i];
        if (row.length < 5) continue;

        try {
          final dateStr = row[0]?.value?.toString() ?? '';
          final typeStr = row[1]?.value?.toString() ?? '';
          final category = row[2]?.value?.toString() ?? '';
          final amountStr = row[3]?.value?.toString() ?? '0';
          final description = row[4]?.value?.toString() ?? '';

          DateTime date;
          try {
            date = DateFormat('dd/MM/yyyy HH:mm').parse(dateStr);
          } catch (e) {
            date = DateTime.now();
          }

          final type = typeStr.toLowerCase().contains('pemasukan') ? 'income' : 'expense';
          final amount = double.tryParse(amountStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;

          if (amount > 0) {
            transactions.add({
              'type': type,
              'category': category,
              'amount': amount,
              'description': description,
              'date': date,
            });
          }
        } catch (e) {
          continue;
        }
      }

      return transactions;
    } catch (e) {
      return null;
    }
  }
}
