import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/savings_provider.dart';
import '../../models/savings_goal_model.dart';
import '../../core/utils/currency_formatter.dart';

class EditSavingsGoalScreen extends StatefulWidget {
  final SavingsGoalModel goal;

  const EditSavingsGoalScreen({super.key, required this.goal});

  @override
  State<EditSavingsGoalScreen> createState() => _EditSavingsGoalScreenState();
}

class _EditSavingsGoalScreenState extends State<EditSavingsGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _goalNameController;
  late TextEditingController _targetAmountController;
  late DateTime _targetDate;

  @override
  void initState() {
    super.initState();
    _goalNameController = TextEditingController(text: widget.goal.goalName);
    _targetAmountController = TextEditingController(
      text: widget.goal.targetAmount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      ),
    );
    _targetDate = widget.goal.targetDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Target Tabungan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _goalNameController,
                decoration: const InputDecoration(
                  labelText: 'Tujuan Tabungan',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Masukkan tujuan' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _targetAmountController,
                decoration: const InputDecoration(
                  labelText: 'Target Jumlah',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                validator: (value) => value?.isEmpty ?? true ? 'Masukkan target' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Target Tanggal'),
                subtitle: Text('${_targetDate.day}/${_targetDate.month}/${_targetDate.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _targetDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                  );
                  if (date != null) {
                    setState(() => _targetDate = date);
                  }
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateGoal,
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                child: const Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateGoal() async {
    if (_formKey.currentState!.validate()) {
      final targetAmount = parseCurrency(_targetAmountController.text);
      final monthlyRec = context.read<SavingsProvider>()
          .calculateMonthlyRecommendation(targetAmount, _targetDate);

      await context.read<SavingsProvider>().updateSavingsGoal(
        widget.goal.id,
        {
          'goalName': _goalNameController.text,
          'targetAmount': targetAmount,
          'targetDate': _targetDate.toIso8601String(),
          'monthlyRecommendation': monthlyRec,
        },
      );

      if (mounted) Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _goalNameController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }
}
