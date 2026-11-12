import 'dart:convert';
import 'package:flutter/services.dart';
import '../data/spiritual_reels_data.dart';
import '../models/spiritual_reel_model.dart';

/// خدمة إدارة وتوفير مقاطع الريلز الإيمانية داخل التطبيق
class SpiritualReelsService {
  static List<SpiritualReelModel>? _cachedReels;

  /// تحميل كافة مقاطع الريلز (من الأصول أو من البيانات المدمجة بالكود فوراً)
  static Future<List<SpiritualReelModel>> getAllReels() async {
    if (_cachedReels != null && _cachedReels!.isNotEmpty) return _cachedReels!;

    // 1. محاولة قراءة ملف الأصول إن وجد
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/spiritual_reels.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      if (jsonList.isNotEmpty) {
        _cachedReels = jsonList
            .map((item) =>
                SpiritualReelModel.fromJson(item as Map<String, dynamic>))
            .toList();
        return _cachedReels!;
      }
    } catch (_) {
      // في حال عدم توفر ملف الأصول في البناء الأساسي (مثل تحديثات الشوربيرد)
    }

    // 2. الضمان الحتمي: استخدام البيانات المدمجة برمجياً
    _cachedReels = kSpiritualReelsRawData
        .map((item) => SpiritualReelModel.fromJson(item))
        .toList();
    return _cachedReels!;
  }

  /// إرجاع المقاطع المنشورة فقط (حسب التاريخ الفعلي)
  /// إذا كان [newestFirst] صحيحاً، يُعرض الأحدث في المقدمة
  static Future<List<SpiritualReelModel>> getReleasedReels({
    bool newestFirst = true,
  }) async {
    final all = await getAllReels();
    final now = DateTime.now();

    var released = all.where((r) => r.releaseDate.isBefore(now)).toList();
    if (released.isEmpty) {
      released = List.from(all);
    }

    if (newestFirst) {
      released.sort((a, b) => b.id.compareTo(a.id));
    } else {
      released.sort((a, b) => a.id.compareTo(b.id));
    }

    return released;
  }

  /// أحدث مقطع تم نشره لعرضه في بطاقة الواجهة الرئيسية
  static Future<SpiritualReelModel?> getLatestReleasedReel() async {
    final released = await getReleasedReels(newestFirst: true);
    if (released.isEmpty) {
      final all = await getAllReels();
      return all.isNotEmpty ? all.first : null;
    }
    return released.first;
  }
}


