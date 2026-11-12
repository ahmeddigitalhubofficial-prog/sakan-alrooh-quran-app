import '../../models/story_item.dart';
import '../../models/story_chapter.dart';

const StoryItem ibrahimStory = StoryItem(
  id: 'ibrahim',
  title: 'قصة سيدنا إبراهيم عليه السلام',
  category: 'prophet',
  icon: '🔥',
  verses: 'قُلْنَا يَا نَارُ كُونِي بَرْدًا وَسَلَامًا عَلَىٰ إِبْرَاهِيمَ',
  lessons: '''
• التوحيد.
• اليقين بالله.
• الصبر على الدعوة.
''',
  chapters: [
    StoryChapter(
      title: 'البحث عن الحقيقة',
      content: '''
بدأ إبراهيم يتأمل في الكون حتى عرف الله.
''',
    ),
    StoryChapter(
      title: 'تحطيم الأصنام',
      content: '''
حطم إبراهيم الأصنام ليثبت لقومه بطلان عبادتها.
''',
    ),
    StoryChapter(
      title: 'النار',
      content: '''
ألقاه قومه في النار فجعلها الله بردًا وسلامًا عليه.
''',
    ),
    StoryChapter(
      title: 'بناء الكعبة',
      content: '''
رفع إبراهيم وإسماعيل قواعد الكعبة المشرفة.
''',
    ),
  ],
);
