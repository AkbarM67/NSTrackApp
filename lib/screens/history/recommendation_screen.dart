import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/transaction_provider.dart';
import '../../core/utils/period_helper.dart';
import '../../core/utils/currency_format.dart';

class RecommendationScreen extends StatelessWidget {
  const RecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analisis & Rekomendasi')),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          final periodTransactions = provider.currentPeriodTransactions;
          final expenses = periodTransactions.where((t) => t.type == 'expense').toList();

          if (expenses.isEmpty) {
            return const Center(child: Text('Belum ada data pengeluaran'));
          }

          // Group by category
          final categoryData = <String, double>{};
          for (var t in expenses) {
            categoryData[t.category] = (categoryData[t.category] ?? 0) + t.amount;
          }

          final totalExpense = categoryData.values.fold(0.0, (a, b) => a + b);
          final sortedCategories = categoryData.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Periode: ${PeriodHelper.getPeriodLabel(PeriodHelper.getCurrentPeriodStart())}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                _buildPieChart(categoryData, totalExpense),
                const SizedBox(height: 24),
                _buildCategoryList(sortedCategories, totalExpense),
                const SizedBox(height: 24),
                _buildRecommendations(sortedCategories, totalExpense),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPieChart(Map<String, double> categoryData, double total) {
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
          children: [
            const Text(
              'Distribusi Pengeluaran',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: categoryData.entries.toList().asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    final percentage = (data.value / total * 100);
                    return PieChartSectionData(
                      value: data.value,
                      title: '${percentage.toStringAsFixed(1)}%',
                      color: colors[index % colors.length],
                      radius: 100,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(List<MapEntry<String, double>> categories, double total) {
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
              'Detail per Kategori',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...categories.asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value;
              final percentage = (category.value / total * 100);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: colors[index % colors.length],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            category.key,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          CurrencyFormat.formatRupiah(category.value),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const SizedBox(width: 24),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: Colors.grey[200],
                            color: colors[index % colors.length],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations(List<MapEntry<String, double>> categories, double total) {
    final recommendations = <String>[];

    if (categories.isNotEmpty) {
      final topCategory = categories.first;
      final topPercentage = (topCategory.value / total * 100);

      if (topPercentage > 40) {
        recommendations.add(
          '💡 ${topCategory.key} menghabiskan ${topPercentage.toStringAsFixed(0)}% dari total pengeluaran. Pertimbangkan untuk mengurangi pengeluaran di kategori ini.',
        );
      }

      // Check for Makanan
      final foodEntry = categories.firstWhere(
        (e) => e.key == 'Makanan',
        orElse: () => const MapEntry('', 0),
      );
      if (foodEntry.value > 0) {
        final foodPercentage = (foodEntry.value / total * 100);
        if (foodPercentage > 30) {
          recommendations.add(
            '🍽️ Pengeluaran makanan cukup tinggi (${foodPercentage.toStringAsFixed(0)}%). Coba masak di rumah lebih sering untuk menghemat.',
          );
        }
      }

      // Check for Transport
      final transportEntry = categories.firstWhere(
        (e) => e.key == 'Transport',
        orElse: () => const MapEntry('', 0),
      );
      if (transportEntry.value > 0) {
        final transportPercentage = (transportEntry.value / total * 100);
        if (transportPercentage > 20) {
          recommendations.add(
            '🚗 Biaya transport ${transportPercentage.toStringAsFixed(0)}% dari pengeluaran. Pertimbangkan transportasi umum atau carpool.',
          );
        }
      }

      // Check for Hiburan
      final entertainmentEntry = categories.firstWhere(
        (e) => e.key == 'Hiburan',
        orElse: () => const MapEntry('', 0),
      );
      if (entertainmentEntry.value > 0) {
        final entertainmentPercentage = (entertainmentEntry.value / total * 100);
        if (entertainmentPercentage > 15) {
          recommendations.add(
            '🎮 Pengeluaran hiburan ${entertainmentPercentage.toStringAsFixed(0)}%. Cari alternatif hiburan gratis atau lebih murah.',
          );
        }
      }

      // General recommendation
      if (recommendations.isEmpty) {
        recommendations.add(
          '✅ Pengeluaran Anda cukup seimbang! Pertahankan pola pengeluaran ini.',
        );
      }

      recommendations.add(
        '💰 Tips: Gunakan aturan 50/30/20 - 50% kebutuhan, 30% keinginan, 20% tabungan.',
      );
    }

    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Rekomendasi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...recommendations.map((rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(rec, style: const TextStyle(fontSize: 14)),
                )),
          ],
        ),
      ),
    );
  }
}
