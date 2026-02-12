import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/transaction_provider.dart';
import '../../core/utils/period_helper.dart';
import '../../core/utils/currency_format.dart';

class PeriodHistoryScreen extends StatefulWidget {
  const PeriodHistoryScreen({super.key});

  @override
  State<PeriodHistoryScreen> createState() => _PeriodHistoryScreenState();
}

class _PeriodHistoryScreenState extends State<PeriodHistoryScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<DateTime> _periods = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPeriods();
    });
  }

  void _loadPeriods() {
    final provider = context.read<TransactionProvider>();
    final periods = PeriodHelper.getAvailablePeriods(provider.transactions);
    
    setState(() {
      _periods = periods;
      _tabController = TabController(length: periods.length, vsync: this);
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_periods.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Riwayat Periode')),
        body: const Center(child: Text('Belum ada riwayat transaksi')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Periode'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _periods.map((period) {
            return Tab(text: PeriodHelper.getPeriodLabel(period));
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _periods.map((period) => _buildPeriodView(period)).toList(),
      ),
    );
  }

  Widget _buildPeriodView(DateTime periodStart) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        final transactions = PeriodHelper.getTransactionsForPeriod(
          provider.transactions,
          periodStart,
        );

        final income = transactions
            .where((t) => t.type == 'income')
            .fold(0.0, (sum, t) => sum + t.amount);
        final expense = transactions
            .where((t) => t.type == 'expense')
            .fold(0.0, (sum, t) => sum + t.amount);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSummaryCards(income, expense),
              const SizedBox(height: 20),
              _buildCategoryAnalysis(transactions),
              const SizedBox(height: 20),
              _buildTransactionList(transactions),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards(double income, double expense) {
    final balance = income - expense;
    return Column(
      children: [
        Card(
          color: Colors.blue[50],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Saldo Periode',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormat.formatRupiah(balance),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: balance >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: balance >= 0 ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    balance >= 0 ? Icons.trending_up : Icons.trending_down,
                    color: balance >= 0 ? Colors.green : Colors.red,
                    size: 32,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.arrow_downward, color: Colors.green, size: 16),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Pemasukan',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        CurrencyFormat.formatRupiah(income),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.arrow_upward, color: Colors.red, size: 16),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Pengeluaran',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        CurrencyFormat.formatRupiah(expense),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryAnalysis(List transactions) {
    final expenses = transactions.where((t) => t.type == 'expense').toList();
    
    if (expenses.isEmpty) {
      return const SizedBox.shrink();
    }

    final categoryData = <String, double>{};
    for (var t in expenses) {
      categoryData[t.category] = (categoryData[t.category] ?? 0) + t.amount;
    }

    final total = categoryData.values.fold(0.0, (a, b) => a + b);
    final sortedCategories = categoryData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final colors = [
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.brown,
      Colors.teal,
      Colors.indigo,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analisis Pengeluaran',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: sortedCategories.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    final percentage = (data.value / total * 100);
                    return PieChartSectionData(
                      value: data.value,
                      title: '${percentage.toStringAsFixed(0)}%',
                      color: colors[index % colors.length],
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...sortedCategories.take(5).toList().asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value;
              final percentage = (category.value / total * 100);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colors[index % colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        category.key,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      CurrencyFormat.formatRupiah(category.value),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (sortedCategories.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '+ ${sortedCategories.length - 5} kategori lainnya',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(List transactions) {
    if (transactions.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('Tidak ada transaksi')),
        ),
      );
    }

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: transactions.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: transaction.type == 'income' 
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              child: Icon(
                transaction.type == 'income' 
                    ? Icons.arrow_downward 
                    : Icons.arrow_upward,
                color: transaction.type == 'income' ? Colors.green : Colors.red,
              ),
            ),
            title: Text(transaction.description),
            subtitle: Text(
              '${transaction.category} • ${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Text(
              CurrencyFormat.formatRupiah(transaction.amount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: transaction.type == 'income' ? Colors.green : Colors.red,
              ),
            ),
          );
        },
      ),
    );
  }
}
