import 'package:flutter/material.dart';

class NotificationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static void showBudgetWarning({
    required String category,
    required double percentage,
    required double spent,
    required double budget,
  }) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    String title;
    String message;
    Color color;
    IconData icon;

    if (percentage >= 100) {
      title = '⚠️ Budget Terlampaui!';
      message = 'Budget $category sudah melebihi ${percentage.toStringAsFixed(0)}%';
      color = Colors.red;
      icon = Icons.error_outline;
    } else if (percentage >= 80) {
      title = '⚡ Peringatan Budget';
      message = 'Budget $category sudah mencapai ${percentage.toStringAsFixed(0)}%';
      color = Colors.orange;
      icon = Icons.warning_amber_rounded;
    } else {
      return; // Tidak perlu notifikasi jika di bawah 80%
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Pengeluaran:', style: TextStyle(fontWeight: FontWeight.w500)),
                      Text(
                        _formatRupiah(spent),
                        style: TextStyle(fontWeight: FontWeight.bold, color: color),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Budget:', style: TextStyle(fontWeight: FontWeight.w500)),
                      Text(_formatRupiah(budget), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  static String _formatRupiah(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }
}
