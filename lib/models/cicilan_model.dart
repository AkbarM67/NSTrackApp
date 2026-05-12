class CicilanModel {
  final String id;
  final String userId;
  final String name;
  final double totalAmount;
  final double monthlyAmount;
  final int totalMonths;
  final int paidMonths;
  final int paymentDay; // tanggal bayar setiap bulan (1-31)
  final DateTime startDate;
  final DateTime? nextPaymentDate;
  final String? description;

  CicilanModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.totalAmount,
    required this.monthlyAmount,
    required this.totalMonths,
    required this.paidMonths,
    required this.paymentDay,
    required this.startDate,
    this.nextPaymentDate,
    this.description,
  });

  double get remainingAmount => totalAmount - (monthlyAmount * paidMonths);
  int get remainingMonths => totalMonths - paidMonths;
  double get progress => paidMonths / totalMonths;
  bool get isCompleted => paidMonths >= totalMonths;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'totalAmount': totalAmount,
      'monthlyAmount': monthlyAmount,
      'totalMonths': totalMonths,
      'paidMonths': paidMonths,
      'paymentDay': paymentDay,
      'startDate': startDate.toIso8601String(),
      'nextPaymentDate': nextPaymentDate?.toIso8601String(),
      'description': description,
    };
  }

  factory CicilanModel.fromMap(String id, Map<String, dynamic> map) {
    return CicilanModel(
      id: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      monthlyAmount: (map['monthlyAmount'] ?? 0).toDouble(),
      totalMonths: map['totalMonths'] ?? 0,
      paidMonths: map['paidMonths'] ?? 0,
      paymentDay: map['paymentDay'] ?? 1,
      startDate: DateTime.parse(map['startDate']),
      nextPaymentDate: map['nextPaymentDate'] != null ? DateTime.parse(map['nextPaymentDate']) : null,
      description: map['description'],
    );
  }
}
