import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/cicilan_provider.dart';
import '../../models/cicilan_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_format.dart';
import 'add_cicilan_screen.dart';

class CicilanScreen extends StatefulWidget {
  const CicilanScreen({super.key});

  @override
  State<CicilanScreen> createState() => _CicilanScreenState();
}

class _CicilanScreenState extends State<CicilanScreen> {
  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      context.read<CicilanProvider>().listenCicilan(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CicilanProvider>(
      builder: (context, provider, _) {
        if (provider.cicilanList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.credit_card_outlined, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text('Belum ada cicilan', style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 8),
                Text('Tambah cicilan untuk pantau pembayaran', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (provider.activeCicilan.isNotEmpty) ...[
              const Text('Aktif', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              ...provider.activeCicilan.map((c) => _buildCicilanCard(context, c, provider)),
            ],
            if (provider.completedCicilan.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Selesai', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              ...provider.completedCicilan.map((c) => _buildCicilanCard(context, c, provider)),
            ],
          ],
        );
      },
    );
  }

  Widget _buildCicilanCard(BuildContext context, CicilanModel cicilan, CicilanProvider provider) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cicilan.isCompleted ? Colors.grey.shade200 : Colors.transparent),
        boxShadow: cicilan.isCompleted ? [] : [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cicilan.isCompleted ? Colors.grey.shade100 : const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.credit_card,
                    color: cicilan.isCompleted ? Colors.grey : AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cicilan.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      if (cicilan.description != null)
                        Text(cicilan.description!, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                if (cicilan.isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                    child: const Text('Lunas', style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
                  )
                else
                  PopupMenuButton(
                    icon: Icon(Icons.more_vert, color: Colors.grey.shade400),
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'bayar', child: Row(children: [Icon(Icons.check_circle_outline, size: 18), SizedBox(width: 8), Text('Bayar Bulan Ini')])),
                      const PopupMenuItem(value: 'hapus', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: Colors.red), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: Colors.red))])),
                    ],
                    onSelected: (value) {
                      if (value == 'bayar') _confirmBayar(context, cicilan, provider);
                      if (value == 'hapus') _confirmHapus(context, cicilan, provider);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Per Bulan', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    const SizedBox(height: 2),
                    Text(CurrencyFormat.formatRupiah(cicilan.monthlyAmount),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Sisa', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    const SizedBox(height: 2),
                    Text('${cicilan.remainingMonths} bulan',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: cicilan.progress.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  cicilan.isCompleted ? Colors.green : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${cicilan.paidMonths}/${cicilan.totalMonths} bulan terbayar',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                Text(CurrencyFormat.formatRupiah(cicilan.remainingAmount),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
            if (!cicilan.isCompleted && cicilan.nextPaymentDate != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _isPaymentSoon(cicilan.nextPaymentDate!) ? Colors.orange.shade50 : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.event_note,
                      size: 16,
                      color: _isPaymentSoon(cicilan.nextPaymentDate!) ? Colors.orange : Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Bayar tgl ${cicilan.nextPaymentDate!.day} ${months[cicilan.nextPaymentDate!.month - 1]} ${cicilan.nextPaymentDate!.year}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _isPaymentSoon(cicilan.nextPaymentDate!) ? Colors.orange.shade700 : Colors.blue.shade700,
                      ),
                    ),
                    if (_isPaymentSoon(cicilan.nextPaymentDate!)) ...[
                      const Spacer(),
                      Text('Segera!', style: TextStyle(fontSize: 11, color: Colors.orange.shade700, fontWeight: FontWeight.bold)),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _isPaymentSoon(DateTime date) {
    final diff = date.difference(DateTime.now()).inDays;
    return diff <= 7 && diff >= 0;
  }

  void _confirmBayar(BuildContext context, CicilanModel cicilan, CicilanProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Bayar Cicilan'),
        content: Text(
          'Bayar cicilan ${cicilan.name} sebesar ${CurrencyFormat.formatRupiah(cicilan.monthlyAmount)}?\n\nAkan otomatis tercatat sebagai pengeluaran.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.bayarCicilan(cicilan.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cicilan berhasil dibayar'), backgroundColor: Colors.green),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Bayar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmHapus(BuildContext context, CicilanModel cicilan, CicilanProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Cicilan'),
        content: Text('Yakin ingin menghapus cicilan ${cicilan.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.deleteCicilan(cicilan.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
