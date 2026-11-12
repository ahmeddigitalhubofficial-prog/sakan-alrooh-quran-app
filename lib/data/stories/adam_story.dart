import '../../models/story_item.dart';
import '../../models/story_chapter.dart';

const StoryItem adamStory = StoryItem(
  id: 'adam',
  title: 'قصة سيدنا آدم عليه السلام',
  category: 'prophet',
  icon: '🌱',
  verses: 'قَالَا رَبَّنَا ظَلَمْنَا أَنفُسَنَا',
  lessons: '''
• التوبة الصادقة.
• الحذر من الشيطان.
• الكبر سبب الهلاك.
''',
  chapters: [
    StoryChapter(
      title: 'خلق آدم',
      content: '''
خلق الله سبحانه وتعالى آدم عليه السلام من طين ثم نفخ فيه من روحه.
''',
    ),
    StoryChapter(
      title: 'سجود الملائكة',
      content: '''
أمر الله الملائكة بالسجود لآدم فسجدوا إلا إبليس.
''',
    ),
    StoryChapter(
      title: 'تعليم آدم الأسماء',
      content: '''
علم الله آدم الأسماء كلها وكرمه بالعلم والمعرفة.
''',
    ),
    StoryChapter(
      title: 'الجنة',
      content: '''
أسكن الله آدم وحواء الجنة وأباح لهما كل شيء إلا شجرة واحدة.
''',
    ),
    StoryChapter(
      title: 'هبوط آدم إلى الأرض',
      content: '''
أكل آدم من الشجرة فتاب إلى الله ثم هبط إلى الأرض.
''',
    ),
  ],
);
