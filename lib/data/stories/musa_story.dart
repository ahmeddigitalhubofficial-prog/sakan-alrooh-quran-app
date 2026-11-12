import '../../models/story_item.dart';
import '../../models/story_chapter.dart';

const StoryItem musaStory = StoryItem(
  id: 'musa',
  title: 'قصة سيدنا موسى عليه السلام',
  category: 'prophet',
  icon: '🌊',
  verses: 'فَأَوْحَيْنَا إِلَىٰ مُوسَىٰ أَنِ اضْرِب بِّعَصَاكَ الْبَحْرَ',
  lessons: '''
• الثقة بالله.
• الصبر.
• نصر الله للمؤمنين.
''',
  chapters: [
    StoryChapter(
      title: 'ميلاد موسى',
      content: '''
ولد موسى في زمن فرعون الذي كان يقتل أبناء بني إسرائيل.
''',
    ),
    StoryChapter(
      title: 'قصر فرعون',
      content: '''
نشأ موسى في قصر فرعون بعناية الله.
''',
    ),
    StoryChapter(
      title: 'الدعوة',
      content: '''
أرسل الله موسى إلى فرعون يدعوه لعبادة الله.
''',
    ),
    StoryChapter(
      title: 'شق البحر',
      content: '''
شق الله البحر لموسى ونجا المؤمنون.
''',
    ),
  ],
);
