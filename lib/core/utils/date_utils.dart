import 'package:intl/intl.dart';

class AppDateUtils {
  static final DateFormat _fullDateFormatter = DateFormat('dd MMM yyyy');
  static final DateFormat _shortDateFormatter = DateFormat('dd/MM/yyyy');
  static final DateFormat _timeFormatter = DateFormat('hh:mm a');
  static final DateFormat _monthYearFormatter = DateFormat('MMMM yyyy');

  static String formatFullDate(DateTime date) => _fullDateFormatter.format(date);
  static String formatShortDate(DateTime date) => _shortDateFormatter.format(date);
  static String formatTime(DateTime date) => _timeFormatter.format(date);
  static String formatMonthYear(DateTime date) => _monthYearFormatter.format(date);

  static DateTime parseUtc(String isoString) => DateTime.parse(isoString).toUtc();

  static List<DateTime> getLast30Days() {
    final now = DateTime.now();
    return List.generate(
      30,
      (index) => now.subtract(Duration(days: index)),
    ).reversed.toList();
  }

  static bool isSunday(DateTime date) => date.weekday == DateTime.sunday;
}
