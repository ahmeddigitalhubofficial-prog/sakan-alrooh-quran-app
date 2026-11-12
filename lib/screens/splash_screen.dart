import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/app_durations.dart';
import '../core/utils/app_radius.dart';
import '../core/utils/app_spacing.dart';
import '../core/services/app_startup_service.dart';
import '../widgets/privacy_consent_dialog.dart';
import '../main.dart';
import 'onboarding_tutorial_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _fadeAnimation;

  late final Animation<double> _scaleAnimation;

  late final Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _initializeAnimations();

    _navigateToApp();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.slow,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.92,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _slideAnimation = Tween<double>(
      begin: 30,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  void _navigateToApp() {
    _initAndNavigate();
  }

  Future<void> _initAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    final hasAcceptedPrivacy =
        prefs.getBool('has_accepted_privacy_policy') ?? false;

    void proceedToNext() {
      final showTutorialOnStartup =
          prefs.getBool('show_tutorial_on_startup') ?? true;
      final hasSeenTutorial = prefs.getBool('has_seen_tutorial') ?? false;

      Widget targetScreen = const MainNavigationScreen();
      if (showTutorialOnStartup && !hasSeenTutorial) {
        targetScreen = const OnboardingTutorialScreen();
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: AppDurations.medium,
          pageBuilder: (_, animation, __) {
            return FadeTransition(
              opacity: animation,
              child: targetScreen,
            );
          },
        ),
      );
    }

    if (!hasAcceptedPrivacy) {
      // انتظار قصير لظهور واجهة البداية ثم إظهار نافذة الموافقة الصريحة فوراً
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      // إظهار نافذة الموافقة الصريحة، ولا يتم تشغيل أي خدمات قبل الضغط على موافق
      PrivacyConsentDialog.show(
        context,
        onAccepted: () {
          AppStartupService.initialize();
          proceedToNext();
        },
      );
      return;
    }

    // تشغيل أنيميشن البداية والتهيئة بالخلفية بالتوازي للمستخدمين الذين وافقوا مسبقاً
    final initFuture = AppStartupService.initialize();
    final minDisplayFuture = Future.delayed(const Duration(milliseconds: 1600));

    await Future.wait([
      minDisplayFuture,
      initFuture.timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          debugPrint('Splash: AppStartupService timeout fallback');
        },
      ),
    ]);

    if (!mounted) return;
    HapticFeedback.lightImpact();
    proceedToNext();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background,
              Color(0xFF0B1D2A),
              AppColors.cardDark,
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (
              context,
              child,
            ) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.translate(
                  offset: Offset(
                    0,
                    _slideAnimation.value,
                  ),
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  ),
                ),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(),
                AppSpacing.h30,
                Text(
                  'سَكَنُ الرُّوح',
                  style: GoogleFonts.cairo(
                    fontSize: 34.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'SAKAN AL-ROOH',
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gold,
                    letterSpacing: 2.5,
                  ),
                ),
                AppSpacing.h10,
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                  ),
                  child: Text(
                    'وَقُل رَّبِّ زِدْنِي عِلْمًا',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.amiri(
                      fontSize: 24.sp,
                      color: AppColors.gold,
                      height: 1.6,
                    ),
                  ),
                ),
                AppSpacing.h10,
                Text(
                  'تطبيق إسلامي متكامل',
                  style: GoogleFonts.cairo(
                    fontSize: 15.sp,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  height: 48.h,
                ),
                _buildStartupProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStartupProgressIndicator() {
    return ValueListenableBuilder<double>(
      valueListenable: AppStartupService.progressNotifier,
      builder: (context, progress, _) {
        return ValueListenableBuilder<String>(
          valueListenable: AppStartupService.statusNotifier,
          builder: (context, statusText, _) {
            final percentage = (progress * 100).toInt();
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 48.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // شريط التقدم الفاخر المتدرج
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: Container(
                      height: 5.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: progress),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        builder: (context, animatedValue, _) {
                          return FractionallySizedBox(
                            alignment: Alignment.centerRight,
                            widthFactor: animatedValue,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFDF7A),
                                    AppColors.gold,
                                    Color(0xFFB38938),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.gold.withValues(alpha: 0.5),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // نص الحالة الحالية ونسبة الإنجاز
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          statusText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 12.sp,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '$percentage%',
                        style: GoogleFonts.cairo(
                          fontSize: 12.sp,
                          color: AppColors.gold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 135.w,
      height: 135.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.gold.withValues(
              alpha: 0.28,
            ),
            AppColors.darkGold.withValues(
              alpha: 0.12,
            ),
          ],
        ),
        border: Border.all(
          color: AppColors.gold.withValues(
            alpha: 0.15,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(
              alpha: 0.18,
            ),
            blurRadius: 35,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 92.w,
          height: 92.w,
          decoration: BoxDecoration(
            color: Colors.white.withValues(
              alpha: 0.03,
            ),
            borderRadius: BorderRadius.circular(
              AppRadius.r30,
            ),
          ),
          child: Icon(
            Icons.mosque_rounded,
            size: 54.sp,
            color: AppColors.gold,
          ),
        ),
      ),
    );
  }
}
