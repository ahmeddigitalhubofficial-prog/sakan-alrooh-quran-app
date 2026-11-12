// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/theme_manager.dart';
import '../services/world_location_service.dart';
import '../services/notification_service.dart';
import '../services/home_widget_service.dart';
import '../services/prayer_service.dart';
import 'common/auto_scroll_text.dart';

class LocationPickerSheet extends StatefulWidget {
  const LocationPickerSheet({super.key});

  static Future<WorldCity?> show(BuildContext context) {
    return showModalBottomSheet<WorldCity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const LocationPickerSheet(),
    );
  }

  @override
  State<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<LocationPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<WorldCity> _filteredCities = [];
  bool _isDetecting = false;
  String _activeLocationDisplay = 'جاري التحميل...';

  final List<String> _quickCityIds = [
    'makkah',
    'madinah',
    'cairo',
    'riyadh',
    'dubai',
    'jerusalem',
    'alexandria',
    'doha',
    'kuwait_city',
  ];

  @override
  void initState() {
    super.initState();
    _filteredCities = WorldLocationService.allCities;
    _loadActiveLocation();
  }

  Future<void> _loadActiveLocation() async {
    final name = await WorldLocationService.getCurrentLocationDisplayName();
    if (mounted) {
      setState(() {
        _activeLocationDisplay = name;
      });
    }
  }

  void _onSearch(String query) {
    setState(() {
      _filteredCities = WorldLocationService.searchCities(query);
    });
  }

  Future<void> _selectCity(WorldCity city) async {
    HapticFeedback.mediumImpact();
    await WorldLocationService.saveManualCity(city);
    await PrayerService.loadCachedMethod();
    await NotificationService().schedulePrayerNotifications(force: true);
    await HomeWidgetService.updateAllPrayerWidgets();
    try {
      FlutterBackgroundService().invoke('update');
    } catch (_) {}

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF1E293B),
          content: Text(
            'تم ضبط مواقيت الصلاة لـ ${city.nameAr}، ${city.countryAr} ${city.flag} 🕌',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
        ),
      );
      Navigator.pop(context, city);
    }
  }

  Future<void> _detectSmartLocation() async {
    setState(() => _isDetecting = true);
    HapticFeedback.lightImpact();

    try {
      final res = await WorldLocationService.detectLocationSmart();
      if (res['success'] == true) {
        await PrayerService.loadCachedMethod();
        await NotificationService().schedulePrayerNotifications(force: true);
        await HomeWidgetService.updateAllPrayerWidgets();
        try {
          FlutterBackgroundService().invoke('update');
        } catch (_) {}

        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF0F766E),
              content: Text(
                'تم تحديد موقعك بدقة: ${res['display']} ✨',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
            ),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(
                'تعذر تحديد الموقع تلقائياً؛ يرجى اختيار مدينتك من القائمة أو البحث باسمها.',
                style: GoogleFonts.cairo(),
              ),
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isDetecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<AppThemeManager>(context).currentTheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            SizedBox(height: 12.h),
            Center(
              child: Container(
                width: 48.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: theme.accentColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.public_rounded, color: theme.accentColor, size: 24.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تحديد المدينة ومواقيت الصلاة العالمية',
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        AutoScrollText(
                          'الموقع الحالي: $_activeLocationDisplay',
                          style: GoogleFonts.cairo(
                            color: theme.accentColor,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),

            // Smart Auto-Detect Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: InkWell(
                onTap: _isDetecting ? null : _detectSmartLocation,
                borderRadius: BorderRadius.circular(16.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.accentColor.withValues(alpha: 0.25),
                        theme.accentColor.withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: theme.accentColor.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isDetecting)
                        SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.accentColor,
                          ),
                        )
                      else
                        Icon(Icons.my_location_rounded, color: theme.accentColor, size: 22.sp),
                      SizedBox(width: 10.w),
                      Text(
                        _isDetecting ? 'جاري تحديد موقعك الفعلي...' : 'تحديد موقعي تلقائياً (GPS والإنترنت)',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 14.h),

            // Search Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearch,
                style: GoogleFonts.cairo(color: Colors.white, fontSize: 14.sp),
                decoration: InputDecoration(
                  hintText: 'ابحث باسم المدينة أو الدولة (مكة، دبي، المنصورة، باريس...)',
                  hintStyle: GoogleFonts.cairo(color: Colors.white38, fontSize: 13.sp),
                  prefixIcon: const Icon(Icons.search_rounded, color: Colors.white54),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: Colors.white54),
                          onPressed: () {
                            _searchController.clear();
                            _onSearch('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.06),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide(color: theme.accentColor),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // Quick Selection Chips
            SizedBox(
              height: 38.h,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                children: _quickCityIds.map((id) {
                  final city = WorldLocationService.findCity(id);
                  if (city == null) return const SizedBox.shrink();
                  return Padding(
                    padding: EdgeInsets.only(left: 8.w),
                    child: ActionChip(
                      onPressed: () => _selectCity(city),
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                      label: Text(
                        '${city.flag} ${city.nameAr}',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 10.h),

            const Divider(color: Colors.white10, height: 1),

            // Cities List
            Expanded(
              child: _filteredCities.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_off_rounded, size: 48.sp, color: Colors.white30),
                          SizedBox(height: 10.h),
                          Text(
                            'لم يتم العثور على مدينة بهذا الاسم',
                            style: GoogleFonts.cairo(color: Colors.white70, fontSize: 14.sp),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'يمكنك استخدام زر التحديد التلقائي لضبط إحداثياتك الحالية',
                            style: GoogleFonts.cairo(color: Colors.white38, fontSize: 12.sp),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                      itemCount: _filteredCities.length,
                      separatorBuilder: (_, __) => Divider(color: Colors.white.withValues(alpha: 0.04), height: 1),
                      itemBuilder: (context, index) {
                        final city = _filteredCities[index];
                        return ListTile(
                          onTap: () => _selectCity(city),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
                          leading: Text(
                            city.flag,
                            style: TextStyle(fontSize: 26.sp),
                          ),
                          title: Text(
                            city.nameAr,
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${city.countryAr} • ${city.nameEn}',
                            style: GoogleFonts.cairo(
                              color: Colors.white54,
                              fontSize: 12.sp,
                            ),
                          ),
                          trailing: Icon(
                            Icons.chevron_left_rounded,
                            color: Colors.white38,
                            size: 20.sp,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
