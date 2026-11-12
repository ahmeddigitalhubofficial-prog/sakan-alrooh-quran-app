import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DateService {
  static String gregorian() {
    return DateFormat(
      'EEEE، d MMMM y',
      'ar',
    ).format(DateTime.now());
  }

  static String hijri({int offsetDays = 0}) {
    final targetDate = DateTime.now().add(Duration(days: offsetDays));
    final hijri = HijriCalendar.fromDate(targetDate);

    return '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} هـ';
  }

  static Future<int> getSavedHijriOffset() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('hijri_offset') ?? 0;
  }
}
