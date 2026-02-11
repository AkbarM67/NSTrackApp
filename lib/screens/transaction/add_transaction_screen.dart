import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/savings_provider.dart';
import '../../providers/budget_provider.dart';
import '../../models/transaction_model.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/receipt_scanner_service.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _receiptScanner = ReceiptScannerService();
  
  String _type = 'expense';
  String _category = 'Makanan';
  String? _selectedSavingsGoalId;
  bool _isScanning = false;

  final List<String> _expenseCategories = ['Makanan', 'Transport', 'Belanja', 'Hiburan', 'Nabung', 'Lainnya'];
  final List<String> _incomeCategories = ['Gaji', 'Bonus', 'Investasi', 'Lainnya'];

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      context.read<SavingsProvider>().listenSavingsGoals(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tambah Transaksi', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          if (_type == 'expense')
            IconButton(
              onPressed: _isScanning ? null : _scanReceipt,
              icon: _isScanning
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.document_scanner_outlined),
              tooltip: 'Scan Struk',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Tipe Transaksi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                    value: 'expense',
                    label: const Text('Pengeluaran'),
                    icon: const Icon(Icons.arrow_upward),
                  ),
                  ButtonSegment(
                    value: 'income',
                    label: const Text('Pemasukan'),
                    icon: const Icon(Icons.arrow_downward),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _type = newSelection.first;
                    _category = _type == 'expense' ? _expenseCategories[0] : _incomeCategories[0];
                  });
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return _type == 'expense' ? AppColors.expense : AppColors.income;
                    }
                    return Colors.grey.shade100;
                  }),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Kategori', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  prefixIcon: Icon(Icons.category_outlined, color: AppColors.primary),
                ),
                items: (_type == 'expense' ? _expenseCategories : _incomeCategories)
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _category = value!;
                    if (_category != 'Nabung') {
                      _selectedSavingsGoalId = null;
                    }
                  });
                },
              ),
              if (_category == 'Nabung') ...[
                const SizedBox(height: 24),
                const Text('Target Tabungan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Consumer<SavingsProvider>(
                  builder: (context, savingsProvider, _) {
                    if (savingsProvider.savingsGoals.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange.shade700),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Belum ada target tabungan. Buat dulu di menu Tabungan.',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return DropdownButtonFormField<String>(
                      value: _selectedSavingsGoalId,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        prefixIcon: Icon(Icons.savings_outlined, color: AppColors.primary),
                        hintText: 'Pilih target tabungan',
                      ),
                      items: savingsProvider.savingsGoals.map((goal) {
                        return DropdownMenuItem(
                          value: goal.id,
                          child: Text(goal.goalName),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedSavingsGoalId = value),
                      validator: (value) => value == null ? 'Pilih target tabungan' : null,
                    );
                  },
                ),
              ],
              const SizedBox(height: 24),
              const Text('Jumlah', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  prefixIcon: Icon(Icons.payments_outlined, color: AppColors.primary),
                  prefixText: 'Rp ',
                  hintText: '0',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                validator: (value) => value?.isEmpty ?? true ? 'Masukkan jumlah' : null,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
              const Text('Deskripsi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  prefixIcon: Icon(Icons.notes_outlined, color: AppColors.primary),
                  hintText: 'Tambahkan catatan...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Simpan Transaksi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ],
          ),
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
        _amountController.text = amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
      }
      
      if (description.isNotEmpty) {
        _descriptionController.text = description;
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(amount > 0 ? 'Struk berhasil dipindai!' : 'Tidak dapat membaca jumlah'),
          backgroundColor: amount > 0 ? Colors.green : Colors.orange,
        ),
      );
    }
  }

  void _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final amount = parseCurrency(_amountController.text);
      final note = _descriptionController.text.isEmpty ? 'Setoran' : _descriptionController.text;

      // Jika kategori Nabung, simpan ke tabungan
      if (_category == 'Nabung' && _selectedSavingsGoalId != null) {
        await context.read<SavingsProvider>().addDeposit(
          _selectedSavingsGoalId!,
          amount,
          note,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Berhasil menabung'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        }
      } else {
        // Simpan sebagai transaksi biasa
        final transaction = TransactionModel(
          id: '',
          userId: userId,
          type: _type,
          amount: amount,
          category: _category,
          description: _descriptionController.text,
          date: DateTime.now(),
        );

        await context.read<TransactionProvider>().addTransaction(transaction);
        
        // Cek notifikasi budget setelah transaksi pengeluaran
        if (_type == 'expense' && mounted) {
          final transactionProvider = context.read<TransactionProvider>();
          final budgetProvider = context.read<BudgetProvider>();
          await Future.delayed(const Duration(milliseconds: 500));
          budgetProvider.checkBudgetNotifications(transactionProvider.transactions);
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaksi berhasil ditambahkan'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _receiptScanner.dispose();
    super.dispose();
  }
}
