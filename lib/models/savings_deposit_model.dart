class SavingsDepositModel {
  final String id;
  final String savingsGoalId;
  final double amount;
  final String note;
  final DateTime date;
  final String? transactionId;

  SavingsDepositModel({
    required this.id,
    required this.savingsGoalId,
    required this.amount,
    required this.note,
    required this.date,
    this.transactionId,
  });

  Map<String, dynamic> toMap() {
    return {
      'savingsGoalId': savingsGoalId,
      'amount': amount,
      'note': note,
      'date': date.toIso8601String(),
      'transactionId': transactionId,
    };
  }

  factory SavingsDepositModel.fromMap(String id, Map<String, dynamic> map) {
    return SavingsDepositModel(
      id: id,
      savingsGoalId: map['savingsGoalId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      note: map['note'] ?? '',
      date: DateTime.parse(map['date']),
      transactionId: map['transactionId'],
    );
  }
}
