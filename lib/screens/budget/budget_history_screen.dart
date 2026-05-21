import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/period_settings_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_format.dart';
import '../../core/utils/period_helper.dart';

class BudgetHistoryScreen extends StatelessWidget {
  const BudgetHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History Budget', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Consumer3<TransactionProvider, BudgetProvider, PeriodSettingsProvider>(
        builder: (context, transactionProvider, budgetProvider, periodProvider, _) {
          final budget = budgetProvider.budget;
          final periods = PeriodHelper.getAvailablePeriods(
            transactionProvider.transactions,
            startDay: periodProvider.startDay,
          );

          if (budget == null) {
            return const Center(child: Text('Belum ada budget yang diatur'));
          }

          if (periods.isEmpty) {
            return const Center(child: Text('Belum ada riwayat transaksi'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: periods.length,
            itemBuilder: (context, index) {
              final periodStart = periods[index];
              final transactions = PeriodHelper.getTransactionsForPeriod(
                transactionProvider.transactions,
                periodStart,
                endDay: periodProvider.endDay,
              );

              final needsSpent = budgetProvider.getNeedsSpent(transactions);
              final wantsSpent = budgetProvider.getWantsSpent(transactions);
              final savingsSpent = budgetProvider.getSavingsSpent(transactions);
              final cicilanSpent = budgetProvider.getCicilanSpent(transactions);
              final isCurrentPeriod = periodStart.year == PeriodHelper.getCurrentPeriodStart().year &&
                  periodStart.month == PeriodHelper.getCurrentPeriodStart().month;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isCurrentPeriod ? AppColors.primary : Colors.grey.shade200,
                    width: isCurrentPeriod ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            PeriodHelper.getPeriodLabel(periodStart, endDay: periodProvider.endDay),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (isCurrentPeriod)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Aktif', style: TextStyle(color: Colors.white, fontSize: 10)),
                          ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          _buildMiniChip(
                            'Kebutuhan',
                            needsSpent,
                            budget.needsAmount,
                            Colors.blue,
                          ),
                          const SizedBox(width: 6),
                          _buildMiniChip(
                            'Keinginan',
                            wantsSpent,
                            budget.wantsAmount,
                            Colors.orange,
                          ),
                          const SizedBox(width: 6),
                          _buildMiniChip(
                            'Tabungan',
                            savingsSpent,
                            budget.savingsAmount,
                            Colors.green,
                          ),
                        ],
                      ),
                    ),
                    children: [
                      const Divider(),
                      const SizedBox(height: 8),
                      _buildHistoryRow(
                        icon: Icons.home_outlined,
                        color: Colors.blue,
                        title: 'Kebutuhan',
                        subtitle: 'Makanan, Transport, Cicilan',
                        spent: needsSpent,
                        budget: budget.needsAmount,
                        cicilanSpent: cicilanSpent,
                      ),
                      const SizedBox(height: 12),
                      _buildHistoryRow(
                        icon: Icons.shopping_bag_outlined,
                        color: Colors.orange,
                        title: 'Keinginan',
                        subtitle: 'Belanja, Hiburan',
                        spent: wantsSpent,
                        budget: budget.wantsAmount,
                      ),
                      const SizedBox(height: 12),
                      _buildHistoryRow(
                        icon: Icons.savings_outlined,
                        color: Colors.green,
                        title: 'Tabungan',
                        subtitle: 'Nabung',
                        spent: savingsSpent,
                        budget: budget.savingsAmount,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Pengeluaran',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            Text(
                              CurrencyFormat.formatRupiah(needsSpent + wantsSpent + savingsSpent),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMiniChip(String label, double spent, double budget, Color color) {
    final isOver = spent > budget;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isOver ? Colors.red.shade50 : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '${(budget > 0 ? (spent / budget * 100).clamp(0, 999) : 0).toStringAsFixed(0)}%',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isOver ? Colors.red : color,
        ),
      ),
    );
  }

  Widget _buildHistoryRow({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required double spent,
    required double budget,
    double cicilanSpent = 0,
  }) {
    final progress = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
    final isOver = spent > budget;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyFormat.formatRupiah(spent),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isOver ? Colors.red : Colors.black87,
                  ),
                ),
                Text(
                  'dari ${CurrencyFormat.formatRupiah(budget)}',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(isOver ? Colors.red : color),
          ),
        ),
        if (cicilanSpent > 0) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.credit_card, size: 11, color: Colors.orange.shade600),
              const SizedBox(width: 4),
              Text(
                'Termasuk cicilan: ${CurrencyFormat.formatRupiah(cicilanSpent)}',
                style: TextStyle(fontSize: 10, color: Colors.orange.shade700),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
