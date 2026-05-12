import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/transaction_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_format.dart';
import '../../core/services/simple_widget_service.dart';
import '../transaction/add_transaction_screen.dart';
import '../transaction/edit_transaction_screen.dart';
import '../transaction/transaction_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _hideAmount = false;

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      context.read<TransactionProvider>().listenTransactions(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildDashboard();
  }

  Widget _buildDashboard() {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        // Update widget
        SimpleWidgetService.updateWidget(provider.balance, provider.totalIncome, provider.totalExpense);
        
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.income, AppColors.income.withOpacity(0.8)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.income.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.arrow_downward, color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 8),
                                const Flexible(
                                  child: Text('Pemasukan', 
                                      style: TextStyle(color: Colors.white, fontSize: 13),
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(_hideAmount ? CurrencyFormat.hideRupiah(provider.totalIncome) : CurrencyFormat.formatRupiah(provider.totalIncome),
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.expense, AppColors.expense.withOpacity(0.8)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.expense.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.arrow_upward, color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 8),
                                const Flexible(
                                  child: Text('Pengeluaran', 
                                      style: TextStyle(color: Colors.white, fontSize: 13),
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(_hideAmount ? CurrencyFormat.hideRupiah(provider.totalExpense) : CurrencyFormat.formatRupiah(provider.totalExpense),
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.gradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Saldo', style: TextStyle(color: Colors.white70, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(_hideAmount ? CurrencyFormat.hideRupiah(provider.balance) : CurrencyFormat.formatRupiah(provider.balance),
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                      IconButton(
                        onPressed: () => setState(() => _hideAmount = !_hideAmount),
                        icon: Icon(_hideAmount ? Icons.visibility_off : Icons.visibility, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Transaksi Terakhir', 
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TransactionListScreen()),
                        );
                      },
                      child: const Text('Lihat Semua', style: TextStyle(color: AppColors.primary)),
                    ),
                  ],
                ),
                Expanded(
                  child: provider.currentPeriodTransactions.isEmpty
                      ? const Center(child: Text('Belum ada transaksi periode ini'))
                      : _buildGroupedList(context, provider),
                ),
              ],
            ),
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
            elevation: 4,
          ),
        );
      },
    );
  }

  Widget _buildGroupedList(BuildContext context, TransactionProvider provider) {
    final transactions = provider.currentPeriodTransactions;

    final Map<String, List> grouped = {};
    for (final t in transactions) {
      final key = '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}-${t.date.day.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(key, () => []).add(t);
    }

    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    final List items = [];
    for (final key in sortedKeys) {
      items.add(grouped[key]!.first.date);
      items.addAll(grouped[key]!);
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        if (item is DateTime) {
          return Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              _formatDate(item),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          );
        }

        final transaction = item;
        return Dismissible(
          key: Key(transaction.id),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (_) {
            context.read<TransactionProvider>().deleteTransaction(transaction.id);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Transaksi dihapus')),
            );
          },
          child: Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 8),
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
              title: Text(transaction.category,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: transaction.description.isNotEmpty
                  ? Text(transaction.description,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12))
                  : null,
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
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Hari ini, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
