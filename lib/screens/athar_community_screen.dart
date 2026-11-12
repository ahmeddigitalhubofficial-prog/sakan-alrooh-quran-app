// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';
import '../core/localization/app_translations.dart';
import '../models/athar_post_model.dart';
import '../services/athar_moderation_service.dart';
import 'card_studio_screen.dart';

class AtharCommunityScreen extends StatefulWidget {
  const AtharCommunityScreen({super.key});

  @override
  State<AtharCommunityScreen> createState() => _AtharCommunityScreenState();
}

class _AtharCommunityScreenState extends State<AtharCommunityScreen> {
  AtharCategory _selectedCategory = AtharCategory.all;
  final AtharModerationService _moderation = AtharModerationService.instance;
  List<String> _blockedUserIds = [];

  // خلفيات ملونة وتدرجات للمنشورات
  static const List<List<Color>> _postGradients = [
    [Color(0xFF0F5A3E), Color(0xFF102C3B)], // زمردي ليلي
    [Color(0xFF1D3557), Color(0xFF0F2027)], // كحلي عميق
    [Color(0xFF2C3E50), Color(0xFF34495E)], // رمادي وقور
    [Color(0xFF4A154B), Color(0xFF1F0D29)], // بنفسجي ملكي
    [Color(0xFF8C5014), Color(0xFF381F08)], // ذهبي برونزي
  ];

  // أيقونات وصور رمزية للمستخدمين
  static const List<IconData> _avatars = [
    Icons.auto_stories_rounded,
    Icons.favorite_rounded,
    Icons.spa_rounded,
    Icons.wb_sunny_rounded,
    Icons.nightlight_round,
    Icons.menu_book_rounded,
    Icons.light_mode_rounded,
  ];

  // المنشورات الأولية (نموذج محاكاة واقعي ومكتمل)
  late List<AtharPost> _allPosts;

  @override
  void initState() {
    super.initState();
    _loadBlockedUsers();
    _initSeedPosts();
  }

  Future<void> _loadBlockedUsers() async {
    final blocked = await _moderation.getBlockedUsers();
    if (mounted) {
      setState(() {
        _blockedUserIds = blocked;
      });
    }
  }

  void _initSeedPosts() {
    _allPosts = [
      AtharPost(
        id: 'seed_1',
        authorId: 'author_1',
        authorName: 'عبدالرحمن الإمام',
        avatarIndex: 0,
        isTrustedAuthor: true,
        category: AtharCategory.tadabbur,
        gradientIndex: 0,
        content:
            '﴿أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ﴾\n\nكلما ضاقت بك السبل وأثقلت عليك هموم الحياة، فقط الجأ إلى ركن الذكر والتسبيح، فإن القلب ما خلق إلا ليرتاح مع خالقه.',
        translatedContent:
            '"Unquestionably, by the remembrance of Allah hearts are assured." [Ar-Ra\'d: 28]\n\nWhenever the ways seem narrow and worldly worries weigh heavily on you, turn to dhikr and tasbeeh; for the heart was created only to find peace in its Creator.',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        jazakAllahCount: 42,
        ameenCount: 28,
        subhanAllahCount: 35,
        comments: [
          AtharComment(
            id: 'c1',
            authorName: 'أم مريم',
            avatarIndex: 1,
            content: 'جزاك الله خيراً، كلمات جاءت في وقتها تماماً.',
            timestamp: DateTime.now().subtract(const Duration(minutes: 40)),
          ),
          AtharComment(
            id: 'c2',
            authorName: 'أحمد علي',
            avatarIndex: 3,
            content: 'اللهم املأ قلوبنا بذكرك وشكرك وحسن عبادتك.',
            timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
          ),
        ],
      ),
      AtharPost(
        id: 'seed_2',
        authorId: 'author_2',
        authorName: 'أبو يوسف',
        avatarIndex: 2,
        isTrustedAuthor: true,
        category: AtharCategory.dua,
        gradientIndex: 1,
        content:
            'اللهم يا مفرّج الكروب، فرّج هم كل مهموم، واشفِ كل مريض لا يعلم بوجعه إلا أنت، وارحم أمواتنا وأموات المسلمين جميعاً يارب العالمين 🤲',
        translatedContent:
            'O Reliever of griefs, relieve the distress of every afflicted person, heal every sick soul whose pain is known only to You, and bestow mercy upon all deceased Muslims, O Lord of all creation 🤲',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        jazakAllahCount: 19,
        ameenCount: 94,
        subhanAllahCount: 15,
        comments: [
          AtharComment(
            id: 'c3',
            authorName: 'سارة خالد',
            avatarIndex: 4,
            content: 'اللهم آمين يارب العالمين ولكم بالمثل.',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          ),
        ],
      ),
      AtharPost(
        id: 'seed_3',
        authorId: 'author_3',
        authorName: 'طالب علم',
        avatarIndex: 5,
        isTrustedAuthor: true,
        category: AtharCategory.zikr,
        gradientIndex: 4,
        content:
            'فائدة في الاستغفار:\nكان شيخ الإسلام ابن تيمية رحمه الله يقول: "إنه ليقف خاطري في المسألة والشيء أو الحالة التي تشكل عليّ، فأستغفر الله تعالى ألف مرة حتى ينشرح الصدر وينحل إشكال ما أشكل."',
        translatedContent:
            'Insight on Seeking Forgiveness (Istighfar):\nIbn Taymiyyah (may Allah have mercy on him) used to say: "Whenever an issue or matter confuses me, I ask Allah for forgiveness a thousand times until my chest expands and the problem is resolved."',
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        jazakAllahCount: 63,
        ameenCount: 12,
        subhanAllahCount: 51,
      ),
      AtharPost(
        id: 'seed_4',
        authorId: 'author_4',
        authorName: 'محبة القرآن',
        avatarIndex: 1,
        isTrustedAuthor: false,
        category: AtharCategory.tadabbur,
        gradientIndex: 3,
        content:
            '﴿وَاصْبِرْ لِحُكْمِ رَبِّكَ فَإِنَّكَ بِأَعْيُنِنَا﴾\n\nتخيل أن رب السماوات والأرض يقول لك: "أنت بأعيننا".. ما أعظم هذا الأمان والسكينة التي تغمر الروح!',
        translatedContent:
            '"And be patient for the decision of your Lord, for indeed, you are in Our eyes." [At-Tur: 48]\n\nImagine the Creator of heavens and earth telling you: "You are in Our eyes".. what immense peace and tranquility overwhelms the soul!',
        timestamp: DateTime.now().subtract(const Duration(hours: 12)),
        jazakAllahCount: 77,
        ameenCount: 41,
        subhanAllahCount: 88,
      ),
    ];
  }

  List<AtharPost> get _visiblePosts {
    return _allPosts.where((post) {
      if (_blockedUserIds.contains(post.authorId)) return false;
      if (post.status == AtharPostStatus.hidden) return false;
      if (_selectedCategory == AtharCategory.all) return true;
      return post.category == _selectedCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.emeraldDark,
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('community_title'),
              style: GoogleFonts.amiri(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.gold,
              ),
            ),
            Text(
              context.tr('community_sub'),
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: context.tr('guidelines_title'),
            icon: const Icon(Icons.verified_user_outlined, color: AppColors.gold),
            onPressed: _showCommunityGuidelinesDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط الترحيب والتصنيفات
          _buildCategoryFilterBar(),

          // الخلاصة
          Expanded(
            child: _visiblePosts.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                    itemCount: _visiblePosts.length,
                    itemBuilder: (context, index) {
                      return _buildPostCard(_visiblePosts[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.gold,
        foregroundColor: Colors.black87,
        elevation: 6,
        icon: const Icon(Icons.edit_note_rounded, size: 24),
        label: Text(
          context.tr('share_athar_btn'),
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
        ),
        onPressed: _openCreatePostSheet,
      ),
    );
  }

  Widget _buildCategoryFilterBar() {
    return Container(
      color: AppColors.emeraldDark.withOpacity(0.4),
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Row(
          children: AtharCategory.values.map((cat) {
            final isSelected = _selectedCategory == cat;
            return Padding(
              padding: EdgeInsets.only(left: 8.w),
              child: ChoiceChip(
                showCheckmark: false,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(cat.icon, style: TextStyle(fontSize: 13.sp)),
                    SizedBox(width: 5.w),
                    Text(
                      cat.localizedTitle(context),
                      style: GoogleFonts.tajawal(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.black87 : Colors.white70,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
                selected: isSelected,
                selectedColor: AppColors.gold,
                backgroundColor: AppColors.cardDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                  side: BorderSide(
                    color: isSelected ? AppColors.gold : Colors.white12,
                  ),
                ),
                onSelected: (val) {
                  if (val) {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedCategory = cat);
                  }
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPostCard(AtharPost post) {
    final gradient = _postGradients[post.gradientIndex % _postGradients.length];

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: post.isTrustedAuthor
              ? AppColors.gold.withOpacity(0.35)
              : Colors.white12,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // رأس المنشور
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 8.h),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: AppColors.cardDark,
                  child: Icon(
                    _avatars[post.avatarIndex % _avatars.length],
                    color: AppColors.gold,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              post.authorName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                          if (post.isTrustedAuthor) ...[
                            SizedBox(width: 4.w),
                            const Icon(
                              Icons.verified_rounded,
                              size: 15,
                              color: AppColors.gold,
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              '${post.category.icon} ${post.category.localizedTitle(context)}',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: AppColors.gold,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            _formatTimestamp(post.timestamp),
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 10.sp,
                            ),
                          ),
                          if (post.status == AtharPostStatus.pending) ...[
                            SizedBox(width: 6.w),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                'قيد المراجعة',
                                style: TextStyle(color: Colors.amber, fontSize: 9.sp),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // زر الخيارات (⋮)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, color: Colors.white70),
                  color: AppColors.cardDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  onSelected: (action) => _handlePostAction(action, post),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'share_card',
                      child: Row(
                        children: [
                          const Icon(Icons.palette_outlined, color: AppColors.gold, size: 18),
                          SizedBox(width: 8.w),
                          Text(context.tr('make_card'), style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'copy',
                      child: Row(
                        children: [
                          const Icon(Icons.copy_rounded, color: Colors.white70, size: 18),
                          SizedBox(width: 8.w),
                          Text(context.tr('copy_text'), style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          const Icon(Icons.flag_outlined, color: Colors.orangeAccent, size: 18),
                          SizedBox(width: 8.w),
                          Text(context.tr('report_post'), style: const TextStyle(color: Colors.orangeAccent)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'block',
                      child: Row(
                        children: [
                          const Icon(Icons.block_rounded, color: Colors.redAccent, size: 18),
                          SizedBox(width: 8.w),
                          Text(context.tr('block_user'), style: const TextStyle(color: Colors.redAccent)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // نص المنشور مع زر الترجمة
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.isTranslated && post.translatedContent != null
                      ? post.translatedContent!
                      : post.content,
                  style: GoogleFonts.amiri(
                    fontSize: 16.5.sp,
                    height: 1.6,
                    color: Colors.white.withOpacity(0.95),
                  ),
                ),
                if (post.translatedContent != null) ...[
                  SizedBox(height: 6.h),
                  InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        post.isTranslated = !post.isTranslated;
                      });
                    },
                    borderRadius: BorderRadius.circular(6.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.g_translate_rounded,
                            size: 14.sp,
                            color: AppColors.gold,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            post.isTranslated
                                ? 'Original • الأصلي'
                                : context.tr('translate_post'),
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.gold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (post.isTranslated) ...[
                            SizedBox(width: 6.w),
                            Text(
                              '(${context.tr('translated_by_sakan')})',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.white38,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(height: 6.h),
          const Divider(color: Colors.white12, height: 1),

          // شريط التفاعلات
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // جزاك الله خيراً
                _buildReactionButton(
                  icon: Icons.auto_awesome_rounded,
                  label: context.tr('reaction_jazakallah'),
                  count: post.jazakAllahCount,
                  isActive: post.isUserJazakAllah,
                  activeColor: AppColors.gold,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      post.isUserJazakAllah = !post.isUserJazakAllah;
                      post.jazakAllahCount += post.isUserJazakAllah ? 1 : -1;
                    });
                  },
                ),

                // آمين
                _buildReactionButton(
                  icon: Icons.volunteer_activism_rounded,
                  label: context.tr('reaction_ameen'),
                  count: post.ameenCount,
                  isActive: post.isUserAmeen,
                  activeColor: Colors.tealAccent,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      post.isUserAmeen = !post.isUserAmeen;
                      post.ameenCount += post.isUserAmeen ? 1 : -1;
                    });
                  },
                ),

                // التعليقات
                InkWell(
                  borderRadius: BorderRadius.circular(10.r),
                  onTap: () => _showCommentsSheet(post),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 17,
                          color: Colors.white70,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${post.comments.length}',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReactionButton({
    required IconData icon,
    required String label,
    required int count,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10.r),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? activeColor : Colors.white60,
            ),
            SizedBox(width: 5.w),
            Text(
              count > 0 ? '$label ($count)' : label,
              style: TextStyle(
                color: isActive ? activeColor : Colors.white70,
                fontSize: 11.5.sp,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.spa_outlined, size: 64.sp, color: AppColors.gold.withOpacity(0.5)),
          SizedBox(height: 12.h),
          Text(
            'لا توجد منشورات في هذا القسم بعد',
            style: GoogleFonts.tajawal(
              color: Colors.white70,
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'كن أول من يترك أثراً طيباً ويشارك الخير!',
            style: TextStyle(color: Colors.white38, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }

  // معالجة القائمة (مشاركة كبطاقة، نسخ، إبلاغ، حظر)
  void _handlePostAction(String action, AtharPost post) async {
    switch (action) {
      case 'share_card':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CardStudioScreen(
              initialText: post.content,
              initialSource: 'سكن الروح - أثر طيب: ${post.authorName}',
            ),
          ),
        );
        break;
      case 'copy':
        await Clipboard.setData(ClipboardData(text: post.content));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم نسخ الأثر بنجاح'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        break;
      case 'report':
        _showReportDialog(post);
        break;
      case 'block':
        _showBlockUserDialog(post);
        break;
    }
  }

  // نافذة الإبلاغ عن محتوى غير لائق
  void _showReportDialog(AtharPost post) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            const Icon(Icons.flag_rounded, color: Colors.orangeAccent),
            SizedBox(width: 8.w),
            const Text('إبلاغ عن محتوى', style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'لماذا تود الإبلاغ عن هذا المنشور؟',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            SizedBox(height: 12.h),
            _reportOption(ctx, post, 'ألفاظ غير لائقة أو إساءة'),
            _reportOption(ctx, post, 'معلومات دينية أو أحاديث مكذوبة'),
            _reportOption(ctx, post, 'إعلانات، روابط أو أرقام تواصل'),
            _reportOption(ctx, post, 'محتوى غير هادف أو مزعج'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white60)),
          ),
        ],
      ),
    );
  }

  Widget _reportOption(BuildContext ctx, AtharPost post, String reason) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.circle_outlined, size: 16, color: AppColors.gold),
      title: Text(reason, style: const TextStyle(color: Colors.white, fontSize: 13)),
      onTap: () {
        Navigator.pop(ctx);
        setState(() {
          post.reportCount++;
          // إذا وصل عدد البلاغات إلى 2 يتم إخفاؤه تلقائياً
          if (post.reportCount >= 2) {
            post.status = AtharPostStatus.hidden;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.emerald,
            content: Text('شكراً لغيرتك وحرصك. تم استلام البلاغ وسيتم مراجعته فوراً.'),
          ),
        );
      },
    );
  }

  // نافذة حظر المستخدم
  void _showBlockUserDialog(AtharPost post) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text('تأكيد حظر المستخدم', style: TextStyle(color: Colors.white)),
        content: Text(
          'هل أنت متأكد من رغبتك في حظر "${post.authorName}"؟ لن تظهر لك أي منشورات منه مجدداً.',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(ctx);
              await _moderation.blockUser(post.authorId);
              await _loadBlockedUsers();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('تم حظر ${post.authorName} بنجاح')),
                );
              }
            },
            child: const Text('حظر', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // شاشة التعليقات
  void _showCommentsSheet(AtharPost post) {
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16.w,
            right: 16.w,
            top: 14.h,
          ),
          child: SizedBox(
            height: 0.65.sh,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Text(
                      'التعليقات الطيبات (${post.comments.length})',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                const Divider(color: Colors.white12, height: 1),
                Expanded(
                  child: post.comments.isEmpty
                      ? Center(
                          child: Text(
                            'لا توجد تعليقات بعد، كن صاحب أول أثر طيب!',
                            style: TextStyle(color: Colors.white38, fontSize: 13.sp),
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          itemCount: post.comments.length,
                          separatorBuilder: (_, __) => SizedBox(height: 10.h),
                          itemBuilder: (context, idx) {
                            final comment = post.comments[idx];
                            return Container(
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 14.r,
                                    backgroundColor: AppColors.emerald,
                                    child: Icon(
                                      _avatars[comment.avatarIndex % _avatars.length],
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          comment.authorName,
                                          style: TextStyle(
                                            color: AppColors.gold,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                        SizedBox(height: 3.h),
                                        Text(
                                          comment.content,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                // حقل كتابة التعليق
                Padding(
                  padding: EdgeInsets.only(bottom: 14.h, top: 8.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'اكتب دعاءً أو كلمة طيبة...',
                            hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                            filled: true,
                            fillColor: Colors.black38,
                            contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.r),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      IconButton(
                        icon: const Icon(Icons.send_rounded, color: AppColors.gold),
                        onPressed: () async {
                          final text = commentController.text.trim();
                          if (text.isEmpty) return;

                          // فحص التعليق بنظام الرقابة
                          final check = await _moderation.inspectContent(
                            text: text,
                            isNewUser: false,
                          );

                          if (!check.isApproved) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.redAccent,
                                  content: Text(check.rejectionReason ?? 'تعليق غير مسموح به'),
                                ),
                              );
                            }
                            return;
                          }

                          final newComment = AtharComment(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            authorName: 'فاعل خير',
                            avatarIndex: 2,
                            content: text,
                            timestamp: DateTime.now(),
                          );

                          setSheetState(() {
                            post.comments.add(newComment);
                          });
                          setState(() {});
                          commentController.clear();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // نافذة إنشاء منشور جديد مع الرقابة الهجينة
  void _openCreatePostSheet() {
    final textController = TextEditingController();
    final nameController = TextEditingController(text: 'فاعل خير');
    AtharCategory selectedCat = AtharCategory.tadabbur;
    int selectedGradient = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16.w,
            right: 16.w,
            top: 14.h,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 14.h),

                // تذكير بالرقابة الإلهية
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.security_rounded, color: AppColors.gold, size: 22),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          '﴿مَّا يَلْفِظُ مِن قَوْلٍ إِلَّا لَدَيْهِ رَقِيبٌ عَتِيدٌ﴾\nاجعل كلماتك شاهدة لك بالخير والبركة.',
                          style: GoogleFonts.amiri(
                            color: Colors.white,
                            fontSize: 13.5.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),

                // اسم الناشر والتصنيف
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: TextField(
                        controller: nameController,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          labelText: 'الاسم أو اللقب',
                          labelStyle: const TextStyle(color: AppColors.gold, fontSize: 12),
                          filled: true,
                          fillColor: Colors.black26,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      flex: 5,
                      child: DropdownButtonFormField<AtharCategory>(
                        value: selectedCat,
                        dropdownColor: AppColors.cardDark,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          labelText: 'التصنيف',
                          labelStyle: const TextStyle(color: AppColors.gold, fontSize: 12),
                          filled: true,
                          fillColor: Colors.black26,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: AtharCategory.values
                            .where((c) => c != AtharCategory.all)
                            .map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text('${c.icon} ${c.title}'),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setSheetState(() => selectedCat = val);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // حقل كتابة النص
                TextField(
                  controller: textController,
                  maxLines: 5,
                  maxLength: 500,
                  style: GoogleFonts.amiri(
                    color: Colors.white,
                    fontSize: 16.sp,
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: 'اكتب تدبراً في آية، أو دعاءً صادقاً، أو فائدة قرآنية تبتغي بها وجه الله...',
                    hintStyle: GoogleFonts.amiri(color: Colors.white30, fontSize: 14.sp),
                    filled: true,
                    fillColor: Colors.black38,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: const BorderSide(color: Colors.white12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: const BorderSide(color: AppColors.gold),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),

                // اختيار لون بطاقة المنشور
                Text(
                  'لون بطاقة الأثر:',
                  style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: List.generate(_postGradients.length, (idx) {
                    final isSelected = selectedGradient == idx;
                    return GestureDetector(
                      onTap: () => setSheetState(() => selectedGradient = idx),
                      child: Container(
                        margin: EdgeInsets.only(left: 10.w),
                        width: 32.w,
                        height: 32.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: _postGradients[idx]),
                          border: Border.all(
                            color: isSelected ? AppColors.gold : Colors.white24,
                            width: isSelected ? 2.5 : 1,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 18.h),

                // زر النشر مع الفحص بالرقابة الهجينة
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    icon: const Icon(Icons.send_rounded),
                    label: Text(
                      'نشر الأثر الطيب',
                      style: GoogleFonts.tajawal(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                      ),
                    ),
                    onPressed: () async {
                      final content = textController.text.trim();
                      final isTrusted = await _moderation.isCurrentUserTrusted();

                      // فحص المحتوى بالرقابة الهجينة
                      final result = await _moderation.inspectContent(
                        text: content,
                        isNewUser: !isTrusted,
                      );

                      if (!result.isApproved) {
                        if (mounted) {
                          _showRejectionAlert(result.rejectionReason ?? 'المحتوى غير مطابق لمعايير المجتمع');
                        }
                        return;
                      }

                      // إنشاء المنشور
                      final newPost = AtharPost(
                        id: 'post_${DateTime.now().millisecondsSinceEpoch}',
                        authorId: 'my_user_id',
                        authorName: nameController.text.trim().isEmpty
                            ? 'فاعل خير'
                            : nameController.text.trim(),
                        avatarIndex: 3,
                        isTrustedAuthor: isTrusted,
                        category: selectedCat,
                        content: content,
                        gradientIndex: selectedGradient,
                        timestamp: DateTime.now(),
                        status: result.recommendedStatus,
                      );

                      // ترقية رتبة المستخدم تدريجياً
                      await _moderation.incrementUserPostsCount();

                      if (!mounted) return;
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                      }
                      setState(() {
                        _allPosts.insert(0, newPost);
                      });

                      if (result.isFlaggedForReview) {
                        _showPendingNotice();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: AppColors.emerald,
                            content: Text('بارك الله فيك، تم نشر أثرك الطيب بنجاح ✨'),
                          ),
                        );
                      }
                    },
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRejectionAlert(String reason) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
            SizedBox(width: 8.w),
            const Text('تنبيه المحتوى', style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
        content: Text(
          reason,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('فهمت ذلك', style: TextStyle(color: AppColors.gold)),
          ),
        ],
      ),
    );
  }

  void _showPendingNotice() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            const Icon(Icons.hourglass_top_rounded, color: AppColors.gold),
            SizedBox(width: 8.w),
            const Text('مشاركتك الأولى معنا', style: TextStyle(color: Colors.white, fontSize: 15)),
          ],
        ),
        content: const Text(
          'أهلاً بك في مجتمع "أثرٌ طيّب"!\n\nنظراً لأنها مشاركتك الأولى، سيخضع منشورك لمراجعة سريعة لضمان نقاء المجتمع ثم يُعتمد تلقائياً وتصبح عضواً موثوقاً ينشر فوراً بإذن الله.',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('حسناً، بارك الله فيكم', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  // ميثاق المجتمع وشروط النشر لـ Google Play UGC
  void _showCommunityGuidelinesDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
        title: Row(
          children: [
            const Icon(Icons.shield_outlined, color: AppColors.gold),
            SizedBox(width: 8.w),
            Text(
              'ميثاق مجتمع سكن الروح',
              style: GoogleFonts.amiri(
                color: AppColors.gold,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'أهلاً بك في ملتقى الخير، هذا المجتمع مخصص لتبادل التدبرات القرآنية والدعوات الصالحة، ونرجو الالتزام بالضوابط التالية:',
                style: TextStyle(color: Colors.white70, fontSize: 13.sp),
              ),
              SizedBox(height: 12.h),
              _guidelineRow('🌿 الكلمة الطيبة:', 'يُمنع أي شكل من أشكال السب أو الإساءة أو الجدال المذموم.'),
              _guidelineRow('🔒 الخصوصية والأمان:', 'يُمنع تبادل أرقام الهواتف أو روابط المواقع الشخصية.'),
              _guidelineRow('📖 التثبت الديني:', 'تجنب نشر الأحاديث المكذوبة أو الفتاوى بغير علم.'),
              _guidelineRow('🛡️ الرقابة المجتمعية:', 'لكل مستخدم الحق في الإبلاغ عن أي محتوى مخالف، وسيتم حجبه فوراً.'),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('أوافق وألتزم بالميثاق', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _guidelineRow(String title, String desc) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13)),
          SizedBox(height: 2.h),
          Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }
}
