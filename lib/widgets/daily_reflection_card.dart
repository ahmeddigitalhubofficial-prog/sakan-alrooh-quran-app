// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/theme_manager.dart';
import '../screens/spiritual_moods_screen.dart';
import '../services/daily_reflection_service.dart';
import '../core/helpers/app_lifecycle_helper.dart';

class DailyReflectionCard extends StatefulWidget {
  const DailyReflectionCard({super.key});

  @override
  State<DailyReflectionCard> createState() => _DailyReflectionCardState();
}

class _DailyReflectionCardState extends State<DailyReflectionCard> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription? _playerSub;
  bool _isPlaying = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _playerSub?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleAudio(String audioUrl) async {
    HapticFeedback.lightImpact();
    if (_isPlaying) {
      await _audioPlayer.stop();
      safeSetState(() => _isPlaying = false);
      return;
    }

    try {
      safeSetState(() => _isLoading = true);
      await _audioPlayer.setUrl(audioUrl);
      _playerSub?.cancel();
      _playerSub = _audioPlayer.playerStateStream.listen((state) {
        safeSetState(() {
          _isPlaying = state.playing && state.processingState != ProcessingState.completed;
          _isLoading = state.processingState == ProcessingState.buffering || state.processingState == ProcessingState.loading;
        });
      });
      await _audioPlayer.play();
    } catch (_) {
      safeSetState(() {
        _isLoading = false;
        _isPlaying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<AppThemeManager>(context);
    final theme = themeManager.currentTheme;

    return ValueListenableBuilder<DailyReflection>(
      valueListenable: DailyReflectionService.currentReflectionNotifier,
      builder: (context, item, _) {
        return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.cardColor,
            theme.cardColor.withValues(alpha: 0.9),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: theme.accentColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: theme.accentColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Text('🕊️', style: TextStyle(fontSize: 18.sp)),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'رسالة لقلبك اليوم',
                    style: GoogleFonts.cairo(
                      color: theme.textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: theme.accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: theme.accentColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  item.moodCategory,
                  style: GoogleFonts.cairo(
                    color: theme.accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11.sp,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),

          // Quran Verse
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: [
                Text(
                  item.verseArabic,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.amiri(
                    color: theme.textColor,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    height: 1.8,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  item.surahAndVerse,
                  style: GoogleFonts.cairo(
                    color: theme.accentColor,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 12.h),

          // Reflection Text
          Text(
            item.reflection,
            style: GoogleFonts.cairo(
              color: theme.textColor.withValues(alpha: 0.9),
              fontSize: 12.5.sp,
              height: 1.6,
            ),
          ),

          SizedBox(height: 14.h),
          Divider(color: theme.dividerColor.withValues(alpha: 0.2)),
          SizedBox(height: 6.h),

          // Action Buttons: Audio, Share, Spiritual Sanctuary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Audio Listen Button
              InkWell(
                borderRadius: BorderRadius.circular(12.r),
                onTap: () => _toggleAudio(item.audioUrl),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  child: Row(
                    children: [
                      _isLoading
                          ? SizedBox(width: 16.w, height: 16.h, child: const CircularProgressIndicator(strokeWidth: 2))
                          : Icon(
                              _isPlaying ? Icons.stop_circle_rounded : Icons.play_circle_fill_rounded,
                              color: theme.accentColor,
                              size: 20.sp,
                            ),
                      SizedBox(width: 6.w),
                      Text(
                        _isPlaying ? 'إيقاف' : 'استماع للتلاوة',
                        style: GoogleFonts.cairo(
                          color: theme.accentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11.5.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Share Button
              IconButton(
                icon: Icon(Icons.share_rounded, color: theme.subtitleColor, size: 18.sp),
                tooltip: 'مشاركة الرسالة',
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Share.share(
                    'رسالة لقلبك اليوم 🕊️\n\n${item.verseArabic}\n(${item.surahAndVerse})\n\n💡 ${item.reflection}\n\nتطبيق نور الهدى 🌙',
                  );
                },
              ),

              // Link to Spiritual Moods
              InkWell(
                borderRadius: BorderRadius.circular(12.r),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SpiritualMoodsScreen()),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  child: Row(
                    children: [
                      Text(
                        'الملاذ الإيماني',
                        style: GoogleFonts.cairo(
                          color: theme.subtitleColor,
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(Icons.arrow_forward_ios_rounded, color: theme.subtitleColor, size: 11.sp),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
      },
    );
  }
}
