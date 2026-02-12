class PeriodHelper {
  // Periode dimulai tanggal 11 setiap bulan
  static const int periodStartDay = 11;

  // Get current active period
  static DateTime getCurrentPeriodStart() {
    final now = DateTime.now();
    if (now.day >= periodStartDay) {
      // Periode bulan ini (11 bulan ini - 10 bulan depan)
      return DateTime(now.year, now.month, periodStartDay);
    } else {
      // Periode bulan lalu (11 bulan lalu - 10 bulan ini)
      return DateTime(now.year, now.month - 1, periodStartDay);
    }
  }

  static DateTime getCurrentPeriodEnd() {
    final start = getCurrentPeriodStart();
    // End adalah tanggal 10 bulan berikutnya
    final nextMonth = DateTime(start.year, start.month + 1, 10, 23, 59, 59);
    return nextMonth;
  }

  // Check if date is in current period
  static bool isInCurrentPeriod(DateTime date) {
    final start = getCurrentPeriodStart();
    final end = getCurrentPeriodEnd();
    return date.isAfter(start.subtract(const Duration(seconds: 1))) && 
           date.isBefore(end.add(const Duration(seconds: 1)));
  }

  // Get period label (e.g., "11 Jan - 10 Feb 2024")
  static String getPeriodLabel(DateTime periodStart) {
    final periodEnd = DateTime(periodStart.year, periodStart.month + 1, 10);
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    
    return '${periodStart.day} ${months[periodStart.month - 1]} - ${periodEnd.day} ${months[periodEnd.month - 1]} ${periodStart.year}';
  }

  // Get all available periods from transactions
  static List<DateTime> getAvailablePeriods(List transactions) {
    final periods = <DateTime>{};
    
    for (var transaction in transactions) {
      final date = transaction.date as DateTime;
      final periodStart = getPeriodStartForDate(date);
      periods.add(periodStart);
    }

    final sortedPeriods = periods.toList()..sort((a, b) => b.compareTo(a));
    return sortedPeriods;
  }

  // Get period start for any date
  static DateTime getPeriodStartForDate(DateTime date) {
    if (date.day >= periodStartDay) {
      return DateTime(date.year, date.month, periodStartDay);
    } else {
      return DateTime(date.year, date.month - 1, periodStartDay);
    }
  }

  // Get transactions for specific period
  static List getTransactionsForPeriod(List transactions, DateTime periodStart) {
    final periodEnd = DateTime(periodStart.year, periodStart.month + 1, 10, 23, 59, 59);
    
    return transactions.where((t) {
      final date = t.date as DateTime;
      return date.isAfter(periodStart.subtract(const Duration(seconds: 1))) && 
             date.isBefore(periodEnd.add(const Duration(seconds: 1)));
    }).toList();
  }
}
