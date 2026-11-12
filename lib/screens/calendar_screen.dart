// ignore_for_file: deprecated_member_use, unused_field, unused_local_variable

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/theme_manager.dart';
import 'fasting_tracker_screen.dart';
import 'zakat_calculator_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _currentMonthDate = DateTime.now();
  int _hijriOffset = 0;

  // Date Converter State
  bool _isConverting = false;
  int _conversionMode = 0; // 0: Greg -> Hijri, 1: Hijri -> Greg
  DateTime _selectedGregorianDate = DateTime.now();

  int _selectedHijriYear = 1447;
  int _selectedHijriMonth = 1;
  int _selectedHijriDay = 1;
  
  String? _convertedResultText;
  String? _convertedEventText;

  @override
  void initState() {
    super.initState();
    _loadSavedOffset();
  }

  Future<void> _loadSavedOffset() async {
    final prefs = await SharedPreferences.getInstance();
    final offset = prefs.getInt('hijri_offset') ?? 0;
    final nowHijri = HijriCalendar.fromDate(DateTime.now().add(Duration(days: offset)));
    setState(() {
      _hijriOffset = offset;
      _selectedHijriYear = nowHijri.hYear;
      _selectedHijriMonth = nowHijri.hMonth;
      _selectedHijriDay = nowHijri.hDay;
    });
  }

  HijriCalendar _getHijriDate(DateTime date) {
    final targetDate = date.add(Duration(days: _hijriOffset));
    return HijriCalendar.fromDate(targetDate);
  }

  int _daysInMonth(DateTime date) {
    var firstDayOfNextMonth = DateTime(date.year, date.month + 1, 1);
    var lastDayOfThisMonth = firstDayOfNextMonth.subtract(
      const Duration(days: 1),
    );
    return lastDayOfThisMonth.day;
  }

  String? _getIslamicEvent(int month, int day) {
    if (month == 1 && day == 1) return 'رأس السنة الهجرية الجديدة 🌙';
    if (month == 1 && day == 10) return 'يوم عاشوراء 🕌';
    if (month == 3 && day == 12) return 'المولد النبوي الشريف 🌸';
    if (month == 7 && day == 27) return 'ذكرى الإسراء والمعراج ⭐️';
    if (month == 8 && day == 15) return 'ليلة النصف من شعبان 🌙';
    if (month == 9 && day == 1) return 'بداية شهر رمضان المبارك 🌙';
    if (month == 9 && day == 17) return 'ذكرى غزوة بدر الكبرى ⚔️';
    if (month == 9 && day == 27) return 'ليلة القدر (تحري) ⭐️';
    if (month == 10 && day == 1) return 'عيد الفطر المبارك 🎉';
    if (month == 12 && day == 9) return 'يوم عرفة (وقفة عيد الأضحى) 🕋';
    if (month == 12 && day == 10) return 'عيد الأضحى المبارك 🕋';
    if (month == 12 && day == 11) return 'أول أيام التشريق 🕋';
    if (month == 12 && day == 12) return 'ثاني أيام التشريق 🕋';
    if (month == 12 && day == 13) return 'ثالث أيام التشريق 🕋';
    return null;
  }

  void _convertGregorianToHijri() {
    final hDate = _getHijriDate(_selectedGregorianDate);
    final gStr = DateFormat('EEEE، d MMMM yyyy', 'ar').format(_selectedGregorianDate);
    final event = _getIslamicEvent(hDate.hMonth, hDate.hDay);

    setState(() {
      _convertedResultText = '$gStr يُطابق:\n${hDate.hDay} ${hDate.longMonthName} ${hDate.hYear} هـ';
      _convertedEventText = event != null ? 'المناسبة: $event' : null;
    });
  }

  void _convertHijriToGregorian() {
    try {
      final h = HijriCalendar();
      h.hYear = _selectedHijriYear;
      h.hMonth = _selectedHijriMonth;
      h.hDay = _selectedHijriDay;
      final gDate = h.hijriToGregorian(_selectedHijriYear, _selectedHijriMonth, _selectedHijriDay);
      final gDateAdjusted = gDate.subtract(Duration(days: _hijriOffset));
      final gStr = DateFormat('EEEE، d MMMM yyyy', 'ar').format(gDateAdjusted);
      final event = _getIslamicEvent(_selectedHijriMonth, _selectedHijriDay);

      setState(() {
        _convertedResultText = '$_selectedHijriDay ${h.longMonthName} $_selectedHijriYear هـ يُطابق:\n$gStr مـ';
        _convertedEventText = event != null ? 'المناسبة: $event' : null;
      });
    } catch (e) {
      setState(() {
        _convertedResultText = 'تاريخ هجري غير صالح، يرجى التثبت من أرقام الأيام والأشهر.';
        _convertedEventText = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<AppThemeManager>(context);
    final theme = themeManager.currentTheme;

    final firstOfMonth = DateTime(
      _currentMonthDate.year,
      _currentMonthDate.month,
      1,
    );

    final startWeekday = firstOfMonth.weekday % 7;
    final totalDays = _daysInMonth(_currentMonthDate);
    final arabicMonthName = DateFormat.MMMM('ar').format(_currentMonthDate);
    final yearString = DateFormat.y('ar').format(_currentMonthDate);

    final todayHijri = _getHijriDate(DateTime.now());

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.primaryColor,
          elevation: 0,
          title: Text(
            'التقويم الإسلامي',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20.sp,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isConverting ? Icons.calendar_month : Icons.published_with_changes_rounded,
                color: Colors.white,
              ),
              tooltip: _isConverting ? 'عرض التقويم' : 'محول التواريخ',
              onPressed: () {
                setState(() {
                  _isConverting = !_isConverting;
                });
              },
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: theme.gradientColors,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Today Hijri Banner
                Card(
                  color: theme.cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                    side: BorderSide(color: theme.accentColor.withValues(alpha: 0.3)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.accentColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.calendar_today_rounded, color: theme.accentColor, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'اليوم في التقويم الهجري',
                                style: GoogleFonts.cairo(
                                  color: theme.subtitleColor,
                                  fontSize: 12.sp,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${todayHijri.hDay} ${todayHijri.longMonthName} ${todayHijri.hYear} هـ',
                                style: GoogleFonts.cairo(
                                  color: theme.textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_hijriOffset != 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.accentColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _hijriOffset > 0 ? '+$_hijriOffset يوم' : '$_hijriOffset يوم',
                              style: GoogleFonts.cairo(color: theme.accentColor, fontSize: 10.sp, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Toggle View Button
                InkWell(
                  onTap: () => setState(() => _isConverting = !_isConverting),
                  borderRadius: BorderRadius.circular(16.r),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    decoration: BoxDecoration(
                      color: theme.accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: theme.accentColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isConverting ? Icons.calendar_today_outlined : Icons.swap_horiz_rounded,
                          color: theme.accentColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isConverting ? 'العودة لعرض الشهر الكامل' : 'أداة البحث والتحويل بين الهجري والميلادي 🔄',
                          style: GoogleFonts.cairo(
                            color: theme.textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Fasting and Zakat Shortcuts
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FastingTrackerScreen()),
                        ),
                        borderRadius: BorderRadius.circular(14.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(color: const Color(0xFF64B5F6).withValues(alpha: 0.35)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.brightness_2_rounded, color: const Color(0xFF64B5F6), size: 16.sp),
                              SizedBox(width: 6.w),
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'متابع الصيام 🌙',
                                    maxLines: 1,
                                    style: GoogleFonts.cairo(
                                      color: theme.textColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ZakatCalculatorScreen()),
                        ),
                        borderRadius: BorderRadius.circular(14.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(color: const Color(0xFFFFB74D).withValues(alpha: 0.35)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calculate_rounded, color: const Color(0xFFFFB74D), size: 16.sp),
                              SizedBox(width: 6.w),
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'حاسبة الزكاة 💰',
                                    maxLines: 1,
                                    style: GoogleFonts.cairo(
                                      color: theme.textColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (_isConverting) _buildDateConverterCard(theme) else ...[
                  // Month Header
                  Card(
                    color: theme.cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      side: BorderSide(
                        color: theme.accentColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios,
                              color: theme.accentColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _currentMonthDate = DateTime(
                                  _currentMonthDate.year,
                                  _currentMonthDate.month - 1,
                                );
                              });
                            },
                          ),
                          Text(
                            '$arabicMonthName $yearString',
                            style: GoogleFonts.cairo(
                              color: theme.textColor,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.arrow_forward_ios,
                              color: theme.accentColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _currentMonthDate = DateTime(
                                  _currentMonthDate.year,
                                  _currentMonthDate.month + 1,
                                );
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Calendar Grid Card
                  Card(
                    color: theme.cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              "أحد",
                              "إثنين",
                              "ثلاثاء",
                              "أربعاء",
                              "خميس",
                              "جمعة",
                              "سبت"
                            ].map((w) {
                              return Expanded(
                                child: Center(
                                  child: Text(
                                    w,
                                    style: GoogleFonts.cairo(
                                      color: theme.accentColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const Divider(
                            height: 16,
                            thickness: 1,
                          ),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              mainAxisSpacing: 6,
                              crossAxisSpacing: 6,
                              childAspectRatio: 0.9,
                            ),
                            itemCount: startWeekday + totalDays,
                            itemBuilder: (context, index) {
                              if (index < startWeekday) {
                                return const SizedBox.shrink();
                              }

                              final day = index - startWeekday + 1;
                              final cellDate = DateTime(
                                _currentMonthDate.year,
                                _currentMonthDate.month,
                                day,
                              );

                              final today = DateTime.now();
                              final isToday = cellDate.year == today.year &&
                                  cellDate.month == today.month &&
                                  cellDate.day == today.day;

                              final hijriCell = _getHijriDate(cellDate);

                              return Container(
                                decoration: BoxDecoration(
                                  color: isToday
                                      ? theme.primaryColor.withValues(alpha: 0.3)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color: isToday
                                        ? theme.accentColor
                                        : theme.dividerColor.withValues(alpha: 0.3),
                                    width: isToday ? 1.5 : 0.8,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$day',
                                      style: GoogleFonts.cairo(
                                        color: theme.textColor,
                                        fontWeight: isToday
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                    Text(
                                      '${hijriCell.hDay}',
                                      style: GoogleFonts.cairo(
                                        color: theme.accentColor,
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Islamic Events for Selected Month
                  (() {
                    final List<Map<String, dynamic>> monthlyEvents = [];
                    final daysCount = _daysInMonth(_currentMonthDate);
                    for (int d = 1; d <= daysCount; d++) {
                      final date = DateTime(_currentMonthDate.year, _currentMonthDate.month, d);
                      final hijri = _getHijriDate(date);
                      final event = _getIslamicEvent(hijri.hMonth, hijri.hDay);
                      if (event != null) {
                        final alreadyAdded = monthlyEvents.any((e) => e['event'] == event);
                        if (!alreadyAdded) {
                          monthlyEvents.add({
                            'event': event,
                            'gregorianDate': date,
                            'hijriDate': hijri,
                          });
                        }
                      }
                    }

                    if (monthlyEvents.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 25),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text(
                            'المناسبات الإسلامية هذا الشهر',
                            style: GoogleFonts.cairo(
                              color: theme.textColor,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...monthlyEvents.map((item) {
                          final eventName = item['event'] as String;
                          final gDate = item['gregorianDate'] as DateTime;
                          final hDate = item['hijriDate'] as HijriCalendar;
                          final gDateStr = DateFormat('d MMMM yyyy', 'ar').format(gDate);

                          return Card(
                            color: theme.cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                              side: BorderSide(
                                color: theme.accentColor.withValues(alpha: 0.15),
                              ),
                            ),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.accentColor.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.star_rounded,
                                  color: theme.accentColor,
                                  size: 24,
                                ),
                              ),
                              title: Text(
                                eventName,
                                style: GoogleFonts.cairo(
                                  color: theme.textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
                                ),
                              ),
                              subtitle: Text(
                                '$gDateStr - ${hDate.hDay} ${hDate.longMonthName} ${hDate.hYear} هـ',
                                style: GoogleFonts.cairo(
                                  color: theme.subtitleColor,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  })(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateConverterCard(AppTheme theme) {
    final hijriMonths = [
      "المحرّم", "صفر", "ربيع الأول", "ربيع الآخر",
      "جمادى الأولى", "جمادى الآخرة", "رجب", "شعبان",
      "رمضان", "شوال", "ذو القعدة", "ذو الحجة"
    ];

    return Card(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(color: theme.accentColor.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment<int>(value: 0, label: Text('ميلادي ⬅️ هجري')),
                    ButtonSegment<int>(value: 1, label: Text('هجري ⬅️ ميلادي')),
                  ],
                  selected: {_conversionMode},
                  onSelectionChanged: (set) {
                    setState(() {
                      _conversionMode = set.first;
                      _convertedResultText = null;
                      _convertedEventText = null;
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color>(
                      (states) => states.contains(WidgetState.selected)
                          ? theme.accentColor.withValues(alpha: 0.3)
                          : Colors.transparent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (_conversionMode == 0) ...[
              // Gregorian to Hijri
              Text(
                'اختر التاريخ الميلادي للبحث والتحويل:',
                style: GoogleFonts.cairo(color: theme.textColor, fontWeight: FontWeight.bold, fontSize: 14.sp),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedGregorianDate,
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                    locale: const Locale('ar'),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedGregorianDate = picked;
                    });
                    _convertGregorianToHijri();
                  }
                },
                icon: const Icon(Icons.event_rounded),
                label: Text(
                  DateFormat('EEEE، d MMMM yyyy', 'ar').format(_selectedGregorianDate),
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor.withValues(alpha: 0.4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: _convertGregorianToHijri,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.accentColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                child: Text(
                  'تحويل التاريخ الآن 🔍',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15.sp),
                ),
              ),
            ] else ...[
              // Hijri to Gregorian
              Text(
                'حدد التاريخ الهجري:',
                style: GoogleFonts.cairo(color: theme.textColor, fontWeight: FontWeight.bold, fontSize: 14.sp),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  // Day
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedHijriDay,
                      dropdownColor: theme.cardColor,
                      decoration: InputDecoration(
                        labelText: 'اليوم',
                        labelStyle: GoogleFonts.cairo(color: theme.subtitleColor),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      style: GoogleFonts.cairo(color: theme.textColor),
                      items: List.generate(30, (i) => i + 1).map((d) {
                        return DropdownMenuItem<int>(value: d, child: Text('$d'));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedHijriDay = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Month
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<int>(
                      value: _selectedHijriMonth,
                      dropdownColor: theme.cardColor,
                      decoration: InputDecoration(
                        labelText: 'الشهر',
                        labelStyle: GoogleFonts.cairo(color: theme.subtitleColor),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      style: GoogleFonts.cairo(color: theme.textColor),
                      items: List.generate(12, (i) => i + 1).map((m) {
                        return DropdownMenuItem<int>(value: m, child: Text(hijriMonths[m - 1]));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedHijriMonth = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Year
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedHijriYear,
                      dropdownColor: theme.cardColor,
                      decoration: InputDecoration(
                        labelText: 'السنة',
                        labelStyle: GoogleFonts.cairo(color: theme.subtitleColor),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      style: GoogleFonts.cairo(color: theme.textColor),
                      items: List.generate(100, (i) => 1400 + i).map((y) {
                        return DropdownMenuItem<int>(value: y, child: Text('$y'));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedHijriYear = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: _convertHijriToGregorian,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.accentColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                child: Text(
                  'تحويل التاريخ الآن 🔍',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15.sp),
                ),
              ),
            ],

            if (_convertedResultText != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: theme.accentColor.withValues(alpha: 0.4)),
                ),
                child: Column(
                  children: [
                    Text(
                      _convertedResultText!,
                      style: GoogleFonts.cairo(
                        color: theme.textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_convertedEventText != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _convertedEventText!,
                        style: GoogleFonts.cairo(
                          color: theme.accentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
