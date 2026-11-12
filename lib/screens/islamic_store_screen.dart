// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/theme_manager.dart';

class IslamicStoreScreen extends StatefulWidget {
  const IslamicStoreScreen({super.key});

  @override
  State<IslamicStoreScreen> createState() => _IslamicStoreScreenState();
}

class _IslamicStoreScreenState extends State<IslamicStoreScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showHowToEarnPoints(BuildContext context, AppTheme theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Text('💎', style: TextStyle(fontSize: 24.sp)),
                    SizedBox(width: 8.w),
                    Text(
                      'كيف تجمع نقاط الحسنات الإيمانية؟',
                      style: GoogleFonts.cairo(color: theme.textColor, fontWeight: FontWeight.bold, fontSize: 16.sp),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                _buildEarnRule('🕌 أداء صلاة الفريضة في وقتها', '+50 حسنة', theme),
                _buildEarnRule('🌅 قراءة أذكار الصباح أو المساء', '+40 حسنة', theme),
                _buildEarnRule('📖 قراءة ورد القرآن الكريم', '+60 حسنة', theme),
                _buildEarnRule('🌙 صيام يوم تطوع أو نافلة', '+100 حسنة', theme),
                _buildEarnRule('📿 إتمام 100 تسبيحة في السبحة', '+20 حسنة', theme),
                _buildEarnRule('🧠 الإجابة الصحيحة في مسابقة المعرفة', '+30 حسنة', theme),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEarnRule(String title, String reward, AppTheme theme) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.cairo(color: theme.textColor, fontSize: 13.sp)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: const Color(0xFF0F5A3E).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.4)),
            ),
            child: Text(
              reward,
              style: GoogleFonts.cairo(color: const Color(0xFF69F0AE), fontWeight: FontWeight.bold, fontSize: 12.sp),
            ),
          ),
        ],
      ),
    );
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
          'متجر زاد المؤمن 💎',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 17.sp),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // 1. Balance Header Card
            Container(
              margin: EdgeInsets.all(16.w),
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22.r),
                gradient: LinearGradient(
                  colors: [theme.primaryColor, theme.cardColor],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                border: Border.all(color: theme.accentColor.withValues(alpha: 0.4), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'رصيدك من الحسنات:',
                        style: GoogleFonts.cairo(color: Colors.white70, fontSize: 12.sp),
                      ),
                      Row(
                        children: [
                          Text(
                            '${themeManager.hasanatPoints}',
                            style: GoogleFonts.cairo(
                              color: theme.accentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 26.sp,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text('حسنة 💎', style: GoogleFonts.cairo(color: Colors.white70, fontSize: 13.sp)),
                        ],
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showHowToEarnPoints(context, theme),
                    icon: const Icon(Icons.help_outline_rounded, size: 16, color: Colors.black),
                    label: Text(
                      'كيف أكسب؟',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 11.sp),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.accentColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Tab Bar
            TabBar(
              controller: _tabController,
              indicatorColor: theme.accentColor,
              labelColor: theme.accentColor,
              unselectedLabelColor: theme.subtitleColor,
              labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13.sp),
              unselectedLabelStyle: GoogleFonts.cairo(fontSize: 12.sp),
              tabs: const [
                Tab(text: '🎨 الثيمات (10)'),
                Tab(text: '📜 المصحف (10)'),
                Tab(text: '📿 السبحة 3D (10)'),
              ],
            ),

            // 3. Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildThemesList(themeManager, theme),
                  _buildQuranBackgroundsList(themeManager, theme),
                  _buildMasbahaStylesList(themeManager, theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 1. Themes Tab ====================
  Widget _buildThemesList(AppThemeManager manager, AppTheme theme) {
    const int themePrice = 100;
    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: AppThemeManager.themes.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final t = AppThemeManager.themes[index];
        final isSelected = manager.currentTheme.id == t.id;
        final isUnlocked = manager.isItemUnlocked(t.id);

        return Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: t.cardColor,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: isSelected ? t.accentColor : Colors.white12,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Theme Color Palette Circles
              Row(
                children: [
                  _buildColorCircle(t.primaryColor),
                  SizedBox(width: 4.w),
                  _buildColorCircle(t.accentColor),
                  SizedBox(width: 4.w),
                  _buildColorCircle(t.scaffoldBackgroundColor),
                ],
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  t.name,
                  style: GoogleFonts.cairo(
                    color: t.textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ),
              if (isSelected)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: t.accentColor,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text('مُفعل ✓', style: GoogleFonts.cairo(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11.sp)),
                )
              else if (isUnlocked)
                OutlinedButton(
                  onPressed: () => manager.selectTheme(t.id),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: t.accentColor,
                    side: BorderSide(color: t.accentColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: Text('تفعيل', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 11.sp)),
                )
              else
                ElevatedButton.icon(
                  onPressed: () async {
                    final success = await manager.unlockStoreItem(t.id, themePrice);
                    if (success) {
                      await manager.selectTheme(t.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('مبروك! تم فتح ثيم ${t.name} بنجاح ✨', style: GoogleFonts.cairo())),
                        );
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('رصيد الحسنات لا يكفي ($themePrice حسنة مطلوبة)', style: GoogleFonts.cairo()), backgroundColor: Colors.redAccent),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.lock_open_rounded, size: 14, color: Colors.black),
                  label: Text('$themePrice 💎', style: GoogleFonts.cairo(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11.sp)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.accentColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ==================== 2. Quran Backgrounds Tab ====================
  Widget _buildQuranBackgroundsList(AppThemeManager manager, AppTheme theme) {
    const int bgPrice = 80;
    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: AppThemeManager.quranBackgrounds.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final bg = AppThemeManager.quranBackgrounds[index];
        final isSelected = manager.currentQuranBg.id == bg.id;
        final isUnlocked = manager.isItemUnlocked(bg.id);

        return Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: bg.backgroundColor,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: isSelected ? theme.accentColor : bg.frameColor.withValues(alpha: 0.5),
              width: isSelected ? 2.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: bg.backgroundColor,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: bg.frameColor, width: 1.5),
                ),
                child: Center(
                  child: Text('📖', style: TextStyle(fontSize: 20.sp)),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bg.name,
                      style: GoogleFonts.cairo(
                        color: bg.textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                      ),
                    ),
                    Text(
                      'نص المصحف والآيات بالخط العربي الفاخر',
                      style: GoogleFonts.cairo(color: bg.textColor.withValues(alpha: 0.6), fontSize: 10.sp),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F5A3E),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text('مُفعل ✓', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.sp)),
                )
              else if (isUnlocked)
                OutlinedButton(
                  onPressed: () => manager.selectQuranBackground(bg.id),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.accentColor,
                    side: BorderSide(color: theme.accentColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: Text('تفعيل', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 11.sp)),
                )
              else
                ElevatedButton.icon(
                  onPressed: () async {
                    final success = await manager.unlockStoreItem(bg.id, bgPrice);
                    if (success) {
                      await manager.selectQuranBackground(bg.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('مبروك! تم فتح خلفية ${bg.name} بنجاح ✨', style: GoogleFonts.cairo())),
                        );
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('رصيد الحسنات لا يكفي ($bgPrice حسنة مطلوبة)', style: GoogleFonts.cairo()), backgroundColor: Colors.redAccent),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.lock_open_rounded, size: 14, color: Colors.black),
                  label: Text('$bgPrice 💎', style: GoogleFonts.cairo(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11.sp)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.accentColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ==================== 3. Masbaha Styles Tab ====================
  Widget _buildMasbahaStylesList(AppThemeManager manager, AppTheme theme) {
    const int stylePrice = 70;
    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: AppThemeManager.masbahaStyles.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final s = AppThemeManager.masbahaStyles[index];
        final isSelected = manager.currentMasbahaStyle.id == s.id;
        final isUnlocked = manager.isItemUnlocked(s.id);

        return Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: isSelected ? s.glowColor : Colors.white12,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: s.beadColor,
                  boxShadow: [
                    BoxShadow(
                      color: s.glowColor.withValues(alpha: 0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text('📿', style: TextStyle(fontSize: 18.sp)),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.name,
                      style: GoogleFonts.cairo(
                        color: theme.textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                      ),
                    ),
                    Text(
                      s.materialName,
                      style: GoogleFonts.cairo(color: theme.subtitleColor, fontSize: 10.sp),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F5A3E),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text('مُفعل ✓', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.sp)),
                )
              else if (isUnlocked)
                OutlinedButton(
                  onPressed: () => manager.selectMasbahaStyle(s.id),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: s.glowColor,
                    side: BorderSide(color: s.glowColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: Text('تفعيل', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 11.sp)),
                )
              else
                ElevatedButton.icon(
                  onPressed: () async {
                    final success = await manager.unlockStoreItem(s.id, stylePrice);
                    if (success) {
                      await manager.selectMasbahaStyle(s.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('مبروك! تم فتح خرزات ${s.name} بنجاح ✨', style: GoogleFonts.cairo())),
                        );
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('رصيد الحسنات لا يكفي ($stylePrice حسنة مطلوبة)', style: GoogleFonts.cairo()), backgroundColor: Colors.redAccent),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.lock_open_rounded, size: 14, color: Colors.black),
                  label: Text('$stylePrice 💎', style: GoogleFonts.cairo(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11.sp)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.accentColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildColorCircle(Color color) {
    return Container(
      width: 18.w,
      height: 18.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: Colors.white24),
      ),
    );
  }
}
