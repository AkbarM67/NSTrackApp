import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/budget_provider.dart';
import '../../models/budget_model.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/constants/app_colors.dart';

class SetBudgetScreen extends StatefulWidget {
  final BudgetModel? budget;
  
  const SetBudgetScreen({super.key, this.budget});

  @override
  State<SetBudgetScreen> createState() => _SetBudgetScreenState();
}

class _SetBudgetScreenState extends State<SetBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _incomeController = TextEditingController();
  
  double _needsPercentage = 50;
  double _wantsPercentage = 30;
  double _savingsPercentage = 20;

  @override
  void initState() {
    super.initState();
    if (widget.budget != null) {
      _incomeController.text = widget.budget!.monthlyIncome.toStringAsFixed(0);
      _needsPercentage = widget.budget!.needsPercentage;
      _wantsPercentage = widget.budget!.wantsPercentage;
      _savingsPercentage = widget.budget!.savingsPercentage;
    }
  }

  @override
  Widget build(BuildContext context) {
    final income = parseCurrency(_incomeController.text);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.budget == null ? 'Atur Budget' : 'Edit Budget',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pendapatan Bulanan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _incomeController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  prefixIcon: Icon(Icons.payments_outlined, color: AppColors.primary),
                  prefixText: 'Rp ',
                  hintText: '0',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                validator: (value) => value?.isEmpty ?? true ? 'Masukkan pendapatan' : null,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 32),
              const Text('Alokasi Budget', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const Text('Sesuaikan persentase sesuai kebutuhan',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 20),
              _buildSlider(
                title: 'Kebutuhan',
                subtitle: 'Makanan, Transport',
                icon: Icons.home_outlined,
                color: Colors.blue,
                value: _needsPercentage,
                amount: income * (_needsPercentage / 100),
                onChanged: (val) {
                  setState(() {
                    _needsPercentage = val;
                    _adjustPercentages();
                  });
                },
              ),
              const SizedBox(height: 20),
              _buildSlider(
                title: 'Keinginan',
                subtitle: 'Belanja, Hiburan',
                icon: Icons.shopping_bag_outlined,
                color: Colors.orange,
                value: _wantsPercentage,
                amount: income * (_wantsPercentage / 100),
                onChanged: (val) {
                  setState(() {
                    _wantsPercentage = val;
                    _adjustPercentages();
                  });
                },
              ),
              const SizedBox(height: 20),
              _buildSlider(
                title: 'Tabungan',
                subtitle: 'Nabung',
                icon: Icons.savings_outlined,
                color: Colors.green,
                value: _savingsPercentage,
                amount: income * (_savingsPercentage / 100),
                onChanged: (val) {
                  setState(() {
                    _savingsPercentage = val;
                    _adjustPercentages();
                  });
                },
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Alokasi', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text(
                      '${(_needsPercentage + _wantsPercentage + _savingsPercentage).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: (_needsPercentage + _wantsPercentage + _savingsPercentage) == 100
                            ? AppColors.primary
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveBudget,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Simpan Budget',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlider({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required double value,
    required double amount,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Text('${value.toInt()}%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: color.withOpacity(0.2),
              thumbColor: color,
              overlayColor: color.withOpacity(0.2),
              trackHeight: 6,
            ),
            child: Slider(
              value: value,
              min: 0,
              max: 100,
              divisions: 20,
              onChanged: onChanged,
            ),
          ),
          Text('Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  void _adjustPercentages() {
    final total = _needsPercentage + _wantsPercentage + _savingsPercentage;
    if (total > 100) {
      final excess = total - 100;
      if (_needsPercentage >= excess) {
        _needsPercentage -= excess;
      } else if (_wantsPercentage >= excess) {
        _wantsPercentage -= excess;
      } else {
        _savingsPercentage -= excess;
      }
    }
  }

  void _saveBudget() async {
    if (_formKey.currentState!.validate()) {
      final total = _needsPercentage + _wantsPercentage + _savingsPercentage;
      if (total != 100) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Total alokasi harus 100%'), backgroundColor: Colors.red),
        );
        return;
      }

      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final budget = BudgetModel(
        id: widget.budget?.id ?? '',
        userId: userId,
        monthlyIncome: parseCurrency(_incomeController.text),
        needsPercentage: _needsPercentage,
        wantsPercentage: _wantsPercentage,
        savingsPercentage: _savingsPercentage,
        createdAt: widget.budget?.createdAt ?? DateTime.now(),
      );

      try {
        await context.read<BudgetProvider>().saveBudget(budget);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Budget berhasil disimpan'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _incomeController.dispose();
    super.dispose();
  }
}
