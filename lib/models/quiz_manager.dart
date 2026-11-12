import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_manager.dart';

class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String category;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.category,
  });
}

class QuizManager extends ChangeNotifier {
  static final QuizManager _instance = QuizManager._internal();
  factory QuizManager() => _instance;
  QuizManager._internal() {
    _loadState();
  }

  int _totalCorrect = 0;
  int get totalCorrect => _totalCorrect;

  final List<QuizQuestion> _allQuestions = [
    QuizQuestion(
      id: 'q1',
      question: 'ما هي السورة التي تسمى "قلب القرآن"؟',
      options: ['سورة البقرة', 'سورة يس', 'سورة الرحمن', 'سورة الإخلاص'],
      correctIndex: 1,
      explanation: 'سورة يس جاء في فضلها أحاديث متعددة بأنها قلب القرآن لما حوته من تقرير أصول الإيمان والبعث والنشور.',
      category: 'علوم القرآن',
    ),
    QuizQuestion(
      id: 'q2',
      question: 'من هو الصحابي الذي تستحي منه ملائكة السماء؟',
      options: ['أبو بكر الصديق', 'عمر بن الخطاب', 'عثمان بن عفان', 'علي بن أبي طالب'],
      correctIndex: 2,
      explanation: 'قال النبي ﷺ عن عثمان بن عفان رضي الله عنه: «أَلَا أَسْتَحِي مِنْ رَجُلٍ تَسْتَحِي مِنْهُ الْمَلَائِكَةُ».',
      category: 'سير الصحابة',
    ),
    QuizQuestion(
      id: 'q3',
      question: 'كم كان عمر النبي ﷺ عندما نزل عليه الوحي في غار حراء؟',
      options: ['35 سنة', '40 سنة', '43 سنة', '45 سنة'],
      correctIndex: 1,
      explanation: 'نزل الوحي على النبي ﷺ وهو في سن الأربعين من عمره الشريف في شهر رمضان بغار حراء.',
      category: 'السيرة النبوية',
    ),
    QuizQuestion(
      id: 'q4',
      question: 'ما هي أطول آية في كتاب الله العزيز؟',
      options: ['آية الكرسي', 'آية الدين (البقرة 282)', 'آخر آية في سورة الحشر', 'آية المداينة في سورة النساء'],
      correctIndex: 1,
      explanation: 'آية الدين في سورة البقرة (الآية 282) هي أطول آية في القرآن الكريم كاملة في صفحة واحدة.',
      category: 'علوم القرآن',
    ),
    QuizQuestion(
      id: 'q5',
      question: 'ما هو أول مسجد بُني في الإسلام؟',
      options: ['المسجد الحرام', 'المسجد النبوي', 'مسجد قباء', 'المسجد الأقصى'],
      correctIndex: 2,
      explanation: 'مسجد قباء بالمدينة المنورة هو أول مسجد أسسه النبي ﷺ عندما وصل المدينة مهاجراً.',
      category: 'التاريخ الإسلامي',
    ),
    QuizQuestion(
      id: 'q6',
      question: 'ما معنى قوله تعالى: ﴿غَاسِقٍ إِذَا وَقَبَ﴾؟',
      options: ['الريح العاصفة', 'الليل إذا أظلم ودخل', 'النجم إذا هوى', 'البحر إذا اشتد موجه'],
      correctIndex: 1,
      explanation: 'الغاسق هو الليل، ووقب أي دخل ظلامه واشتد سواده.',
      category: 'معاني الكلمات',
    ),
  ];

  List<QuizQuestion> get allQuestions => _allQuestions;

  QuizQuestion get todayQuestion {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return _allQuestions[dayOfYear % _allQuestions.length];
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    _totalCorrect = prefs.getInt('quiz_total_correct') ?? 0;
    notifyListeners();
  }

  Future<void> recordCorrectAnswer() async {
    _totalCorrect += 1;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('quiz_total_correct', _totalCorrect);
    AppThemeManager().addHasanatPoints(30); // 30 hasanat points for quiz
    notifyListeners();
  }
}
