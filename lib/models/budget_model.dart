class BudgetModel {
  final String id;
  final String userId;
  final double monthlyIncome;
  final double needsPercentage;
  final double wantsPercentage;
  final double savingsPercentage;
  final DateTime createdAt;

  BudgetModel({
    required this.id,
    required this.userId,
    required this.monthlyIncome,
    this.needsPercentage = 50,
    this.wantsPercentage = 30,
    this.savingsPercentage = 20,
    required this.createdAt,
  });

  double get needsAmount => monthlyIncome * (needsPercentage / 100);
  double get wantsAmount => monthlyIncome * (wantsPercentage / 100);
  double get savingsAmount => monthlyIncome * (savingsPercentage / 100);

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'monthlyIncome': monthlyIncome,
      'needsPercentage': needsPercentage,
      'wantsPercentage': wantsPercentage,
      'savingsPercentage': savingsPercentage,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BudgetModel.fromMap(String id, Map<String, dynamic> map) {
    return BudgetModel(
      id: id,
      userId: map['userId'] ?? '',
      monthlyIncome: (map['monthlyIncome'] ?? 0).toDouble(),
      needsPercentage: (map['needsPercentage'] ?? 50).toDouble(),
      wantsPercentage: (map['wantsPercentage'] ?? 30).toDouble(),
      savingsPercentage: (map['savingsPercentage'] ?? 20).toDouble(),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
