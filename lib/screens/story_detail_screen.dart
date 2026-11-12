// story_detail_screen.dart

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/quran_library_model.dart';
import '../models/theme_manager.dart';
import 'surah_detail_screen.dart';

class StoryDetailScreen extends StatefulWidget {
  final QuranLibraryStory story;

  const StoryDetailScreen({
    super.key,
    required this.story,
  });

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  double _fontSize = 15.sp;

  void _changeFontSize(bool increase) {
    setState(() {
      if (increase && _fontSize < 24.sp) {
        _fontSize += 1.5.sp;
      } else if (!increase && _fontSize > 12.sp) {
        _fontSize -= 1.5.sp;
      }
    });
  }

  void _shareStoryQuote(dynamic theme) async {
    final textToShare = '''
📜 ${widget.story.title}
------------------------
📍 المكان والحقبة: ${widget.story.location} - ${widget.story.era}
📖 السورة والآيات: ${widget.story.surahName ?? ''} (${widget.story.verseRange ?? ''})
------------------------
💡 نبذة وأسباب النزول:
${widget.story.summary}

-- تم المشاركة عبر تطبيق نور الهدى 🕌
''';

    await Clipboard.setData(ClipboardData(text: textToShare));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: theme.accentColor,
          content: Text(
            'تم نسخ القصة والبطاقة الدعوية بنجاح! 🎨',
            style: GoogleFonts.cairo(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<AppThemeManager>(context).currentTheme;
    final story = widget.story;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        elevation: 0,
        title: Text(
          story.title,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline_rounded),
            onPressed: () => _changeFontSize(false),
            tooltip: 'تصغير الخط',
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () => _changeFontSize(true),
            tooltip: 'تكبير الخط',
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () => _shareStoryQuote(theme),
            tooltip: 'مشاركة البطاقة الدعوية',
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
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: theme.accentColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: theme.accentColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.auto_stories_rounded,
                            color: theme.accentColor,
                            size: 24.sp,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            story.title,
                            style: GoogleFonts.cairo(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: theme.textColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12.h),

                    // Tags (Location & Era & Surah)
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        if (story.surahName != null)
                          Chip(
                            backgroundColor:
                                theme.accentColor.withValues(alpha: 0.12),
                            side: BorderSide(
                                color:
                                    theme.accentColor.withValues(alpha: 0.3)),
                            avatar: Icon(Icons.menu_book_rounded,
                                size: 16.sp, color: theme.accentColor),
                            label: Text(
                              'سورة ${story.surahName} (${story.verseRange})',
                              style: GoogleFonts.cairo(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                color: theme.textColor,
                              ),
                            ),
                          ),
                        Chip(
                          backgroundColor:
                              Colors.amber.withValues(alpha: 0.12),
                          side: BorderSide(
                              color: Colors.amber.withValues(alpha: 0.3)),
                          avatar: Icon(Icons.history_toggle_off_rounded,
                              size: 16.sp, color: Colors.amber),
                          label: Text(
                            story.era,
                            style: GoogleFonts.cairo(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: theme.textColor,
                            ),
                          ),
                        ),
                        Chip(
                          backgroundColor: Colors.teal.withValues(alpha: 0.12),
                          side: BorderSide(
                              color: Colors.teal.withValues(alpha: 0.3)),
                          avatar: Icon(Icons.place_rounded,
                              size: 16.sp, color: Colors.teal),
                          label: Text(
                            story.location,
                            style: GoogleFonts.cairo(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: theme.textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // Summary Box
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: theme.accentColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: theme.accentColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      color: theme.accentColor,
                      size: 24.sp,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        story.summary,
                        style: GoogleFonts.cairo(
                          fontSize: 13.sp,
                          color: theme.textColor,
                          fontWeight: FontWeight.bold,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // Full Story Content Card
              Container(
                padding: EdgeInsets.all(18.w),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: theme.accentColor.withValues(alpha: 0.12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'أحداث القصة والنصوص المباركة:',
                      style: GoogleFonts.cairo(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.accentColor,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      story.fullStory,
                      style: GoogleFonts.cairo(
                        fontSize: _fontSize,
                        color: theme.textColor,
                        height: 1.8,
                      ),
                    ),
                  ],
                ),
              ),

              if (story.asbabNuzul != null) ...[
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            color: Colors.amber,
                            size: 22.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'سبب النزول المعتمد:',
                            style: GoogleFonts.cairo(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        story.asbabNuzul!,
                        style: GoogleFonts.cairo(
                          fontSize: 13.sp,
                          color: theme.textColor,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: 16.h),

              // Lessons Card
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: theme.accentColor.withValues(alpha: 0.12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.psychology_rounded,
                          color: theme.accentColor,
                          size: 22.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'الدروس والفوائد الإيمانية:',
                          style: GoogleFonts.cairo(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: theme.accentColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    ...story.lessons.map(
                      (l) => Padding(
                        padding: EdgeInsets.only(bottom: 6.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('• ',
                                style: TextStyle(
                                    color: theme.accentColor,
                                    fontSize: 16.sp)),
                            Expanded(
                              child: Text(
                                l,
                                style: GoogleFonts.cairo(
                                  fontSize: 13.sp,
                                  color: theme.textColor,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Navigation Button to Surah in Quran
              if (story.surahNumber != null)
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.accentColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SurahDetailScreen(
                            surahNumber: story.surahNumber!,
                            surahName: story.surahName ?? '',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.menu_book_rounded),
                    label: Text(
                      'اقرأ سورة ${story.surahName} الآن في المصحف 📖',
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
