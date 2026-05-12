import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/cicilan_provider.dart';
import '../../models/cicilan_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';

class AddCicilanScreen extends StatefulWidget {
  const AddCicilanScreen({super.key});

  @override
  State<AddCicilanScreen> createState() => _AddCicilanScreenState();
}

class _AddCicilanScreenState extends State<AddCicilanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _monthlyAmountController = TextEditingController();
  final _descriptionController = TextEditingController();

  int _totalMonths = 12;
  int _paymentDay = 1;
  DateTime _startDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tambah Cicilan', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nama Cicilan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Contoh: Cicilan HP, KPR, Motor...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  prefixIcon: Icon(Icons.credit_card, color: AppColors.primary),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Masukkan nama cicilan' : null,
              ),
              const SizedBox(height: 20),
              const Text('Total Harga', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _totalAmountController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  prefixIcon: Icon(Icons.payments_outlined, color: AppColors.primary),
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                validator: (v) => v?.isEmpty ?? true ? 'Masukkan total harga' : null,
                onChanged: (_) => _autoFillMonthly(),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Jumlah Bulan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          value: _totalMonths,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            filled: true,
                            fillColor: const Color(0xFFF5F5F5),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          ),
                          items: [3, 6, 9, 12, 18, 24, 36, 48, 60]
                              .map((m) => DropdownMenuItem(value: m, child: Text('$m bulan')))
                              .toList(),
                          onChanged: (v) {
                            setState(() => _totalMonths = v!);
                            _autoFillMonthly();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tanggal Bayar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          value: _paymentDay,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            filled: true,
                            fillColor: const Color(0xFFF5F5F5),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          ),
                          items: List.generate(28, (i) => i + 1)
                              .map((d) => DropdownMenuItem(value: d, child: Text('Tgl $d')))
                              .toList(),
                          onChanged: (v) => setState(() => _paymentDay = v!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Cicilan per Bulan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _monthlyAmountController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  prefixIcon: Icon(Icons.payments_outlined, color: AppColors.primary),
                  prefixText: 'Rp ',
                  helperText: 'Otomatis terisi, bisa diubah manual',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                validator: (v) => v?.isEmpty ?? true ? 'Masukkan cicilan per bulan' : null,
              ),
              const SizedBox(height: 20),
              const Text('Tanggal Mulai', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _startDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) setState(() => _startDate = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Text('${_startDate.day}/${_startDate.month}/${_startDate.year}',
                          style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Keterangan (opsional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'Contoh: Cicilan HP Samsung di Akulaku',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  prefixIcon: Icon(Icons.notes_outlined, color: AppColors.primary),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Simpan Cicilan',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _autoFillMonthly() {
    final total = parseCurrency(_totalAmountController.text);
    if (total > 0 && _totalMonths > 0) {
      final monthly = (total / _totalMonths).roundToDouble();
      _monthlyAmountController.text = monthly
          .toStringAsFixed(0)
          .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final totalAmount = parseCurrency(_totalAmountController.text);
    final monthlyAmount = parseCurrency(_monthlyAmountController.text);

    // Hitung next payment date
    final now = DateTime.now();
    DateTime nextPayment;
    if (now.day <= _paymentDay) {
      nextPayment = DateTime(now.year, now.month, _paymentDay);
    } else {
      nextPayment = DateTime(now.year, now.month + 1, _paymentDay);
    }

    final cicilan = CicilanModel(
      id: '',
      userId: userId,
      name: _nameController.text.trim(),
      totalAmount: totalAmount,
      monthlyAmount: monthlyAmount,
      totalMonths: _totalMonths,
      paidMonths: 0,
      paymentDay: _paymentDay,
      startDate: _startDate,
      nextPaymentDate: nextPayment,
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
    );

    await context.read<CicilanProvider>().addCicilan(cicilan);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cicilan berhasil ditambahkan'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _totalAmountController.dispose();
    _monthlyAmountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
