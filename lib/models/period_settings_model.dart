class PeriodSettingsModel {
  final String userId;
  final int startDay; // default 11
  final int endDay;   // default 10

  const PeriodSettingsModel({
    required this.userId,
    this.startDay = 11,
    this.endDay = 10,
  });

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'startDay': startDay,
        'endDay': endDay,
      };

  factory PeriodSettingsModel.fromMap(Map<String, dynamic> map) {
    return PeriodSettingsModel(
      userId: map['userId'] ?? '',
      startDay: map['startDay'] ?? 11,
      endDay: map['endDay'] ?? 10,
    );
  }

  factory PeriodSettingsModel.defaultSettings(String userId) {
    return PeriodSettingsModel(userId: userId, startDay: 11, endDay: 10);
  }
}
