import 'package:quran/quran.dart' as quran;

/// نموذج بيانات مقطع الريلز الإيماني (Spiritual Reel Model)
class SpiritualReelModel {
  final int id;
  final String title;
  final int surah;
  final int ayah;
  final String screenKey;
  final String featureBadge;
  final String hookText;
  final String ayahText;
  final String videoUrl;
  final DateTime releaseDate;
  final String youtubeUrl;
  final String instagramUrl;
  final String tiktokUrl;
  final String facebookUrl;

  const SpiritualReelModel({
    required this.id,
    required this.title,
    required this.surah,
    required this.ayah,
    required this.screenKey,
    required this.featureBadge,
    required this.hookText,
    required this.ayahText,
    required this.videoUrl,
    required this.releaseDate,
    required this.youtubeUrl,
    required this.instagramUrl,
    required this.tiktokUrl,
    required this.facebookUrl,
  });

  /// فحص هل الفيديو منشور بالفعل أم لم يحن موعد نشره بعد
  bool get isReleased => releaseDate.isBefore(DateTime.now());

  /// اسم السورة الكريمة بالعربية
  String get surahName {
    try {
      return quran.getSurahNameArabic(surah);
    } catch (_) {
      return 'سورة رقم $surah';
    }
  }

  factory SpiritualReelModel.fromJson(Map<String, dynamic> json) {
    return SpiritualReelModel(
      id: json['id'] as int? ?? 1,
      title: json['title'] as String? ?? '',
      surah: json['surah'] as int? ?? 1,
      ayah: json['ayah'] as int? ?? 1,
      screenKey: json['screen_key'] as String? ?? 'quran',
      featureBadge: json['feature_badge'] as String? ?? 'سكن الروح',
      hookText: json['hook_text'] as String? ?? '',
      ayahText: json['ayah_text'] as String? ?? '',
      videoUrl: json['video_url'] as String? ?? '',
      releaseDate: DateTime.tryParse(json['release_date'] as String? ?? '') ??
          DateTime(2026, 10, 24),
      youtubeUrl: json['youtube_url'] as String? ?? 'https://www.youtube.com/@SakanAl-Rooh',
      instagramUrl: json['instagram_url'] as String? ?? 'https://www.instagram.com/sakan.alrooh.app',
      tiktokUrl: json['tiktok_url'] as String? ?? 'https://www.tiktok.com/@sakan.alrooh.app',
      facebookUrl: json['facebook_url'] as String? ?? 'https://www.facebook.com/profile.php?id=61595603427400',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'surah': surah,
        'ayah': ayah,
        'screen_key': screenKey,
        'feature_badge': featureBadge,
        'hook_text': hookText,
        'ayah_text': ayahText,
        'video_url': videoUrl,
        'release_date': releaseDate.toIso8601String(),
        'youtube_url': youtubeUrl,
        'instagram_url': instagramUrl,
        'tiktok_url': tiktokUrl,
        'facebook_url': facebookUrl,
      };
}

