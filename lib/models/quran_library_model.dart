// quran_library_model.dart

class QuranLibraryStory {
  final String id;
  final String title;
  final String category; // 'asbab_nuzul', 'prophets', 'seerah', 'rulings'
  final int? surahNumber;
  final String? surahName;
  final String? verseRange;
  final String summary;
  final String fullStory;
  final String? asbabNuzul;
  final List<String> lessons;
  final String era; // e.g. 'العهد المكي', 'العهد المدني', 'قبل البعثة'
  final String location; // e.g. 'مكة المكرمة', 'المدينة المنورة', 'غار حراء'

  const QuranLibraryStory({
    required this.id,
    required this.title,
    required this.category,
    this.surahNumber,
    this.surahName,
    this.verseRange,
    required this.summary,
    required this.fullStory,
    this.asbabNuzul,
    required this.lessons,
    required this.era,
    required this.location,
  });
}
