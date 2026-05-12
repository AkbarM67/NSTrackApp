import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/services/firebase_service.dart';
import '../models/savings_goal_model.dart';
import '../models/savings_deposit_model.dart';
import '../models/transaction_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SavingsProvider with ChangeNotifier {
  final FirebaseService _service = FirebaseService();

  List<SavingsGoalModel> _savingsGoals = [];
  List<SavingsGoalModel> get savingsGoals => _savingsGoals;
  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  List<SavingsDepositModel> _deposits = [];
  List<SavingsDepositModel> get deposits => _deposits;

  void listenSavingsGoals(String userId) {
    _isLoaded = false;
    FirebaseAuth.instance.currentUser?.getIdToken(true).then((_) {
      _service.getSavingsGoals(userId).listen((snapshot) {
        _savingsGoals = snapshot.docs
            .map((doc) => SavingsGoalModel.fromMap(
                doc.id, doc.data() as Map<String, dynamic>))
            .toList();
        _isLoaded = true;
        notifyListeners();
      }, onError: (e) {
        Future.delayed(const Duration(seconds: 1), () {
          _service.getSavingsGoals(userId).listen((snapshot) {
            _savingsGoals = snapshot.docs
                .map((doc) => SavingsGoalModel.fromMap(
                    doc.id, doc.data() as Map<String, dynamic>))
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

  void listenDeposits(String savingsGoalId) {
    _service.getSavingsDeposits(savingsGoalId).listen((snapshot) {
      _deposits = snapshot.docs
          .map((doc) => SavingsDepositModel.fromMap(
              doc.id, doc.data() as Map<String, dynamic>))
          .toList();
      notifyListeners();
    });
  }

  Future<void> addSavingsGoal(SavingsGoalModel goal) async {
    await _service.addSavingsGoal(goal.toMap());
  }

  Future<void> addDeposit(String savingsGoalId, double amount, String note) async {
    final goal = _savingsGoals.firstWhere((g) => g.id == savingsGoalId);
    final userId = FirebaseAuth.instance.currentUser?.uid;
    
    // Catat transaksi pengeluaran terlebih dahulu
    String? transactionId;
    if (userId != null) {
      final transaction = TransactionModel(
        id: '',
        userId: userId,
        type: 'expense',
        amount: amount,
        category: 'Nabung',
        description: 'Nabung: ${goal.goalName} - $note',
        date: DateTime.now(),
      );
      transactionId = await _service.addTransaction(transaction.toMap());
    }
    
    // Simpan deposit dengan referensi transaction ID
    final deposit = SavingsDepositModel(
      id: '',
      savingsGoalId: savingsGoalId,
      amount: amount,
      note: note,
      date: DateTime.now(),
      transactionId: transactionId,
    );
    
    await _service.addSavingsDeposit(deposit.toMap());
    
    // Update current amount
    final newAmount = goal.currentAmount + amount;
    await _service.updateSavingsGoal(savingsGoalId, {'currentAmount': newAmount});
  }

  Future<void> deleteDeposit(String savingsGoalId, String depositId, double amount) async {
    // Hapus transaksi terkait jika ada
    final deposit = _deposits.firstWhere((d) => d.id == depositId);
    if (deposit.transactionId != null) {
      await _service.deleteTransaction(deposit.transactionId!);
    }
    
    // Hapus deposit
    await _service.deleteSavingsDeposit(depositId);
    
    // Update current amount
    final goal = _savingsGoals.firstWhere((g) => g.id == savingsGoalId);
    final newAmount = goal.currentAmount - amount;
    await _service.updateSavingsGoal(savingsGoalId, {'currentAmount': newAmount});
  }

  Future<void> deleteSavingsGoal(String id) async {
    await _service.deleteSavingsGoal(id);
  }

  Future<void> updateSavingsGoal(String id, Map<String, dynamic> data) async {
    await _service.updateSavingsGoal(id, data);
  }

  double calculateMonthlyRecommendation(double remainingAmount, DateTime targetDate) {
    final now = DateTime.now();
    final monthsLeft = (targetDate.year - now.year) * 12 + (targetDate.month - now.month);
    
    if (monthsLeft <= 0) return remainingAmount;
    return remainingAmount / monthsLeft;
  }

  double calculateWeeklyRecommendation(double remainingAmount, DateTime targetDate) {
    final now = DateTime.now();
    final daysLeft = targetDate.difference(now).inDays;
    final weeksLeft = (daysLeft / 7).ceil();
    
    if (weeksLeft <= 0) return remainingAmount;
    return remainingAmount / weeksLeft;
  }

  double calculateDailyRecommendation(double remainingAmount, DateTime targetDate) {
    final now = DateTime.now();
    final daysLeft = targetDate.difference(now).inDays;
    
    if (daysLeft <= 0) return remainingAmount;
    return remainingAmount / daysLeft;
  }
}
