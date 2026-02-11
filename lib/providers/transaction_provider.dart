import 'package:flutter/material.dart';
import '../core/services/firebase_service.dart';
import '../models/transaction_model.dart';

class TransactionProvider with ChangeNotifier {
  final FirebaseService _service = FirebaseService();

  List<TransactionModel> _transactions = [];
  List<TransactionModel> get transactions => _transactions;

  double get totalIncome => _transactions
      .where((t) => t.type == 'income')
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == 'expense')
      .fold(0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;

  void listenTransactions(String userId) {
    _service.getTransactions(userId).listen((snapshot) {
      _transactions = snapshot.docs
          .map((doc) => TransactionModel.fromMap(
              doc.id, doc.data() as Map<String, dynamic>))
          .toList();
      notifyListeners();
    });
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _service.addTransaction(transaction.toMap());
  }

  Future<void> deleteTransaction(String id) async {
    await _service.deleteTransaction(id);
  }

  Future<void> updateTransaction(String id, TransactionModel transaction) async {
    await _service.updateTransaction(id, transaction.toMap());
  }

  List<TransactionModel> getTransactionsByMonth(int year, int month) {
    return _transactions.where((t) {
      return t.date.year == year && t.date.month == month;
    }).toList();
  }

  List<TransactionModel> getTransactionsByYear(int year) {
    return _transactions.where((t) => t.date.year == year).toList();
  }
}
