import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class ReceiptScannerService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  Future<Map<String, dynamic>?> scanReceipt() async {
    try {
      print('📸 Starting receipt scan...');
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image == null) {
        print('❌ No image selected');
        return null;
      }

      print('✅ Image captured: ${image.path}');
      final inputImage = InputImage.fromFilePath(image.path);
      print('🔍 Processing OCR...');
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      print('=== OCR RESULT ===');
      print(recognizedText.text);
      print('==================');

      final result = _parseReceiptText(recognizedText.text);
      print('💰 Parsed amount: ${result['amount']}');
      print('📝 Parsed description: ${result['description']}');
      
      return result;
    } catch (e) {
      print('❌ OCR Error: $e');
      return null;
    }
  }

  Map<String, dynamic> _parseReceiptText(String text) {
    double? amount;
    String description = '';

    final lines = text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    
    // Pattern prioritas tinggi untuk total
    final highPriorityPatterns = [
      RegExp(r'(?:total|grand\s*total|total\s*bayar|total\s*belanja)[:\s]*rp?\.?\s*([\d.,]+)', caseSensitive: false),
      RegExp(r'(?:jumlah|bayar|pembayaran)[:\s]*rp?\.?\s*([\d.,]+)', caseSensitive: false),
    ];
    
    // Pattern prioritas rendah
    final lowPriorityPatterns = [
      RegExp(r'rp\.?\s*([\d.,]+)', caseSensitive: false),
      RegExp(r'([\d.,]+)\s*(?:ribu|rb)', caseSensitive: false),
      RegExp(r'([\d]{1,3}(?:[.,]\d{3})+)', caseSensitive: false),
    ];

    // Cari dengan prioritas tinggi dulu
    for (final line in lines) {
      for (final pattern in highPriorityPatterns) {
        final match = pattern.firstMatch(line);
        if (match != null) {
          final parsed = _parseAmount(match.group(1) ?? '');
          if (parsed != null && parsed > 100) {
            amount = parsed;
            break;
          }
        }
      }
      if (amount != null) break;
    }

    // Jika tidak ketemu, cari dengan prioritas rendah (ambil yang terbesar)
    if (amount == null) {
      double maxAmount = 0;
      for (final line in lines) {
        for (final pattern in lowPriorityPatterns) {
          final matches = pattern.allMatches(line);
          for (final match in matches) {
            final parsed = _parseAmount(match.group(1) ?? '');
            if (parsed != null && parsed > maxAmount && parsed > 100) {
              maxAmount = parsed;
            }
          }
        }
      }
      if (maxAmount > 0) amount = maxAmount;
    }

    // Ambil nama toko dari baris awal (skip baris yang terlalu pendek)
    for (final line in lines.take(5)) {
      if (line.length >= 3 && line.length <= 50 && !RegExp(r'\d{4,}').hasMatch(line)) {
        description = line;
        break;
      }
    }

    return {
      'amount': amount ?? 0.0,
      'description': description.isEmpty ? 'Pembelian' : description,
    };
  }

  double? _parseAmount(String text) {
    if (text.isEmpty) return null;
    
    // Hapus semua karakter kecuali angka
    String cleaned = text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleaned.isEmpty) return null;
    
    // Handle format "ribu" atau "rb"
    if (text.toLowerCase().contains('ribu') || text.toLowerCase().contains('rb')) {
      final num = double.tryParse(cleaned);
      return num != null ? num * 1000 : null;
    }
    
    return double.tryParse(cleaned);
  }

  void dispose() {
    _textRecognizer.close();
  }
}
