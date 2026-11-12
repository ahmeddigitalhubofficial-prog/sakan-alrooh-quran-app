class HadithModel {
  final String id;
  final String text;
  final String narrator;
  final String source;
  final String topic;
  final String explanation;

  const HadithModel({
    required this.id,
    required this.text,
    required this.narrator,
    required this.source,
    required this.topic,
    required this.explanation,
  });
}

class HadithTopic {
  final String id;
  final String title;
  final String icon;
  final List<HadithModel> hadiths;

  const HadithTopic({
    required this.id,
    required this.title,
    required this.icon,
    required this.hadiths,
  });
}
