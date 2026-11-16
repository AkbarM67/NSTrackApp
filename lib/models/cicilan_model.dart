class CicilanModel {
  final String id;
  final String userId;
  final String name;
  final double totalAmount;
  final double monthlyAmount;
  final int totalMonths;
  final double totalPaid; // akumulasi nominal yang sudah dibayar (bisa parsial)
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
    this.totalPaid = 0,
    required this.paymentDay,
    required this.startDate,
    this.nextPaymentDate,
    this.description,
  });

  // Jumlah bulan penuh yang sudah terbayar.
  // Naik hanya jika akumulasi pembayaran mencapai 1 bulan penuh.
  int get paidMonths {
    if (monthlyAmount <= 0) return 0;
    final m = (totalPaid / monthlyAmount).floor();
    if (m < 0) return 0;
    if (m > totalMonths) return totalMonths;
    return m;
  }

  double get remainingAmount {
    final r = totalAmount - totalPaid;
    return r < 0 ? 0.0 : r;
  }

  int get remainingMonths {
    final r = totalMonths - paidMonths;
    return r < 0 ? 0 : r;
  }

  double get progress {
    if (totalAmount <= 0) return 0.0;
    final p = totalPaid / totalAmount;
    if (p < 0.0) return 0.0;
    if (p > 1.0) return 1.0;
    return p;
  }

  bool get isCompleted => totalAmount > 0 && totalPaid >= totalAmount;

  // Sisa nominal yang dibutuhkan untuk menyelesaikan bulan yang sedang berjalan.
  // Dipakai untuk prefill input pembayaran.
  double get remainingForCurrentMonth {
    if (isCompleted || monthlyAmount <= 0) return 0.0;
    final paidIntoMonth = totalPaid % monthlyAmount;
    if (paidIntoMonth == 0) return monthlyAmount;
    final needed = monthlyAmount - paidIntoMonth;
    return needed < 0 ? 0.0 : needed;
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'totalAmount': totalAmount,
      'monthlyAmount': monthlyAmount,
      'totalMonths': totalMonths,
      'totalPaid': totalPaid,
      'paidMonths': paidMonths, // disimpan untuk kompatibilitas baca lama
      'paymentDay': paymentDay,
      'startDate': startDate.toIso8601String(),
      'nextPaymentDate': nextPaymentDate?.toIso8601String(),
      'description': description,
    };
  }

  factory CicilanModel.fromMap(String id, Map<String, dynamic> map) {
    // Kompatibilitas data lama: jika tidak ada 'totalPaid', hitung dari paidMonths lama
    double totalPaid;
    if (map['totalPaid'] != null) {
      totalPaid = (map['totalPaid'] as num).toDouble();
    } else {
      final oldPaidMonths = (map['paidMonths'] ?? 0) as num;
      final monthly = (map['monthlyAmount'] ?? 0).toDouble();
      totalPaid = (oldPaidMonths.toInt() * monthly).toDouble();
    }
    return CicilanModel(
      id: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      monthlyAmount: (map['monthlyAmount'] ?? 0).toDouble(),
      totalMonths: map['totalMonths'] ?? 0,
      totalPaid: totalPaid,
      paymentDay: map['paymentDay'] ?? 1,
      startDate: DateTime.parse(map['startDate']),
      nextPaymentDate: map['nextPaymentDate'] != null ? DateTime.parse(map['nextPaymentDate']) : null,
      description: map['description'],
    );
  }
}
