import '../models/payslip_model.dart';

class PayslipParser {
  static PayslipData parsePayslip(String text) {
    final lines = text.split('\n');

    String employeeName = '';
    double totalSalary = 0.0;
    double netSalary = 0.0;
    String month = '';
    String year = '';

    try {
      // Extract employee name
      employeeName = _extractEmployeeName(lines);
      
      // Extract total salary
      totalSalary = _extractTotalSalary(lines);
      
      // Extract net salary
      netSalary = _extractNetSalary(lines);
      
      // Extract month and year
      final dateInfo = _extractMonthAndYear(lines);
      month = dateInfo['month'] ?? '';
      year = dateInfo['year'] ?? '';

      return PayslipData(
        employeeName: employeeName,
        totalSalary: totalSalary,
        netSalary: netSalary,
        month: month,
        year: year,
        extractedDate: DateTime.now(),
      );
    } catch (e) {
      // Return empty data if parsing fails
      return PayslipData.empty();
    }
  }

  static String _extractEmployeeName(List<String> lines) {
    // Look for patterns like "Employee Name:", "Name:", "Employee:", etc.
    final namePatterns = [
      r'employee\s*name\s*:?\s*(.+)',
      r'name\s*:?\s*(.+)',
      r'employee\s*:?\s*(.+)',
      r'emp\s*name\s*:?\s*(.+)',
      r'full\s*name\s*:?\s*(.+)',
    ];

    for (final line in lines) {
      final cleanLine = line.trim().toLowerCase();
      for (final pattern in namePatterns) {
        final regex = RegExp(pattern, caseSensitive: false);
        final match = regex.firstMatch(cleanLine);
        if (match != null) {
          final name = match.group(1)?.trim() ?? '';
          if (name.isNotEmpty && name.length > 2) {
            return _cleanName(name);
          }
        }
      }
    }

    // If no explicit name pattern found, try to find a name-like string
    for (final line in lines) {
      final cleanLine = line.trim();
      if (_isLikelyName(cleanLine)) {
        return _cleanName(cleanLine);
      }
    }

    return '';
  }

  static double _extractTotalSalary(List<String> lines) {
    // Look for patterns like "Total Salary:", "Gross Salary:", "Total:", etc.
    final salaryPatterns = [
      r'total\s*salary\s*:?\s*\$?(\d+[\d,]*\.?\d*)',
      r'gross\s*salary\s*:?\s*\$?(\d+[\d,]*\.?\d*)',
      r'total\s*:?\s*\$?(\d+[\d,]*\.?\d*)',
      r'gross\s*:?\s*\$?(\d+[\d,]*\.?\d*)',
      r'basic\s*salary\s*:?\s*\$?(\d+[\d,]*\.?\d*)',
    ];

    for (final line in lines) {
      final cleanLine = line.trim().toLowerCase();
      for (final pattern in salaryPatterns) {
        final regex = RegExp(pattern, caseSensitive: false);
        final match = regex.firstMatch(cleanLine);
        if (match != null) {
          final salaryStr = match.group(1)?.replaceAll(',', '') ?? '';
          final salary = double.tryParse(salaryStr);
          if (salary != null && salary > 0) {
            return salary;
          }
        }
      }
    }

    return 0.0;
  }

  static double _extractNetSalary(List<String> lines) {
    // Look for patterns like "Net Salary:", "Net Pay:", "Take Home:", etc.
    final netSalaryPatterns = [
      r'net\s*salary\s*:?\s*\$?(\d+[\d,]*\.?\d*)',
      r'net\s*pay\s*:?\s*\$?(\d+[\d,]*\.?\d*)',
      r'take\s*home\s*:?\s*\$?(\d+[\d,]*\.?\d*)',
      r'net\s*:?\s*\$?(\d+[\d,]*\.?\d*)',
      r'final\s*pay\s*:?\s*\$?(\d+[\d,]*\.?\d*)',
    ];

    for (final line in lines) {
      final cleanLine = line.trim().toLowerCase();
      for (final pattern in netSalaryPatterns) {
        final regex = RegExp(pattern, caseSensitive: false);
        final match = regex.firstMatch(cleanLine);
        if (match != null) {
          final salaryStr = match.group(1)?.replaceAll(',', '') ?? '';
          final salary = double.tryParse(salaryStr);
          if (salary != null && salary > 0) {
            return salary;
          }
        }
      }
    }

    return 0.0;
  }

  static Map<String, String> _extractMonthAndYear(List<String> lines) {
    // Look for date patterns
    final datePatterns = [
      r'(\w+)\s+(\d{4})',
      r'(\d{1,2})/(\d{4})',
      r'(\d{4})-(\d{1,2})',
      r'pay\s*period\s*:?\s*(\w+)\s+(\d{4})',
      r'month\s*:?\s*(\w+)\s+(\d{4})',
      r'for\s*:?\s*(\w+)\s+(\d{4})',
    ];

    final months = [
      'january', 'february', 'march', 'april', 'may', 'june',
      'july', 'august', 'september', 'october', 'november', 'december',
      'jan', 'feb', 'mar', 'apr', 'may', 'jun',
      'jul', 'aug', 'sep', 'oct', 'nov', 'dec'
    ];

    for (final line in lines) {
      final cleanLine = line.trim().toLowerCase();
      for (final pattern in datePatterns) {
        final regex = RegExp(pattern, caseSensitive: false);
        final match = regex.firstMatch(cleanLine);
        if (match != null) {
          final part1 = match.group(1)?.toLowerCase() ?? '';
          final part2 = match.group(2) ?? '';
          
          if (months.contains(part1) && part2.length == 4) {
            return {'month': _capitalizeFirst(part1), 'year': part2};
          }
        }
      }
    }

    // Default to current month/year if not found
    final now = DateTime.now();
    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return {
      'month': monthNames[now.month - 1],
      'year': now.year.toString()
    };
  }

  static String _cleanName(String name) {
    // Remove common prefixes and suffixes
    final cleaned = name
        .replaceAll(RegExp(r'^(mr\.?|ms\.?|mrs\.?|dr\.?)\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s*(jr\.?|sr\.?|ii|iii)$', caseSensitive: false), '')
        .trim();
    
    return _capitalizeWords(cleaned);
  }

  static String _capitalizeWords(String text) {
    return text.split(' ').map((word) => _capitalizeFirst(word)).join(' ');
  }

  static String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static bool _isLikelyName(String text) {
    // Check if text looks like a name (contains only letters, spaces, and common punctuation)
    final nameRegex = RegExp(r"^[a-zA-Z\s\.\-']+");
    return nameRegex.hasMatch(text) && 
           text.length >= 3 && 
           text.length <= 50 &&
           text.split(' ').length <= 4;
  }
} 