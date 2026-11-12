import '../../models/story_item.dart';
import '../../models/story_chapter.dart';

const StoryItem muhammadStory = StoryItem(
  id: 'muhammad',
  title: 'السيرة النبوية',
  category: 'seerah',
  icon: '🕌',
  verses: 'وَإِنَّكَ لَعَلَىٰ خُلُقٍ عَظِيمٍ',
  lessons: '''
• الرحمة.
• الصبر.
• القيادة.
''',
  chapters: [
    StoryChapter(
      title: 'الميلاد',
      content: '''
ولد النبي محمد ﷺ في مكة عام الفيل.
''',
    ),
    StoryChapter(
      title: 'نزول الوحي',
      content: '''
نزل جبريل على النبي ﷺ في غار حراء.
''',
    ),
    StoryChapter(
      title: 'الهجرة',
      content: '''
هاجر النبي ﷺ من مكة إلى المدينة.
''',
    ),
    StoryChapter(
      title: 'فتح مكة',
      content: '''
دخل النبي ﷺ مكة فاتحًا وعفا عن أهلها.
''',
    ),
    StoryChapter(
      title: 'الوفاة',
      content: '''
توفي النبي ﷺ بعد إكمال الرسالة.
''',
    ),
  ],
);
