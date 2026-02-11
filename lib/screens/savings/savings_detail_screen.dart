import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../providers/savings_provider.dart';
import '../../models/savings_goal_model.dart';
import '../../core/utils/currency_format.dart';
import 'add_deposit_screen.dart';
import 'edit_savings_goal_screen.dart';

class SavingsDetailScreen extends StatefulWidget {
  final SavingsGoalModel goal;

  const SavingsDetailScreen({super.key, required this.goal});

  @override
  State<SavingsDetailScreen> createState() => _SavingsDetailScreenState();
}

class _SavingsDetailScreenState extends State<SavingsDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SavingsProvider>().listenDeposits(widget.goal.id);
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.goal.currentAmount / widget.goal.targetAmount;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.goal.goalName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditSavingsGoalScreen(goal: widget.goal),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Hapus Tabungan'),
                  content: Text('Hapus "${widget.goal.goalName}" dan semua setorannya?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await context.read<SavingsProvider>().deleteSavingsGoal(widget.goal.id);
                        if (context.mounted) {
                          Navigator.pop(context);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Tabungan dihapus')),
                          );
                        }
                      },
                      child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (widget.goal.photoUrl != null)
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(File(widget.goal.photoUrl!)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.blue[50],
              child: Column(
                children: [
                  if (widget.goal.description != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lightbulb_outline, color: Colors.orange),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.goal.description!,
                              style: const TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Text('Target: ${CurrencyFormat.formatRupiah(widget.goal.targetAmount)}',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Terkumpul: ${CurrencyFormat.formatRupiah(widget.goal.currentAmount)}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: progress, minHeight: 8),
                  const SizedBox(height: 8),
                  Text('${(progress * 100).toStringAsFixed(1)}% tercapai'),
                  const SizedBox(height: 12),
                  Text('Rekomendasi per bulan: ${CurrencyFormat.formatRupiah(widget.goal.monthlyRecommendation)}',
                      style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('History Setoran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            Consumer<SavingsProvider>(
              builder: (context, provider, _) {
                if (provider.deposits.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: Text('Belum ada setoran')),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.deposits.length,
                  itemBuilder: (context, index) {
                    final deposit = provider.deposits[index];
                    return Dismissible(
                      key: Key(deposit.id),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Hapus Setoran'),
                            content: const Text('Hapus setoran ini?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Batal'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (direction) async {
                        await context.read<SavingsProvider>().deleteDeposit(
                          widget.goal.id,
                          deposit.id,
                          deposit.amount,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Setoran dihapus')),
                          );
                        }
                      },
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.savings),
                        ),
                        title: Text(CurrencyFormat.formatRupiah(deposit.amount),
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(deposit.note),
                        trailing: Text(
                          '${deposit.date.day}/${deposit.date.month}/${deposit.date.year}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddDepositScreen(savingsGoalId: widget.goal.id),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Setoran'),
      ),
    );
  }
}
