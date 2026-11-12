// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../data/stories_data.dart';
import '../models/story_item.dart';
import '../models/story_chapter.dart';
import '../models/theme_manager.dart';
import '../widgets/common/auto_scroll_text.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  Map<String, int> _progressMap = {}; // storyId -> last chapter index

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final map = <String, int>{};
    for (final story in StoriesDatabase.stories) {
      final saved = prefs.getInt('story_progress_${story.id}');
      if (saved != null) map[story.id] = saved;
    }
    if (mounted) setState(() => _progressMap = map);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<StoryItem> _getFilteredStories(String cat) {
    return StoriesDatabase.stories.where((story) {
      final matchesCat = story.category == cat;
      final searchLower = _searchQuery.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty ||
          story.title.contains(searchLower) ||
          story.lessons.contains(searchLower) ||
          story.chapters.any(
            (c) =>
                c.title.contains(searchLower) ||
                c.content.contains(searchLower),
          );
      return matchesCat && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<AppThemeManager>(context);
    final theme = themeManager.currentTheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.primaryColor,
          elevation: 0,
          title: Text(
            'موسوعة قصص القرآن وأسباب النزول',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 18.sp,
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: theme.accentColor,
            labelColor: theme.accentColor,
            unselectedLabelColor: Colors.white70,
            labelStyle:
                GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14.sp),
            unselectedLabelStyle: GoogleFonts.cairo(fontSize: 12.sp),
            tabs: const [
              Tab(text: 'قصص الأنبياء', icon: Icon(Icons.auto_stories_rounded)),
              Tab(text: 'قصص القرآن', icon: Icon(Icons.menu_book_rounded)),
              Tab(text: 'أسباب النزول', icon: Icon(Icons.mosque_rounded)),
              Tab(text: 'الغزوات والسيرة', icon: Icon(Icons.shield_rounded)),
            ],
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: theme.gradientColors,
            ),
          ),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: theme.accentColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    style: TextStyle(color: theme.textColor),
                    decoration: InputDecoration(
                      hintText: 'ابحث عن نبي، قصة، آية، سبب نزول، أو غزوة...',
                      hintStyle: GoogleFonts.cairo(
                        color: theme.subtitleColor.withOpacity(0.6),
                        fontSize: 13.sp,
                      ),
                      prefixIcon:
                          Icon(Icons.search, color: theme.accentColor),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (val) =>
                        setState(() => _searchQuery = val.trim()),
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildStoriesList(_getFilteredStories('prophet'), theme),
                    _buildStoriesList(_getFilteredStories('quran_story'), theme),
                    _buildStoriesList(_getFilteredStories('asbab_nuzul'), theme),
                    _buildStoriesList(_getFilteredStories('biography'), theme),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoriesList(List<StoryItem> stories, AppTheme theme) {
    if (stories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_outlined,
                size: 64, color: theme.subtitleColor.withOpacity(0.4)),
            const SizedBox(height: 12),
            Text(
              'لا توجد نتائج تطابق بحثك',
              style: GoogleFonts.cairo(color: theme.subtitleColor, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      itemCount: stories.length,
      itemBuilder: (context, index) {
        final story = stories[index];
        final chaptersCount = story.chapters.length;
        final preview = story.chapters.isNotEmpty
            ? story.chapters.first.content
            : '';
        final savedChapter = _progressMap[story.id] ?? 0;
        final readProgress = chaptersCount > 0
            ? (savedChapter + 1) / chaptersCount
            : 0.0;

        return Card(
          color: theme.cardColor,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: theme.accentColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () async {
              await _openStoryReader(story, theme);
              _loadProgress(); // refresh after reading
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Icon circle
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.accentColor.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(story.icon,
                        style: const TextStyle(fontSize: 26)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AutoScrollText(
                          story.title,
                          style: GoogleFonts.cairo(
                            color: theme.textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Chapter count badge
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.accentColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$chaptersCount فصول',
                                style: GoogleFonts.cairo(
                                  color: theme.accentColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (savedChapter > 0) ...[  
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'الفصل ${savedChapter + 1}/$chaptersCount',
                                  style: GoogleFonts.cairo(
                                    color: Colors.green.shade600,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: readProgress,
                            backgroundColor:
                                theme.accentColor.withOpacity(0.15),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              savedChapter == 0
                                  ? theme.accentColor.withOpacity(0.3)
                                  : readProgress >= 1.0
                                      ? Colors.green
                                      : theme.accentColor,
                            ),
                            minHeight: 3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          preview.replaceAll('\n', ' ').trim(),
                          style: GoogleFonts.cairo(
                            color: theme.subtitleColor,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios,
                      color: theme.accentColor, size: 18),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openStoryReader(StoryItem story, AppTheme theme) async {
    final savedChapter = _progressMap[story.id] ?? 0;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _StoryReaderScreen(
          story: story,
          theme: theme,
          initialChapter: savedChapter,
        ),
      ),
    );
  }
}

// ============================================================
//  Story Reader Screen (with chapters)
// ============================================================

class _StoryReaderScreen extends StatefulWidget {
  final StoryItem story;
  final AppTheme theme;
  final int initialChapter;

  const _StoryReaderScreen({
    required this.story,
    required this.theme,
    this.initialChapter = 0,
  });

  @override
  State<_StoryReaderScreen> createState() => _StoryReaderScreenState();
}

class _StoryReaderScreenState extends State<_StoryReaderScreen> {
  late int _currentChapter;
  double _fontSize = 18.0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentChapter = widget.initialChapter;
  }

  Future<void> _saveProgress(int chapter) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('story_progress_${widget.story.id}', chapter);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _goToChapter(int index) {
    setState(() => _currentChapter = index);
    _saveProgress(index);
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final story = widget.story;
    final chapters = story.chapters;
    final chapter = chapters[_currentChapter];
    final isFirst = _currentChapter == 0;
    final isLast = _currentChapter == chapters.length - 1;
    final progress = chapters.length > 1
        ? (_currentChapter + 1) / chapters.length
        : 1.0;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.primaryColor,
          elevation: 0,
          title: Text(
            story.title,
            style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold, color: Colors.white),
          ),
          actions: [
            // Font size controls
            IconButton(
              icon: const Icon(Icons.text_decrease, color: Colors.white),
              onPressed: () =>
                  setState(() => _fontSize = (_fontSize - 2).clamp(14, 32)),
            ),
            IconButton(
              icon: const Icon(Icons.text_increase, color: Colors.white),
              onPressed: () =>
                  setState(() => _fontSize = (_fontSize + 2).clamp(14, 32)),
            ),
            // Chapter list
            IconButton(
              icon: const Icon(Icons.list, color: Colors.white),
              onPressed: () => _showChapterList(context, chapters, theme),
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: theme.gradientColors,
            ),
          ),
          child: Column(
            children: [
              // Progress bar
              _buildProgressBar(theme, progress, chapters.length),

              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Story icon & title header
                      if (_currentChapter == 0) ...[
                        _buildStoryHeader(story, theme),
                        const SizedBox(height: 20),
                        // Verses card
                        if (story.verses.isNotEmpty)
                          _buildVersesCard(story.verses, theme),
                        const SizedBox(height: 16),
                      ],

                      // Chapter content card
                      _buildChapterCard(chapter, theme),

                      const SizedBox(height: 16),

                      // Lessons at the end
                      if (isLast && story.lessons.isNotEmpty)
                        _buildLessonsCard(story.lessons, theme),
                    ],
                  ),
                ),
              ),

              // Navigation footer
              _buildNavigationFooter(theme, isFirst, isLast, chapters.length),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(AppTheme theme, double progress, int total) {
    return Container(
      color: theme.primaryColor.withOpacity(0.8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الفصل ${_currentChapter + 1} من $total',
                style: GoogleFonts.cairo(
                    color: Colors.white70, fontSize: 12),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: GoogleFonts.cairo(
                    color: theme.accentColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(theme.accentColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryHeader(StoryItem story, AppTheme theme) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                  color: theme.accentColor.withOpacity(0.5), width: 2),
              boxShadow: [
                BoxShadow(
                  color: theme.accentColor.withOpacity(0.15),
                  blurRadius: 20,
                  spreadRadius: 4,
                )
              ],
            ),
            alignment: Alignment.center,
            child: Text(story.icon,
                style: const TextStyle(fontSize: 44)),
          ),
          const SizedBox(height: 12),
          Text(
            story.title,
            style: GoogleFonts.cairo(
              color: theme.textColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersesCard(String verses, AppTheme theme) {
    return Card(
      color: theme.cardColor.withOpacity(0.9),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.accentColor.withOpacity(0.4), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome, color: theme.accentColor, size: 16),
                const SizedBox(width: 8),
                Text(
                  'الآية المرتبطة',
                  style: GoogleFonts.cairo(
                      color: theme.accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
                const SizedBox(width: 8),
                Icon(Icons.auto_awesome, color: theme.accentColor, size: 16),
              ],
            ),
            const Divider(height: 20),
            Text(
              verses,
              style: GoogleFonts.amiri(
                color: theme.textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.8,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChapterCard(StoryChapter chapter, AppTheme theme) {
    return Card(
      color: theme.cardColor,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chapter title
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: theme.accentColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    chapter.title,
                    style: GoogleFonts.cairo(
                      color: theme.accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1),
            // Chapter content
            Text(
              chapter.content,
              style: GoogleFonts.amiri(
                color: theme.textColor,
                fontSize: _fontSize,
                height: 1.9,
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonsCard(String lessons, AppTheme theme) {
    return Card(
      color: theme.cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.green.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.wb_incandescent, color: theme.accentColor),
                const SizedBox(width: 8),
                Text(
                  'الدروس والعبر المستفادة',
                  style: GoogleFonts.cairo(
                    color: theme.accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1),
            Text(
              lessons,
              style: GoogleFonts.cairo(
                color: theme.textColor,
                fontSize: _fontSize - 2,
                height: 1.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationFooter(
      AppTheme theme, bool isFirst, bool isLast, int total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous chapter
          Expanded(
            child: isFirst
                ? const SizedBox()
                : OutlinedButton.icon(
                    onPressed: () => _goToChapter(_currentChapter - 1),
                    icon: const Icon(Icons.arrow_forward_ios, size: 16),
                    label: Text(
                      'السابق',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.accentColor,
                      side: BorderSide(color: theme.accentColor),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          // Dots indicator
          Row(
            children: List.generate(
              total.clamp(0, 8),
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: i == _currentChapter ? 16 : 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: i == _currentChapter
                      ? theme.accentColor
                      : theme.accentColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Next chapter
          Expanded(
            child: isLast
                ? ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: Text(
                      'انتهيت',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: () => _goToChapter(_currentChapter + 1),
                    icon: const Icon(Icons.arrow_back_ios, size: 16),
                    label: Text(
                      'الفصل التالي',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.accentColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showChapterList(
      BuildContext context, List<StoryChapter> chapters, AppTheme theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'فصول القصة',
                  style: GoogleFonts.cairo(
                    color: theme.textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: chapters.length,
                  itemBuilder: (_, i) {
                    final isActive = i == _currentChapter;
                    return ListTile(
                      leading: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isActive
                              ? theme.accentColor
                              : theme.accentColor.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            color: isActive ? Colors.white : theme.accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      title: Text(
                        chapters[i].title,
                        style: GoogleFonts.cairo(
                          color: theme.textColor,
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _goToChapter(i);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
