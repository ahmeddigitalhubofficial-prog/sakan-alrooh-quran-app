class Zikr {
  final String id;
  final String text;
  final int count;
  final String description;
  final String category;
  final String? audioUrl;
  int currentCount;

  Zikr({
    required this.id,
    required this.text,
    required this.count,
    required this.description,
    required this.category,
    this.audioUrl,
    this.currentCount = 0,
  });

  // نسخة جديدة لتسهيل إعادة تعيين العدادات
  Zikr copy() {
    return Zikr(
      id: id,
      text: text,
      count: count,
      description: description,
      category: category,
      audioUrl: audioUrl,
      currentCount: 0,
    );
  }
}
