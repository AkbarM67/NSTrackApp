import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/transaction_provider.dart';
import '../../models/transaction_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_format.dart';
import 'edit_transaction_screen.dart';
import 'add_transaction_screen.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  String _selectedType = 'all';
  String _selectedCategory = 'all';
  DateTimeRange? _dateRange;

  final List<String> _allCategories = [
    'all',
    'Makanan',
    'Transport',
    'Belanja',
    'Hiburan',
    'Nabung',
    'Gaji',
    'Bonus',
    'Investasi',
    'Lainnya'
  ];

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      context.read<TransactionProvider>().listenTransactions(userId);
    }
  }

  List<TransactionModel> _filterTransactions(List<TransactionModel> transactions) {
    return transactions.where((t) {
      bool typeMatch = _selectedType == 'all' || t.type == _selectedType;
      bool categoryMatch = _selectedCategory == 'all' || t.category == _selectedCategory;
      bool dateMatch = _dateRange == null ||
          (t.date.isAfter(_dateRange!.start.subtract(const Duration(days: 1))) &&
              t.date.isBefore(_dateRange!.end.add(const Duration(days: 1))));
      return typeMatch && categoryMatch && dateMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Semua Transaksi', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: Consumer<TransactionProvider>(
              builder: (context, provider, _) {
                final filteredTransactions = _filterTransactions(provider.transactions);

                if (filteredTransactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text('Tidak ada transaksi', style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = filteredTransactions[index];
                    return Dismissible(
                      key: Key(transaction.id),
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        context.read<TransactionProvider>().deleteTransaction(transaction.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Transaksi dihapus')),
                        );
                      },
                      child: Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: transaction.type == 'income'
                                  ? AppColors.income.withOpacity(0.1)
                                  : AppColors.expense.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              transaction.type == 'income' ? Icons.arrow_downward : Icons.arrow_upward,
                              color: transaction.type == 'income' ? AppColors.income : AppColors.expense,
                              size: 20,
                            ),
                          ),
                          title: Text(transaction.category, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                transaction.description,
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                              ),
                            ],
                          ),
                          trailing: Text(
                            CurrencyFormat.formatRupiah(transaction.amount),
                            style: TextStyle(
                              color: transaction.type == 'income' ? AppColors.income : AppColors.expense,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditTransactionScreen(transaction: transaction),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Transaksi'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (_dateRange != null)
              Chip(
                label: Text(
                  '${_dateRange!.start.day}/${_dateRange!.start.month} - ${_dateRange!.end.day}/${_dateRange!.end.month}',
                  style: const TextStyle(fontSize: 12),
                ),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => setState(() => _dateRange = null),
                backgroundColor: AppColors.primary.withOpacity(0.1),
              ),
            if (_dateRange != null) const SizedBox(width: 8),
            if (_selectedType != 'all')
              Chip(
                label: Text(
                  _selectedType == 'income' ? 'Pemasukan' : 'Pengeluaran',
                  style: const TextStyle(fontSize: 12),
                ),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => setState(() => _selectedType = 'all'),
                backgroundColor: AppColors.primary.withOpacity(0.1),
              ),
            if (_selectedType != 'all') const SizedBox(width: 8),
            if (_selectedCategory != 'all')
              Chip(
                label: Text(_selectedCategory, style: const TextStyle(fontSize: 12)),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => setState(() => _selectedCategory = 'all'),
                backgroundColor: AppColors.primary.withOpacity(0.1),
              ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Filter Transaksi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                const Text('Tipe', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'all', label: Text('Semua')),
                    ButtonSegment(value: 'income', label: Text('Masuk')),
                    ButtonSegment(value: 'expense', label: Text('Keluar')),
                  ],
                  selected: {_selectedType},
                  onSelectionChanged: (Set<String> newSelection) {
                    setModalState(() => _selectedType = newSelection.first);
                    setState(() => _selectedType = newSelection.first);
                  },
                ),
                const SizedBox(height: 20),
                const Text('Kategori', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                  ),
                  items: _allCategories.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(cat == 'all' ? 'Semua Kategori' : cat),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setModalState(() => _selectedCategory = value!);
                    setState(() => _selectedCategory = value!);
                  },
                ),
                const SizedBox(height: 20),
                const Text('Rentang Tanggal', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      initialDateRange: _dateRange,
                    );
                    if (picked != null) {
                      setModalState(() => _dateRange = picked);
                      setState(() => _dateRange = picked);
                    }
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    _dateRange == null
                        ? 'Pilih Tanggal'
                        : '${_dateRange!.start.day}/${_dateRange!.start.month}/${_dateRange!.start.year} - ${_dateRange!.end.day}/${_dateRange!.end.month}/${_dateRange!.end.year}',
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setModalState(() {
                            _selectedType = 'all';
                            _selectedCategory = 'all';
                            _dateRange = null;
                          });
                          setState(() {
                            _selectedType = 'all';
                            _selectedCategory = 'all';
                            _dateRange = null;
                          });
                        },
                        child: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                        child: const Text('Terapkan', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
