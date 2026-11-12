// references_screen.dart

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/theme_manager.dart';

class ReferenceItem {
  final String category;
  final String title;
  final String source;
  final String description;
  final IconData icon;

  const ReferenceItem({
    required this.category,
    required this.title,
    required this.source,
    required this.description,
    required this.icon,
  });
}

class TechLibraryItem {
  final String name;
  final String version;
  final String purpose;
  final String sourceUrl;

  const TechLibraryItem({
    required this.name,
    required this.version,
    required this.purpose,
    required this.sourceUrl,
  });
}

class ReferencesScreen extends StatefulWidget {
  const ReferencesScreen({super.key});

  @override
  State<ReferencesScreen> createState() => _ReferencesScreenState();
}

class _ReferencesScreenState extends State<ReferencesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _markdownText = '';
  bool _isLoadingMd = true;

  final List<ReferenceItem> _islamicReferences = const [
    ReferenceItem(
      category: 'متتبع صيام النوافل والتطوع',
      title: 'أحكام وسنن صيام التطوع والقضاء',
      source: 'الصحيحان والسنن الأربعة وكتاب فقه السنة',
      description:
          'متابعة وإحصائيات صيام الإثنين والخميس، الأيام البيض (13، 14، 15 هـ)، عاشوراء، عرفة، والست من شوال وفق الهدي النبوي الصحيح.',
      icon: Icons.brightness_6_rounded,
    ),
    ReferenceItem(
      category: 'رفيق المشاعر والسكينة (Spiritual Moods)',
      title: 'أدعية تفريج الكرب والسكينة والطمأنينة',
      source: 'كتاب "الأذكار" للإمام النووي و"الوابل الصيب" لابن القيم',
      description:
          'آيات وأدعية نبوية مأثورة وقصص إيمانية ملهمة مختارة بدقة لمعالجة حالات الحزن، القلق، الحيرة، وشكر النعمة.',
      icon: Icons.favorite_rounded,
    ),
    ReferenceItem(
      category: 'موسوعة الأحاديث النبوية والأربعين النووية',
      title: 'الأربعون النووية وصحيح السنة المطهرة',
      source: 'متن الأربعين النووية للإمام النووي وصحيح البخاري ومسلم (تحقيق الألباني)',
      description:
          'أحاديث صحيحة موثقة بالأبواب مع شرح معاني الكلمات المستغلقة واستخلاص الفوائد الإيمانية والتربوية.',
      icon: Icons.menu_book_rounded,
    ),
    ReferenceItem(
      category: 'حاسبة الزكاة الشرعية الشاملة',
      title: 'فقه ونصاب الزكاة (الأموال، الذهب، التجارة، الفطر)',
      source: 'دار الإفتاء المصرية ومجمع الفقه الإسلامي الدولي',
      description:
          'حساب دقيق لزكاة الأموال، المدخرات البنكية، عروض التجارة، والذهب والفضة (نصاب 85 جرام عيار 24) بنسبة 2.5% الشرعية.',
      icon: Icons.calculate_rounded,
    ),
    ReferenceItem(
      category: 'إذاعات القرآن الكريم الحية',
      title: 'إذاعات القرآن الكريم المباشرة 24/7',
      source: 'إذاعة القرآن الكريم من القاهرة ومكة المكرمة والمدينة المنورة',
      description:
          'بث حي ومباشر على مدار الساعة للتلاوات والبرامج الدينية وإذاعات كبار القراء بصوت فائق النقاء.',
      icon: Icons.radio_rounded,
    ),
    ReferenceItem(
      category: 'أسماء الله الحسنى الـ 99',
      title: 'الكتاب والسنة والشروح المعتمدة',
      source: 'تفسير ابن كثير والتفسير الميسر والقواعد المثلى للشيخ ابن عثيمين',
      description:
          'معاني ودلالات وفضل الأسماء الحسنى الـ 99 مستخلصة من أمهات كتب العقيدة والتفسير مع البحث التفاعلي.',
      icon: Icons.stars_rounded,
    ),
    ReferenceItem(
      category: 'القرآن الكريم والتلاوات',
      title: 'نص المصحف والتلاوات الصوتية',
      source: 'مجمع الملك فهد لطباعة المصحف الشريف & Tanzil.net & EveryAyah & MP3Quran',
      description:
          'النص القرآني المعتمد برواية حفص عن عاصم بالرسم العثماني الموثق، والتلاوات الصوتية المستمرة لكبار القراء.',
      icon: Icons.auto_stories_rounded,
    ),
    ReferenceItem(
      category: 'الأذكار والأدعية',
      title: 'حصن المسلم وأمهات كتب الحديث',
      source: 'كتاب "حصن المسلم" للدكتور سعيد بن علي بن وهف القحطاني',
      description:
          'جميع أذكار الصباح والمساء والصلاة والنوم المأثورة عن النبي ﷺ موثقة بالتشكيل والصوتيات الأوفلاين لـ 4 قراء.',
      icon: Icons.auto_awesome_rounded,
    ),
    ReferenceItem(
      category: 'موسوعة قصص القرآن وأسباب النزول',
      title: 'أسباب النزول وقصص الأنبياء والسيرة النبوية',
      source: 'كتاب "أسباب النزول" للواحدي، "قصص الأنبياء" لابن كثير، و"الرحيق المختوم" للمباركفوري',
      description:
          'موسوعة شاملة لقصص الأنبياء الـ 25 وقصص القرآن العظيمة وأسباب نزول السور والآيات وسيرة وغزوات النبي ﷺ.',
      icon: Icons.history_edu_rounded,
    ),
    ReferenceItem(
      category: 'مواقيت الصلاة والقبلة بالواقع المعزز',
      title: 'الهيئة المصرية العامة للمساحة',
      source: 'Egyptian General Authority of Survey (طريقة 19.5° للفجر و 17.5° للعشاء)',
      description:
          'حساب فلكي دقيق لمواقيت الصلاة حسب الموقع الجغرافي، مع توجيه القبلة بالواقع المعزز AR ومجسم ثلاثي الأبعاد للكعبة.',
      icon: Icons.access_time_filled_rounded,
    ),
    ReferenceItem(
      category: 'الحماية والحفظ الرقمي',
      title: 'نظام التشفير والتحقق SHA-256 Data Integrity',
      source: 'خوارزمية التشفير القياسية SHA-256 من معهد NIST',
      description:
          'فحص رقمي تلقائي عند بدء التشغيل للتأكد من سلامة نصوص الأذكار والأحاديث وعدم تعرض الحزمة لأي تعديل خارجي.',
      icon: Icons.security_rounded,
    ),
    ReferenceItem(
      category: 'سياسة الخصوصية وأمان البيانات',
      title: 'وثيقة الخصوصية المعتمدة لمتجر Play Console',
      source: 'سياسة حماية بيانات المستخدم أوفلاين (Privacy Policy 2026)',
      description:
          'التطبيق أوفلاين بالكامل لا يجمع أي بيانات شخصية، ويحفظ التفضيلات محلياً بأمان، ومطابق لكافة سياسات الأمان.',
      icon: Icons.privacy_tip_rounded,
    ),
  ];

  final List<TechLibraryItem> _techLibraries = const [
    TechLibraryItem(
      name: 'quran',
      version: '1.2.9',
      purpose: 'نصوص القرآن الكريم وفهرس السور والأجزاء والصفحات بدون إنترنت.',
      sourceUrl: 'pub.dev/packages/quran',
    ),
    TechLibraryItem(
      name: 'adhan',
      version: '2.0.0+1',
      purpose: 'حساب مواقيت الصلاة الفلكية بدقة طبقاً للموقع الجغرافي والطريقة المصرية.',
      sourceUrl: 'pub.dev/packages/adhan',
    ),
    TechLibraryItem(
      name: 'geolocator',
      version: '14.0.2',
      purpose: 'تحديد الإحداثيات الجغرافية لحساب المواقيت والقبلة بالـ GPS.',
      sourceUrl: 'pub.dev/packages/geolocator',
    ),
    TechLibraryItem(
      name: 'flutter_compass',
      version: '0.8.1',
      purpose: 'قراءة الحساس المغناطيسي لتوجيه بوصلة القبلة بالواقع المعزز.',
      sourceUrl: 'pub.dev/packages/flutter_compass',
    ),
    TechLibraryItem(
      name: 'camera',
      version: '0.12.0+1',
      purpose: 'تشغيل الكاميرا لتوجيه القبلة بالواقع المعزز (AR Qibla).',
      sourceUrl: 'pub.dev/packages/camera',
    ),
    TechLibraryItem(
      name: 'just_audio',
      version: '0.10.5',
      purpose: 'محرك تشغيل التلاوات الصوتية والأذكار وإذاعات القرآن المباشرة.',
      sourceUrl: 'pub.dev/packages/just_audio',
    ),
    TechLibraryItem(
      name: 'hijri',
      version: '3.0.1',
      purpose: 'حساب التقويم الهجري ومطابقة الأيام والمناسبات الإسلامية.',
      sourceUrl: 'pub.dev/packages/hijri',
    ),
    TechLibraryItem(
      name: 'shared_preferences',
      version: '2.5.5',
      purpose: 'التخزين المحلي الآمن لإعدادات المستخدم وإحصائيات الورد اليومي.',
      sourceUrl: 'pub.dev/packages/shared_preferences',
    ),
    TechLibraryItem(
      name: 'flutter_secure_storage',
      version: 'Latest',
      purpose: 'التخزين المشفر للمفاتيح والبيانات الحساسة على مستوى النظام.',
      sourceUrl: 'pub.dev/packages/flutter_secure_storage',
    ),
    TechLibraryItem(
      name: 'flutter_local_notifications',
      version: '21.0.0',
      purpose: 'إرسال إشعارات الأذان والورد اليومي والتنبيهات في المواعيد.',
      sourceUrl: 'pub.dev/packages/flutter_local_notifications',
    ),
    TechLibraryItem(
      name: 'crypto',
      version: '3.0.6',
      purpose: 'التشفير والتحقق الرقمي لسلامة البيانات ونصوص الأذكار (SHA-256).',
      sourceUrl: 'pub.dev/packages/crypto',
    ),
    TechLibraryItem(
      name: 'in_app_review',
      version: '2.0.9',
      purpose: 'نظام تقييم التطبيق المباشر 5 نجوم وربطه بمتاجر التطبيقات.',
      sourceUrl: 'pub.dev/packages/in_app_review',
    ),
    TechLibraryItem(
      name: 'in_app_update',
      version: '4.2.3',
      purpose: 'نظام التحديث التلقائي الفوري والمرن من متجر Google Play.',
      sourceUrl: 'pub.dev/packages/in_app_update',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMarkdown();
  }

  Future<void> _loadMarkdown() async {
    try {
      final text = await rootBundle.loadString('REFERENCES.md');
      setState(() {
        _markdownText = text;
        _isLoadingMd = false;
      });
    } catch (_) {
      setState(() {
        _isLoadingMd = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<AppThemeManager>(context).currentTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'المصادر والمراجع والمكتبات',
          style: GoogleFonts.cairo(
            color: theme.textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.accentColor,
          labelColor: theme.accentColor,
          unselectedLabelColor: theme.subtitleColor,
          labelStyle: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
          unselectedLabelStyle: GoogleFonts.cairo(
            fontWeight: FontWeight.normal,
            fontSize: 13.sp,
          ),
          tabs: const [
            Tab(text: 'المصادر الشرعية 🕌'),
            Tab(text: 'المكتبات البرمجية 💻'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildIslamicSourcesTab(theme),
            _buildTechLibrariesTab(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildIslamicSourcesTab(dynamic theme) {
    return ListView(
      padding: EdgeInsets.all(16.w),
      physics: const BouncingScrollPhysics(),
      children: [
        // Reassurance Banner
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.accentColor.withValues(alpha: 0.2),
                theme.cardColor,
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(20.r),
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
                  color: theme.accentColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.verified_rounded,
                  color: theme.accentColor,
                  size: 28.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'محتوى شرعي مراجع وموثوق 100%',
                      style: GoogleFonts.cairo(
                        color: theme.textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'تم اعتماد كافة الأحاديث والنصوص والأذكار من أمهات كتب السنة المعتمدة بدون أحاديث ضعيفة أو موضوعة.',
                      style: GoogleFonts.cairo(
                        color: theme.subtitleColor,
                        fontSize: 12.sp,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // Section Title
        Text(
          'قائمة المراجع والمصادر الإسلامية:',
          style: GoogleFonts.cairo(
            color: theme.textColor,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(height: 12.h),

        // List of References
        ..._islamicReferences.map((ref) => _buildReferenceCard(theme, ref)),

        SizedBox(height: 16.h),

        // Full documentation file viewer button if loaded
        if (!_isLoadingMd && _markdownText.isNotEmpty)
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: theme.accentColor),
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            onPressed: () => _showFullMarkdownDialog(theme),
            icon: Icon(Icons.article_rounded, color: theme.accentColor),
            label: Text(
              'عرض التقرير الكامل للمراجع (REFERENCES.md)',
              style: GoogleFonts.cairo(
                color: theme.accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildReferenceCard(dynamic theme, ReferenceItem ref) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: theme.accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  ref.icon,
                  color: theme.accentColor,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ref.category,
                      style: GoogleFonts.cairo(
                        color: theme.accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                      ),
                    ),
                    Text(
                      ref.title,
                      style: GoogleFonts.cairo(
                        color: theme.textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                Icon(Icons.source_rounded,
                    color: theme.subtitleColor, size: 14.sp),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    ref.source,
                    style: GoogleFonts.cairo(
                      color: theme.textColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            ref.description,
            style: GoogleFonts.cairo(
              color: theme.subtitleColor,
              fontSize: 12.sp,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechLibrariesTab(dynamic theme) {
    return ListView(
      padding: EdgeInsets.all(16.w),
      physics: const BouncingScrollPhysics(),
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الشفافية التقنية والبرمجية 💻',
                style: GoogleFonts.cairo(
                  color: theme.textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'يستخدم التطبيق مكتبات برمجية عالمية مفتوحة المصدر مجربة ومفحوصة أمنياً لضمان أعلى أداء واستقرار بدون إعلانات أو تتبع.',
                style: GoogleFonts.cairo(
                  color: theme.subtitleColor,
                  fontSize: 12.sp,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        ..._techLibraries.map((lib) => _buildTechLibraryCard(theme, lib)),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildTechLibraryCard(dynamic theme, TechLibraryItem lib) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              Icons.code_rounded,
              color: Colors.blueAccent,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      lib.name,
                      style: GoogleFonts.firaCode(
                        color: theme.textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: theme.accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'v${lib.version}',
                        style: GoogleFonts.firaCode(
                          color: theme.accentColor,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  lib.purpose,
                  style: GoogleFonts.cairo(
                    color: theme.subtitleColor,
                    fontSize: 12.sp,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFullMarkdownDialog(dynamic theme) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        title: Row(
          children: [
            Icon(Icons.article_rounded, color: theme.accentColor),
            SizedBox(width: 10.w),
            Text(
              'ملف REFERENCES.md',
              style: GoogleFonts.cairo(
                color: theme.textColor,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400.h,
          child: SingleChildScrollView(
            child: SelectableText(
              _markdownText,
              style: GoogleFonts.cairo(
                color: theme.textColor,
                fontSize: 12.sp,
                height: 1.5,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'إغلاق',
              style: GoogleFonts.cairo(
                color: theme.accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
