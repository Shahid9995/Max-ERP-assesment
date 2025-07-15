class PayslipData {
  final String employeeName;
  final double totalSalary;
  final double netSalary;
  final String month;
  final String year;
  final DateTime? extractedDate;

  PayslipData({
    required this.employeeName,
    required this.totalSalary,
    required this.netSalary,
    required this.month,
    required this.year,
    this.extractedDate,
  });

  factory PayslipData.empty() {
    return PayslipData(
      employeeName: '',
      totalSalary: 0.0,
      netSalary: 0.0,
      month: '',
      year: '',
      extractedDate: null,
    );
  }

  bool get isEmpty => employeeName.isEmpty && totalSalary == 0.0 && netSalary == 0.0;

  String get formattedTotalSalary => '\$${totalSalary.toStringAsFixed(2)}';
  String get formattedNetSalary => '\$${netSalary.toStringAsFixed(2)}';
  String get formattedPeriod => '$month $year';
} 