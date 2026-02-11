import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/budget_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_format.dart';
import 'set_budget_screen.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      context.read<BudgetProvider>().loadBudget(userId);
      context.read<TransactionProvider>().listenTransactions(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer2<BudgetProvider, TransactionProvider>(
        builder: (context, budgetProvider, transactionProvider, _) {
          final budget = budgetProvider.budget;

          if (budget == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance_wallet_outlined, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('Belum ada budget', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                  const SizedBox(height: 8),
                  Text('Atur budget bulanan untuk kelola keuangan', 
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SetBudgetScreen()),
                      );
                      if (result == true && mounted) {
                        final userId = FirebaseAuth.instance.currentUser?.uid;
                        if (userId != null) {
                          context.read<BudgetProvider>().loadBudget(userId);
                        }
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Atur Budget'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            );
          }

          final now = DateTime.now();
          final monthTransactions = transactionProvider.transactions.where((t) {
            return t.date.year == now.year && t.date.month == now.month;
          }).toList();

          final needsSpent = budgetProvider.getNeedsSpent(monthTransactions);
          final wantsSpent = budgetProvider.getWantsSpent(monthTransactions);
          final savingsSpent = budgetProvider.getSavingsSpent(monthTransactions);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.gradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Budget Bulanan', style: TextStyle(color: Colors.white70, fontSize: 14)),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => SetBudgetScreen(budget: budget)),
                              );
                              if (result == true && mounted) {
                                final userId = FirebaseAuth.instance.currentUser?.uid;
                                if (userId != null) {
                                  context.read<BudgetProvider>().loadBudget(userId);
                                }
                              }
                            },
                          ),
                        ],
                      ),
                      Text(CurrencyFormat.formatRupiah(budget.monthlyIncome),
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 8),
                      Text('Metode ${budget.needsPercentage.toInt()}/${budget.wantsPercentage.toInt()}/${budget.savingsPercentage.toInt()}',
                          style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildCategoryCard(
                  title: 'Kebutuhan',
                  icon: Icons.home_outlined,
                  color: Colors.blue,
                  percentage: budget.needsPercentage,
                  budgetAmount: budget.needsAmount,
                  spentAmount: needsSpent,
                  categories: 'Makanan, Transport',
                ),
                const SizedBox(height: 16),
                _buildCategoryCard(
                  title: 'Keinginan',
                  icon: Icons.shopping_bag_outlined,
                  color: Colors.orange,
                  percentage: budget.wantsPercentage,
                  budgetAmount: budget.wantsAmount,
                  spentAmount: wantsSpent,
                  categories: 'Belanja, Hiburan',
                ),
                const SizedBox(height: 16),
                _buildCategoryCard(
                  title: 'Tabungan',
                  icon: Icons.savings_outlined,
                  color: Colors.green,
                  percentage: budget.savingsPercentage,
                  budgetAmount: budget.savingsAmount,
                  spentAmount: savingsSpent,
                  categories: 'Nabung',
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline, color: Colors.blue.shade700, size: 20),
                          const SizedBox(width: 8),
                          Text('Tips Mengelola Budget',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildTip('Prioritaskan kebutuhan daripada keinginan'),
                      _buildTip('Sisihkan tabungan di awal bulan'),
                      _buildTip('Catat setiap pengeluaran secara rutin'),
                      _buildTip('Review budget setiap akhir bulan'),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required IconData icon,
    required Color color,
    required double percentage,
    required double budgetAmount,
    required double spentAmount,
    required String categories,
  }) {
    final progress = budgetAmount > 0 ? (spentAmount / budgetAmount).clamp(0.0, 1.0) : 0.0;
    final remaining = budgetAmount - spentAmount;
    final isOverBudget = spentAmount > budgetAmount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('${percentage.toInt()}% • $categories',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isOverBudget ? Colors.red.shade50 : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('${(progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isOverBudget ? Colors.red : color)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Terpakai', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  const SizedBox(height: 2),
                  Text(CurrencyFormat.formatRupiah(spentAmount),
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, 
                          color: isOverBudget ? Colors.red : Colors.black87)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(isOverBudget ? 'Over Budget' : 'Sisa',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  const SizedBox(height: 2),
                  Text(CurrencyFormat.formatRupiah(remaining.abs()),
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, 
                          color: isOverBudget ? Colors.red : color)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(isOverBudget ? Colors.red : color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: Colors.blue.shade700, fontSize: 16)),
          Expanded(child: Text(text, style: TextStyle(fontSize: 12, color: Colors.blue.shade900))),
        ],
      ),
    );
  }
}
