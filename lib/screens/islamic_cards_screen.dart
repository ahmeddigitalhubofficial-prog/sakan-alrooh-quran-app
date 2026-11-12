// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/theme_manager.dart';

class GreetingTemplate {
  final String id;
  final String title;
  final String occasion;
  final String message;
  final List<Color> gradient;
  final String emoji;

  const GreetingTemplate({
    required this.id,
    required this.title,
    required this.occasion,
    required this.message,
    required this.gradient,
    required this.emoji,
  });
}

class IslamicCardsScreen extends StatefulWidget {
  const IslamicCardsScreen({super.key});

  @override
  State<IslamicCardsScreen> createState() => _IslamicCardsScreenState();
}

class _IslamicCardsScreenState extends State<IslamicCardsScreen> {
  final TextEditingController _senderNameController = TextEditingController();

  static const List<GreetingTemplate> templates = [
    GreetingTemplate(
      id: 'friday',
      title: 'جمعة طيبة مباركة',
      occasion: 'يوم الجمعة المبارك',
      message: 'طابت جمعتكم بذكر الله، وعطر الله أيامكم بالصلاة على الحبيب المصطفى ﷺ، وجعل لكم في هذه الساعة المباركة دعوة لا تُرد ونوراً ما بين الجمعتين.',
      gradient: [Color(0xFF0F5A3E), Color(0xFF05140E)],
      emoji: '🕌',
    ),
    GreetingTemplate(
      id: 'ramadan',
      title: 'مبارك عليكم شهر رمضان',
      occasion: 'شهر رمضان المبارك',
      message: 'أهلاً بشهر الخير والرحمات.. مبارك عليكم حلول شهر رمضان المبارك، تقبل الله منا ومنكم الصيام والقيام وصالح الأعمال، وأعاده علينا وعليكم باليمن والبركات.',
      gradient: [Color(0xFF1D3557), Color(0xFF0A1128)],
      emoji: '🌙',
    ),
    GreetingTemplate(
      id: 'eid_fitr',
      title: 'عيد فطر سعيد ومبارك',
      occasion: 'عيد الفطر السعيد',
      message: 'تقبل الله طاعتكم وأتم عليكم فرحتكم.. كل عام وأنتم بخير وصحة وسعادة بمناسبة عيد الفطر المبارك، أعاده الله عليكم وعلى الأمة الإسلامية بالخير والمسرات.',
      gradient: [Color(0xFF5C3D21), Color(0xFF1F1105)],
      emoji: '🎉',
    ),
    GreetingTemplate(
      id: 'eid_adha',
      title: 'عيد أضحى مبارك',
      occasion: 'عيد الأضحى المبارك',
      message: 'بأسمى آيات التهاني والتبريكات، نهنئكم بحلول عيد الأضحى المبارك، تقبل الله منا ومنكم صالح الأعمال وجعل أيامكم كلها أعياداً وفرحاً.',
      gradient: [Color(0xFF1A1A1A), Color(0xFF332B12)],
      emoji: '🕋',
    ),
    GreetingTemplate(
      id: 'arafah',
      title: 'دعاء وبركة يوم عرفة',
      occasion: 'يوم عرفة المبارك',
      message: 'خير الدعاء دعاء يوم عرفة.. نسأل الله في هذا اليوم الفضيل أن يغفر ذنوبكم، ويفرج همومكم، ويستجيب دعواتكم، ويكتبكم من عتقائه من النار.',
      gradient: [Color(0xFF026873), Color(0xFF012E40)],
      emoji: '🤲',
    ),
    GreetingTemplate(
      id: 'dua_gift',
      title: 'إهداء ودعاء للأحبة',
      occasion: 'دعاء ومحبة في الله',
      message: 'اللهم احفظ أحبتي بعينك التي لا تنام، ويسر أمورهم، واشرح صدورهم، وارزقهم من حيث لا يحتسبون، واجمعنا بهم في جنات النعيم.',
      gradient: [Color(0xFF3F2B63), Color(0xFF160D27)],
      emoji: '🌸',
    ),
  ];

  late GreetingTemplate _selectedTemplate;

  @override
  void initState() {
    super.initState();
    _selectedTemplate = templates.first;
  }

  @override
  void dispose() {
    _senderNameController.dispose();
    super.dispose();
  }

  void _shareCard() {
    HapticFeedback.mediumImpact();
    final sender = _senderNameController.text.trim();
    final senderText = sender.isNotEmpty ? '\n\nمقدم من: $sender' : '';
    final text = '✨ ${_selectedTemplate.title} ✨\n\n${_selectedTemplate.message}$senderText\n\n— بطاقة مباركة من تطبيق سكن الروح (Sakan Al-Rooh) 🌙';
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<AppThemeManager>(context).currentTheme;
    final sender = _senderNameController.text.trim();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'صانع بطاقات التهنئة الإسلامية 🎨',
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
              // 1. Interactive Preview Card
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.r),
                  gradient: LinearGradient(
                    colors: _selectedTemplate.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.6), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: _selectedTemplate.gradient.first.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(_selectedTemplate.emoji, style: TextStyle(fontSize: 40.sp)),
                    SizedBox(height: 10.h),
                    Text(
                      _selectedTemplate.title,
                      style: GoogleFonts.cairo(
                        color: const Color(0xFFFFD700),
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      _selectedTemplate.message,
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 13.sp,
                        height: 1.8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (sender.isNotEmpty) ...[
                      SizedBox(height: 16.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          'من: $sender',
                          style: GoogleFonts.cairo(color: const Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 12.sp),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(height: 18.h),

              // 2. Share Button
              ElevatedButton.icon(
                onPressed: _shareCard,
                icon: const Icon(Icons.share_rounded, color: Colors.black),
                label: Text(
                  'مشاركة البطاقة عبر واتساب والتطبيقات 📤',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14.sp),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.accentColor,
                  foregroundColor: Colors.black,
                  minimumSize: Size(double.infinity, 46.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                ),
              ),

              SizedBox(height: 20.h),

              // 3. Sender Name Input
              TextField(
                controller: _senderNameController,
                style: GoogleFonts.cairo(color: theme.textColor, fontSize: 13.sp),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'اكتب اسمك ليظهر على البطاقة (اختياري)',
                  labelStyle: GoogleFonts.cairo(color: theme.subtitleColor, fontSize: 12.sp),
                  prefixIcon: Icon(Icons.edit_note_rounded, color: theme.accentColor),
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide(color: theme.accentColor, width: 1.5),
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // 4. Select Occasion Templates
              Text(
                'اختر مناسبة البطاقة:',
                style: GoogleFonts.cairo(color: theme.textColor, fontWeight: FontWeight.bold, fontSize: 14.sp),
              ),
              SizedBox(height: 10.h),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: templates.length,
                separatorBuilder: (_, __) => SizedBox(height: 10.h),
                itemBuilder: (context, index) {
                  final t = templates[index];
                  final isSelected = _selectedTemplate.id == t.id;

                  return Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: isSelected ? theme.accentColor : theme.dividerColor.withValues(alpha: 0.2),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ListTile(
                      leading: Text(t.emoji, style: TextStyle(fontSize: 24.sp)),
                      title: Text(
                        t.title,
                        style: GoogleFonts.cairo(
                          color: isSelected ? theme.accentColor : theme.textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.sp,
                        ),
                      ),
                      subtitle: Text(
                        t.occasion,
                        style: GoogleFonts.cairo(color: theme.subtitleColor, fontSize: 11.sp),
                      ),
                      trailing: isSelected ? Icon(Icons.check_circle_rounded, color: theme.accentColor) : null,
                      onTap: () {
                        setState(() {
                          _selectedTemplate = t;
                        });
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }
}
