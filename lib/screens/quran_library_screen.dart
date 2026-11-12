// quran_library_screen.dart

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../data/quran_library_database.dart';
import '../models/quran_library_model.dart';
import '../models/theme_manager.dart';
import 'story_detail_screen.dart';

class QuranLibraryScreen extends StatefulWidget {
  const QuranLibraryScreen({super.key});

  @override
  State<QuranLibraryScreen> createState() => _QuranLibraryScreenState();
}

class _QuranLibraryScreenState extends State<QuranLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<AppThemeManager>(context).currentTheme;

    List<QuranLibraryStory> stories =
        QuranLibraryDatabase.getStoriesByCategory(_selectedCategory);

    if (_searchQuery.trim().isNotEmpty) {
      stories = QuranLibraryDatabase.searchStories(_searchQuery);
    }

    final categories = [
      {'id': 'all', 'name': 'الكل 📚'},
      {'id': 'asbab_nuzul', 'name': 'أسباب النزول 📖'},
      {'id': 'prophets', 'name': 'قصص الأنبياء 🕌'},
      {'id': 'seerah', 'name': 'السيرة والغزوات ⚔️'},
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        elevation: 0,
        title: Text(
          'موسوعة قصص القرآن وأسباب النزول',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
            color: Colors.white,
          ),
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
            // Search Input Header Bar
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                style: GoogleFonts.cairo(color: theme.textColor),
                decoration: InputDecoration(
                  hintText: 'ابحث في الموسوعة باسم القصة، النبي، أو السورة...',
                  hintStyle: GoogleFonts.cairo(
                    color: theme.subtitleColor.withValues(alpha: 0.7),
                    fontSize: 13.sp,
                  ),
                  prefixIcon:
                      Icon(Icons.search_rounded, color: theme.accentColor),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded,
                              color: theme.subtitleColor),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: theme.cardColor,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide(
                        color: theme.accentColor.withValues(alpha: 0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide(
                        color: theme.accentColor.withValues(alpha: 0.2)),
                  ),
                ),
              ),
            ),

            // Category Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: categories.map((cat) {
                  final isSelected = _selectedCategory == cat['id'];
                  return Padding(
                    padding: EdgeInsets.only(left: 8.w),
                    child: ChoiceChip(
                      label: Text(
                        cat['name']!,
                        style: GoogleFonts.cairo(
                          color: isSelected
                              ? theme.scaffoldBackgroundColor
                              : theme.textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: theme.accentColor,
                      backgroundColor: theme.cardColor,
                      side: BorderSide(
                        color: isSelected
                            ? theme.accentColor
                            : theme.accentColor.withValues(alpha: 0.2),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedCategory = cat['id']!;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            // Stories List View
            Expanded(
              child: stories.isEmpty
                  ? Center(
                      child: Text(
                        'لم يتم العثور على أسباب نزول أو قصص بهذه الكلمة',
                        style: GoogleFonts.cairo(
                          color: theme.subtitleColor,
                          fontSize: 14.sp,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 8.h),
                      itemCount: stories.length,
                      itemBuilder: (context, index) {
                        final story = stories[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 12.h),
                          color: theme.cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                            side: BorderSide(
                              color: theme.accentColor.withValues(alpha: 0.15),
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20.r),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      StoryDetailScreen(story: story),
                                ),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.all(16.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(8.w),
                                        decoration: BoxDecoration(
                                          color: theme.accentColor
                                              .withValues(alpha: 0.12),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.menu_book_rounded,
                                          color: theme.accentColor,
                                          size: 22.sp,
                                        ),
                                      ),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: Text(
                                          story.title,
                                          style: GoogleFonts.cairo(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                            color: theme.textColor,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: theme.accentColor,
                                        size: 16.sp,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    story.summary,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.cairo(
                                      fontSize: 13.sp,
                                      color: theme.subtitleColor,
                                      height: 1.5,
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                  Row(
                                    children: [
                                      if (story.surahName != null)
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8.w, vertical: 3.h),
                                          decoration: BoxDecoration(
                                            color: theme.accentColor
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(8.r),
                                          ),
                                          child: Text(
                                            'سورة ${story.surahName}',
                                            style: GoogleFonts.cairo(
                                              fontSize: 11.sp,
                                              fontWeight: FontWeight.bold,
                                              color: theme.accentColor,
                                            ),
                                          ),
                                        ),
                                      SizedBox(width: 8.w),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8.w, vertical: 3.h),
                                        decoration: BoxDecoration(
                                          color: Colors.amber
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(8.r),
                                        ),
                                        child: Text(
                                          story.era,
                                          style: GoogleFonts.cairo(
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.amber,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
