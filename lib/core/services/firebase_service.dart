import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // USERS
  Future<void> saveUser(Map<String, dynamic> data, String uid) async {
    await _db.collection('users').doc(uid).set(data);
  }

  Future<DocumentSnapshot> getUser(String uid) async {
    return await _db.collection('users').doc(uid).get();
  }

  // TRANSACTIONS
  Future<String> addTransaction(Map<String, dynamic> data) async {
    final doc = await _db.collection('transactions').add(data);
    return doc.id;
  }

  Stream<QuerySnapshot> getTransactions(String userId) {
    return _db.collection('transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots();
  }

  Future<void> deleteTransaction(String id) async {
    await _db.collection('transactions').doc(id).delete();
  }

  Future<void> updateTransaction(String id, Map<String, dynamic> data) async {
    await _db.collection('transactions').doc(id).update(data);
  }

  // SAVINGS GOALS
  Future<void> addSavingsGoal(Map<String, dynamic> data) async {
    await _db.collection('savings_goals').add(data);
  }

  Stream<QuerySnapshot> getSavingsGoals(String userId) {
    return _db.collection('savings_goals')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  Future<void> updateSavingsGoal(String id, Map<String, dynamic> data) async {
    await _db.collection('savings_goals').doc(id).update(data);
  }

  Future<void> deleteSavingsGoal(String id) async {
    await _db.collection('savings_goals').doc(id).delete();
  }

  // SAVINGS DEPOSITS
  Future<String> addSavingsDeposit(Map<String, dynamic> data) async {
    final doc = await _db.collection('savings_deposits').add(data);
    return doc.id;
  }

  Stream<QuerySnapshot> getSavingsDeposits(String savingsGoalId) {
    return _db.collection('savings_deposits')
        .where('savingsGoalId', isEqualTo: savingsGoalId)
        .orderBy('date', descending: true)
        .snapshots();
  }

  Future<void> deleteSavingsDeposit(String id) async {
    await _db.collection('savings_deposits').doc(id).delete();
  }
}
