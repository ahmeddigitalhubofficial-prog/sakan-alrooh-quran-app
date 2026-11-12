// tafsir_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TafsirService {
  /// التفسير الميسر للسور المسبقة الحفظ أوفلاين
  static final Map<String, String> _builtinTafsir = {
    // سورة الفاتحة
    '1_1': 'أبتدئ قراءة القرآن باسم الله مستعيناً به، (الله) علم على الرب تبارك وتعالى، المستحق للعبادة وحده دون سواه.',
    '1_2': '(الحمد لله رب العالمين) الثناء على الله بصفات كماله، وعلى نعمه الظاهرة والباطنة، الدينية والدنيوية.',
    '1_3': '(الرحمن الرحيم) ثناء على الله تعالى بعد حمده، والرحمن الذي وسعت رحمته كل شيء، والرحيم بالمؤمنين.',
    '1_4': '(مالك يوم الدين) هو وحده المالك والمترأس ليوم الحساب والجزاء وهو يوم القيامة.',
    '1_5': '(إياك نعبد وإياك نستعين) نخصك وحدك بالعبادة، ونستعين بك وحدك في جميع أمورنا.',
    '1_6': '(اهدنا الصراط المستقيم) دَلَّنا ووفِّقنا وسلوك الطريق المستقيم الثابت الذي لا عوج فيه.',
    '1_7': '(صراط الذين أنعمت عليهم) طريق النبيين والصديقين والشهداء والصالحين، غير المغضوب عليهم ولا الضالين.',

    // آية الكرسي (البقرة 255)
    '2_255': 'الله الذي لا إله بحق إلا هو، الحي القيوم، لا تأخذه سنة ولا نوم، له ما في السماوات والأرض، يعلم ما بين أيديهم وما خلفهم، وسع كرسيه السماوات والأرض وهو العلي العظيم.',

    // سورة الإخلاص
    '112_1': 'قل أيها الرسول للمشركين: هو الله المنفرد بالألوهية والربوبية والأسماء والصفات لا شريك له.',
    '112_2': 'الله الذي تقصده جميع الخلائق وتفتقر إليه في حوائجها ومطالبها.',
    '112_3': 'ليس له ولد ولا والد، منزه عن النقص والصاحبة والولد.',
    '112_4': 'ولم يكن له كفواً ولا شبيهاً ولا نظيراً أحد من خلقه.',

    // سورة الفلق
    '113_1': 'قل ألوذ وأعتصم برب الفلق وهو الصبح.',
    '113_2': 'من شر جميع المخلوقات وأذاها.',
    '113_3': 'ومن شر الليل إذا أظلم ودخل في كل شيء.',
    '113_4': 'ومن شر الساحرات اللاتي ينفثن في العقد للسيئات والضر.',
    '113_5': 'ومن شر الحاسد إذا حسد وتمنى زوال النعمة.',

    // سورة الناس
    '114_1': 'قل أعوذ وألوذ برب الناس ومربيهم.',
    '114_2': 'ملك الناس المتصرف في شؤونهم جميعاً.',
    '114_3': 'إله الناس المألوه المعبود بحق دون سواه.',
    '114_4': 'من شر الشيطان الخناس الذي يوسوس عند الغفلة ويخنس عند ذكر الله.',
    '114_5': 'الذي يلقي الوساوس والشرور في صدور الناس.',
    '114_6': 'من شياطين الجن وشياطين الإنس.',
  };

  /// ذاكرة التخزين المؤقت في الـ RAM
  static final Map<String, String> _memoryCache = {};

  /// الحصول على التفسير الميسر للآية مع الحفظ والتخزين التلقائي أوفلاين
  static Future<String> getTafsir({
    required int surahNumber,
    required int verseNumber,
    String? verseText,
  }) async {
    final key = '${surahNumber}_$verseNumber';

    // 1. التثبت من القيمة المدمجة محلياً
    if (_builtinTafsir.containsKey(key)) {
      return _builtinTafsir[key]!;
    }

    // 2. التثبت من ذاكرة الـ RAM
    if (_memoryCache.containsKey(key)) {
      return _memoryCache[key]!;
    }

    // 3. التثبت من التخزين المحلي الآمن SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTafsir = prefs.getString('tafsir_$key');
      if (savedTafsir != null && savedTafsir.isNotEmpty) {
        _memoryCache[key] = savedTafsir;
        return savedTafsir;
      }
    } catch (_) {}

    // 4. جلب التفسير الميسر الرسمي من شبكة API ومجمّع التفسير
    try {
      final client = HttpClient();
      final url = Uri.parse(
          'https://api.alquran.cloud/v1/ayah/$surahNumber:$verseNumber/ar.muyassar');

      final request = await client.getUrl(url).timeout(const Duration(seconds: 5));
      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final json = jsonDecode(responseBody);

        if (json['code'] == 200 && json['data'] != null) {
          final text = json['data']['text'].toString().trim();
          if (text.isNotEmpty) {
            // حفظ التفسير في ذاكرة الجهاز ليعمل أوفلاين للأبد
            _memoryCache[key] = text;
            try {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('tafsir_$key', text);
            } catch (_) {}
            return text;
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Tafsir fetch error: $e');
      }
    }

    // 5. رسالة واضحة في حالة عدم وجود اتصال بالإنترنت للآية لأول مرة
    return 'يتطلب تحميل التفسير الميسر لهذه الآية الاتصال بالإنترنت لأول مرة، وسيتم حفظه محلياً على جهازك فور التحميل ليعمل أوفلاين دائماً.';
  }
}
