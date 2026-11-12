import 'story_chapter.dart';

class StoryItem {
  final String id;

  final String title;

  final String category;

  final String icon;

  final String verses;

  final String lessons;

  final List<StoryChapter> chapters;

  const StoryItem({
    required this.id,
    required this.title,
    required this.category,
    required this.icon,
    required this.verses,
    required this.lessons,
    required this.chapters,
  });
}
