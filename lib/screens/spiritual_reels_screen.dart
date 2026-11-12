// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

import '../core/constants/app_colors.dart';
import '../core/helpers/app_lifecycle_helper.dart';
import '../models/spiritual_reel_model.dart';
import '../services/social_service.dart';
import '../services/spiritual_reels_service.dart';
import 'surah_detail_screen.dart';

/// شاشة تصفح مقاطع الريلز الإيمانية (سكينة مرئية) بتمرير عمودي سلس
class SpiritualReelsScreen extends StatefulWidget {
  final List<SpiritualReelModel>? initialReels;
  final int initialIndex;

  const SpiritualReelsScreen({
    super.key,
    this.initialReels,
    this.initialIndex = 0,
  });

  @override
  State<SpiritualReelsScreen> createState() => _SpiritualReelsScreenState();
}

class _SpiritualReelsScreenState extends State<SpiritualReelsScreen>
    with WidgetsBindingObserver {
  late PageController _pageController;
  List<SpiritualReelModel> _reels = [];
  bool _isLoading = true;

  // Controllers map keyed by page index to manage memory efficiently
  final Map<int, VideoPlayerController> _controllers = {};
  final Set<int> _failedIndices = {};
  int _currentIndex = 0;
  bool _isMuted = false;
  bool _showPlayPauseOverlay = false;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _loadReels();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (AppLifecycleHelper.isBackground) {
      _pauseCurrentVideo();
    }
  }

  Future<void> _loadReels() async {
    if (widget.initialReels != null && widget.initialReels!.isNotEmpty) {
      _reels = widget.initialReels!;
    } else {
      _reels = await SpiritualReelsService.getReleasedReels(newestFirst: true);
    }

    if (_reels.isEmpty) {
      _reels = await SpiritualReelsService.getAllReels();
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    if (_reels.isNotEmpty) {
      _initControllerForIndex(_currentIndex);
      if (_currentIndex + 1 < _reels.length) {
        _initControllerForIndex(_currentIndex + 1, autoPlay: false);
      }
    }
  }

  Future<void> _initControllerForIndex(int index, {bool autoPlay = true}) async {
    if (index < 0 || index >= _reels.length) return;
    if (_controllers.containsKey(index)) {
      final ctrl = _controllers[index]!;
      if (autoPlay && !ctrl.value.isPlaying) {
        ctrl.play();
        if (mounted) setState(() => _isPlaying = true);
      }
      return;
    }

    final reel = _reels[index];
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(reel.videoUrl),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );

    _controllers[index] = controller;

    try {
      await controller.initialize().timeout(const Duration(seconds: 8));
      controller.setLooping(true);
      controller.setVolume(_isMuted ? 0.0 : 1.0);

      if (index == _currentIndex && autoPlay && mounted) {
        controller.play();
        setState(() => _isPlaying = true);
      } else if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Video initialize error for reel ${reel.id}: $e');
      if (mounted) {
        setState(() {
          _failedIndices.add(index);
        });
      }
    }
  }

  void _onPageChanged(int index) {
    // 1. Pause previously active controller
    if (_controllers.containsKey(_currentIndex)) {
      _controllers[_currentIndex]?.pause();
    }

    setState(() {
      _currentIndex = index;
      _isPlaying = true;
    });

    // 2. Play newly active controller
    _initControllerForIndex(index, autoPlay: true);

    // 3. Preload adjacent next video for seamless experience
    if (index + 1 < _reels.length) {
      _initControllerForIndex(index + 1, autoPlay: false);
    }

    // 4. Clean up distant controllers to avoid memory leaks
    _cleanupDistantControllers(index);
  }

  void _cleanupDistantControllers(int activeIndex) {
    final keysToRemove = <int>[];
    _controllers.forEach((idx, controller) {
      if ((idx - activeIndex).abs() > 2) {
        controller.dispose();
        keysToRemove.add(idx);
      }
    });
    for (final k in keysToRemove) {
      _controllers.remove(k);
    }
  }

  void _pauseCurrentVideo() {
    final ctrl = _controllers[_currentIndex];
    if (ctrl != null && ctrl.value.isPlaying) {
      ctrl.pause();
      if (mounted) setState(() => _isPlaying = false);
    }
  }

  void _togglePlayPause() {
    final ctrl = _controllers[_currentIndex];
    if (ctrl == null || !ctrl.value.isInitialized) return;

    HapticFeedback.selectionClick();
    setState(() {
      if (ctrl.value.isPlaying) {
        ctrl.pause();
        _isPlaying = false;
      } else {
        ctrl.play();
        _isPlaying = true;
      }
      _showPlayPauseOverlay = true;
    });

    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted) {
        setState(() {
          _showPlayPauseOverlay = false;
        });
      }
    });
  }

  void _toggleMute() {
    HapticFeedback.selectionClick();
    setState(() {
      _isMuted = !_isMuted;
      final targetVolume = _isMuted ? 0.0 : 1.0;
      _controllers.forEach((_, c) => c.setVolume(targetVolume));
    });
  }

  void _shareReel(SpiritualReelModel reel) {
    HapticFeedback.mediumImpact();
    final text = '✨ ${reel.title}\n\n'
        '${reel.ayahText}\n'
        'سورة ${reel.surahName} - آية ${reel.ayah}\n\n'
        '🌿 شاهد المقطع وحمّل تطبيق «سكن الروح» الخالي تماماً من الإعلانات:\n'
        '${reel.youtubeUrl.isNotEmpty ? reel.youtubeUrl : SocialService.universalBioUrl}';
    Share.share(text, subject: reel.title);
  }

  void _openInQuran(SpiritualReelModel reel) {
    _pauseCurrentVideo();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SurahDetailScreen(
          surahNumber: reel.surah,
          surahName: reel.surahName,
          initialVerse: reel.ayah,
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.gold,
                ),
              )
            : _reels.isEmpty
                ? _buildEmptyState()
                : Stack(
                    children: [
                      // 1. Vertical PageView for Reels
                      PageView.builder(
                        controller: _pageController,
                        scrollDirection: Axis.vertical,
                        itemCount: _reels.length,
                        onPageChanged: _onPageChanged,
                        itemBuilder: (context, index) {
                          return _buildReelPage(index, _reels[index]);
                        },
                      ),

                      // 2. Top Header Overlay (Back, Day badge, Mute)
                      _buildTopHeader(),

                      // 3. Play/Pause Animated Center Feedback
                      if (_showPlayPauseOverlay)
                        Center(
                          child: Container(
                            padding: EdgeInsets.all(18.w),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isPlaying ? Icons.play_arrow_rounded : Icons.pause_rounded,
                              size: 50.sp,
                              color: AppColors.gold,
                            ),
                          ),
                        ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildTopHeader() {
    final currentReel =
        _reels.isNotEmpty && _currentIndex < _reels.length ? _reels[_currentIndex] : null;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 8.h,
          left: 16.w,
          right: 16.w,
          bottom: 12.h,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.85),
              Colors.black.withValues(alpha: 0.4),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          children: [
            // Close / Back Button
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20.sp,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),

            // Badge & Reel Title
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.gold, AppColors.darkGold],
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          'سكينة مرئية',
                          style: GoogleFonts.cairo(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      if (currentReel != null)
                        Text(
                          'مقطع اليوم ${currentReel.id}',
                          style: GoogleFonts.cairo(
                            fontSize: 12.sp,
                            color: AppColors.gold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                  if (currentReel != null)
                    Text(
                      currentReel.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),

            // Mute / Unmute Button
            IconButton(
              icon: Icon(
                _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                color: _isMuted ? Colors.redAccent : Colors.white,
                size: 22.sp,
              ),
              onPressed: _toggleMute,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReelPage(int index, SpiritualReelModel reel) {
    final controller = _controllers[index];
    final isInitialized = controller != null && controller.value.isInitialized;

    return GestureDetector(
      onTap: _togglePlayPause,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Color
          Container(color: Colors.black),

          // Video Playback Area
          if (isInitialized)
            Center(
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              ),
            )
          else if (_failedIndices.contains(index))
            _buildFallbackReelCard(index, reel)
          else
            const Center(
              child: CircularProgressIndicator(
                color: AppColors.gold,
                strokeWidth: 2.5,
              ),
            ),

          // Bottom Dark Gradient for legibility
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 280.h,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.95),
                    Colors.black.withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Floating Action Column (Right Side)
          Positioned(
            right: 12.w,
            bottom: 40.h,
            child: _buildSideActionColumn(reel),
          ),

          // Reel Information (Left & Bottom Side)
          Positioned(
            left: 16.w,
            right: 76.w,
            bottom: 24.h,
            child: _buildBottomReelInfo(reel),
          ),

          // Thin Video Progress Indicator at bottom
          if (isInitialized)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: VideoProgressIndicator(
                controller,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: AppColors.gold,
                  bufferedColor: Colors.white24,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFallbackReelCard(int index, SpiritualReelModel reel) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F1E19),
            Color(0xFF06100D),
            Colors.black,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 14.sp, color: AppColors.gold),
                    SizedBox(width: 6.w),
                    Text(
                      'سكينة مرئية • مقطع اليوم ${reel.id}',
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 28.h),

              // Glowing Play Button
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  final target = reel.youtubeUrl.isNotEmpty ? reel.youtubeUrl : reel.videoUrl;
                  SocialService.openUrl(target);
                },
                child: Container(
                  width: 88.w,
                  height: 88.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.gold, AppColors.darkGold],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.45),
                        blurRadius: 28,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    size: 58.sp,
                    color: Colors.black,
                  ),
                ),
              ),

              SizedBox(height: 14.h),

              Text(
                'اضغط لمشاهدة المقطع الآن',
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: 28.h),

              // Decorative Ayah Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(18.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
                ),
                child: Column(
                  children: [
                    Text(
                      reel.ayahText,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.amiri(
                        fontSize: 18.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        height: 1.8,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'سورة ${reel.surahName} • آية ${reel.ayah}',
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        color: AppColors.gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // Action buttons row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (reel.youtubeUrl.isNotEmpty) ...[
                    ElevatedButton.icon(
                      onPressed: () => SocialService.openUrl(reel.youtubeUrl),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF0000),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      icon: Icon(Icons.play_circle_fill_rounded, size: 16.sp),
                      label: Text('يوتيوب', style: GoogleFonts.cairo(fontSize: 12.sp, fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(width: 10.w),
                  ],
                  OutlinedButton.icon(
                    onPressed: () => _openInQuran(reel),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.gold,
                      side: const BorderSide(color: AppColors.gold),
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    icon: Icon(Icons.menu_book_rounded, size: 16.sp),
                    label: Text('المصحف', style: GoogleFonts.cairo(fontSize: 12.sp, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomReelInfo(SpiritualReelModel reel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Surah & Ayah Badge
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.emerald.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.menu_book_rounded,
                size: 13.sp,
                color: AppColors.gold,
              ),
              SizedBox(width: 5.w),
              Text(
                'سورة ${reel.surahName} • آية ${reel.ayah}',
                style: GoogleFonts.cairo(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 8.h),

        // Hook / Catchy Reflection Text
        if (reel.hookText.isNotEmpty)
          Text(
            reel.hookText,
            style: GoogleFonts.cairo(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.35,
            ),
          ),

        SizedBox(height: 6.h),

        // Deep-link Action Button
        ElevatedButton.icon(
          onPressed: () => _openInQuran(reel),
          icon: Icon(
            Icons.auto_stories_rounded,
            size: 16.sp,
            color: Colors.black,
          ),
          label: Text(
            'اقرأ في المصحف الشريف',
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            elevation: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildSideActionColumn(SpiritualReelModel reel) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Share Button
        _buildActionIconButton(
          icon: Icons.share_rounded,
          label: 'مشاركة',
          color: Colors.white,
          onTap: () => _shareReel(reel),
        ),

        SizedBox(height: 14.h),

        // Separator label: شاهد على
        Text(
          'شاهد على',
          style: GoogleFonts.cairo(
            fontSize: 9.sp,
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),

        SizedBox(height: 6.h),

        // YouTube Shorts Button
        _buildSocialMiniButton(
          icon: Icons.play_circle_fill_rounded,
          accentColor: const Color(0xFFFF0000),
          tooltip: 'يوتيوب شورتس',
          onTap: () {
            _pauseCurrentVideo();
            if (reel.youtubeUrl.isNotEmpty) {
              SocialService.openUrl(reel.youtubeUrl);
            } else {
              SocialService.openYouTube();
            }
          },
        ),

        SizedBox(height: 8.h),

        // Instagram Button
        _buildSocialMiniButton(
          icon: Icons.camera_alt_rounded,
          accentColor: const Color(0xFFE1306C),
          tooltip: 'إنستغرام ريلز',
          onTap: () {
            _pauseCurrentVideo();
            SocialService.openInstagram();
          },
        ),

        SizedBox(height: 8.h),

        // TikTok Button
        _buildSocialMiniButton(
          icon: Icons.music_note_rounded,
          accentColor: const Color(0xFF00F2FE),
          tooltip: 'تيك توك',
          onTap: () {
            _pauseCurrentVideo();
            SocialService.openTikTok();
          },
        ),

        SizedBox(height: 8.h),

        // Facebook Button
        _buildSocialMiniButton(
          icon: Icons.facebook_rounded,
          accentColor: const Color(0xFF1877F2),
          tooltip: 'فيسبوك',
          onTap: () {
            _pauseCurrentVideo();
            SocialService.openFacebook();
          },
        ),
      ],
    );
  }

  Widget _buildActionIconButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: color, size: 22.sp),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 10.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMiniButton({
    required IconData icon,
    required Color accentColor,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            shape: BoxShape.circle,
            border: Border.all(color: accentColor.withValues(alpha: 0.8), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.3),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(icon, color: accentColor, size: 18.sp),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 64.sp,
              color: AppColors.gold,
            ),
            SizedBox(height: 16.h),
            Text(
              'لا توجد مقاطع منشورة حالياً',
              style: GoogleFonts.cairo(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'ترقبوا نشر المقاطع الإيمانية اليومية بإذن الله.',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 13.sp,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
              ),
              child: Text(
                'العودة للرئيسية',
                style: GoogleFonts.cairo(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

