import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/savings_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool isMonthly = true;
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      context.read<TransactionProvider>().listenTransactions(userId);
      context.read<SavingsProvider>().listenSavingsGoals(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('Bulanan')),
                    ButtonSegment(value: false, label: Text('Tahunan')),
                  ],
                  selected: {isMonthly},
                  onSelectionChanged: (Set<bool> newSelection) {
                    setState(() => isMonthly = newSelection.first);
                  },
                ),
                const SizedBox(height: 20),
                if (isMonthly) _buildMonthlyView(provider) else _buildYearlyView(provider),
                const SizedBox(height: 20),
                _buildSavingsChart(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthlyView(TransactionProvider provider) {
    final transactions = provider.getTransactionsByMonth(selectedYear, selectedMonth);
    final income = transactions.where((t) => t.type == 'income').fold(0.0, (sum, t) => sum + t.amount);
    final expense = transactions.where((t) => t.type == 'expense').fold(0.0, (sum, t) => sum + t.amount);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                setState(() {
                  if (selectedMonth == 1) {
                    selectedMonth = 12;
                    selectedYear--;
                  } else {
                    selectedMonth--;
                  }
                });
              },
            ),
            Text('${_getMonthName(selectedMonth)} $selectedYear', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () {
                setState(() {
                  if (selectedMonth == 12) {
                    selectedMonth = 1;
                    selectedYear++;
                  } else {
                    selectedMonth++;
                  }
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildSummaryCards(income, expense),
        const SizedBox(height: 20),
        _buildMonthlyChart(provider),
        const SizedBox(height: 20),
        _buildPieChart(provider),
      ],
    );
  }

  Widget _buildYearlyView(TransactionProvider provider) {
    final transactions = provider.getTransactionsByYear(selectedYear);
    final income = transactions.where((t) => t.type == 'income').fold(0.0, (sum, t) => sum + t.amount);
    final expense = transactions.where((t) => t.type == 'expense').fold(0.0, (sum, t) => sum + t.amount);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => setState(() => selectedYear--),
            ),
            Text('$selectedYear', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () => setState(() => selectedYear++),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildSummaryCards(income, expense),
        const SizedBox(height: 20),
        _buildYearlyChart(provider),
        const SizedBox(height: 20),
        _buildPieChart(provider),
      ],
    );
  }

  Widget _buildSummaryCards(double income, double expense) {
    return Row(
      children: [
        Expanded(
          child: Card(
            color: Colors.green[100],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('Pemasukan', style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 8),
                  Text('Rp ${income.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Card(
            color: Colors.red[100],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('Pengeluaran', style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 8),
                  Text('Rp ${expense.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyChart(TransactionProvider provider) {
    final daysInMonth = DateTime(selectedYear, selectedMonth + 1, 0).day;
    final incomeData = <int, double>{};
    final expenseData = <int, double>{};

    for (var day = 1; day <= daysInMonth; day++) {
      incomeData[day] = 0;
      expenseData[day] = 0;
    }

    final transactions = provider.getTransactionsByMonth(selectedYear, selectedMonth);
    for (var t in transactions) {
      if (t.type == 'income') {
        incomeData[t.date.day] = (incomeData[t.date.day] ?? 0) + t.amount;
      } else {
        expenseData[t.date.day] = (expenseData[t.date.day] ?? 0) + t.amount;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Grafik Harian', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 5,
                        getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(fontSize: 10)),
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: incomeData.entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: expenseData.entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 20, height: 10, color: Colors.green),
                const SizedBox(width: 5),
                const Text('Pemasukan', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 20),
                Container(width: 20, height: 10, color: Colors.red),
                const SizedBox(width: 5),
                const Text('Pengeluaran', style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearlyChart(TransactionProvider provider) {
    final incomeData = <int, double>{};
    final expenseData = <int, double>{};

    for (var month = 1; month <= 12; month++) {
      incomeData[month] = 0;
      expenseData[month] = 0;
    }

    final transactions = provider.getTransactionsByYear(selectedYear);
    for (var t in transactions) {
      if (t.type == 'income') {
        incomeData[t.date.month] = (incomeData[t.date.month] ?? 0) + t.amount;
      } else {
        expenseData[t.date.month] = (expenseData[t.date.month] ?? 0) + t.amount;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Grafik Bulanan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const months = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
                          return Text(months[value.toInt() - 1], style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  barGroups: List.generate(12, (index) {
                    final month = index + 1;
                    return BarChartGroupData(
                      x: month,
                      barRods: [
                        BarChartRodData(toY: incomeData[month]!, color: Colors.green, width: 8),
                        BarChartRodData(toY: expenseData[month]!, color: Colors.red, width: 8),
                      ],
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 20, height: 10, color: Colors.green),
                const SizedBox(width: 5),
                const Text('Pemasukan', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 20),
                Container(width: 20, height: 10, color: Colors.red),
                const SizedBox(width: 5),
                const Text('Pengeluaran', style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 
                    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return months[month - 1];
  }

  Widget _buildPieChart(TransactionProvider provider) {
    final transactions = isMonthly 
        ? provider.getTransactionsByMonth(selectedYear, selectedMonth)
        : provider.getTransactionsByYear(selectedYear);

    final categoryData = <String, double>{};
    for (var t in transactions.where((t) => t.type == 'expense')) {
      categoryData[t.category] = (categoryData[t.category] ?? 0) + t.amount;
    }

    if (categoryData.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('Belum ada data pengeluaran')),
        ),
      );
    }

    final colors = [Colors.red, Colors.orange, Colors.purple, Colors.pink, Colors.brown];
    int colorIndex = 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Pengeluaran per Kategori', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: categoryData.entries.map((e) {
                    final color = colors[colorIndex % colors.length];
                    colorIndex++;
                    return PieChartSectionData(
                      value: e.value,
                      title: '${(e.value / categoryData.values.fold(0.0, (a, b) => a + b) * 100).toStringAsFixed(0)}%',
                      color: color,
                      radius: 80,
                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 5,
              children: categoryData.entries.map((e) {
                final color = colors[(categoryData.keys.toList().indexOf(e.key)) % colors.length];
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 16, height: 16, color: color),
                    const SizedBox(width: 5),
                    Text('${e.key}: Rp ${e.value.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11)),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

  Widget _buildSavingsChart() {
    return Consumer<SavingsProvider>(
      builder: (context, provider, _) {
        if (provider.savingsGoals.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: Text('Belum ada target tabungan')),
            ),
          );
        }

        final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.pink];

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('Progress Tabungan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: provider.savingsGoals.asMap().entries.map((entry) {
                        final index = entry.key;
                        final goal = entry.value;
                        final progress = (goal.currentAmount / goal.targetAmount * 100).toStringAsFixed(0);
                        return PieChartSectionData(
                          value: goal.currentAmount,
                          title: '${goal.goalName}\n$progress%',
                          color: colors[index % colors.length],
                          radius: 80,
                          titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                        );
                      }).toList(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 5,
                  children: provider.savingsGoals.asMap().entries.map((entry) {
                    final index = entry.key;
                    final goal = entry.value;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 16, height: 16, color: colors[index % colors.length]),
                        const SizedBox(width: 5),
                        Text('${goal.goalName}: Rp ${goal.currentAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11)),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }