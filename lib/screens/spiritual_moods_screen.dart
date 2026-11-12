// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/theme_manager.dart';
import '../widgets/common/auto_scroll_text.dart';
import 'card_studio_screen.dart';
import 'spiritual_sleep_screen.dart';

class MoodItem {
  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final IconData icon;
  final Color accentColor;
  final String quranAyah;
  final String quranRef;
  final String prophetDua;
  final String calmingDhikr;
  final int dhikrCount;

  const MoodItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.icon,
    required this.accentColor,
    required this.quranAyah,
    required this.quranRef,
    required this.prophetDua,
    required this.calmingDhikr,
    this.dhikrCount = 10,
  });
}

class SpiritualMoodsScreen extends StatelessWidget {
  const SpiritualMoodsScreen({super.key});

  static const List<MoodItem> moods = [
    MoodItem(
      id: 'anxious',
      title: 'قلق أو خائف',
      subtitle: 'لطمأنينة القلب وسكون الروح وبث الأمان',
      emoji: '🌿',
      icon: Icons.spa_outlined,
      accentColor: Color(0xFF26A69A),
      quranAyah: 'الَّذِينَ آمَنُوا وَتَطْمَئِنُّ قُلُوبُهُم بِذِكْرِ اللَّهِ ۗ أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
      quranRef: 'سورة الرعد: 28',
      prophetDua: '« اللَّهُمَّ إِنِّي عَبْدُكَ، ابْنُ عَبْدِكَ، ابْنُ أَمَتِكَ، نَاصِيَتِي بِيَدِكَ، مَاضٍ فِيَّ حُكْمُكَ، عَدْلٌ فِيَّ قَضَاؤُكَ، أَسْأَلُكَ بِكُلِّ اسْمٍ هُوَ لَكَ سَمَّيْتَ بِهِ نَفْسَكَ، أَوْ أَنْزَلْتَهُ فِي كِتَابِكَ، أَوْ عَلَّمْتَهُ أَحَدًا مِنْ خَلْقِكَ، أَوِ اسْتَأْثَرْتَ بِهِ فِي عِلْمِ الْغَيْبِ عِنْدَكَ، أَنْ تَجْعَلَ الْقُرْآنَ رَبِيعَ قَلْبِي، وَنُورَ صَدْرِي، وَجَلاءَ حُزْنِي، وَذَهَابَ هَمِّي »',
      calmingDhikr: 'لا حَوْلَ وَلا قُوَّةَ إِلا بِاللَّهِ الْعَلِيِّ الْعَظِيمِ',
      dhikrCount: 10,
    ),
    MoodItem(
      id: 'sad',
      title: 'حزين ومكسور الخاطر',
      subtitle: 'لجبر الخواطر ورفع الأحزان والبشارة',
      emoji: '🌧️',
      icon: Icons.cloud_outlined,
      accentColor: Color(0xFF5C6BC0),
      quranAyah: 'لَا تَحْزَنْ إِنَّ اللَّهَ مَعَنَا ۖ فَأَنزَلَ اللَّهُ سَكِينَتَهُ عَلَيْهِ\nوَلَسَوْفَ يُعْطِيكَ رَبُّكَ فَتَرْضَىٰ',
      quranRef: 'التوبة: 40 | الضحى: 5',
      prophetDua: '« اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ، وَالْعَجْزِ وَالْكَسَلِ، وَالْبُخْلِ وَالْجُبْنِ، وَضَلَعِ الدَّيْنِ وَغَلَبَةِ الرِّجَالِ »',
      calmingDhikr: 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
      dhikrCount: 10,
    ),
    MoodItem(
      id: 'stressed',
      title: 'مضغوط ومشتت الذهن',
      subtitle: 'لتيسير الأمور وصرف الشتات وحسن التوكل',
      emoji: '🌪️',
      icon: Icons.air_rounded,
      accentColor: Color(0xFF78909C),
      quranAyah: 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا • إِنَّ مَعَ الْعُسْرِ يُسْرًا • فَإِذَا فَرَغْتَ فَانصَبْ • وَإِلَىٰ رَبِّكَ فَارْغَب',
      quranRef: 'سورة الشرح: 5-8',
      prophetDua: '« يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ، أَصْلِحْ لِي شَأْنِي كُلَّهُ، وَلا تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ »',
      calmingDhikr: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ الْعَظِيمِ',
      dhikrCount: 10,
    ),
    MoodItem(
      id: 'sustenance',
      title: 'أسعى للرزق والبركة',
      subtitle: 'لفتح أبواب الخير والبركة وسعة العطاء',
      emoji: '💰',
      icon: Icons.monetization_on_outlined,
      accentColor: Color(0xFFFFA000),
      quranAyah: 'فَقُلْتُ اسْتَغْفِرُوا رَبَّكُمْ إِنَّهُ كَانَ غَفَّارًا • يُرْسِلِ السَّمَاءَ عَلَيْكُم مِّدْرَارًا • وَيُمْدِدْكُم بِأَمْوَالٍ وَبَنِينَ وَيَجْعَل لَّكُمْ جَنَّاتٍ وَيَجْعَل لَّكُمْ أَنْهَارًا',
      quranRef: 'سورة نوح: 10-12',
      prophetDua: '« اللَّهُمَّ اكْفِنِي بِحَلالِكَ عَنْ حَرَامِكَ، وَأَغْنِنِي بِفَضْلِكَ عَمَّنْ سِوَاكَ »',
      calmingDhikr: 'أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ وَأَتُوبُ إِلَيْهِ',
      dhikrCount: 33,
    ),
    MoodItem(
      id: 'repentance',
      title: 'نادم وأطلب التوبة والمغفرة',
      subtitle: 'لسعة رحمة الله ومحو الذنوب وتجديد العهد',
      emoji: '🤲',
      icon: Icons.clean_hands_outlined,
      accentColor: Color(0xFF66BB6A),
      quranAyah: 'قُلْ يَا عِبَادِيَ الَّذِينَ أَسْرَفُوا عَلَىٰ أَنفُسِهِمْ لَا تَقْنَطُوا مِن رَّحْمَةِ اللَّهِ ۚ إِنَّ اللَّهَ يَغْفِرُ الذُّنُوبَ جَمِيعًا ۚ إِنَّهُ هُوَ الْغَفُورُ الرَّحِيمُ',
      quranRef: 'سورة الزمر: 53',
      prophetDua: '« اللَّهُمَّ أَنْتَ رَبِّي لا إِلَهَ إِلا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لا يَغْفِرُ الذُّنُوبَ إِلا أَنْتَ »',
      calmingDhikr: 'رَبِّ اغْفِرْ لِي وَتُبْ عَلَيَّ إِنَّكَ أَنْتَ التَّوَّابُ الرَّحِيمُ',
      dhikrCount: 10,
    ),
    MoodItem(
      id: 'grateful',
      title: 'ممتن وشاكر لله',
      subtitle: 'لزيادة النعم ودوام الفضل والحمد الجميل',
      emoji: '🌸',
      icon: Icons.favorite_border_rounded,
      accentColor: Color(0xFFEC407A),
      quranAyah: 'وَإِذْ تَأَذَّنَ رَبُّكُمْ لَئِن شَكَرْتُمْ لَأَزِيدَنَّكُمْ ۖ وَلَئِن كَفَرْتُمْ إِنَّ عَذَابِي لَشَدِيدٌ',
      quranRef: 'سورة إبراهيم: 7',
      prophetDua: '« اللَّهُمَّ مَا أَصْبَحَ (أَوْ أَمْسَى) بِي مِنْ نِعْمَةٍ أَوْ بِأَحَدٍ مِنْ خَلْقِكَ، فَمِنْكَ وَحْدَكَ لا شَرِيكَ لَكَ، فَلَكَ الْحَمْدُ وَلَكَ الشُّكْرُ »',
      calmingDhikr: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ حَمْداً كَثِيراً طَيِّباً مُبَارَكاً فِيهِ',
      dhikrCount: 10,
    ),
    MoodItem(
      id: 'sick',
      title: 'مريض أو متألم',
      subtitle: 'لطلب الشفاء والعافية والرقى النبوية المباركة',
      emoji: '🩹',
      icon: Icons.healing_outlined,
      accentColor: Color(0xFF29B6F6),
      quranAyah: 'وَإِذَا مَرِضْتُ فَهُوَ يَشْفِينِ • وَنُنَزِّلُ مِنَ الْقُرْآنِ مَا هُوَ شِفَاءٌ وَرَحْمَةٌ لِّلْمُؤْمِنِينَ',
      quranRef: 'الشعراء: 80 | الإسراء: 82',
      prophetDua: '« اللَّهُمَّ رَبَّ النَّاسِ، أَذْهِبِ الْبَأْسَ، اشْفِ أَنْتَ الشَّافِي، لا شِفَاءَ إِلا شِفَاؤُكَ، شِفَاءً لا يُغَادِرُ سَقَمًا »',
      calmingDhikr: 'أَعُوذُ بِاللَّهِ وَقُدْرَتِهِ مِنْ شَرِّ مَا أَجِدُ وَأُحَاذِرُ',
      dhikrCount: 7,
    ),
    MoodItem(
      id: 'decision',
      title: 'مقبل على أمر جديد ومحتار',
      subtitle: 'لطلب الهداية والبصيرة والتوفيق وسداد الرأي',
      emoji: '🧭',
      icon: Icons.explore_outlined,
      accentColor: Color(0xFFAB47BC),
      quranAyah: 'وَتَوَكَّلْ عَلَى الْعَزِيزِ الرَّحِيمِ • الَّذِي يَرَاكَ حِينَ تَقُومُ • وَتَقَلُّبَكَ فِي السَّاجِدِينَ',
      quranRef: 'سورة الشعراء: 217-219',
      prophetDua: '« اللَّهُمَّ إِنِّي أَسْتَخِيرُكَ بِعِلْمِكَ، وَأَسْتَقْدِرُكَ بِقُدْرَتِكَ، وَأَسْأَلُكَ مِنْ فَضْلِكَ الْعَظِيمِ، فَإِنَّكَ تَقْدِرُ وَلا أَقْدِرُ، وَتَعْلَمُ وَلا أَعْلَمُ، وَأَنْتَ عَلامُ الْغُيُوبِ »',
      calmingDhikr: 'اللَّهُمَّ خِرْ لِي وَاخْتَرْ لِي وَلا تَكِلْنِي إِلَى نَفْسِي',
      dhikrCount: 10,
    ),
    MoodItem(
      id: 'faith_weak',
      title: 'أشعر بفتور وضعف الإيمان',
      subtitle: 'لتجديد جذوة الإيمان وقوة الصلة بالله والخشوع',
      emoji: '🔥',
      icon: Icons.whatshot_outlined,
      accentColor: Color(0xFFFF7043),
      quranAyah: 'أَلَمْ يَأْنِ لِلَّذِينَ آمَنُوا أَن تَخْشَعَ قُلُوبُهُمْ لِذِكْرِ اللَّهِ وَمَا نَزَلَ مِنَ الْحَقِّ وَلَا يَكُونُوا كَالَّذِينَ أُوتُوا الْكِتَابَ مِن قَبْلُ',
      quranRef: 'سورة الحديد: 16',
      prophetDua: '« يَا مُقَلِّبَ الْقُلُوبِ ثَبِّتْ قَلْبِي عَلَى دِينِكَ، اللَّهُمَّ مُصَرِّفَ الْقُلُوبِ صَرِّفْ قُلُوبَنَا عَلَى طَاعَتِكَ »',
      calmingDhikr: 'لا إِلَهَ إِلا اللَّهُ وَحْدَهُ لا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
      dhikrCount: 10,
    ),
    MoodItem(
      id: 'lonely',
      title: 'أشعر بالوحدة والغربة',
      subtitle: 'لمعية الله وأنس القرب ولطفه الدائم بالعبد',
      emoji: '🕊️',
      icon: Icons.night_shelter_outlined,
      accentColor: Color(0xFF26C6DA),
      quranAyah: 'وَإِذَا سَأَلَكَ عِبَادِي عَنِّي فَإِنِّي قَرِيبٌ ۖ أُجِيبُ دَعْوَةَ الدَّاعِ إِذَا دَعَانِ ۖ فَلْيَسْتَجِيبُوا لِي وَلْيُؤْمِنُوا بِي لَعَلَّهُمْ يَرْشُدُونَ',
      quranRef: 'سورة البقرة: 186',
      prophetDua: '« اللَّهُمَّ آنِسْ وَحْشَتِي فِي قَلْبِي، وَاجْعَلْ لِي مِنْ لَدُنْكَ وَلِيًّا، وَاجْعَلْ لِي مِنْ لَدُنْكَ نَصِيرًا »',
      calmingDhikr: 'سُبْحَانَ اللَّهِ، وَالْحَمْدُ لِلَّهِ، وَلا إِلَهَ إِلا اللَّهُ، وَاللَّهُ أَكْبَرُ',
      dhikrCount: 10,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<AppThemeManager>(context).currentTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'الملاذ الإيماني • بماذا تشعر؟ 🤍',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16.sp),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Container(
                padding: EdgeInsets.all(18.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  gradient: LinearGradient(
                    colors: [theme.primaryColor, theme.cardColor],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  border: Border.all(color: theme.accentColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Text('🤍', style: TextStyle(fontSize: 32.sp)),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ألا بذكر الله تطمئن القلوب',
                            style: GoogleFonts.cairo(
                              color: theme.accentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15.sp,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'اختر ما يمر به قلبك الآن، ليرشدك التطبيق إلى آيات السكينة والأدعية والأذكار المخصصة لحالتك.',
                            style: GoogleFonts.cairo(color: Colors.white70, fontSize: 11.sp, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 14.h),

              // محراب السكينة وصوتيات النوم المريح
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SpiritualSleepScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0D1B2A), Color(0xFF1B263B)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.4), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46.w,
                        height: 46.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFD4AF37).withOpacity(0.15),
                        ),
                        child: const Icon(Icons.nightlight_round, color: Color(0xFFD4AF37), size: 24),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: AutoScrollText(
                                    'محراب السكينة وصوتيات النوم',
                                    style: GoogleFonts.cairo(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD4AF37),
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Text(
                                    'جديد 🌙',
                                    style: GoogleFonts.cairo(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 9.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'تلاوات هادئة مدمجة بأصوات المطر ومؤقت إيقاف ذكي',
                              style: GoogleFonts.cairo(color: const Color(0xFF90A4AE), fontSize: 11.sp),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFD4AF37), size: 16),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 18.h),

              Text(
                'اختر حالتك النفسية والروحية:',
                style: GoogleFonts.cairo(
                  color: theme.textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),

              SizedBox(height: 12.h),

              // 10 Mood Cards
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: moods.length,
                separatorBuilder: (_, __) => SizedBox(height: 10.h),
                itemBuilder: (context, index) {
                  final mood = moods[index];
                  return _buildMoodTile(context, mood, theme);
                },
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodTile(BuildContext context, MoodItem mood, AppTheme theme) {
    return Card(
      color: theme.cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.r),
        side: BorderSide(color: mood.accentColor.withValues(alpha: 0.3), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18.r),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MoodDetailScreen(mood: mood),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: mood.accentColor.withValues(alpha: 0.15),
                ),
                child: Center(
                  child: Text(mood.emoji, style: TextStyle(fontSize: 22.sp)),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mood.title,
                      style: GoogleFonts.cairo(
                        color: theme.textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      mood.subtitle,
                      style: GoogleFonts.cairo(
                        color: theme.subtitleColor,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: mood.accentColor, size: 16.sp),
            ],
          ),
        ),
      ),
    );
  }
}

class MoodDetailScreen extends StatefulWidget {
  final MoodItem mood;

  const MoodDetailScreen({super.key, required this.mood});

  @override
  State<MoodDetailScreen> createState() => _MoodDetailScreenState();
}

class _MoodDetailScreenState extends State<MoodDetailScreen> {
  int _counter = 0;

  void _increment() {
    if (_counter < widget.mood.dhikrCount) {
      HapticFeedback.lightImpact();
      setState(() {
        _counter++;
      });
      if (_counter == widget.mood.dhikrCount) {
        HapticFeedback.mediumImpact();
        Provider.of<AppThemeManager>(context, listen: false).addHasanatPoints(30);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تقبل الله منك وطمأن قلبك 🤍 (+30 حسنة)', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            backgroundColor: const Color(0xFF0F5A3E),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<AppThemeManager>(context).currentTheme;
    final mood = widget.mood;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          '${mood.emoji} ${mood.title}',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16.sp),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            onPressed: () {
              Share.share(
                '🕊️ آية السكينة:\n"${mood.quranAyah}"\n(${mood.quranRef})\n\n🤲 دعاء الطمأنينة:\n${mood.prophetDua}\n\nمن تطبيق نور الهدى 🌙',
              );
            },
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Quran Ayah Card
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(color: mood.accentColor.withValues(alpha: 0.4), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: mood.accentColor.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.menu_book_rounded, color: mood.accentColor, size: 20.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'آية السكينة واليقين 📖',
                          style: GoogleFonts.cairo(color: mood.accentColor, fontWeight: FontWeight.bold, fontSize: 14.sp),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      '« ${mood.quranAyah} »',
                      style: GoogleFonts.amiri(
                        color: theme.textColor,
                        fontSize: 19.sp,
                        fontWeight: FontWeight.bold,
                        height: 2.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      mood.quranRef,
                      style: GoogleFonts.cairo(color: theme.subtitleColor, fontSize: 11.sp),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 18.h),

              // 2. Prophet Dua Card
              Container(
                padding: EdgeInsets.all(18.w),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(22.r),
                  border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.favorite_rounded, color: Colors.amber, size: 20.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'الدعاء النبوي المأثور 🤲',
                          style: GoogleFonts.cairo(color: theme.textColor, fontWeight: FontWeight.bold, fontSize: 14.sp),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      mood.prophetDua,
                      style: GoogleFonts.cairo(
                        color: theme.textColor.withValues(alpha: 0.9),
                        fontSize: 13.sp,
                        height: 1.8,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 14.h),

              // زر صمم وشارك كحالة ستوري 9:16
              ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CardStudioScreen(
                        initialText: '﴿ ${mood.quranAyah} ﴾',
                        initialSource: '${mood.quranRef} • ${mood.title}',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.camera_alt_rounded, size: 20),
                label: Text(
                  'صمم وشارك كحالة ستوري (9:16) 📲',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13.sp),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                  elevation: 2,
                ),
              ),

              SizedBox(height: 18.h),

              // 3. Calming Interactive Dhikr Counter Card
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(24.r),
                  gradient: LinearGradient(
                    colors: [theme.cardColor, mood.accentColor.withValues(alpha: 0.15)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  border: Border.all(color: mood.accentColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      'الورد والذكر المهدئ 📿',
                      style: GoogleFonts.cairo(color: mood.accentColor, fontWeight: FontWeight.bold, fontSize: 14.sp),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      mood.calmingDhikr,
                      style: GoogleFonts.amiri(
                        color: theme.textColor,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        height: 1.8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 18.h),
                    GestureDetector(
                      onTap: _increment,
                      child: Container(
                        width: 90.w,
                        height: 90.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: mood.accentColor,
                          boxShadow: [
                            BoxShadow(
                              color: mood.accentColor.withValues(alpha: 0.4),
                              blurRadius: 18,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '$_counter / ${mood.dhikrCount}',
                            style: GoogleFonts.cairo(
                              color: Colors.black,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      _counter >= mood.dhikrCount ? 'تم إتمام الورد بنجاح 🤍' : 'اضغط على الدائرة للتسبيح',
                      style: GoogleFonts.cairo(color: theme.subtitleColor, fontSize: 11.sp),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }
}
