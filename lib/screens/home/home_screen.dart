import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../dashboard/dashboard_screen.dart';
import '../history/history_screen.dart';
import '../budget/budget_screen.dart';
import '../savings/savings_screen.dart';
import '../profile/profile_screen.dart';
import '../../widgets/top_bar.dart';
import '../../core/services/receipt_scanner_service.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/budget_provider.dart';
import '../../models/transaction_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final _receiptScanner = ReceiptScannerService();
  bool _isScanning = false;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const HistoryScreen(),
    const BudgetScreen(),
    const SavingsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex != 4 ? AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
      ) : null,
      body: Column(
        children: [
          if (_selectedIndex != 4) const TopBar(),
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'scanReceiptFAB',
        onPressed: _isScanning ? null : _scanReceipt,
        child: _isScanning
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.document_scanner, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.dashboard, 'Beranda', 0),
            _buildNavItem(Icons.history, 'History', 1),
            const SizedBox(width: 40),
            _buildNavItem(Icons.account_balance_wallet, 'Budget', 2),
            _buildNavItem(Icons.savings, 'Tabungan', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _scanReceipt() async {
    setState(() => _isScanning = true);

    final result = await _receiptScanner.scanReceipt();

    setState(() => _isScanning = false);

    if (result != null && mounted) {
      final amount = result['amount'] as double;
      final description = result['description'] as String;

      if (amount > 0) {
        _showConfirmDialog(amount, description);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat membaca jumlah dari struk'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _showConfirmDialog(double amount, String description) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.receipt_long, color: Color(0xFF4CAF50)),
            SizedBox(width: 12),
            Text('Hasil Scan Struk', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Deskripsi:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 4),
              Text(description, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 12),
              const Text('Jumlah:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 4),
              Text(
                'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50)),
              ),
              const SizedBox(height: 12),
              const Text('Simpan sebagai transaksi pengeluaran?', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _saveTransaction(amount, description);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)),
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _saveTransaction(double amount, String description) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final transaction = TransactionModel(
      id: '',
      userId: userId,
      type: 'expense',
      amount: amount,
      category: 'Lainnya',
      description: description,
      date: DateTime.now(),
    );

    await context.read<TransactionProvider>().addTransaction(transaction);

    if (mounted) {
      final transactionProvider = context.read<TransactionProvider>();
      final budgetProvider = context.read<BudgetProvider>();
      await Future.delayed(const Duration(milliseconds: 500));
      budgetProvider.checkBudgetNotifications(transactionProvider.transactions);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaksi berhasil disimpan'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    _receiptScanner.dispose();
    super.dispose();
  }
}
