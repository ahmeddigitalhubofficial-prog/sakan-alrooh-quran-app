// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhan/adhan.dart';

import '../core/constants/app_version.dart';
import '../models/theme_manager.dart';
import '../services/cloud_sync_service.dart';
import '../services/in_app_update_service.dart';
import '../services/owner_service.dart';
import '../services/notification_service.dart';
import '../services/prayer_service.dart';


class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  bool _isTestingSync = false;
  String _syncStatusText = 'جاهز للفحص السحابي';
  final TextEditingController _announcementController = TextEditingController();
  int _retainedUsersCount = 1;
  int _registeredUsersCount = 1;
  int _pendingNotificationsCount = 0;
  Map<String, dynamic>? _remoteSyncInfo;
  String? _todayPrayerSummary;

  @override
  void initState() {
    super.initState();
    _loadRetainedUsers();
    _loadNotificationHealth();
  }

  Future<void> _loadRetainedUsers() async {
    try {
      final retainedCount = await CloudSyncService.getRetainedUsersCount();
      final totalRegistered = await CloudSyncService.getTotalRegisteredUsersCount();
      if (mounted) {
        setState(() {
          _retainedUsersCount = retainedCount;
          _registeredUsersCount = totalRegistered > 0 ? totalRegistered : 1;
        });
      }
    } catch (e) {
      debugPrint('Error loading retained users: $e');
    }
  }

  String _formatNum(dynamic n) {
    if (n == null) return '0';
    if (n is num) {
      return NumberFormat('#,###').format(n);
    }
    return n.toString();
  }

  Future<void> _loadNotificationHealth() async {
    try {
      final notifs = await NotificationService().getPendingNotifications();
      final syncInfo = await CloudSyncService.getRemoteNotificationSyncInfo();
      final prefs = await SharedPreferences.getInstance();

      final useGPS = prefs.getBool('use_gps') ?? false;
      Coordinates coordinates = Coordinates(30.0444, 31.2357);
      if (useGPS) {
        final lat = prefs.getDouble('saved_lat');
        final lng = prefs.getDouble('saved_lng');
        if (lat != null && lng != null) coordinates = Coordinates(lat, lng);
      }
      final now = DateTime.now();
      final pt = PrayerService.getPrayerTimes(coordinates, now);
      final timeFmt = DateFormat('h:mm a', 'ar');
      final prayerSummary = 'فجر ${timeFmt.format(pt.fajr)} • ظهر ${timeFmt.format(pt.dhuhr)} • عصر ${timeFmt.format(pt.asr)} • مغرب ${timeFmt.format(pt.maghrib)} • عشاء ${timeFmt.format(pt.isha)}';

      if (mounted) {
        setState(() {
          _pendingNotificationsCount = notifs.length;
          _remoteSyncInfo = syncInfo;
          _todayPrayerSummary = prayerSummary;
        });
      }
    } catch (e) {
      debugPrint('Error loading notification health: $e');
    }
  }

  @override
  void dispose() {
    _announcementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<AppThemeManager>(context);
    final theme = themeManager.currentTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'لوحة تحكم مالك التطبيق 👑',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 17.sp),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Owner Status Card
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFD4AF37),
                      Color(0xFF8C6D1F),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: const BoxDecoration(
                            color: Colors.black26,
                            shape: BoxShape.circle,
                          ),
                          child: Text('👑', style: TextStyle(fontSize: 24.sp)),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'وضع المالك والمطور مفعّل',
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.sp,
                                ),
                              ),
                              Text(
                                'حساب المالك: ${OwnerService.ownerEmail}',
                                style: GoogleFonts.cairo(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 11.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    const Divider(color: Colors.white24),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'الإصدار: ${AppVersion.version} (Build ${AppVersion.buildNumber})',
                          style: GoogleFonts.cairo(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'نقاطك: ${themeManager.hasanatPoints} 💎',
                          style: GoogleFonts.cairo(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // 2. Section: User Analytics & Retention (Level 4 Analytics)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'إحصائيات المستخدمين والتثبيتات والاحتفاظ 👥',
                    style: GoogleFonts.cairo(
                      color: theme.accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh_rounded, size: 20.sp, color: theme.accentColor),
                    tooltip: 'تحديث الإحصائيات الآن',
                    onPressed: () async {
                      HapticFeedback.lightImpact();
                      final messenger = ScaffoldMessenger.of(context);
                      await _loadRetainedUsers();
                      if (mounted) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('تم تحديث أرقام المستخدمين والاحتفاظ 🔄', style: GoogleFonts.cairo()),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 6.h),

              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: CloudSyncService.getAdminOverviewStream(),
                builder: (context, snapshot) {
                  final data = snapshot.data?.data();
                  final harvest = data?['spiritual_harvest'] as Map<String, dynamic>? ?? {};
                  final rawInstalls = (data?['total_installations'] as int?) ?? 0;
                  final totalInstalls = rawInstalls > _registeredUsersCount ? rawInstalls : _registeredUsersCount;
                  final totalSyncs = harvest['total_sync_events'] ?? 0;
                  final totalTasbih = harvest['total_tasbih_counted'] ?? 0;
                  final totalFasting = harvest['total_fasting_days'] ?? 0;
                  
                  final effectiveInstalls = totalInstalls > 0 ? totalInstalls : 1;
                  final retained = _retainedUsersCount > effectiveInstalls ? effectiveInstalls : _retainedUsersCount;
                  final retentionRate = ((retained / effectiveInstalls) * 100.0).clamp(0.0, 100.0);

                  return Column(
                    children: [
                      Row(
                        children: [
                          _buildMetricCard('إجمالي التثبيتات', '${_formatNum(totalInstalls)} 📲', const Color(0xFFE5C07B), theme),
                          SizedBox(width: 8.w),
                          _buildMetricCard('محتفظون بالتطبيق', '${_formatNum(retained)} 🟢', const Color(0xFF00E676), theme),
                          SizedBox(width: 8.w),
                          _buildMetricCard('نسبة الاحتفاظ', '${retentionRate.toStringAsFixed(0)}% 📈', const Color(0xFF64B5F6), theme),
                        ],
                      ),
                      SizedBox(height: 14.h),
                      Row(
                        children: [
                          _buildMetricCard('عمليات المزامنة', '${_formatNum(totalSyncs)} 🔄', const Color(0xFF42A5F5), theme),
                          SizedBox(width: 8.w),
                          _buildMetricCard('إجمالي التسبيحات', '${_formatNum(totalTasbih)} 📿', const Color(0xFF00E676), theme),
                          SizedBox(width: 8.w),
                          _buildMetricCard('أيام الصيام', '${_formatNum(totalFasting)} 🌙', const Color(0xFFFFB74D), theme),
                        ],
                      ),
                    ],
                  );
                },
              ),

              SizedBox(height: 20.h),

              // 3. Section: Global Announcement Remote Control
              Text(
                'التحكم في الإعلانات والتنبيهات العامة 📢',
                style: GoogleFonts.cairo(
                  color: theme.accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15.sp,
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: theme.accentColor.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _announcementController,
                      style: GoogleFonts.cairo(color: theme.textColor, fontSize: 13.sp),
                      decoration: InputDecoration(
                        hintText: 'اكتب رسالة عامة تظهر لجميع المستخدمين في الشاشة الرئيسية...',
                        hintStyle: GoogleFonts.cairo(color: theme.subtitleColor, fontSize: 12.sp),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r)),
                        filled: true,
                        fillColor: Colors.black12,
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.accentColor,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                            ),
                            icon: const Icon(Icons.send_rounded, size: 18),
                            label: Text('نشر الإعلان للجميع', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                            onPressed: () async {
                              final text = _announcementController.text.trim();
                              if (text.isNotEmpty) {
                                await CloudSyncService.updateGlobalAnnouncement(text);
                                _announcementController.clear();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('تم نشر الإعلان بنجاح في السحابة 📢', style: GoogleFonts.cairo())),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 8.w),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                          tooltip: 'مسح الإعلان الحالي',
                          onPressed: () async {
                            await CloudSyncService.updateGlobalAnnouncement('');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('تم مسح الإعلان العام', style: GoogleFonts.cairo())),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // 3. Section: Cloud Notification Center
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'مركز الإشعارات والمزامنة الشاملة 🕌',
                    style: GoogleFonts.cairo(
                      color: theme.accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    tooltip: 'تحديث حالة الإشعارات',
                    onPressed: _loadNotificationHealth,
                  ),
                ],
              ),
              SizedBox(height: 8.h),

              // Health Status Card
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: theme.accentColor.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.notifications_active_rounded, color: Colors.amber, size: 22.sp),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'الإشعارات المجدولة بالنظام: $_pendingNotificationsCount إشعار',
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.sp,
                              color: theme.textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_todayPrayerSummary != null) ...[
                      SizedBox(height: 6.h),
                      Text(
                        _todayPrayerSummary!,
                        style: GoogleFonts.cairo(
                          fontSize: 11.sp,
                          color: theme.textColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                    if (_remoteSyncInfo != null) ...[
                      SizedBox(height: 6.h),
                      Text(
                        'إصدار المزامنة السحابية: ${_remoteSyncInfo!['version'] ?? 'افتراضي'} (${_remoteSyncInfo!['note'] ?? ''})',
                        style: GoogleFonts.cairo(
                          fontSize: 11.sp,
                          color: Colors.greenAccent,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 10.h),

              // Force Global Notification Resync (Cloud Sync for All Users)
              _buildAdminActionCard(
                icon: Icons.cell_tower_rounded,
                title: 'إعادة مزامنة إشعارات جميع المستخدمين حول العالم 🔄',
                subtitle: 'إجبار هواتف جميع المستخدمين على إعادة جدولة وتثبيت الأذان والأذكار فوراً',
                color: const Color(0xFF9C27B0),
                theme: theme,
                onTap: () async {
                  HapticFeedback.heavyImpact();
                  final messenger = ScaffoldMessenger.of(context);
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('تأكيد إعادة المزامنة العالمية', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                      content: Text('هل تريد إرسال أمر سحابي لجميع مستخدمي التطبيق لتحديث وإعادة جدولة إشعارات الأذان والأذكار بالكامل؟', style: GoogleFonts.cairo()),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text('إلغاء', style: GoogleFonts.cairo()),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9C27B0)),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text('تأكيد الإرسال', style: GoogleFonts.cairo(color: Colors.white)),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    try {
                      await CloudSyncService.triggerGlobalNotificationResync(
                        note: 'تحديث شامل لجدولة الأذان والمنبهات (الوضع الدقيق)',
                      );
                      await _loadNotificationHealth();
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('تم إرسال أمر المزامنة العالمية لجميع المستخدمين بنجاح! 🚀', style: GoogleFonts.cairo()),
                          backgroundColor: Colors.green[700],
                        ),
                      );
                    } catch (e) {
                      messenger.showSnackBar(
                        SnackBar(content: Text('حدث خطأ أثناء الإرسال: $e', style: GoogleFonts.cairo())),
                      );
                    }
                  }
                },
              ),
              SizedBox(height: 10.h),

              // Test Audio Instant Notifications
              Row(
                children: [
                  Expanded(
                    child: _buildMiniActionBtn(
                      title: 'تجربة الفجر 🔊',
                      color: const Color(0xFF2E7D32),
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        await NotificationService().showInstantAzanNotification(
                          prayerId: 1000,
                          prayerName: 'الفجر (تجريبي)',
                          sound: 'fajr_athan',
                          cityName: 'القاهرة',
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _buildMiniActionBtn(
                      title: 'تجربة الأذان 🔊',
                      color: const Color(0xFF1565C0),
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        await NotificationService().showInstantAzanNotification(
                          prayerId: 1001,
                          prayerName: 'الظهر (تجريبي)',
                          sound: 'athan1',
                          cityName: 'القاهرة',
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _buildMiniActionBtn(
                      title: 'تجربة الأذكار 🔔',
                      color: const Color(0xFFE65100),
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        await NotificationService().showInstantAzkarNotification(
                          id: 9999,
                          title: 'أذكار الصباح (تجريبي) ☀️',
                          body: 'ابتدئ يومك بذكر الله، تجربة وصول الإشعار والصوت بنجاح.',
                          payload: 'azkar_sabah',
                        );
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              // 4. Section: Developer Tools
              Text(
                'أدوات الاختبار السريع 🛠️',
                style: GoogleFonts.cairo(
                  color: theme.accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15.sp,
                ),
              ),
              SizedBox(height: 12.h),

              // Add Hasanat points
              _buildAdminActionCard(
                icon: Icons.diamond_rounded,
                title: 'إضافة +5,000 نقطة حسنات تجريبية',
                subtitle: 'لشراء واختبار عناصر المتجر فوراً',
                color: const Color(0xFF00E676),
                theme: theme,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  themeManager.addHasanatPoints(5000);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('تمت إضافة 5,000 حسنة بنجاح 💎', style: GoogleFonts.cairo())),
                  );
                },
              ),

              SizedBox(height: 10.h),

              // Trigger In-App update check
              _buildAdminActionCard(
                icon: Icons.system_update_rounded,
                title: 'فحص التحديث المباشر للمتجر',
                subtitle: 'تشغيل محاكي Google Play In-App Update',
                color: const Color(0xFF42A5F5),
                theme: theme,
                onTap: () async {
                  HapticFeedback.lightImpact();
                  await InAppUpdateService.manualCheckForUpdate(context);
                },
              ),

              SizedBox(height: 10.h),

              // Trigger Full Cloud Sync
              _buildAdminActionCard(
                icon: Icons.cloud_sync_rounded,
                title: _isTestingSync ? 'جاري رفع البيانات...' : 'مزامنة فورية شاملة مع Firebase',
                subtitle: _syncStatusText,
                color: const Color(0xFFFF9800),
                theme: theme,
                onTap: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  setState(() {
                    _isTestingSync = true;
                    _syncStatusText = 'جاري الاتصال بالسحابة...';
                  });
                  final success = await CloudSyncService.syncUserDataToCloud();
                  if (!mounted) return;
                  final text = success
                      ? 'تمت المزامنة بنجاح في تمام ${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}'
                      : 'فشل الاتصال بالسحابة';
                  setState(() {
                    _isTestingSync = false;
                    _syncStatusText = text;
                  });
                  messenger.showSnackBar(
                    SnackBar(content: Text(text, style: GoogleFonts.cairo())),
                  );
                },
              ),

              SizedBox(height: 10.h),

              // Lock / Exit Owner Mode
              _buildAdminActionCard(
                icon: Icons.lock_outline_rounded,
                title: 'إيقاف وضع المالك',
                subtitle: 'إعادة التطبيق لوضع المستخدم العادي',
                color: Colors.redAccent,
                theme: theme,
                onTap: () async {
                  final navigator = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(context);
                  await OwnerService().setOwnerMode(false);
                  if (!mounted) return;
                  navigator.pop();
                  messenger.showSnackBar(
                    SnackBar(content: Text('تم إيقاف وضع المالك', style: GoogleFonts.cairo())),
                  );
                },
              ),

              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, Color color, AppTheme theme) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(value, style: GoogleFonts.cairo(color: color, fontWeight: FontWeight.bold, fontSize: 14.sp)),
            SizedBox(height: 2.h),
            Text(title, textAlign: TextAlign.center, style: GoogleFonts.cairo(color: theme.subtitleColor, fontSize: 10.sp)),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required AppTheme theme,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: color, size: 22.sp),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        color: theme.textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5.sp,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.cairo(
                        color: theme.subtitleColor,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: theme.subtitleColor, size: 14.sp),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniActionBtn({
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              fontSize: 11.5.sp,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

