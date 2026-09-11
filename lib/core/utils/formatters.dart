/// Formats Indian currency values (Lakh / Crore).
class Formatters {
  static String formatPrice(double price) {
    if (price >= 10000000) {
      final crore = price / 10000000;
      return '₹${_trimDecimal(crore)} Crore';
    }
    if (price >= 100000) {
      final lakh = price / 100000;
      return '₹${_trimDecimal(lakh)} Lakh';
    }
    return '₹${price.toStringAsFixed(0)}';
  }

  static String formatArea(double area) {
    return '${area.toStringAsFixed(0)} sq.ft';
  }

  static String formatCompactPrice(double price) {
    if (price >= 10000000) {
      return '₹${_trimDecimal(price / 10000000)} Cr';
    }
    if (price >= 100000) {
      return '₹${_trimDecimal(price / 100000)} L';
    }
    return '₹${price.toStringAsFixed(0)}';
  }

  static String formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  static String formatMobile(String mobile) {
    final cleaned = mobile.replaceAll(RegExp(r'[\s\-\+]'), '');
    String digits = cleaned;
    if (digits.startsWith('91') && digits.length == 12) {
      digits = digits.substring(2);
    }
    if (digits.length == 10) {
      return '+91 ${digits.substring(0, 5)} ${digits.substring(5)}';
    }
    return mobile;
  }

  static String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  static String _trimDecimal(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }
}
