class SavingsGoalModel {
  final String id;
  final String userId;
  final String goalName;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final double monthlyRecommendation;
  final String? photoUrl;
  final String? description;

  SavingsGoalModel({
    required this.id,
    required this.userId,
    required this.goalName,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    required this.monthlyRecommendation,
    this.photoUrl,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'goalName': goalName,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'targetDate': targetDate.toIso8601String(),
      'monthlyRecommendation': monthlyRecommendation,
      'photoUrl': photoUrl,
      'description': description,
    };
  }

  factory SavingsGoalModel.fromMap(String id, Map<String, dynamic> map) {
    return SavingsGoalModel(
      id: id,
      userId: map['userId'] ?? '',
      goalName: map['goalName'] ?? '',
      targetAmount: (map['targetAmount'] ?? 0).toDouble(),
      currentAmount: (map['currentAmount'] ?? 0).toDouble(),
      targetDate: DateTime.parse(map['targetDate']),
      monthlyRecommendation: (map['monthlyRecommendation'] ?? 0).toDouble(),
      photoUrl: map['photoUrl'],
      description: map['description'],
    );
  }
}
