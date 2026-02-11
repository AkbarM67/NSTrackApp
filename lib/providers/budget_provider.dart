import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/budget_model.dart';
import '../core/services/notification_service.dart';

class BudgetProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  BudgetModel? _budget;
  BudgetModel? get budget => _budget;

  Future<void> loadBudget(String userId) async {
    try {
      final snapshot = await _db
          .collection('budgets')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        _budget = BudgetModel.fromMap(
          snapshot.docs.first.id,
          snapshot.docs.first.data(),
        );
        notifyListeners();
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> saveBudget(BudgetModel budget) async {
    try {
      if (_budget != null) {
        await _db.collection('budgets').doc(_budget!.id).update(budget.toMap());
      } else {
        await _db.collection('budgets').add(budget.toMap());
      }
      _budget = budget;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  double getNeedsSpent(List transactions) {
    return transactions
        .where((t) => t.type == 'expense' && 
               ['Makanan', 'Transport'].contains(t.category))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getWantsSpent(List transactions) {
    return transactions
        .where((t) => t.type == 'expense' && 
               ['Belanja', 'Hiburan'].contains(t.category))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getSavingsSpent(List transactions) {
    return transactions
        .where((t) => t.type == 'expense' && t.category == 'Nabung')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  void checkBudgetNotifications(List transactions) {
    if (_budget == null) return;

    final needsSpent = getNeedsSpent(transactions);
    final wantsSpent = getWantsSpent(transactions);
    final savingsSpent = getSavingsSpent(transactions);

    final needsPercentage = (_budget!.needsAmount > 0) ? (needsSpent / _budget!.needsAmount) * 100 : 0.0;
    final wantsPercentage = (_budget!.wantsAmount > 0) ? (wantsSpent / _budget!.wantsAmount) * 100 : 0.0;
    final savingsPercentage = (_budget!.savingsAmount > 0) ? (savingsSpent / _budget!.savingsAmount) * 100 : 0.0;

    if (needsPercentage >= 80) {
      NotificationService.showBudgetWarning(
        category: 'Kebutuhan',
        percentage: needsPercentage.toDouble(),
        spent: needsSpent,
        budget: _budget!.needsAmount,
      );
    } else if (wantsPercentage >= 80) {
      NotificationService.showBudgetWarning(
        category: 'Keinginan',
        percentage: wantsPercentage.toDouble(),
        spent: wantsSpent,
        budget: _budget!.wantsAmount,
      );
    } else if (savingsPercentage >= 80) {
      NotificationService.showBudgetWarning(
        category: 'Tabungan',
        percentage: savingsPercentage.toDouble(),
        spent: savingsSpent,
        budget: _budget!.savingsAmount,
      );
    }
  }
}
