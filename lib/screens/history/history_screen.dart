import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/savings_provider.dart';
import '../../core/services/excel_service.dart';
import '../../core/services/google_sheets_import_service.dart';
import '../../core/utils/currency_format.dart';
import '../../models/transaction_model.dart';
import 'period_history_screen.dart';
import 'recommendation_screen.dart';

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
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RecommendationScreen()),
              );
            },
            tooltip: 'Analisis & Rekomendasi',
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PeriodHistoryScreen()),
              );
            },
            tooltip: 'Riwayat Periode',
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.file_download, size: 20),
                    SizedBox(width: 8),
                    Text('Export ke Excel'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.file_upload, size: 20),
                    SizedBox(width: 8),
                    Text('Import dari Excel'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'import_sheets',
                child: Row(
                  children: [
                    Icon(Icons.cloud_download, size: 20),
                    SizedBox(width: 8),
                    Text('Import dari Google Sheets'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'export') _exportToExcel();
              if (value == 'import') _importFromExcel();
              if (value == 'import_sheets') _importFromGoogleSheets();
            },
          ),
        ],
      ),
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
                      'Saldo Bulan Ini',
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

  void _exportToExcel() async {
    final provider = context.read<TransactionProvider>();
    final excelService = ExcelService();
    
    final filePath = await excelService.exportTransactions(provider.transactions);
    
    if (mounted) {
      if (filePath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File tersimpan: $filePath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal export data'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _importFromExcel() async {
    final excelService = ExcelService();
    final data = await excelService.importTransactions();
    
    if (data == null || data.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak ada data untuk diimport'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final provider = context.read<TransactionProvider>();
    int successCount = 0;

    for (var item in data) {
      try {
        final transaction = TransactionModel(
          id: '',
          userId: userId,
          type: item['type'],
          amount: item['amount'],
          category: item['category'],
          description: item['description'],
          date: item['date'],
        );
        await provider.addTransaction(transaction);
        successCount++;
      } catch (e) {
        continue;
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Berhasil import $successCount transaksi'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _importFromGoogleSheets() async {
    // Dialog untuk input Spreadsheet ID dan Sheet Name
    final spreadsheetIdController = TextEditingController();
    final sheetNameController = TextEditingController(text: 'Sheet1');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import dari Google Sheets'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Masukkan Spreadsheet ID dari URL Google Sheets Anda',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: spreadsheetIdController,
                decoration: const InputDecoration(
                  labelText: 'Spreadsheet ID',
                  hintText: '1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: sheetNameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Sheet',
                  hintText: 'Sheet1',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Pastikan sheet sudah di-share "Anyone with the link"',
                style: TextStyle(fontSize: 11, color: Colors.orange),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Import'),
          ),
        ],
      ),
    );

    if (result != true) return;

    final spreadsheetId = spreadsheetIdController.text.trim();
    final sheetName = sheetNameController.text.trim();

    if (spreadsheetId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Spreadsheet ID tidak boleh kosong'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final data = await GoogleSheetsImportService.importFromSheet(
      spreadsheetId,
      sheetName,
    );

    if (mounted) Navigator.pop(context); // Close loading

    if (data == null || data.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal import atau tidak ada data'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final provider = context.read<TransactionProvider>();
    int successCount = 0;

    for (var item in data) {
      try {
        final transaction = TransactionModel(
          id: '',
          userId: userId,
          type: item['type'],
          amount: item['amount'],
          category: item['category'],
          description: item['description'],
          date: item['date'],
        );
        await provider.addTransaction(transaction);
        successCount++;
      } catch (e) {
        continue;
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Berhasil import $successCount transaksi dari Google Sheets'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}