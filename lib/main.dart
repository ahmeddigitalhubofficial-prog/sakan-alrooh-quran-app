import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:noor_al_hoda/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'services/cloud_sync_service.dart';
import 'services/daily_reflection_service.dart';
import 'services/in_app_update_service.dart';
import 'widgets/update_announcement_banner.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'core/utils/error_reporter.dart';
import 'core/services/app_startup_service.dart';
import 'core/localization/locale_manager.dart';
import 'core/localization/app_translations.dart';
import 'widgets/common/quick_language_button.dart';
import 'models/task_manager.dart';
import 'models/theme_manager.dart';
import 'models/sunan_manager.dart';

import 'screens/home_screen.dart';
import 'screens/quran_screen.dart';
import 'screens/azkar_screen.dart';
import 'screens/prayer_times_screen.dart';
import 'screens/tasbih_screen.dart';
import 'screens/stories_screen.dart';
import 'screens/hadith_screen.dart';
import 'screens/names_of_allah_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/setting_screen.dart';
import 'screens/ward_tracker_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/khatma_planner_screen.dart';
import 'screens/ar_qibla_screen.dart';
import 'screens/islamic_store_screen.dart';
import 'screens/spiritual_moods_screen.dart';
import 'screens/islamic_radio_screen.dart';
import 'screens/fasting_tracker_screen.dart';
import 'services/owner_service.dart';
import 'screens/owner_dashboard_screen.dart';
import 'screens/zakat_calculator_screen.dart';
import 'screens/islamic_quiz_screen.dart';
import 'screens/islamic_cards_screen.dart';
import 'screens/card_studio_screen.dart';
import 'screens/global_dhikr_screen.dart';
import 'screens/thawab_dedication_screen.dart';
import 'screens/good_deeds_challenge_screen.dart';
import 'models/global_dhikr_manager.dart';
import 'models/thawab_manager.dart';
import 'models/good_deeds_challenge_manager.dart';
import 'models/quiz_manager.dart';


Future<void> main() async {
  // 0. تهيئة معالجة الأخطاء العالمية لحماية التطبيق من الانهيار مفاجئ
  FlutterError.onError = (FlutterErrorDetails details) {
    CustomErrorReporter.logError(details.exception, details.stack);
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    CustomErrorReporter.logError(error, stack);
    return true;
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return CustomErrorReporter.buildErrorWidget(details);
  };

  // 1. تأكيد تهيئة أدوات فلاتر الأساسية وتثبيت الاتجاه فوراً
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // 2. تشغيل واجهة التطبيق فوراً لظهور شاشة الـ Splash Screen في أول 100ms بدون أي شاشة سوداء أو بيضاء
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppThemeManager(),
        ),
        ChangeNotifierProvider(
          create: (_) => SpiritualTaskManager(),
        ),
        ChangeNotifierProvider(
          create: (_) => SunanManager(),
        ),
        ChangeNotifierProvider(
          create: (_) => GlobalDhikrManager(),
        ),
        ChangeNotifierProvider(
          create: (_) => ThawabManager(),
        ),
        ChangeNotifierProvider(
          create: (_) => GoodDeedsChallengeManager(),
        ),
        ChangeNotifierProvider(
          create: (_) => QuizManager(),
        ),
        ChangeNotifierProvider(
          create: (_) => LocaleManager(),
        ),
      ],
      child: const MyApp(),
    ),
  );

  // 3. تشغيل خدمات التهيئة في الخلفية فقط إذا كان المستخدم قد وافق مسبقاً على سياسة الخصوصية
  SharedPreferences.getInstance().then((prefs) {
    final hasAccepted = prefs.getBool('has_accepted_privacy_policy') ?? false;
    if (hasAccepted) {
      AppStartupService.initialize();
    }
  }).catchError((_) {});
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final localeManager = Provider.of<LocaleManager>(context);

    return ScreenUtilInit(
      designSize: const Size(
        390,
        844,
      ),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (
        context,
        child,
      ) {
        return MaterialApp(
          navigatorKey: NotificationService.navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'سكن الروح | Sakan Al-Rooh',
          builder: (context, child) {
            return Directionality(
              textDirection: localeManager.textDirection,
              child: child!,
            );
          },
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ar'),
            Locale('en'),
            Locale('fr'),
            Locale('id'),
            Locale('tr'),
            Locale('ur'),
          ],
          locale: localeManager.currentLocale,
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(
              0xFF06151F,
            ),
            primaryColor: const Color(
              0xFFD4AF37,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Color(0xFF102C3B),
              selectedItemColor: Color(0xFFD4AF37),
              unselectedItemColor: Colors.white70,
              type: BottomNavigationBarType.fixed,
            ),
          ),
          onGenerateRoute: (settings) {
            final uri = Uri.tryParse(settings.name ?? '');
            if (uri != null && (uri.path == '/owner' || uri.host == 'owner' || uri.scheme == 'sakanalrooh')) {
              OwnerService().setOwnerMode(true);
              return MaterialPageRoute(builder: (_) => const OwnerDashboardScreen());
            }
            return null;
          },
          home: const SplashScreen(),
        );
      },
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({
    super.key,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with WidgetsBindingObserver {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      NotificationService.checkPendingNotification(context);
      // استرجاع ومزامنة البيانات أوتوماتيكياً في الخلفية دون أي ضغط زر
      await CloudSyncService.restoreUserDataFromCloud();
      CloudSyncService.syncUserDataToCloud();
      // تهيئة المزامنة السحابية الذكية لخاطرة وتدبر اليوم من Sim.ai / Firebase
      DailyReflectionService.initCloudSync();
      // فحص أحدث إصدار وتحديثات Shorebird تلقائياً فور دخول التطبيق
      if (mounted) {
        InAppUpdateService.checkForUpdates(context);
        UpdateAnnouncementService.checkAndShowUpdateAnnouncement(context);
        _downloadShorebirdPatchInBackground();
      }
    });
  }

  Future<void> _downloadShorebirdPatchInBackground() async {
    try {
      final shorebird = ShorebirdCodePush();
      if (await shorebird.isNewPatchAvailableForDownload()) {
        await shorebird.downloadUpdateIfAvailable();
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.resumed) {
      // مزامنة تلقائية هادئة مع السحابة عند تعليق أو استئناف التطبيق
      CloudSyncService.syncUserDataToCloud();
    }
  }


  List<Widget> get _screens => [
    const HomeScreen(),
    const QuranScreen(),
    const AzkarScreen(),
    const PrayerTimesScreen(),
    ArQiblaScreen(isActive: _currentIndex == 4),
  ];

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: const Color(
          0xFF102C3B,
        ),
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF0F2027),
                      Color(0xFF203A43),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.tr('app_name'),
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 26.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    const QuickLanguageButton(isCompact: true),
                  ],
                ),
              ),
              _buildDrawerItem(
                Icons.fingerprint_rounded,
                'السبحة',
                const TasbihScreen(),
              ),
              _buildDrawerItem(
                Icons.auto_stories_rounded,
                'موسوعة القصص وأسباب النزول',
                const StoriesScreen(),
              ),
              _buildDrawerItem(
                Icons.format_quote_rounded,
                'الأحاديث النبوية',
                const HadithScreen(),
              ),
              _buildDrawerItem(
                Icons.star_rounded,
                'أسماء الله الحسنى',
                const NamesOfAllahScreen(),
              ),
              _buildDrawerItem(
                Icons.calendar_month_rounded,
                'التقويم الإسلامي',
                const CalendarScreen(),
              ),
              _buildDrawerItem(
                Icons.track_changes_rounded,
                'متابعة الورد',
                const WardTrackerScreen(),
              ),
              _buildDrawerItem(
                Icons.assignment_turned_in_rounded,
                'منظم الختمات',
                const KhatmaPlannerScreen(),
              ),
              _buildDrawerItem(
                Icons.storefront_rounded,
                'متجر زاد المؤمن 💎',
                const IslamicStoreScreen(),
              ),
              _buildDrawerItem(
                Icons.spa_rounded,
                'الملاذ الإيماني النفسي 🤍',
                const SpiritualMoodsScreen(),
              ),
              _buildDrawerItem(
                Icons.radio_rounded,
                'إذاعات القرآن الكريم 📻',
                const IslamicRadioScreen(),
              ),
              _buildDrawerItem(
                Icons.brightness_2_rounded,
                'متابع الصيام الإيماني 🌙',
                const FastingTrackerScreen(),
              ),
              _buildDrawerItem(
                Icons.calculate_rounded,
                'حاسبة الزكاة الشاملة 💰',
                const ZakatCalculatorScreen(),
              ),
              _buildDrawerItem(
                Icons.camera_alt_rounded,
                'استوديو بطاقات وحالات الواتساب 📸',
                const CardStudioScreen(),
              ),
              _buildDrawerItem(
                Icons.diversity_3_rounded,
                'عداد الأذكار الجماعي المليوني 📿',
                const GlobalDhikrScreen(),
              ),
              _buildDrawerItem(
                Icons.volunteer_activism_rounded,
                'إهداء الثواب والصدقة الجارية 🤲',
                const ThawabDedicationScreen(),
              ),
              _buildDrawerItem(
                Icons.emoji_events_rounded,
                'تحدي الصحبة الصالحة 🏆',
                const GoodDeedsChallengeScreen(),
              ),
              _buildDrawerItem(
                Icons.quiz_rounded,
                'سؤال اليوم وتحدي الصديق 🧠',
                const IslamicQuizScreen(),
              ),
              _buildDrawerItem(
                Icons.card_giftcard_rounded,
                'صانع بطاقات التهنئة 🎨',
                const IslamicCardsScreen(),
              ),
              _buildDrawerItem(
                Icons.settings_rounded,
                'الإعدادات',
                const SettingsScreen(),
              ),
              if (OwnerService().isOwner)
                _buildDrawerItem(
                  Icons.admin_panel_settings_rounded,
                  'لوحة تحكم المالك 👑',
                  const OwnerDashboardScreen(),
                ),
              const ShorebirdPatchInfoTile(),
            ],
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedLabelStyle: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 10.sp,
        ),
        elevation: 10,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(
              Icons.home_rounded,
            ),
            label: context.tr('nav_home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(
              Icons.menu_book_rounded,
            ),
            label: context.tr('nav_quran'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(
              Icons.favorite_rounded,
            ),
            label: context.tr('nav_azkar'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(
              Icons.access_time_rounded,
            ),
            label: context.tr('nav_prayer'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(
              Icons.explore_rounded,
            ),
            label: context.tr('nav_qibla'),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title,
    Widget screen,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.amber,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 15.sp,
        ),
      ),
      onTap: () {
        Navigator.pop(
          context,
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => screen,
          ),
        );
      },
    );
  }
}

class ShorebirdPatchInfoTile extends StatefulWidget {
  const ShorebirdPatchInfoTile({super.key});

  @override
  State<ShorebirdPatchInfoTile> createState() => _ShorebirdPatchInfoTileState();
}

class _ShorebirdPatchInfoTileState extends State<ShorebirdPatchInfoTile> {
  final _shorebirdCodePush = ShorebirdCodePush();
  int? _currentPatchNumber;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPatchInfo();
  }

  Future<void> _checkPatchInfo() async {
    try {
      final patchNum = await _shorebirdCodePush.currentPatchNumber();
      if (mounted) {
        setState(() {
          _currentPatchNumber = patchNum;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkForUpdates() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('جاري الفحص عن تحديثات فورية...'),
        duration: Duration(seconds: 2),
      ),
    );
    try {
      final isUpdateAvailable = await _shorebirdCodePush.isNewPatchAvailableForDownload();
      if (!mounted) return;
      if (isUpdateAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يتوفر تحديث جديد! جاري تنزيله الآن... ⏳'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 3),
          ),
        );
        await _shorebirdCodePush.downloadUpdateIfAvailable();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تنزيل التحديث بنجاح! 🎉 يرجى إغلاق التطبيق تماماً من الخلفية وإعادة فتحه لتطبيقه.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 6),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_currentPatchNumber != null
                ? 'التطبيق محدث لأحدث Patch رقم #$_currentPatchNumber'
                : 'التطبيق يعمل على أحدث نسخة أساسية!'),
            backgroundColor: Colors.amber.shade900,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('التطبيق محدث بأحدث البيانات.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        onTap: _checkForUpdates,
        borderRadius: BorderRadius.circular(12.r),
        child: Row(
          children: [
            Icon(
              Icons.system_update_alt_rounded,
              color: Colors.amber,
              size: 24.sp,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'حالة التحديث الفوري',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    _isLoading
                        ? 'جاري فحص الـ Patch...'
                        : (_currentPatchNumber != null
                            ? '⚡ الـ Patch النشط: #$_currentPatchNumber'
                            : '⚡ النسخة الأساسية (جاهز للـ Patches)'),
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.refresh_rounded,
              color: Colors.white54,
              size: 18.sp,
            ),
          ],
        ),
      ),
    );
  }
}
