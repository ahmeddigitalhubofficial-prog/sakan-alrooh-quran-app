// onboarding_tutorial_screen.dart

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'feature_guide_screen.dart';
import '../core/localization/app_translations.dart';
import '../main.dart';
import '../models/theme_manager.dart';

class TutorialSlide {
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;

  const TutorialSlide({
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
  });
}

class OnboardingTutorialScreen extends StatefulWidget {
  final bool isReplay;

  const OnboardingTutorialScreen({
    super.key,
    this.isReplay = false,
  });

  @override
  State<OnboardingTutorialScreen> createState() =>
      _OnboardingTutorialScreenState();
}

class _OnboardingTutorialScreenState extends State<OnboardingTutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<TutorialSlide> _buildSlides(BuildContext context) => [
    TutorialSlide(
      title: context.tr('onb_slide1_title'),
      description: context.tr('onb_slide1_desc'),
      icon: Icons.menu_book_rounded,
      accentColor: const Color(0xFFD4AF37),
    ),
    TutorialSlide(
      title: context.tr('onb_slide2_title'),
      description: context.tr('onb_slide2_desc'),
      icon: Icons.auto_awesome_rounded,
      accentColor: const Color(0xFF2E7D32),
    ),
    TutorialSlide(
      title: context.tr('onb_slide3_title'),
      description: context.tr('onb_slide3_desc'),
      icon: Icons.explore_rounded,
      accentColor: const Color(0xFF0288D1),
    ),
    TutorialSlide(
      title: context.tr('onb_slide4_title'),
      description: context.tr('onb_slide4_desc'),
      icon: Icons.fact_check_rounded,
      accentColor: const Color(0xFF7B1FA2),
    ),
  ];

  Future<void> _completeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_tutorial', true);

    if (!mounted) return;

    HapticFeedback.mediumImpact();

    if (widget.isReplay) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<AppThemeManager>(context).currentTheme;
    final slides = _buildSlides(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Skip Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr('onb_header_title'),
                    style: GoogleFonts.cairo(
                      color: theme.accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                  TextButton(
                    onPressed: _completeTutorial,
                    child: Text(
                      widget.isReplay ? context.tr('close') : context.tr('onb_skip'),
                      style: GoogleFonts.cairo(
                        color: theme.subtitleColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Slides PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: slides.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final slide = slides[index];
                  return Padding(
                    padding: EdgeInsets.all(28.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 150.w,
                          height: 150.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: slide.accentColor.withValues(alpha: 0.15),
                            border: Border.all(
                              color: slide.accentColor.withValues(alpha: 0.4),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: slide.accentColor.withValues(alpha: 0.2),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            slide.icon,
                            size: 70.sp,
                            color: slide.accentColor,
                          ),
                        ),
                        SizedBox(height: 40.h),
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            color: theme.textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 22.sp,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          slide.description,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            color: theme.subtitleColor,
                            fontSize: 14.sp,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Page Indicator Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                slides.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  width: _currentPage == index ? 24.w : 8.w,
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? theme.accentColor
                        : theme.subtitleColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
            ),

            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FeatureGuideScreen()),
                );
              },
              icon: Icon(Icons.lightbulb_outline_rounded, color: theme.accentColor, size: 18.sp),
              label: Text(
                context.tr('onb_feature_guide'),
                style: GoogleFonts.cairo(
                  color: theme.textColor,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            // Bottom Action Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 16.h),
              child: SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.accentColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26.r),
                    ),
                    elevation: 4,
                  ),
                  onPressed: () {
                    if (_currentPage < slides.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _completeTutorial();
                    }
                  },
                  child: Text(
                    _currentPage == slides.length - 1
                        ? (widget.isReplay ? context.tr('onb_close_guide') : context.tr('onb_start'))
                        : context.tr('onb_next'),
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
