import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/theme_manager.dart';

class ChangelogEntry {
  final String version;
  final String date;
  final String title;
  final String description;
  final List<String> improvements;
  final List<String> fixes;
  final List<String> patches;

  ChangelogEntry({
    required this.version,
    required this.date,
    required this.title,
    required this.description,
    required this.improvements,
    required this.fixes,
    required this.patches,
  });
}

class ChangelogScreen extends StatefulWidget {
  const ChangelogScreen({super.key});

  @override
  State<ChangelogScreen> createState() => _ChangelogScreenState();
}

class _ChangelogScreenState extends State<ChangelogScreen> {
  List<ChangelogEntry> _entries = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadChangelog();
  }

  Future<void> _loadChangelog() async {
    try {
      final markdownText = await rootBundle.loadString('CHANGELOG.md');
      final parsedEntries = _parseChangelog(markdownText);
      if (parsedEntries.isNotEmpty) {
        setState(() {
          _entries = parsedEntries;
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}

    setState(() {
      _isLoading = false;
      _errorMessage = 'فشل في تحميل سجل التغييرات.';
    });
  }

  List<ChangelogEntry> _parseChangelog(String markdownText) {
    final entries = <ChangelogEntry>[];
    final lines = markdownText.split('\n');

    String? currentVersion;
    String? currentDate;
    String currentTitle = '';
    String currentDescription = '';
    List<String> currentImprovements = [];
    List<String> currentFixes = [];
    List<String> currentPatches = [];

    String activeSection = ''; // 'improvements', 'fixes', 'patches'

    void saveCurrentEntry() {
      if (currentVersion != null) {
        entries.add(ChangelogEntry(
          version: currentVersion,
          date: currentDate ?? '',
          title: currentTitle.trim().isNotEmpty ? currentTitle.trim() : 'تحديث v$currentVersion',
          description: currentDescription.trim(),
          improvements: List.from(currentImprovements),
          fixes: List.from(currentFixes),
          patches: List.from(currentPatches),
        ));
      }
      // Reset
      currentTitle = '';
      currentDescription = '';
      currentImprovements.clear();
      currentFixes.clear();
      currentPatches.clear();
      activeSection = '';
    }

    final versionRegex = RegExp(r'^##\s*\[([^\]]+)\](?:\s*-\s*(.*))?$');

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      final versionMatch = versionRegex.firstMatch(line);
      if (versionMatch != null) {
        saveCurrentEntry();
        currentVersion = versionMatch.group(1);
        currentDate = versionMatch.group(2) ?? '';
        continue;
      }

      if (line.startsWith('### Title:')) {
        currentTitle = line.replaceFirst('### Title:', '').trim();
        continue;
      }

      if (line.startsWith('### Description:')) {
        currentDescription = line.replaceFirst('### Description:', '').trim();
        continue;
      }

      if (line.startsWith('### Improvements')) {
        activeSection = 'improvements';
        continue;
      }

      if (line.startsWith('### Fixes')) {
        activeSection = 'fixes';
        continue;
      }

      if (line.startsWith('### Patches')) {
        activeSection = 'patches';
        continue;
      }

      if (line.startsWith('-') || line.startsWith('*')) {
        final itemText = line.substring(1).trim();
        if (itemText.isEmpty || itemText == '-') continue;

        if (activeSection == 'fixes') {
          currentFixes.add(itemText);
        } else if (activeSection == 'patches') {
          currentPatches.add(itemText);
        } else {
          currentImprovements.add(itemText);
        }
      }
    }

    saveCurrentEntry();
    return entries;
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
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon:
                Icon(Icons.arrow_back_ios_new_rounded, color: theme.textColor),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'سجل التحديثات والتطويرات',
            style: GoogleFonts.cairo(
              color: theme.textColor,
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
            ),
          ),
          centerTitle: true,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: theme.gradientColors,
            ),
          ),
          child: SafeArea(
            child: _buildBody(theme),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(AppTheme theme) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(theme.accentColor),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded,
                  color: Colors.redAccent, size: 60.sp),
              SizedBox(height: 16.h),
              Text(
                _errorMessage!,
                style:
                    GoogleFonts.cairo(color: theme.textColor, fontSize: 16.sp),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _loadChangelog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.accentColor,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text('إعادة المحاولة',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    if (_entries.isEmpty) {
      return Center(
        child: Text(
          'لا يوجد سجل تغييرات متاح حالياً.',
          style: GoogleFonts.cairo(color: theme.subtitleColor, fontSize: 16.sp),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      itemCount: _entries.length,
      itemBuilder: (context, index) {
        final entry = _entries[index];
        final isFirst = index == 0;
        final isLast = index == _entries.length - 1;

        return ChangelogRow(
          entry: entry,
          isFirst: isFirst,
          isLast: isLast,
          theme: theme,
        );
      },
    );
  }
}

class ChangelogRow extends StatelessWidget {
  final ChangelogEntry entry;
  final bool isFirst;
  final bool isLast;
  final AppTheme theme;

  const ChangelogRow({
    super.key,
    required this.entry,
    required this.isFirst,
    required this.isLast,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Version & Date
        SizedBox(
          width: 80.w,
          child: Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.version,
                  style: GoogleFonts.cairo(
                    color: theme.accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  entry.date,
                  style: GoogleFonts.cairo(
                    color: theme.subtitleColor,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Middle Timeline Line & Dot
        SizedBox(
          width: 24.w,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              // Vertical connecting line
              Positioned(
                top: isFirst ? 14.h : 0,
                bottom: isLast ? null : 0,
                height: isLast ? 14.h : null,
                width: 2.w,
                child: Container(
                  color: theme.dividerColor.withValues(alpha: 0.4),
                ),
              ),
              // Timeline Dot
              Positioned(
                top: 10.h,
                child: Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.accentColor,
                    boxShadow: [
                      BoxShadow(
                        color: theme.accentColor.withValues(alpha: 0.4),
                        blurRadius: 6,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Right Column: Changelog Content Card
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: 24.h),
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardColor.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    Text(
                      entry.title,
                      style: GoogleFonts.cairo(
                        color: theme.textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                    if (entry.description.isNotEmpty) ...[
                      SizedBox(height: 6.h),
                      // Description
                      Text(
                        entry.description,
                        style: GoogleFonts.cairo(
                          color: theme.subtitleColor,
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                    SizedBox(height: 16.h),
                    Divider(
                        color: theme.dividerColor.withValues(alpha: 0.2),
                        height: 1),

                    // Collapsible Categories
                    CollapsibleCategoryList(
                      title: 'تحسينات',
                      count: entry.improvements.length,
                      items: entry.improvements,
                      theme: theme,
                      emptyMessage: 'لا توجد تحسينات في هذا الإصدار.',
                    ),
                    Divider(
                        color: theme.dividerColor.withValues(alpha: 0.2),
                        height: 1),

                    CollapsibleCategoryList(
                      title: 'إصلاحات',
                      count: entry.fixes.length,
                      items: entry.fixes,
                      theme: theme,
                      emptyMessage: 'لا توجد إصلاحات في هذا الإصدار.',
                    ),
                    Divider(
                        color: theme.dividerColor.withValues(alpha: 0.2),
                        height: 1),

                    CollapsibleCategoryList(
                      title: 'تطويرات فرعية',
                      count: entry.patches.length,
                      items: entry.patches,
                      theme: theme,
                      emptyMessage: 'لا توجد تطويرات فرعية في هذا الإصدار.',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CollapsibleCategoryList extends StatefulWidget {
  final String title;
  final int count;
  final List<String> items;
  final AppTheme theme;
  final String emptyMessage;

  const CollapsibleCategoryList({
    super.key,
    required this.title,
    required this.count,
    required this.items,
    required this.theme,
    required this.emptyMessage,
  });

  @override
  State<CollapsibleCategoryList> createState() =>
      _CollapsibleCategoryListState();
}

class _CollapsibleCategoryListState extends State<CollapsibleCategoryList> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          borderRadius: BorderRadius.circular(8.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${widget.title} (${widget.count})',
                    style: GoogleFonts.cairo(
                      color: widget.theme.textColor.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: widget.theme.accentColor,
                    size: 20.sp,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Expanded Content with smooth transition
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.fastOutSlowIn,
          child: _isExpanded
              ? Padding(
                  padding: EdgeInsets.only(bottom: 12.h, left: 8.w, right: 8.w),
                  child: widget.count == 0
                      ? Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.h),
                          child: Text(
                            widget.emptyMessage,
                            style: GoogleFonts.cairo(
                              color: widget.theme.subtitleColor
                                  .withValues(alpha: 0.7),
                              fontSize: 12.sp,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      : Column(
                          children: widget.items.map((item) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 4.h),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Bullet Point Dot
                                  Padding(
                                    padding:
                                        EdgeInsets.only(top: 8.h, left: 8.w),
                                    child: Container(
                                      width: 5.w,
                                      height: 5.w,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: widget.theme.accentColor
                                            .withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ),
                                  // Text content
                                  Expanded(
                                    child: Text(
                                      item,
                                      style: GoogleFonts.cairo(
                                        color: widget.theme.textColor
                                            .withValues(alpha: 0.85),
                                        fontSize: 13.sp,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
