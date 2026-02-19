class SavingsGoalModel {
  final String id;
  final String userId;
  final String goalName;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final double monthlyRecommendation;
  final double weeklyRecommendation;
  final double dailyRecommendation;
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
    this.weeklyRecommendation = 0,
    this.dailyRecommendation = 0,
    this.photoUrl,
    this.description,
  });

  // Getter untuk menghitung rekomendasi real-time berdasarkan sisa target
  double get remainingAmount => targetAmount - currentAmount;
  
  double get currentMonthlyRecommendation {
    final now = DateTime.now();
    final monthsLeft = (targetDate.year - now.year) * 12 + (targetDate.month - now.month);
    if (monthsLeft <= 0 || remainingAmount <= 0) return 0;
    return remainingAmount / monthsLeft;
  }
  
  double get currentWeeklyRecommendation {
    final now = DateTime.now();
    final daysLeft = targetDate.difference(now).inDays;
    final weeksLeft = (daysLeft / 7).ceil();
    if (weeksLeft <= 0 || remainingAmount <= 0) return 0;
    return remainingAmount / weeksLeft;
  }
  
  double get currentDailyRecommendation {
    final now = DateTime.now();
    final daysLeft = targetDate.difference(now).inDays;
    if (daysLeft <= 0 || remainingAmount <= 0) return 0;
    return remainingAmount / daysLeft;
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'goalName': goalName,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'targetDate': targetDate.toIso8601String(),
      'monthlyRecommendation': monthlyRecommendation,
      'weeklyRecommendation': weeklyRecommendation,
      'dailyRecommendation': dailyRecommendation,
      'photoUrl': photoUrl,
      'description': description,
    };
  }

  factory SavingsGoalModel.fromMap(String id, Map<String, dynamic> map) {
    final targetAmount = (map['targetAmount'] ?? 0).toDouble();
    final currentAmount = (map['currentAmount'] ?? 0).toDouble();
    final targetDate = DateTime.parse(map['targetDate']);
    final remainingAmount = targetAmount - currentAmount;
    
    // Hitung ulang jika data lama tidak punya field ini
    double weeklyRec = (map['weeklyRecommendation'] ?? 0).toDouble();
    double dailyRec = (map['dailyRecommendation'] ?? 0).toDouble();
    
    if (weeklyRec == 0 || dailyRec == 0) {
      final now = DateTime.now();
      final daysLeft = targetDate.difference(now).inDays;
      final weeksLeft = (daysLeft / 7).ceil();
      
      if (weeksLeft > 0) weeklyRec = remainingAmount / weeksLeft;
      if (daysLeft > 0) dailyRec = remainingAmount / daysLeft;
    }
    
    return SavingsGoalModel(
      id: id,
      userId: map['userId'] ?? '',
      goalName: map['goalName'] ?? '',
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      targetDate: targetDate,
      monthlyRecommendation: (map['monthlyRecommendation'] ?? 0).toDouble(),
      weeklyRecommendation: weeklyRec,
      dailyRecommendation: dailyRec,
      photoUrl: map['photoUrl'],
      description: map['description'],
    );
  }
}
