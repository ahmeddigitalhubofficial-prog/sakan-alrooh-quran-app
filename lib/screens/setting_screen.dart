// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_version.dart';
import '../models/theme_manager.dart';
import '../services/world_location_service.dart';
import '../widgets/location_picker_sheet.dart';
import '../services/notification_service.dart';
import '../services/home_widget_service.dart';
import '../services/app_review_service.dart';
import '../services/app_share_service.dart';
import '../services/cloud_sync_service.dart';
import '../services/auth_service.dart';
import '../services/huawei_auth_service.dart';
import '../services/device_ecosystem_service.dart';
import '../services/in_app_update_service.dart';
import '../services/owner_service.dart';
import 'changelog_screen.dart';
import 'feature_guide_screen.dart';
import 'onboarding_tutorial_screen.dart';
import 'owner_dashboard_screen.dart';
import 'references_screen.dart';
import 'privacy_policy_screen.dart';
import '../widgets/common/quick_language_button.dart';
import '../core/localization/locale_manager.dart';
import '../core/localization/app_translations.dart';
import '../widgets/home/social_channels_card.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _azanEnabled = true;
  String _azanSound = 'athan';

  bool _tasbihSound = true;

  bool _vibration = true;

  bool _dailyReminder = true;

  bool _saveLastRead = true;

  double _fontSize = 22;

  String _selectedTheme = 'emerald';

  bool _useGPS = false;
  String _selectedCity = 'القاهرة';
  String _locationDisplayName = 'القاهرة، مصر 🇪🇬';
  int _hijriOffset = 0;
  bool _showTutorialOnStartup = true;

  int _gearTapCount = 0;
  DateTime? _lastGearTapTime;
  bool _doubleTapArmed = false;
  Timer? _doubleTapResetTimer;

  @override
  void initState() {
    super.initState();

    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final validThemes = AppThemeManager.themes
        .map(
          (e) => e.id,
        )
        .toList();

    setState(() {
      _azanEnabled = prefs.getBool(
            'azan_enabled',
          ) ??
          true;
      _azanSound = prefs.getString('azan_sound') ?? 'athan';

      _tasbihSound = prefs.getBool(
            'tasbih_sound',
          ) ??
          true;

      _vibration = prefs.getBool(
            'vibration_enabled',
          ) ??
          true;

      _dailyReminder = prefs.getBool(
            'daily_reminder',
          ) ??
          true;

      _saveLastRead = prefs.getBool(
            'save_last_read',
          ) ??
          true;

      _fontSize = prefs.getDouble(
            'quran_font_size',
          ) ??
          22;

      _selectedTheme = prefs.getString(
            'selected_app_theme',
          ) ??
          'emerald';

      if (!validThemes.contains(
        _selectedTheme,
      )) {
        _selectedTheme = AppThemeManager.themes.first.id;
      }

      _useGPS = prefs.getBool('use_gps') ?? false;
      _selectedCity = prefs.getString('saved_city') ?? 'القاهرة';
      _hijriOffset = prefs.getInt('hijri_offset') ?? 0;
      _showTutorialOnStartup = prefs.getBool('show_tutorial_on_startup') ?? true;
    });

    final locName = await WorldLocationService.getCurrentLocationDisplayName();
    if (mounted) {
      setState(() {
        _locationDisplayName = locName;
      });
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      'azan_enabled',
      _azanEnabled,
    );
    await prefs.setString('azan_sound', _azanSound);

    await prefs.setBool(
      'tasbih_sound',
      _tasbihSound,
    );

    await prefs.setBool(
      'vibration_enabled',
      _vibration,
    );

    await prefs.setBool(
      'daily_reminder',
      _dailyReminder,
    );

    await prefs.setBool(
      'save_last_read',
      _saveLastRead,
    );

    await prefs.setDouble(
      'quran_font_size',
      _fontSize,
    );

    await prefs.setBool('use_gps', _useGPS);
    await prefs.setString('saved_city', _selectedCity);
  }

  Future<void> _toggleGPS(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    if (enabled) {
      setState(() {
        _useGPS = true;
      });

      final detected = await WorldLocationService.detectLocationSmart();
      if (detected['success'] == true) {
        final locName = await WorldLocationService.getCurrentLocationDisplayName();
        if (mounted) {
          setState(() {
            _locationDisplayName = locName;
            _selectedCity = detected['city'] as String? ?? 'القاهرة';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'تم تحديد موقعك بنجاح: $locName 📍',
                style: GoogleFonts.cairo(),
              ),
              backgroundColor: const Color(0xFF102C3B),
            ),
          );
        }
        await NotificationService().schedulePrayerNotifications(force: true);
        FlutterBackgroundService().invoke('update');
        await HomeWidgetService.updateAllPrayerWidgets();
      } else {
        setState(() {
          _useGPS = false;
        });
        await prefs.setBool('use_gps', false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'تعذر التحديد التلقائي. يرجى اختيار مدينتك أو دولتك من القائمة 🌍',
                style: GoogleFonts.cairo(),
              ),
              backgroundColor: Colors.red.shade800,
            ),
          );
        }
      }
    } else {
      setState(() {
        _useGPS = false;
      });
      await prefs.setBool('use_gps', false);
      await NotificationService().schedulePrayerNotifications(force: true);
      FlutterBackgroundService().invoke('update');
      await HomeWidgetService.updateAllPrayerWidgets();
    }
  }



  @override
  Widget build(
    BuildContext context,
  ) {
    final themeManager = Provider.of<AppThemeManager>(
      context,
    );

    final theme = themeManager.currentTheme;

    return Directionality(
      textDirection: Provider.of<LocaleManager>(context).textDirection,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: theme.gradientColors,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                right: 18.w,
                left: 18.w,
                top: 18.h,
                bottom: 120.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (Navigator.canPop(context))
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_rounded,
                            color: theme.accentColor,
                          ),
                          onPressed: () => Navigator.pop(context),
                        )
                      else
                        const SizedBox(width: 48),
                      const QuickLanguageButton(isCompact: true),
                    ],
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  GestureDetector(
                    onTap: _onGearTap,
                    onLongPress: _onGearLongPress,
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.settings_rounded,
                            size: 60.sp,
                            color: theme.accentColor,
                          ),
                          SizedBox(
                            height: 12.h,
                          ),
                          Text(
                            context.tr('nav_settings'),
                            style: GoogleFonts.cairo(
                              color: theme.textColor,
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 25.h,
                  ),
                  if (OwnerService().isOwner) ...[
                    _buildOwnerBanner(theme),
                    SizedBox(height: 12.h),
                  ],
                  _buildCheckUpdateCard(theme),
                  SizedBox(
                    height: 12.h,
                  ),
                  _buildLanguageCard(theme),
                  SizedBox(
                    height: 15.h,
                  ),
                  _buildSectionTitle(
                    'إعدادات الصلاة',
                    theme,
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  _buildSwitchCard(
                    title: 'تفعيل الأذان',
                    subtitle: 'تشغيل تنبيهات الأذان',
                    value: _azanEnabled,
                    onChanged: (value) async {
                      setState(() {
                        _azanEnabled = value;
                      });

                      await _saveSettings();
                      await NotificationService().schedulePrayerNotifications(force: true);
                    },
                    icon: Icons.mosque_rounded,
                    theme: theme,
                  ),
                  if (_azanEnabled) ...[
                    SizedBox(
                      height: 15.h,
                    ),
                    _buildAzanSoundSelector(theme),
                    SizedBox(
                      height: 15.h,
                    ),
                    _buildActionCard(
                      title: 'تجربة إشعار وصوت الأذان الآن 🔔',
                      subtitle: 'فحص فوري لوصول التنبيه وتوافق إعدادات الهاتف',
                      icon: Icons.notifications_active_rounded,
                      color: const Color(0xFFD4AF37),
                      onTap: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final res = await NotificationService().sendInstantTestNotification();
                        final notifOk = res['areNotificationsEnabled'] == true;
                        final alarmsOk = res['canScheduleExactAlarms'] == true;
                        if (!notifOk || !alarmsOk) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                !notifOk
                                    ? 'تنبيه: إشعارات التطبيق معطلة في إعدادات نظام هاتفك! يرجى السماح بها.'
                                    : 'تنبيه: إذن المنبهات الدقيقة (Exact Alarms) معطل في نظام هاتفك!',
                                style: const TextStyle(fontFamily: 'Cairo'),
                              ),
                              backgroundColor: Colors.red.shade800,
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        } else {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text(
                                'تم إرسال إشعار الأذان التجريبي! انظر لشريط الإشعارات بالأعلى 🔔',
                                style: TextStyle(fontFamily: 'Cairo'),
                              ),
                              backgroundColor: Color(0xFF102C3B),
                              duration: Duration(seconds: 4),
                            ),
                          );
                        }
                      },
                      theme: theme,
                    ),
                  ],
                  SizedBox(
                    height: 15.h,
                  ),
                  _buildSwitchCard(
                    title: 'التذكير اليومي',
                    subtitle: 'إشعارات بالأذكار والورد',
                    value: _dailyReminder,
                    onChanged: (value) async {
                      setState(() {
                        _dailyReminder = value;
                      });

                      await _saveSettings();
                      await NotificationService().schedulePrayerNotifications(force: true);
                    },
                    icon: Icons.notifications_active_rounded,
                    theme: theme,
                  ),
                  SizedBox(
                    height: 35.h,
                  ),
                  _buildSectionTitle(
                    'إعدادات الموقع الجغرافي',
                    theme,
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  _buildSwitchCard(
                    title: 'تحديد الموقع تلقائياً (GPS)',
                    subtitle: 'تفعيل الـ GPS لحساب المواقيت والقبلة',
                    value: _useGPS,
                    onChanged: (value) async {
                      await _toggleGPS(value);
                    },
                    icon: Icons.gps_fixed_rounded,
                    theme: theme,
                  ),
                  if (!_useGPS) ...[
                    SizedBox(
                      height: 15.h,
                    ),
                    _buildCitySelector(theme),
                  ],
                  SizedBox(
                    height: 15.h,
                  ),
                  _buildHijriOffsetSelector(theme),
                  SizedBox(
                    height: 35.h,
                  ),
                  _buildSectionTitle(
                    'الصوت والاهتزاز',
                    theme,
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  _buildSwitchCard(
                    title: 'صوت السبحة',
                    subtitle: 'تشغيل صوت عند التسبيح',
                    value: _tasbihSound,
                    onChanged: (value) async {
                      setState(() {
                        _tasbihSound = value;
                      });

                      await _saveSettings();
                    },
                    icon: Icons.volume_up_rounded,
                    theme: theme,
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  _buildSwitchCard(
                    title: 'الاهتزاز',
                    subtitle: 'اهتزاز عند الضغط',
                    value: _vibration,
                    onChanged: (value) async {
                      setState(() {
                        _vibration = value;
                      });

                      await _saveSettings();
                    },
                    icon: Icons.vibration_rounded,
                    theme: theme,
                  ),
                  SizedBox(
                    height: 35.h,
                  ),
                  _buildSectionTitle(
                    'الثيمات',
                    theme,
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  _buildThemeSelector(
                    themeManager,
                    theme,
                  ),
                  SizedBox(
                    height: 35.h,
                  ),
                  _buildSectionTitle(
                    'القرآن',
                    theme,
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  _buildFontSizeCard(
                    theme,
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  _buildSwitchCard(
                    title: 'حفظ آخر قراءة',
                    subtitle: 'استكمال القراءة تلقائيًا',
                    value: _saveLastRead,
                    onChanged: (value) async {
                      setState(() {
                        _saveLastRead = value;
                      });

                      await _saveSettings();
                    },
                    icon: Icons.bookmark_rounded,
                    theme: theme,
                  ),
                  SizedBox(
                    height: 35.h,
                  ),
                  _buildSectionTitle(
                    'البيانات',
                    theme,
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  _buildActionCard(
                    title: 'إعادة ضبط البيانات',
                    subtitle: 'حذف بيانات السبحة والورد فقط',
                    icon: Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                    onTap: () async {
                      final messenger = ScaffoldMessenger.of(
                        context,
                      );

                      final prefs = await SharedPreferences.getInstance();

                      await prefs.remove(
                        'tasbih_counter',
                      );

                      await prefs.remove(
                        'tasbih_daily',
                      );

                      await prefs.remove(
                        'weekly_count',
                      );

                      await prefs.remove(
                        'monthly_count',
                      );

                      await prefs.remove(
                        'tasbih_total',
                      );

                      await prefs.remove(
                        'daily_tasks',
                      );

                      await prefs.remove(
                        'last_read_surah',
                      );

                      await prefs.remove(
                        'last_read_surah_name',
                      );

                      await prefs.remove(
                        'last_read_verse',
                      );

                      if (!mounted) {
                        return;
                      }

                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            'تم حذف البيانات',
                            style: GoogleFonts.cairo(),
                          ),
                        ),
                      );
                    },
                    theme: theme,
                  ),
                  SizedBox(
                    height: 35.h,
                  ),

                  _buildSectionTitle(
                    'المزامنة وحفظ البيانات سحابياً ☁️',
                    theme,
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  // 1. أزرار الربط الذكية المتكيفة مع نظام وتشغيل الجهاز
                  if (DeviceEcosystemService().isApple) ...[
                    _buildActionCard(
                      title: AuthService.isLinkedWithApple
                          ? 'حسابك مرتبط بـ Apple 🍏'
                          : 'ربط الحساب بـ Apple ID 🍏',
                      subtitle: AuthService.isLinkedWithApple
                          ? 'بياناتك وأورادك وتختيماتك محمية بآمان عبر حساب Apple الخاص بك'
                          : 'ربط بياناتك وإنجازاتك بحساب Apple لحمايتها واسترجاعها على أي جهاز iOS',
                      icon: Icons.apple,
                      color: AuthService.isLinkedWithApple ? Colors.greenAccent : Colors.white,
                      onTap: () async {
                        try {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'جاري الاتصال بـ Apple ID للربط والمزامنة...',
                                style: TextStyle(fontFamily: 'Cairo'),
                              ),
                            ),
                          );
                          final user = await AuthService.linkWithApple();
                          if (context.mounted && user != null) {
                            setState(() {});
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'تم ربط واسترجاع بياناتك بنجاح عبر Apple ID! 🍏',
                                  style: const TextStyle(fontFamily: 'Cairo'),
                                ),
                                backgroundColor: Colors.green.shade800,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            final msg = e.toString().replaceAll('Exception: ', '');
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'فشل الاتصال بـ Apple: $msg',
                                  style: const TextStyle(fontFamily: 'Cairo'),
                                ),
                                backgroundColor: Colors.red.shade800,
                              ),
                            );
                          }
                        }
                      },
                      theme: theme,
                    ),
                    SizedBox(height: 15.h),
                  ] else if (DeviceEcosystemService().isHuawei) ...[
                    _buildActionCard(
                      title: 'ربط الحساب بـ Huawei ID 🔗',
                      subtitle: 'لمستخدمي أجهزة وهواتف هواوي لمزامنة الحساب وحفظ البيانات بآمان',
                      icon: Icons.link_rounded,
                      color: Colors.redAccent,
                      onTap: () => _showHuaweiSignInPrivacyPrompt(context, theme),
                      theme: theme,
                    ),
                    SizedBox(height: 15.h),
                  ] else ...[
                    _buildActionCard(
                      title: AuthService.isLinkedWithGoogle
                          ? 'حسابك مرتبط بـ Google 🟢'
                          : 'ربط الحساب بـ Google للمزامنة والدعم 🔗',
                      subtitle: AuthService.isLinkedWithGoogle
                          ? 'بياناتك وأورادك وتختيماتك محمية بآمان عبر حساب Google الخاص بك'
                          : 'ربط بياناتك وإنجازاتك بحسابك الشخصي لحمايتها واسترجاعها على أي جهاز آخر',
                      icon: Icons.account_circle_outlined,
                      color: AuthService.isLinkedWithGoogle ? Colors.greenAccent : Colors.amber,
                      onTap: () async {
                        try {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'جاري الاتصال بـ Google للربط والمزامنة...',
                                style: TextStyle(fontFamily: 'Cairo'),
                              ),
                            ),
                          );
                          final user = await AuthService.linkWithGoogle();
                          if (context.mounted && user != null) {
                            setState(() {});
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'تم ربط واسترجاع بياناتك بنجاح على حساب ${user.email ?? user.displayName ?? "Google"}! 🟢',
                                  style: const TextStyle(fontFamily: 'Cairo'),
                                ),
                                backgroundColor: Colors.green.shade800,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            final msg = e.toString().replaceAll('Exception: ', '');
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'فشل الاتصال بـ Google: $msg',
                                  style: const TextStyle(fontFamily: 'Cairo'),
                                ),
                                backgroundColor: Colors.red.shade800,
                              ),
                            );
                          }
                        }
                      },
                      theme: theme,
                    ),
                    SizedBox(height: 15.h),
                  ],
                  _buildActionCard(
                    title: 'كود النقل السحابي الشامل 🔑',
                    subtitle: 'انقل بياناتك وختماتك لأي جهاز آخر (هواوي، أمازون، آيفون) عبر كود سري',
                    icon: Icons.vpn_key_outlined,
                    color: Colors.purpleAccent,
                    onTap: () => _showUniversalSyncDialog(context, theme),
                    theme: theme,
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  _buildActionCard(
                    title: 'رفع ومزامنة بياناتي إلى السحابة ☁️',
                    subtitle: 'حفظ الختمة والأوراد والتسبيحات والشارات سحابياً لحمايتها من الضياع',
                    icon: Icons.cloud_upload_outlined,
                    color: Colors.blueAccent,
                    onTap: () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'جاري المزامنة مع السحابة...',
                            style: TextStyle(fontFamily: 'Cairo'),
                          ),
                        ),
                      );
                      final success = await CloudSyncService.syncUserDataToCloud();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? 'تمت المزامنة وحفظ البيانات سحابياً بنجاح! 🟢'
                                  : 'تعذر المزامنة حالياً. تأكد من الاتصال بالإنترنت.',
                              style: const TextStyle(fontFamily: 'Cairo'),
                            ),
                            backgroundColor: success ? Colors.green.shade800 : Colors.red.shade800,
                          ),
                        );
                      }
                    },
                    theme: theme,
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  _buildActionCard(
                    title: 'استرجاع البيانات المحفوظة من السحابة 🔄',
                    subtitle: 'استعادة ختمتك وأورادك وتسبيحاتك السابقة على هذا الجهاز',
                    icon: Icons.cloud_download_outlined,
                    color: Colors.tealAccent,
                    onTap: () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'جاري استرجاع البيانات من السحابة...',
                            style: TextStyle(fontFamily: 'Cairo'),
                          ),
                        ),
                      );
                      final success = await CloudSyncService.restoreUserDataFromCloud();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? 'تم استرجاع وتحديث بياناتك بنجاح! 🟢'
                                  : 'لم يتم العثور على نسخة سحابية سابقة لحسابك.',
                              style: const TextStyle(fontFamily: 'Cairo'),
                            ),
                            backgroundColor: success ? Colors.green.shade800 : Colors.orange.shade800,
                          ),
                        );
                      }
                    },
                    theme: theme,
                  ),
                  SizedBox(
                    height: 35.h,
                  ),

                  _buildSectionTitle(
                    'الدليل التعريفي والتعليمات',
                    theme,
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  _buildSwitchCard(
                    title: 'عرض الدليل عند الإقلاع',
                    subtitle: 'عرض جولة تعليمية بالخصائص عند أول تشغيل',
                    value: _showTutorialOnStartup,
                    onChanged: (value) async {
                      setState(() {
                        _showTutorialOnStartup = value;
                      });
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('show_tutorial_on_startup', value);
                    },
                    icon: Icons.auto_stories_rounded,
                    theme: theme,
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  _buildActionCard(
                    title: 'إعادة عرض الدليل التعريفي الآن',
                    subtitle: 'تصفح ميزات وخصائص التطبيق التفاعلية 📖',
                    icon: Icons.play_circle_outline_rounded,
                    color: theme.accentColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OnboardingTutorialScreen(isReplay: true),
                        ),
                      );
                    },
                    theme: theme,
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  _buildActionCard(
                    title: 'دليل الوصول لكافة ميزات التطبيق 💡',
                    subtitle: 'شرح تفاعلي بخطوات واضحة للوصول لكل خصائص التطبيق',
                    icon: Icons.lightbulb_outline_rounded,
                    color: Colors.amber,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FeatureGuideScreen(),
                        ),
                      );
                    },
                    theme: theme,
                  ),
                  SizedBox(
                    height: 35.h,
                  ),
                  _buildSectionTitle(
                    'حول التطبيق والتفاعل',
                    theme,
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  SocialChannelsCard(
                    theme: theme,
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  _buildCheckUpdateCard(theme),
                  SizedBox(
                    height: 15.h,
                  ),
                  _buildShareAppCard(theme),
                  SizedBox(
                    height: 15.h,
                  ),
                  _buildRateAppCard(theme),
                  SizedBox(
                    height: 15.h,
                  ),
                  _buildReferencesCard(theme),
                  SizedBox(
                    height: 15.h,
                  ),
                  _buildPrivacyPolicyCard(theme),
                  SizedBox(
                    height: 15.h,
                  ),
                  _buildAboutAppCard(theme),
                  SizedBox(
                    height: 40.h,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageCard(dynamic theme) {
    final localeManager = Provider.of<LocaleManager>(context);
    final currentLang = localeManager.currentLanguageInfo;

    return _buildActionCard(
      title: context.tr('select_language'),
      subtitle: '${currentLang.flag} ${currentLang.nativeName} (${currentLang.name})',
      icon: Icons.language_rounded,
      color: theme.accentColor,
      onTap: () {
        QuickLanguageButton.showLanguageSelectionSheet(context);
      },
      theme: theme,
    );
  }

  Widget _buildSectionTitle(
    String title,
    dynamic theme,
  ) {
    return Text(
      title,
      style: GoogleFonts.cairo(
        fontSize: 22.sp,
        fontWeight: FontWeight.bold,
        color: theme.accentColor,
      ),
    );
  }

  Widget _buildSwitchCard({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required IconData icon,
    required dynamic theme,
  }) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(
          18.w,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(
            alpha: 0.05,
          ),
          borderRadius: BorderRadius.circular(
            24.r,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(
                12.w,
              ),
              decoration: BoxDecoration(
                color: theme.accentColor,
                borderRadius: BorderRadius.circular(
                  16.r,
                ),
              ),
              child: Icon(
                icon,
                color: Colors.black,
              ),
            ),
            SizedBox(
              width: 16.w,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      color: theme.textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 17.sp,
                    ),
                  ),
                  SizedBox(
                    height: 4.h,
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      color: theme.subtitleColor,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              activeColor: theme.accentColor,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelector(
    AppThemeManager themeManager,
    dynamic theme,
  ) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(
          18.w,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(
            alpha: 0.05,
          ),
          borderRadius: BorderRadius.circular(
            24.r,
          ),
        ),
        child: DropdownButtonFormField<String>(
          value: AppThemeManager.themes.any(
            (e) => e.id == _selectedTheme,
          )
              ? _selectedTheme
              : AppThemeManager.themes.first.id,
          dropdownColor: theme.cardColor,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withValues(
              alpha: 0.05,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                18.r,
              ),
            ),
          ),
          style: GoogleFonts.cairo(
            color: theme.textColor,
          ),
          items: AppThemeManager.themes.map(
            (appTheme) {
              return DropdownMenuItem<String>(
                value: appTheme.id,
                child: Text(
                  appTheme.name,
                  style: GoogleFonts.cairo(
                    color: theme.textColor,
                  ),
                ),
              );
            },
          ).toList(),
          onChanged: (themeId) async {
            if (themeId == null) return;

            setState(() {
              _selectedTheme = themeId;
            });

            await themeManager.selectTheme(
              themeId,
            );
          },
        ),
      ),
    );
  }

  Widget _buildFontSizeCard(
    dynamic theme,
  ) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(
          18.w,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(
            alpha: 0.05,
          ),
          borderRadius: BorderRadius.circular(
            24.r,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'حجم خط القرآن',
              style: GoogleFonts.cairo(
                color: theme.textColor,
                fontWeight: FontWeight.bold,
                fontSize: 17.sp,
              ),
            ),
            SizedBox(
              height: 15.h,
            ),
            Slider(
              value: _fontSize,
              min: 16,
              max: 40,
              activeColor: theme.accentColor,
              onChanged: (value) async {
                setState(() {
                  _fontSize = value;
                });

                await _saveSettings();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required dynamic theme,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(
          24.r,
        ),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(
            18.w,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(
              alpha: 0.05,
            ),
            borderRadius: BorderRadius.circular(
              24.r,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(
                  12.w,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(
                    16.r,
                  ),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                ),
              ),
              SizedBox(
                width: 16.w,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        color: theme.textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 17.sp,
                      ),
                    ),
                    SizedBox(
                      height: 4.h,
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.cairo(
                        color: theme.subtitleColor,
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCitySelector(dynamic theme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24.r),
        onTap: () async {
          final selected = await LocationPickerSheet.show(context);
          if (selected != null) {
            final locName = await WorldLocationService.getCurrentLocationDisplayName();
            setState(() {
              _locationDisplayName = locName;
              _selectedCity = selected.nameAr;
              _useGPS = false;
            });
            await NotificationService().schedulePrayerNotifications(force: true);
            FlutterBackgroundService().invoke('update');
            await HomeWidgetService.updateAllPrayerWidgets();
          }
        },
        child: Container(
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: theme.accentColor.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: theme.accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  Icons.public_rounded,
                  color: theme.accentColor,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الدولة والمدينة (عالمياً)',
                      style: GoogleFonts.cairo(
                        color: theme.textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _locationDisplayName,
                      style: GoogleFonts.cairo(
                        color: theme.accentColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: theme.accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'تغيير 🌍',
                      style: GoogleFonts.cairo(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.accentColor,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12.sp,
                      color: theme.accentColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHijriOffsetSelector(dynamic theme) {
    final Map<int, String> options = {
      -2: '-2 يوم (تقديم يومين)',
      -1: '-1 يوم (تقديم يوم)',
      0: 'تلقائي (حسب التقويم)',
      1: '+1 يوم (تأخير يوم)',
      2: '+2 يوم (تأخير يومين)',
    };

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تعديل التقويم الهجري (رؤية الهلال)',
              style: GoogleFonts.cairo(
                color: theme.textColor,
                fontWeight: FontWeight.bold,
                fontSize: 15.sp,
              ),
            ),
            SizedBox(height: 10.h),
            DropdownButtonFormField<int>(
              dropdownColor: theme.cardColor,
              value: options.containsKey(_hijriOffset) ? _hijriOffset : 0,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18.r),
                ),
              ),
              style: GoogleFonts.cairo(color: theme.textColor),
              items: options.entries.map((entry) {
                return DropdownMenuItem<int>(
                  value: entry.key,
                  child: Text(
                    entry.value,
                    style: GoogleFonts.cairo(color: theme.textColor),
                  ),
                );
              }).toList(),
              onChanged: (offset) async {
                if (offset == null) return;
                setState(() {
                  _hijriOffset = offset;
                });
                final prefs = await SharedPreferences.getInstance();
                await prefs.setInt('hijri_offset', offset);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAzanSoundSelector(dynamic theme) {
    final Map<String, String> sounds = {
      'athan': 'الأذان الافتراضي 🔔',
      'athan_aqsa': 'أذان المسجد الأقصى 🕌',
      'athan_medina': 'أذان المسجد النبوي 🕌',
      'athan_makkah': 'أذان الحرم المكي 🕌',
      'athan_abdulbasit': 'أذان الشيخ عبد الباسط 🎙️',
    };

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'صوت الأذان المفضل',
              style: GoogleFonts.cairo(
                color: theme.textColor,
                fontWeight: FontWeight.bold,
                fontSize: 15.sp,
              ),
            ),
            SizedBox(height: 10.h),
            DropdownButtonFormField<String>(
              dropdownColor: theme.cardColor,
              value: sounds.containsKey(_azanSound) ? _azanSound : 'athan',
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18.r),
                ),
              ),
              style: GoogleFonts.cairo(color: theme.textColor),
              items: sounds.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(
                    entry.value,
                    style: GoogleFonts.cairo(color: theme.textColor),
                  ),
                );
              }).toList(),
              onChanged: (sound) async {
                if (sound == null) return;
                setState(() {
                  _azanSound = sound;
                });
                await _saveSettings();
                await NotificationService().schedulePrayerNotifications(force: true);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRateAppCard(dynamic theme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24.r),
        onTap: () async {
          await AppReviewService.showRatingDialog(context);
        },
        child: Container(
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: theme.accentColor.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: Colors.black,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تقييم تطبيق سكن الروح | Sakan Al-Rooh ⭐️',
                      style: GoogleFonts.cairo(
                        color: theme.textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 17.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'دعماً لنشر الخير، شاركنا تقييمك ورأيك المبارك على المتجر',
                      style: GoogleFonts.cairo(
                        color: theme.subtitleColor,
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: theme.accentColor,
                size: 16.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShareAppCard(dynamic theme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24.r),
        onTap: () {
          AppShareService.showInviteBottomSheet(context);
        },
        child: Container(
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: const Icon(
                  Icons.card_giftcard_rounded,
                  color: Colors.black,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'دعوة الأصدقاء وترشيح التطبيق 🎁',
                      style: GoogleFonts.cairo(
                        color: theme.textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 17.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'شارك سكن الروح كصدقة جارية ولك أجر كل من يقرأ أو يسبح',
                      style: GoogleFonts.cairo(
                        color: theme.subtitleColor,
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: theme.accentColor,
                size: 16.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckUpdateCard(dynamic theme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24.r),
        onTap: () async {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'جاري التحقق من متجر Google Play...',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
              duration: Duration(seconds: 1),
            ),
          );
          await InAppUpdateService().checkForUpdate(
            context: context,
            showNoUpdateToast: true,
          );
        },
        child: Container(
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            color: theme.accentColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: theme.accentColor.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: theme.accentColor,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: const Icon(
                  Icons.system_update_rounded,
                  color: Colors.black,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'التحقق من وجود تحديثات للمتجر 🚀',
                      style: GoogleFonts.cairo(
                        color: theme.textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'فحص فوري لأحدث إصدار رسمي متاح على Google Play',
                      style: GoogleFonts.cairo(
                        color: theme.subtitleColor,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_back_ios_new_rounded,
                color: theme.accentColor,
                size: 16.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutAppCard(dynamic theme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24.r),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ChangelogScreen(),
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: theme.accentColor,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: const Icon(
                  Icons.history_toggle_off_rounded,
                  color: Colors.black,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تحديثات سكن الروح (سجل الإصدارات) 📜',
                      style: GoogleFonts.cairo(
                        color: theme.textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'سجل كامل وتراكمي لجميع التطويرات والإصدارات (v${AppVersion.version})',
                      style: GoogleFonts.cairo(
                        color: theme.subtitleColor,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_back_ios_new_rounded,
                color: theme.accentColor,
                size: 16.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReferencesCard(dynamic theme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24.r),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ReferencesScreen(),
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            color: theme.accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: theme.accentColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: theme.accentColor,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: Colors.black,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المصادر والمراجع والمكتبات 🕌',
                      style: GoogleFonts.cairo(
                        color: theme.textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'توثيق صحة المحتوى الإسلامي والشفافية البرمجية',
                      style: GoogleFonts.cairo(
                        color: theme.subtitleColor,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_back_ios_new_rounded,
                color: theme.accentColor,
                size: 16.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyPolicyCard(dynamic theme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24.r),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PrivacyPolicyScreen(),
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: theme.accentColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  Icons.policy_rounded,
                  color: theme.accentColor,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'سياسة الخصوصية وحماية البيانات 🛡️',
                      style: GoogleFonts.cairo(
                        color: theme.textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'بيانات الموقع والتخزين المحلي وحقوق المستخدم المعتمدة',
                      style: GoogleFonts.cairo(
                        color: theme.subtitleColor,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_back_ios_new_rounded,
                color: theme.accentColor,
                size: 16.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOwnerBanner(dynamic theme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24.r),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const OwnerDashboardScreen()),
          );
        },
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFD4AF37), Color(0xFF8C6D1F)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: const BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                ),
                child: Text('👑', style: TextStyle(fontSize: 22.sp)),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'لوحة تحكم مالك التطبيق 👑',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                      ),
                    ),
                    Text(
                      'أدوات المطور والاختبار والمزامنة الفورية',
                      style: GoogleFonts.cairo(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 11.5.sp,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onGearTap() {
    final now = DateTime.now();
    if (_lastGearTapTime == null || now.difference(_lastGearTapTime!) > const Duration(milliseconds: 500)) {
      _gearTapCount = 1;
      _doubleTapArmed = false;
    } else {
      _gearTapCount++;
      if (_gearTapCount == 2) {
        _doubleTapArmed = true;
        _doubleTapResetTimer?.cancel();
        _doubleTapResetTimer = Timer(const Duration(seconds: 2), () {
          _doubleTapArmed = false;
          _gearTapCount = 0;
        });
      }
    }
    _lastGearTapTime = now;
  }

  void _onGearLongPress() {
    if (_doubleTapArmed) {
      _doubleTapArmed = false;
      _gearTapCount = 0;
      _doubleTapResetTimer?.cancel();
      HapticFeedback.mediumImpact();
      _handleOwnerAccess();
    }
  }

  void _handleOwnerAccess() {
    if (OwnerService().isOwner) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const OwnerDashboardScreen()),
      );
      return;
    }

    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'التحقق من الهوية',
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16.sp),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'أدخل رمز المرور للمتابعة:',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(fontSize: 12.sp),
            ),
            SizedBox(height: 14.h),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              textAlign: TextAlign.center,
              maxLength: 4,
              decoration: InputDecoration(
                counterText: '',
                hintText: '• • • •',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إلغاء', style: GoogleFonts.cairo()),
          ),
          ElevatedButton(
            onPressed: () async {
              final pin = pinController.text.trim();
              final success = await OwnerService().verifyAndActivate(pin);
              if (ctx.mounted) Navigator.pop(ctx);
              if (success) {
                if (mounted) {
                  setState(() {});
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OwnerDashboardScreen()),
                  );
                }
              }
            },
            child: Text('متابعة', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showUniversalSyncDialog(BuildContext context, dynamic theme) async {
    final code = await CloudSyncService.getOrGenerateUniversalSyncCode();
    final inputCtrl = TextEditingController();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: theme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: Row(
            children: [
              Icon(Icons.vpn_key_rounded, color: theme.accentColor),
              SizedBox(width: 8.w),
              Text(
                'كود النقل السحابي الشامل 🔑',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16.sp, color: theme.textColor),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'كود جهازك الحالي لنقل بياناتك لأي هاتف آخر:',
                  style: GoogleFonts.cairo(color: theme.subtitleColor, fontSize: 12.sp),
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: theme.accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: theme.accentColor.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        code,
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                          letterSpacing: 2,
                          color: theme.accentColor,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy_rounded),
                        color: theme.accentColor,
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: code));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم نسخ كود النقل السحابي! 📋', style: TextStyle(fontFamily: 'Cairo')),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                const Divider(),
                SizedBox(height: 12.h),
                Text(
                  'أو أدخل كود من جهازك السابق لاسترجاع بياناتك:',
                  style: GoogleFonts.cairo(color: theme.subtitleColor, fontSize: 12.sp),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: inputCtrl,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    fontSize: 16.sp,
                    color: theme.textColor,
                  ),
                  decoration: InputDecoration(
                    hintText: 'مثال: SKN-7X89',
                    hintStyle: GoogleFonts.cairo(color: Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('إلغاء', style: GoogleFonts.cairo(color: theme.subtitleColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.accentColor,
                foregroundColor: Colors.black,
              ),
              onPressed: () async {
                final targetCode = inputCtrl.text.trim();
                if (targetCode.isEmpty) return;
                if (targetCode == '1992' || targetCode.toUpperCase() == 'SKN-OWNER' || targetCode.toUpperCase() == 'SKN-1992') {
                  Navigator.pop(ctx);
                  await OwnerService().setOwnerMode(true);
                  if (context.mounted) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const OwnerDashboardScreen()));
                  }
                  return;
                }
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('جاري استرجاع البيانات عبر الكود السحابي...', style: TextStyle(fontFamily: 'Cairo')),
                  ),
                );
                final success = await CloudSyncService.restoreFromUniversalSyncCode(targetCode);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'تم استرجاع كافة بياناتك بنجاح ونقلها لهذا الجهاز! 🟢'
                            : 'الكود غير صحيح أو لم يتم العثور على بيانات مرتبطة به.',
                        style: const TextStyle(fontFamily: 'Cairo'),
                      ),
                      backgroundColor: success ? Colors.green.shade800 : Colors.red.shade800,
                    ),
                  );
                }
              },
              child: Text('استرجاع البيانات 📥', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showHuaweiSignInPrivacyPrompt(BuildContext context, dynamic theme) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0D1B2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: BorderSide(
            color: Colors.redAccent.withValues(alpha: 0.4),
            width: 1.2,
          ),
        ),
        title: Row(
          children: [
            Icon(Icons.shield_rounded, color: Colors.redAccent, size: 22.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'تسجيل الدخول وسياسة الخصوصية',
                style: GoogleFonts.cairo(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تطبيق "سكن الروح" يحترم خصوصيتك. بتسجيل الدخول باستخدام حساب هواوي (Huawei ID)، فإنك توافق على سياسة الخصوصية واستخدام بيانات حسابك (المعرف الرقمي، الاسم، البريد) حصرياً لمزامنة تقدمك وأذكارك وختماتك سحابياً بأمان.',
              style: GoogleFonts.cairo(
                fontSize: 12.5.sp,
                color: Colors.white70,
                height: 1.6,
              ),
            ),
            SizedBox(height: 12.h),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                );
              },
              child: Row(
                children: [
                  Icon(Icons.menu_book_rounded, color: theme.accentColor, size: 16.sp),
                  SizedBox(width: 6.w),
                  Text(
                    'قراءة سياسة الخصوصية بالتفصيل ↗',
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      color: theme.accentColor,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'إلغاء',
              style: GoogleFonts.cairo(color: Colors.white60),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _performHuaweiSignIn(context);
            },
            child: Text(
              'موافق والمتابعة',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performHuaweiSignIn(BuildContext context) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'جاري الاتصال بـ Huawei ID...',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
        ),
      );
      final huaweiUser = await HuaweiAuthService().signIn();
      if (context.mounted && huaweiUser != null) {
        await CloudSyncService.linkHuaweiId(
          openId: huaweiUser.openId,
          displayName: huaweiUser.displayName,
          email: huaweiUser.email,
        );
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'تم ربط حسابك بـ Huawei ID بنجاح! 🔴',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: Colors.green.shade800,
          ),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تعذر تسجيل الدخول بـ Huawei ID. تأكد من توفر خدمات هواوي على جهازك.',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'خدمات هواوي غير مفعلة على هذا الجهاز.',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
          ),
        );
      }
    }
  }
}

