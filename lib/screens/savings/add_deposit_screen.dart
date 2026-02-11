import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/savings_provider.dart';
import '../../core/utils/currency_formatter.dart';

class AddDepositScreen extends StatefulWidget {
  final String savingsGoalId;

  const AddDepositScreen({super.key, required this.savingsGoalId});

  @override
  State<AddDepositScreen> createState() => _AddDepositScreenState();
}

class _AddDepositScreenState extends State<AddDepositScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Setoran')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Setoran',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                validator: (value) => value?.isEmpty ?? true ? 'Masukkan jumlah' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Catatan (opsional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveDeposit,
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveDeposit() async {
    if (_formKey.currentState!.validate()) {
      final amount = parseCurrency(_amountController.text);
      final note = _noteController.text.isEmpty ? 'Setoran' : _noteController.text;

      await context.read<SavingsProvider>().addDeposit(
        widget.savingsGoalId,
        amount,
        note,
      );

      if (mounted) Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}
