import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/period_settings_provider.dart';
import '../../core/constants/app_colors.dart';

class PeriodSettingsScreen extends StatefulWidget {
  const PeriodSettingsScreen({super.key});

  @override
  State<PeriodSettingsScreen> createState() => _PeriodSettingsScreenState();
}

class _PeriodSettingsScreenState extends State<PeriodSettingsScreen> {
  late int _startDay;
  late int _endDay;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final settings = context.read<PeriodSettingsProvider>().settings;
    _startDay = settings.startDay;
    _endDay = settings.endDay;
  }

  String _previewLabel() {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final now = DateTime.now();
    return '$_startDay ${months[now.month - 1]} - $_endDay ${months[now.month % 12]} ${now.year}';
  }

  Future<void> _save() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    setState(() => _saving = true);
    try {
      await context.read<PeriodSettingsProvider>().saveSettings(userId, _startDay, _endDay);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengaturan periode disimpan'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Pengaturan Periode', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Periode menentukan rentang waktu perhitungan pemasukan & pengeluaran kamu.',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Tanggal Mulai Periode', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('Setiap bulan periode dimulai tanggal ini', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            const SizedBox(height: 12),
            _buildDayPicker(
              selected: _startDay,
              onChanged: (val) => setState(() => _startDay = val),
            ),
            const SizedBox(height: 28),
            const Text('Tanggal Akhir Periode', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('Setiap bulan periode berakhir tanggal ini', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            const SizedBox(height: 12),
            _buildDayPicker(
              selected: _endDay,
              onChanged: (val) => setState(() => _endDay = val),
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Preview Periode', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_month, size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        _previewLabel(),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Simpan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayPicker({required int selected, required ValueChanged<int> onChanged}) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(31, (i) {
        final day = i + 1;
        final isSelected = selected == day;
        return GestureDetector(
          onTap: () => onChanged(day),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.grey.shade300,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '$day',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ),
        );
      }),
    );
  }
}
