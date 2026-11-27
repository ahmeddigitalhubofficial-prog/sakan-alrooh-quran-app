import 'package:flutter/material.dart';
import '../core/localization/app_translations.dart';

enum AtharCategory {
  all('الكل', '🌟'),
  tadabbur('تدبّر آية', '📖'),
  dua('دعاء ومواساة', '🤲'),
  zikr('فائدة وأذكار', '🌿'),
  cards('بطاقات وتصاميم', '🎨');

  final String title;
  final String icon;
  const AtharCategory(this.title, this.icon);

  String localizedTitle(BuildContext context) {
    switch (this) {
      case AtharCategory.all:
        return context.tr('cat_all');
      case AtharCategory.tadabbur:
        return context.tr('cat_tadabbur');
      case AtharCategory.dua:
        return context.tr('cat_dua');
      case AtharCategory.zikr:
        return context.tr('cat_zikr');
      case AtharCategory.cards:
        return context.tr('cat_cards');
    }
  }
}

enum AtharPostStatus {
  approved,
  pending,
  reported,
  hidden,
}

class AtharComment {
  final String id;
  final String authorName;
  final int avatarIndex;
  final String content;
  final DateTime timestamp;

  AtharComment({
    required this.id,
    required this.authorName,
    required this.avatarIndex,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'authorName': authorName,
        'avatarIndex': avatarIndex,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
      };

  factory AtharComment.fromJson(Map<String, dynamic> json) => AtharComment(
        id: json['id'] ?? '',
        authorName: json['authorName'] ?? 'مستخدم سكن الروح',
        avatarIndex: json['avatarIndex'] ?? 0,
        content: json['content'] ?? '',
        timestamp: json['timestamp'] != null
            ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
            : DateTime.now(),
      );
}

class AtharPost {
  final String id;
  final String authorId;
  final String authorName;
  final int avatarIndex;
  final bool isTrustedAuthor;
  final AtharCategory category;
  final String content;
  final String? translatedContent;
  bool isTranslated;
  final int gradientIndex;
  final String? imageUrl;
  final DateTime timestamp;
  int jazakAllahCount;
  int ameenCount;
  int subhanAllahCount;
  int reportCount;
  AtharPostStatus status;
  bool isUserJazakAllah;
  bool isUserAmeen;
  bool isUserSubhanAllah;
  List<AtharComment> comments;

  AtharPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.avatarIndex = 0,
    this.isTrustedAuthor = false,
    required this.category,
    required this.content,
    this.translatedContent,
    this.isTranslated = false,
    this.gradientIndex = 0,
    this.imageUrl,
    required this.timestamp,
    this.jazakAllahCount = 0,
    this.ameenCount = 0,
    this.subhanAllahCount = 0,
    this.reportCount = 0,
    this.status = AtharPostStatus.approved,
    this.isUserJazakAllah = false,
    this.isUserAmeen = false,
    this.isUserSubhanAllah = false,
    List<AtharComment>? comments,
  }) : comments = comments ?? [];

  int get totalInteractions =>
      jazakAllahCount + ameenCount + subhanAllahCount + comments.length;

  AtharPost copyWith({
    String? id,
    String? authorId,
    String? authorName,
    int? avatarIndex,
    bool? isTrustedAuthor,
    AtharCategory? category,
    String? content,
    String? translatedContent,
    bool? isTranslated,
    int? gradientIndex,
    String? imageUrl,
    DateTime? timestamp,
    int? jazakAllahCount,
    int? ameenCount,
    int? subhanAllahCount,
    int? reportCount,
    AtharPostStatus? status,
    bool? isUserJazakAllah,
    bool? isUserAmeen,
    bool? isUserSubhanAllah,
    List<AtharComment>? comments,
  }) {
    return AtharPost(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      isTrustedAuthor: isTrustedAuthor ?? this.isTrustedAuthor,
      category: category ?? this.category,
      content: content ?? this.content,
      translatedContent: translatedContent ?? this.translatedContent,
      isTranslated: isTranslated ?? this.isTranslated,
      gradientIndex: gradientIndex ?? this.gradientIndex,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp ?? this.timestamp,
      jazakAllahCount: jazakAllahCount ?? this.jazakAllahCount,
      ameenCount: ameenCount ?? this.ameenCount,
      subhanAllahCount: subhanAllahCount ?? this.subhanAllahCount,
      reportCount: reportCount ?? this.reportCount,
      status: status ?? this.status,
      isUserJazakAllah: isUserJazakAllah ?? this.isUserJazakAllah,
      isUserAmeen: isUserAmeen ?? this.isUserAmeen,
      isUserSubhanAllah: isUserSubhanAllah ?? this.isUserSubhanAllah,
      comments: comments ?? List.from(this.comments),
    );
  }
}
