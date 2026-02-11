import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class ReceiptScannerService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  Future<Map<String, dynamic>?> scanReceipt() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image == null) return null;

      final inputImage = InputImage.fromFilePath(image.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      return _parseReceiptText(recognizedText.text);
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> _parseReceiptText(String text) {
    double? amount;
    String description = '';

    final lines = text.split('\n');
    
    // Cari total/jumlah dengan berbagai format
    final patterns = [
      RegExp(r'(?:total|jumlah|bayar|grand total)[:\s]*rp?\.?\s*([\d.,]+)', caseSensitive: false),
      RegExp(r'rp\.?\s*([\d.,]+)', caseSensitive: false),
      RegExp(r'([\d.,]+)\s*(?:ribu|rb)', caseSensitive: false),
    ];

    for (final line in lines) {
      for (final pattern in patterns) {
        final match = pattern.firstMatch(line);
        if (match != null) {
          String numStr = match.group(1) ?? '';
          numStr = numStr.replaceAll(RegExp(r'[.,]'), '');
          final parsed = double.tryParse(numStr);
          if (parsed != null && parsed > 0) {
            if (amount == null || parsed > amount) {
              amount = parsed;
            }
          }
        }
      }
    }

    // Ambil baris pertama sebagai deskripsi (biasanya nama toko)
    if (lines.isNotEmpty) {
      description = lines.first.trim();
      if (description.length > 50) {
        description = description.substring(0, 50);
      }
    }

    return {
      'amount': amount ?? 0.0,
      'description': description.isEmpty ? 'Pembelian' : description,
    };
  }

  void dispose() {
    _textRecognizer.close();
  }
}
