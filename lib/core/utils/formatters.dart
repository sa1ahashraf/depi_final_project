import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  static String egyptianPhone(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 11 || !digits.startsWith('01')) return value;
    return '${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6)}';
  }

  static String currency(num value) => NumberFormat.currency(
    locale: 'ar_EG',
    symbol: 'ج.م',
    decimalDigits: 2,
  ).format(value);

  static String date(DateTime value) =>
      DateFormat('dd/MM/yyyy', 'ar').format(value);

  static String time(DateTime value) =>
      DateFormat('hh:mm a', 'ar').format(value);

  static String number(num value) =>
      NumberFormat.decimalPattern('ar').format(value);
}
