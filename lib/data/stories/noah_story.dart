import '../../models/story_item.dart';
import '../../models/story_chapter.dart';

const StoryItem noahStory = StoryItem(
  id: 'noah',
  title: 'قصة سيدنا نوح عليه السلام',
  category: 'prophet',
  icon: '🚢',
  verses: 'وَمَا آمَنَ مَعَهُ إِلَّا قَلِيلٌ',
  lessons: '''
• الصبر الطويل.
• النجاة بالإيمان.
• الثقة بالله.
''',
  chapters: [
    StoryChapter(
      title: 'دعوة نوح',
      content: '''
أرسل الله نوحًا إلى قومه يدعوهم لعبادة الله وحده.
''',
    ),
    StoryChapter(
      title: 'تكذيب القوم',
      content: '''
سخر قوم نوح منه ورفضوا الإيمان برسالته.
''',
    ),
    StoryChapter(
      title: 'بناء السفينة',
      content: '''
أمر الله نوحًا ببناء السفينة استعدادًا للطوفان.
''',
    ),
    StoryChapter(
      title: 'الطوفان',
      content: '''
غرق الكافرون ونجا المؤمنون مع نوح في السفينة.
''',
    ),
  ],
);
