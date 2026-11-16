import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/services/firebase_service.dart';
import '../models/cicilan_model.dart';
import '../models/transaction_model.dart';

class CicilanProvider with ChangeNotifier {
  final FirebaseService _service = FirebaseService();

  List<CicilanModel> _cicilanList = [];
  List<CicilanModel> get cicilanList => _cicilanList;
  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  List<CicilanModel> get activeCicilan => _cicilanList.where((c) => !c.isCompleted).toList();
  List<CicilanModel> get completedCicilan => _cicilanList.where((c) => c.isCompleted).toList();

  void reset() {
    _cicilanList = [];
    _isLoaded = false;
    notifyListeners();
  }

  void listenCicilan(String userId) {
    _isLoaded = false;
    // Paksa refresh token dulu sebelum listen
    FirebaseAuth.instance.currentUser?.getIdToken(true).then((_) {
      _service.getCicilan(userId).listen((snapshot) {
        _cicilanList = snapshot.docs
            .map((doc) => CicilanModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList();
        _isLoaded = true;
        notifyListeners();
      }, onError: (e) {
        // Retry sekali setelah 1 detik
        Future.delayed(const Duration(seconds: 1), () {
          _service.getCicilan(userId).listen((snapshot) {
            _cicilanList = snapshot.docs
                .map((doc) => CicilanModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
                .toList();
            _isLoaded = true;
            notifyListeners();
          }, onError: (_) {
            _isLoaded = true;
            notifyListeners();
          });
        });
      });
    });
  }

  Future<void> addCicilan(CicilanModel cicilan) async {
    await _service.addCicilan(cicilan.toMap());
  }

  Future<void> bayarCicilan(String cicilanId, double amount) async {
    if (amount <= 0) return;
    final cicilan = _cicilanList.firstWhere((c) => c.id == cicilanId);
    final userId = FirebaseAuth.instance.currentUser?.uid;

    // Catat sebagai transaksi pengeluaran sesuai jumlah yang dibayar
    if (userId != null) {
      final transaction = TransactionModel(
        id: '',
        userId: userId,
        type: 'expense',
        amount: amount,
        category: 'Cicilan',
        description: 'Cicilan: ${cicilan.name} (${cicilan.paidMonths + 1}/${cicilan.totalMonths})',
        date: DateTime.now(),
      );
      await _service.addTransaction(transaction.toMap());
    }

    final newTotalPaid = (cicilan.totalPaid + amount).clamp(0.0, cicilan.totalAmount).toDouble();
    int newPaidMonths = 0;
    if (cicilan.monthlyAmount > 0) {
      final m = (newTotalPaid / cicilan.monthlyAmount).floor();
      newPaidMonths = m < 0 ? 0 : (m > cicilan.totalMonths ? cicilan.totalMonths : m);
    }
    final completed = newTotalPaid >= cicilan.totalAmount;

    // nextPaymentDate maju hanya jika ada bulan penuh yang baru selesai
    DateTime? nextPayment;
    if (completed) {
      nextPayment = null;
    } else if (newPaidMonths > cicilan.paidMonths) {
      nextPayment = _calculateNextPayment(cicilan.paymentDay);
    } else {
      nextPayment = cicilan.nextPaymentDate;
    }

    await _service.updateCicilan(cicilanId, {
      'totalPaid': newTotalPaid,
      'paidMonths': newPaidMonths,
      'nextPaymentDate': nextPayment?.toIso8601String(),
    });
  }

  Future<void> deleteCicilan(String id) async {
    await _service.deleteCicilan(id);
  }

  DateTime _calculateNextPayment(int paymentDay) {
    final now = DateTime.now();
    // Bulan depan di tanggal paymentDay
    var next = DateTime(now.year, now.month + 1, paymentDay);
    // Handle bulan yang tidak punya tanggal tersebut (misal Feb 30)
    final lastDay = DateTime(next.year, next.month + 1, 0).day;
    if (paymentDay > lastDay) {
      next = DateTime(next.year, next.month, lastDay);
    }
    return next;
  }
}
