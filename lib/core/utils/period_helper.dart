class PeriodHelper {
  // Default periode dimulai tanggal 11 setiap bulan
  static const int defaultStartDay = 11;
  static const int defaultEndDay = 10;

  // Untuk kompatibilitas kode lama
  static int get periodStartDay => defaultStartDay;

  static DateTime getCurrentPeriodStart({int startDay = defaultStartDay}) {
    final now = DateTime.now();
    if (now.day >= startDay) {
      return DateTime(now.year, now.month, startDay);
    } else {
      return DateTime(now.year, now.month - 1, startDay);
    }
  }

  static DateTime getCurrentPeriodEnd({int startDay = defaultStartDay, int endDay = defaultEndDay}) {
    final start = getCurrentPeriodStart(startDay: startDay);
    return DateTime(start.year, start.month + 1, endDay, 23, 59, 59);
  }

  static bool isInCurrentPeriod(DateTime date, {int startDay = defaultStartDay, int endDay = defaultEndDay}) {
    final start = getCurrentPeriodStart(startDay: startDay);
    final end = getCurrentPeriodEnd(startDay: startDay, endDay: endDay);
    return date.isAfter(start.subtract(const Duration(seconds: 1))) &&
        date.isBefore(end.add(const Duration(seconds: 1)));
  }

  static String getPeriodLabel(DateTime periodStart, {int endDay = defaultEndDay}) {
    final periodEnd = DateTime(periodStart.year, periodStart.month + 1, endDay);
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${periodStart.day} ${months[periodStart.month - 1]} - ${periodEnd.day} ${months[periodEnd.month - 1]} ${periodStart.year}';
  }

  static List<DateTime> getAvailablePeriods(List transactions, {int startDay = defaultStartDay}) {
    final periods = <DateTime>{};
    for (var transaction in transactions) {
      final date = transaction.date as DateTime;
      final periodStart = getPeriodStartForDate(date, startDay: startDay);
      periods.add(periodStart);
    }
    final sortedPeriods = periods.toList()..sort((a, b) => b.compareTo(a));
    return sortedPeriods;
  }

  static DateTime getPeriodStartForDate(DateTime date, {int startDay = defaultStartDay}) {
    if (date.day >= startDay) {
      return DateTime(date.year, date.month, startDay);
    } else {
      return DateTime(date.year, date.month - 1, startDay);
    }
  }

  static List getTransactionsForPeriod(List transactions, DateTime periodStart, {int endDay = defaultEndDay}) {
    final periodEnd = DateTime(periodStart.year, periodStart.month + 1, endDay, 23, 59, 59);
    return transactions.where((t) {
      final date = t.date as DateTime;
      return date.isAfter(periodStart.subtract(const Duration(seconds: 1))) &&
          date.isBefore(periodEnd.add(const Duration(seconds: 1)));
    }).toList();
  }
}
