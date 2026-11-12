import 'package:shared_preferences/shared_preferences.dart';
import '../models/athar_post_model.dart';

class ModerationResult {
  final bool isApproved;
  final bool isFlaggedForReview;
  final String? rejectionReason;
  final AtharPostStatus recommendedStatus;

  ModerationResult({
    required this.isApproved,
    this.isFlaggedForReview = false,
    this.rejectionReason,
    required this.recommendedStatus,
  });
}

class AtharModerationService {
  static final AtharModerationService instance = AtharModerationService._();
  AtharModerationService._();

  static const String _blockedUsersKey = 'athar_blocked_users';
  static const String _userPostsCountKey = 'athar_my_posts_count';

  // قائمة الكلمات المحظورة لمنع الإساءة والمحتوى غير اللائق
  static final List<String> _blacklistedWords = [
    'كلب',
    'حمار',
    'غبي',
    'احمق',
    'أحمق',
    'لعنة',
    'ملعون',
    'وسخ',
    'قذر',
    'سافل',
    'حقير',
    'تافه',
    'كافر',
    'مرتد',
    'زنديق',
    'منافق',
    'موتوا',
    'اقتلوا',
    'fuck',
    'shit',
    'bitch',
    'asshole',
    'porn',
    'sex',
    'xxx',
    'تعارف',
    'واتساب',
    'شات خاص',
    'سناب',
    'انستا',
    'انستقرام',
  ];

  // فحص أرقام الهواتف لمنع تداول الأرقام الشخصية
  static final RegExp _phoneRegex = RegExp(
    r'(\+?\d{1,4}[-.\s]?)?(\(?\d{2,4}\)?[-.\s]?)?\d{3,4}[-.\s]?\d{4}',
  );

  // فحص الروابط الخارجية لمنع الروابط المشبوهة والإعلانات
  static final RegExp _urlRegex = RegExp(
    r'(https?:\/\/)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
    caseSensitive: false,
  );

  /// فحص المنشور أو التعليق قبل نشره
  Future<ModerationResult> inspectContent({
    required String text,
    required bool isNewUser,
  }) async {
    final cleanText = text.trim();

    // 1. فحص الطول والجدية
    if (cleanText.isEmpty) {
      return ModerationResult(
        isApproved: false,
        rejectionReason: 'المنشور لا يمكن أن يكون فارغاً.',
        recommendedStatus: AtharPostStatus.hidden,
      );
    }

    if (cleanText.length < 5) {
      return ModerationResult(
        isApproved: false,
        rejectionReason: 'الرجاء كتابة فائدة أو عبارة ذات معنى (5 أحرف على الأقل).',
        recommendedStatus: AtharPostStatus.hidden,
      );
    }

    // 2. فحص الكلمات المحظورة
    final lower = cleanText.toLowerCase();
    for (final word in _blacklistedWords) {
      if (lower.contains(word)) {
        return ModerationResult(
          isApproved: false,
          rejectionReason: 'المنشور يحتوي على ألفاظ أو عبارات غير مسموح بنشرها في هذا المجتمع الإيماني.',
          recommendedStatus: AtharPostStatus.hidden,
        );
      }
    }

    // 3. فحص أرقام الهواتف
    if (_phoneRegex.hasMatch(cleanText)) {
      return ModerationResult(
        isApproved: false,
        rejectionReason: 'يُمنع منعاً باتاً نشر أرقام الهواتف أو وسائل التواصل الشخصية للحفاظ على خصوصيتك وأمان المجتمع.',
        recommendedStatus: AtharPostStatus.hidden,
      );
    }

    // 4. فحص الروابط الخارجية
    if (_urlRegex.hasMatch(cleanText)) {
      return ModerationResult(
        isApproved: false,
        rejectionReason: 'يُمنع نشر الروابط الخارجية لمنع الإعلانات وحماية المستخدمين.',
        recommendedStatus: AtharPostStatus.hidden,
      );
    }

    // 5. نظام المستخدم الجديد (الموافقة المسبقة) مقابل المستخدم الموثوق
    if (isNewUser) {
      return ModerationResult(
        isApproved: true,
        isFlaggedForReview: true,
        rejectionReason: null,
        recommendedStatus: AtharPostStatus.pending,
      );
    }

    // منشور سليم ومستخدم موثوق
    return ModerationResult(
      isApproved: true,
      isFlaggedForReview: false,
      rejectionReason: null,
      recommendedStatus: AtharPostStatus.approved,
    );
  }

  /// زيادة عدد منشورات المستخدم وتحديث مستوى ثقته
  Future<bool> incrementUserPostsCount() async {
    final prefs = await SharedPreferences.getInstance();
    final count = (prefs.getInt(_userPostsCountKey) ?? 0) + 1;
    await prefs.setInt(_userPostsCountKey, count);
    return count >= 2; // يصبح موثوقاً بعد أول مشاركتين صالحتين
  }

  /// هل المستخدم الحالي عضو موثوق؟
  Future<bool> isCurrentUserTrusted() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_userPostsCountKey) ?? 0;
    return count >= 2;
  }

  /// إدارة حظر المستخدمين (Block Users)
  Future<void> blockUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_blockedUsersKey) ?? [];
    if (!list.contains(userId)) {
      list.add(userId);
      await prefs.setStringList(_blockedUsersKey, list);
    }
  }

  Future<List<String>> getBlockedUsers() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_blockedUsersKey) ?? [];
  }

  Future<bool> isUserBlocked(String userId) async {
    final blocked = await getBlockedUsers();
    return blocked.contains(userId);
  }
}
