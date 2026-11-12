// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../data/hadith_data.dart';
import '../models/hadith_model.dart';
import '../models/theme_manager.dart';

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen>
    with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  HadithTopic? _selectedTopic;
  final Set<String> _favorites = {};

  List<HadithModel> get _filteredHadiths {
    final topic = _selectedTopic;
    if (topic == null) return [];
    if (_searchQuery.isEmpty) return topic.hadiths;
    final q = _searchQuery.toLowerCase();
    return topic.hadiths
        .where((h) =>
            h.text.contains(q) ||
            h.narrator.contains(q) ||
            h.explanation.contains(q))
        .toList();
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
            _selectedTopic == null
                ? 'الأحاديث النبوية الشريفة'
                : _selectedTopic!.title,
            style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold, color: Colors.white),
          ),
          leading: _selectedTopic != null
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => setState(() => _selectedTopic = null),
                )
              : null,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: theme.gradientColors,
            ),
          ),
          child: _selectedTopic == null
              ? _buildTopicsGrid(theme)
              : _buildHadithList(theme),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────
  //  Topics Grid
  // ────────────────────────────────────────────────
  Widget _buildTopicsGrid(AppTheme theme) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(theme)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) =>
                  _buildTopicCard(HadithDatabase.topics[index], theme),
              childCount: HadithDatabase.topics.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.15,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  Widget _buildHeader(AppTheme theme) {
    final total = HadithDatabase.topics.fold<int>(
        0, (sum, t) => sum + t.hadiths.length);
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor,
            theme.primaryColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📿 الأحاديث النبوية',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$total حديثاً شريفاً في ${HadithDatabase.topics.length} أبواب',
                  style: GoogleFonts.cairo(
                      color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text('☪️', style: TextStyle(fontSize: 30)),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicCard(HadithTopic topic, AppTheme theme) {
    return Card(
      color: theme.cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: theme.accentColor.withOpacity(0.2)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => setState(() => _selectedTopic = topic),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(topic.icon, style: const TextStyle(fontSize: 36)),
              const SizedBox(height: 10),
              Text(
                topic.title,
                style: GoogleFonts.cairo(
                  color: theme.textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: theme.accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${topic.hadiths.length} أحاديث',
                  style: GoogleFonts.cairo(
                    color: theme.accentColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────
  //  Hadith List
  // ────────────────────────────────────────────────
  Widget _buildHadithList(AppTheme theme) {
    final hadiths = _filteredHadiths;

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            decoration: BoxDecoration(
              color: theme.cardColor.withOpacity(0.85),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.accentColor.withOpacity(0.3)),
            ),
            child: TextField(
              style: TextStyle(color: theme.textColor),
              decoration: InputDecoration(
                hintText: 'ابحث في الأحاديث...',
                hintStyle: GoogleFonts.cairo(
                    color: theme.subtitleColor.withOpacity(0.6)),
                prefixIcon: Icon(Icons.search, color: theme.accentColor),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (v) => setState(() => _searchQuery = v.trim()),
            ),
          ),
        ),
        // Count badge
        Padding(
          padding: const EdgeInsets.only(right: 16, bottom: 4),
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${hadiths.length} حديث',
                  style: GoogleFonts.cairo(
                    color: theme.accentColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: hadiths.isEmpty
              ? Center(
                  child: Text(
                    'لا توجد نتائج',
                    style: GoogleFonts.cairo(
                        color: theme.subtitleColor, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  itemCount: hadiths.length,
                  itemBuilder: (context, i) =>
                      _buildHadithCard(hadiths[i], i + 1, theme),
                ),
        ),
      ],
    );
  }

  Widget _buildHadithCard(HadithModel hadith, int number, AppTheme theme) {
    final isFav = _favorites.contains(hadith.id);

    return Card(
      color: theme.cardColor,
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.accentColor.withOpacity(0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Number + copy + fav
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: theme.accentColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$number',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.red : theme.subtitleColor,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      if (isFav) {
                        _favorites.remove(hadith.id);
                      } else {
                        _favorites.add(hadith.id);
                      }
                    });
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon:
                      Icon(Icons.copy, color: theme.subtitleColor, size: 18),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(
                        text:
                            '${hadith.text}\n\nرواه: ${hadith.narrator}\nالمصدر: ${hadith.source}'));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تم نسخ الحديث',
                            style: GoogleFonts.cairo()),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: theme.accentColor,
                      ),
                    );
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Hadith text
            Text(
              hadith.text,
              style: GoogleFonts.amiri(
                color: theme.textColor,
                fontSize: 18,
                height: 1.8,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            // Narrator + source
            Row(
              children: [
                Icon(Icons.person_outline,
                    size: 14, color: theme.accentColor),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    hadith.narrator,
                    style: GoogleFonts.cairo(
                      color: theme.accentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    hadith.source,
                    style: GoogleFonts.cairo(
                      color: theme.primaryColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            // Explanation — collapsible
            if (hadith.explanation.isNotEmpty) ...[
              const SizedBox(height: 10),
              _ExpandableExplanation(
                  explanation: hadith.explanation, theme: theme),
            ],
          ],
        ),
      ),
    );
  }
}

/// Collapsible explanation widget
class _ExpandableExplanation extends StatefulWidget {
  final String explanation;
  final AppTheme theme;

  const _ExpandableExplanation(
      {required this.explanation, required this.theme});

  @override
  State<_ExpandableExplanation> createState() =>
      _ExpandableExplanationState();
}

class _ExpandableExplanationState extends State<_ExpandableExplanation> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: widget.theme.accentColor.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: widget.theme.accentColor.withOpacity(0.2), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline,
                    color: widget.theme.accentColor, size: 14),
                const SizedBox(width: 6),
                Text(
                  'الشرح والفائدة',
                  style: GoogleFonts.cairo(
                    color: widget.theme.accentColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: widget.theme.accentColor,
                  size: 18,
                ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 8),
              Text(
                widget.explanation,
                style: GoogleFonts.cairo(
                  color: widget.theme.textColor,
                  fontSize: 13,
                  height: 1.7,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
