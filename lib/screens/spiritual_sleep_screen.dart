// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../models/theme_manager.dart';
import '../services/in_app_telemetry_service.dart';
import '../widgets/common/auto_scroll_text.dart';

class SleepTrack {
  final String id;
  final String title;
  final String subtitle;
  final String reciter;
  final String duration;
  final String audioUrl;
  final IconData icon;

  const SleepTrack({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.reciter,
    required this.duration,
    required this.audioUrl,
    required this.icon,
  });
}

class AmbientSound {
  final String id;
  final String name;
  final String audioUrl;
  final IconData icon;

  const AmbientSound({
    required this.id,
    required this.name,
    required this.audioUrl,
    required this.icon,
  });
}

class SpiritualSleepScreen extends StatefulWidget {
  const SpiritualSleepScreen({super.key});

  @override
  State<SpiritualSleepScreen> createState() => _SpiritualSleepScreenState();
}

class _SpiritualSleepScreenState extends State<SpiritualSleepScreen>
    with SingleTickerProviderStateMixin {
  // مشغلا الصوت: الأول للتلاوة والثاني لأصوات الطبيعة
  late final AudioPlayer _recitationPlayer;
  late final AudioPlayer _ambientPlayer;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  // التلاوات المختارة للنوم والسكينة
  final List<SleepTrack> _tracks = const [
    SleepTrack(
      id: 'mulk',
      title: 'سورة الملك (المانعة من عذاب القبر)',
      subtitle: 'سُنّة نبوية مؤكدة للقراءة والاستماع كل ليلة قبل النوم',
      reciter: 'الشيخ مشاري العفاسي',
      duration: '7:45',
      audioUrl: 'https://server8.mp3quran.net/afs/067.mp3',
      icon: Icons.nightlight_round,
    ),
    SleepTrack(
      id: 'yasin',
      title: 'سورة يس (قلب القرآن وراحة الصدور)',
      subtitle: 'لقضاء الحوائج وسكينة النفس وطرد الوساوس',
      reciter: 'الشيخ مشاري العفاسي',
      duration: '14:20',
      audioUrl: 'https://server8.mp3quran.net/afs/036.mp3',
      icon: Icons.favorite_rounded,
    ),
    SleepTrack(
      id: 'rahman',
      title: 'سورة الرحمن (عروس القرآن)',
      subtitle: 'آيات الرحمة والجمال الإلهي لسكون الروح',
      reciter: 'الشيخ مشاري العفاسي',
      duration: '11:15',
      audioUrl: 'https://server8.mp3quran.net/afs/055.mp3',
      icon: Icons.water_drop_rounded,
    ),
    SleepTrack(
      id: 'maryam',
      title: 'سورة مريم (جبر الخواطر والفرج)',
      subtitle: 'استشعار لطف الله الخفي في أشد الأوقات',
      reciter: 'الشيخ مشاري العفاسي',
      duration: '16:50',
      audioUrl: 'https://server8.mp3quran.net/afs/019.mp3',
      icon: Icons.spa_rounded,
    ),
    SleepTrack(
      id: 'baqarah',
      title: 'سورة البقرة (طاردة الشياطين وبركة البيت)',
      subtitle: 'حفظ وأمان وسكينة تملأ أرجاء البيت والقلب',
      reciter: 'الشيخ مشاري العفاسي',
      duration: '1:58:00',
      audioUrl: 'https://server8.mp3quran.net/afs/002.mp3',
      icon: Icons.shield_rounded,
    ),
    SleepTrack(
      id: 'sleep_azkar',
      title: 'أذكار النوم الصحيحة المأثورة',
      subtitle: 'التحصين النبوي المبارك قبل وضع الرأس على الوسادة',
      reciter: 'الشيخ مشاري العفاسي',
      duration: '8:30',
      audioUrl: 'https://archive.org/download/MsherrY-03_uP_bY_mUSLEm/03.mp3',
      icon: Icons.bedtime_rounded,
    ),
    SleepTrack(
      id: 'ruqyah',
      title: 'الرقية الشرعية للسكينة والشفاء',
      subtitle: 'آيات الحفظ والشفاء وطرد العين والأرق',
      reciter: 'الشيخ مشاري العفاسي',
      duration: '32:10',
      audioUrl: 'https://archive.org/download/Alafasy_Azkar_Sabah_Masaa/ruqyah.mp3',
      icon: Icons.healing_rounded,
    ),
  ];

  // أصوات الطبيعة المصاحبة
  final List<AmbientSound> _ambientSounds = const [
    AmbientSound(
      id: 'none',
      name: 'تلاوة نقية فقط',
      audioUrl: '',
      icon: Icons.volume_off_rounded,
    ),
    AmbientSound(
      id: 'rain',
      name: 'صوت مطر هادئ 🌧️',
      audioUrl: 'https://actions.google.com/sounds/v1/weather/rain_heavy.ogg',
      icon: Icons.grain_rounded,
    ),
    AmbientSound(
      id: 'stream',
      name: 'خرير ماء عذب 🌊',
      audioUrl: 'https://actions.google.com/sounds/v1/water/stream_water.ogg',
      icon: Icons.waves_rounded,
    ),
  ];

  int _selectedTrackIndex = 0;
  int _selectedAmbientIndex = 0;

  bool _isPlaying = false;
  bool _isLoading = false;

  final double _recitationVolume = 1.0;
  final double _ambientVolume = 0.35;

  // مؤقت النوم الذكي
  int _sleepTimerMinutes = 0; // 0 = معطل
  Timer? _sleepTimer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _recitationPlayer = AudioPlayer();
    _ambientPlayer = AudioPlayer();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // متابعة حالة المشغل
    _recitationPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          _isLoading = state.processingState == ProcessingState.loading ||
              state.processingState == ProcessingState.buffering;
        });
      }
    });
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    _recitationPlayer.dispose();
    _ambientPlayer.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    HapticFeedback.lightImpact();
    if (_isPlaying) {
      await _recitationPlayer.pause();
      if (_ambientPlayer.playing) await _ambientPlayer.pause();
    } else {
      await _playTrack(_selectedTrackIndex);
    }
  }

  Future<void> _playTrack(int index) async {
    setState(() {
      _selectedTrackIndex = index;
      _isLoading = true;
    });

    final track = _tracks[index];
    try {
      await _recitationPlayer.setUrl(track.audioUrl);
      await _recitationPlayer.setVolume(_recitationVolume);
      await _recitationPlayer.play();

      // تشغيل الصوت المصاحب إذا تم اختياره
      if (_selectedAmbientIndex > 0) {
        final ambient = _ambientSounds[_selectedAmbientIndex];
        await _ambientPlayer.setUrl(ambient.audioUrl);
        await _ambientPlayer.setVolume(_ambientVolume);
        await _ambientPlayer.setLoopMode(LoopMode.one);
        await _ambientPlayer.play();
      }

      InAppTelemetryService.logFeaturePulse('spiritual_sleep_play', metadata: {
        'track': track.title,
        'reciter': track.reciter,
      });
    } catch (e) {
      debugPrint('Sleep Player Error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectAmbientSound(int index) async {
    HapticFeedback.selectionClick();
    setState(() => _selectedAmbientIndex = index);

    if (index == 0) {
      await _ambientPlayer.stop();
    } else {
      final ambient = _ambientSounds[index];
      try {
        await _ambientPlayer.setUrl(ambient.audioUrl);
        await _ambientPlayer.setVolume(_ambientVolume);
        await _ambientPlayer.setLoopMode(LoopMode.one);
        if (_isPlaying) {
          await _ambientPlayer.play();
        }
      } catch (e) {
        debugPrint('Ambient Error: $e');
      }
    }
  }

  void _setSleepTimer(int minutes) {
    HapticFeedback.mediumImpact();
    _sleepTimer?.cancel();
    setState(() {
      _sleepTimerMinutes = minutes;
      _remainingSeconds = minutes * 60;
    });

    if (minutes > 0) {
      _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_remainingSeconds <= 1) {
          timer.cancel();
          _performGentleFadeOut();
        } else {
          setState(() {
            _remainingSeconds--;
          });
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم ضبط مؤقت النوم: سيتم إيقاف الصوت بعد $minutes دقيقة بهدوء 🌙',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: const Color(0xFF1B3B36),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _performGentleFadeOut() async {
    // تلاشٍ تدريجي هادئ لمستوى الصوت على مدار 10 ثوانٍ
    for (int i = 10; i >= 0; i--) {
      final factor = i / 10.0;
      await _recitationPlayer.setVolume(_recitationVolume * factor);
      await _ambientPlayer.setVolume(_ambientVolume * factor);
      await Future.delayed(const Duration(milliseconds: 600));
    }
    await _recitationPlayer.pause();
    await _ambientPlayer.pause();
    await _recitationPlayer.setVolume(_recitationVolume);
    await _ambientPlayer.setVolume(_ambientVolume);
    if (mounted) {
      setState(() {
        _sleepTimerMinutes = 0;
        _remainingSeconds = 0;
      });
    }
  }

  String _formatTimer(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<AppThemeManager>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A121A), // خلفية ليلية كحلية عميقة جداً ومريحة للعين
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'محراب السكينة وصوتيات النوم 🌙',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: const Color(0xFFE0E6ED),
            fontSize: 16.sp,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _sleepTimerMinutes > 0 ? Icons.timer : Icons.timer_outlined,
              color: _sleepTimerMinutes > 0 ? const Color(0xFFD4AF37) : Colors.white70,
            ),
            tooltip: 'مؤقت النوم الذكي',
            onPressed: _showTimerModal,
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // بطاقة مشغل السكينة العلوية مع النبض المتوهج
              _buildCenterPlayerCard(),

              SizedBox(height: 18.h),

              // مؤشر مؤقت النوم الحي إن كان مفعلاً
              if (_sleepTimerMinutes > 0) _buildTimerBanner(),

              SizedBox(height: 18.h),

              // قسم المؤثرات الصوتية المصاحبة (مطر، ماء، نقي)
              _buildAmbientSoundSelector(),

              SizedBox(height: 22.h),

              // قائمة التلاوات الخاشعة
              Text(
                'اختر سورة أو ورداً للنوم والسكينة:',
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFB0BEC5),
                ),
              ),

              SizedBox(height: 10.h),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _tracks.length,
                separatorBuilder: (ctx, i) => SizedBox(height: 8.h),
                itemBuilder: (ctx, index) {
                  final track = _tracks[index];
                  final isSelected = index == _selectedTrackIndex;
                  return _buildTrackTile(track, index, isSelected);
                },
              ),

              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterPlayerCard() {
    final currentTrack = _tracks[_selectedTrackIndex];

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF13222E),
            const Color(0xFF0F1B24).withOpacity(0.9),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: const Color(0xFF1E3A4B), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // أيقونة النبض الهادئة المتلألئة
          ScaleTransition(
            scale: _isPlaying ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
            child: Container(
              width: 90.w,
              height: 90.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFD4AF37).withOpacity(0.3),
                    const Color(0xFF1B3B36).withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Center(
                child: Container(
                  width: 64.w,
                  height: 64.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF1A2F3D),
                  ),
                  child: Icon(
                    currentTrack.icon,
                    color: const Color(0xFFD4AF37),
                    size: 32.sp,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 12.h),

          SizedBox(
            width: double.infinity,
            child: AutoScrollText(
              currentTrack.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          SizedBox(height: 4.h),

          Text(
            '${currentTrack.reciter} • ${currentTrack.duration}',
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              color: const Color(0xFF90A4AE),
            ),
          ),

          SizedBox(height: 16.h),

          // زر التشغيل والإيقاف الرئيسي
          GestureDetector(
            onTap: _togglePlay,
            child: Container(
              width: 65.w,
              height: 65.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFD4AF37), Color(0xFFAA820A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withOpacity(0.35),
                    blurRadius: 14,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: _isLoading
                    ? SizedBox(
                        width: 26.w,
                        height: 26.w,
                        child: const CircularProgressIndicator(
                          color: Colors.black87,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Icon(
                        _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.black87,
                        size: 38.sp,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerBanner() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2D2A),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFF2E5950)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.nightlight_round, color: Color(0xFFD4AF37), size: 18),
              SizedBox(width: 8.w),
              Text(
                'مؤقت النوم مفعّل: إيقاف تدريجي بعد',
                style: GoogleFonts.cairo(fontSize: 12.sp, color: Colors.white70),
              ),
            ],
          ),
          Text(
            _formatTimer(_remainingSeconds),
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFD4AF37),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmbientSoundSelector() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1B24),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFF1E3242)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.waves_rounded, color: Color(0xFF80CBC4), size: 18),
              SizedBox(width: 8.w),
              Text(
                'المؤثرات الصوتية المصاحبة (مزيج الاسترخاء):',
                style: GoogleFonts.cairo(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: List.generate(_ambientSounds.length, (idx) {
              final ambient = _ambientSounds[idx];
              final isSel = idx == _selectedAmbientIndex;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: InkWell(
                    onTap: () => _selectAmbientSound(idx),
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      decoration: BoxDecoration(
                        color: isSel ? const Color(0xFF1E3B36) : const Color(0xFF15222E),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isSel ? const Color(0xFF26A69A) : Colors.transparent,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            ambient.icon,
                            color: isSel ? const Color(0xFF80CBC4) : Colors.white54,
                            size: 20.sp,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            ambient.name,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                              fontSize: 10.sp,
                              color: isSel ? Colors.white : Colors.white54,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackTile(SleepTrack track, int index, bool isSelected) {
    return InkWell(
      onTap: () => _playTrack(index),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF162B38) : const Color(0xFF0F1A22),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF1A2A36),
            width: isSelected ? 1.4 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFD4AF37).withOpacity(0.2) : const Color(0xFF1A2D3A),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSelected && _isPlaying ? Icons.volume_up_rounded : track.icon,
                color: isSelected ? const Color(0xFFD4AF37) : Colors.white60,
                size: 22.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isSelected
                      ? AutoScrollText(
                          track.title,
                          style: GoogleFonts.cairo(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFD4AF37),
                          ),
                        )
                      : Text(
                          track.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                  Text(
                    track.subtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 10.sp,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              track.duration,
              style: GoogleFonts.cairo(
                fontSize: 11.sp,
                color: isSelected ? const Color(0xFFD4AF37) : Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTimerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F1C26),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) {
        final options = [15, 30, 45, 60, 90, 0];
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'ضبط مؤقت النوم الذكي 🌙',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'سيقوم التطبيق بخفض الصوت تدريجياً وإيقافه بهدوء حتى لا يوقظك',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(fontSize: 11.sp, color: Colors.white54),
                ),
                SizedBox(height: 16.h),
                Wrap(
                  spacing: 10.w,
                  runSpacing: 10.h,
                  alignment: WrapAlignment.center,
                  children: options.map((mins) {
                    final isSel = _sleepTimerMinutes == mins;
                    final label = mins == 0 ? 'تعطيل المؤقت' : '$mins دقيقة';
                    return ChoiceChip(
                      label: Text(
                        label,
                        style: GoogleFonts.cairo(
                          color: isSel ? Colors.black87 : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      selected: isSel,
                      selectedColor: const Color(0xFFD4AF37),
                      backgroundColor: const Color(0xFF182834),
                      onSelected: (val) {
                        Navigator.pop(ctx);
                        _setSleepTimer(mins);
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        );
      },
    );
  }
}
