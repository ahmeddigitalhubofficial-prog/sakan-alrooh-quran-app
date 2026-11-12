// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/quran_card_generator_service.dart';
import '../services/in_app_telemetry_service.dart';

class CardStudioScreen extends StatefulWidget {
  final String? initialText;
  final String? initialSource;

  const CardStudioScreen({
    super.key,
    this.initialText,
    this.initialSource,
  });

  @override
  State<CardStudioScreen> createState() => _CardStudioScreenState();
}

class _CardStudioScreenState extends State<CardStudioScreen> {
  final GlobalKey _cardKey = GlobalKey();

  late TextEditingController _textController;
  late TextEditingController _sourceController;
  late TextEditingController _signatureController;

  int _selectedThemeIndex = 0;
  int _selectedRatioIndex = 0; // 0: 9:16 (Story), 1: 1:1 (Square), 2: 16:9 (Landscape)
  double _fontSize = 22.0;
  bool _showSignature = true;
  bool _isExporting = false;

  final List<Map<String, dynamic>> _presets = [
    {
      'text': '﴿ وَإِذَا سَأَلَكَ عِبَادِي عَنِّي فَإِنِّي قَرِيبٌ ۖ أُجِيبُ دَعْوَةَ الدَّاعِ إِذَا دَعَانِ ﴾',
      'source': 'سورة البقرة - الآية 186',
    },
    {
      'text': '﴿ لَا تَحْزَنْ إِنَّ اللَّهَ مَعَنَا ﴾',
      'source': 'سورة التوبة - الآية 40',
    },
    {
      'text': '﴿ وَاصْبِرْ لِحُكْمِ رَبِّكَ فَإِنَّكَ بِأَعْيُنِنَا ﴾',
      'source': 'سورة الطور - الآية 48',
    },
    {
      'text': '﴿ فَمَا ظَنُّكُم بِرَبِّ الْعَالَمِينَ ﴾',
      'source': 'سورة الصافات - الآية 87',
    },
    {
      'text': 'اللَّهُمَّ إِنَّكَ عَفُوٌّ كَرِيمٌ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي',
      'source': 'دعاء مأثور',
    },
    {
      'text': 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ نِعْمَ الْمَوْلَىٰ وَنِعْمَ النَّصِيرُ',
      'source': 'أذكار وتفويض',
    },
  ];

  final List<Map<String, dynamic>> _themes = [
    {
      'name': 'ذهبي ملكي',
      'bgGradient': [Color(0xFF141923), Color(0xFF0B0E14), Color(0xFF1A1F2C)],
      'accentColor': Color(0xFFE5C07B),
      'textColor': Color(0xFFFFF7E6),
      'subColor': Color(0xFFD4AF37),
      'borderColor': Color(0xFFE5C07B),
      'icon': Icons.stars_rounded,
    },
    {
      'name': 'زمردي فاخر',
      'bgGradient': [Color(0xFF062820), Color(0xFF021712), Color(0xFF0A3B30)],
      'accentColor': Color(0xFF4ECCA3),
      'textColor': Color(0xFFE8F8F5),
      'subColor': Color(0xFF2E8B57),
      'borderColor': Color(0xFF4ECCA3),
      'icon': Icons.eco_rounded,
    },
    {
      'name': 'ليلي عميق',
      'bgGradient': [Color(0xFF0F172A), Color(0xFF020617), Color(0xFF1E293B)],
      'accentColor': Color(0xFF60A5FA),
      'textColor': Color(0xFFF1F5F9),
      'subColor': Color(0xFF93C5FD),
      'borderColor': Color(0xFF38BDF8),
      'icon': Icons.nightlight_round,
    },
    {
      'name': 'أبيض لؤلؤي',
      'bgGradient': [Color(0xFFF8FAFC), Color(0xFFEDE9FE), Color(0xFFF1F5F9)],
      'accentColor': Color(0xFF6366F1),
      'textColor': Color(0xFF1E293B),
      'subColor': Color(0xFF475569),
      'borderColor': Color(0xFFCBD5E1),
      'icon': Icons.wb_sunny_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.initialText ?? _presets[0]['text'],
    );
    _sourceController = TextEditingController(
      text: widget.initialSource ?? _presets[0]['source'],
    );
    _signatureController = TextEditingController(
      text: 'صدقة جارية • تطبيق سكن الروح - Sakan Al-Rooh 🕊️',
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _sourceController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _shareCard() async {
    setState(() => _isExporting = true);
    HapticFeedback.mediumImpact();
    try {
      final success = await QuranCardGeneratorService.shareCardImage(
        _cardKey,
        caption: '${_textController.text}\n\n${_sourceController.text}\n\nنشرت عبر تطبيق سكن الروح (Sakan Al-Rooh) 🌿',
      );
      if (mounted) {
        if (success) {
          InAppTelemetryService.logFeaturePulse('story_card_shared', metadata: {
            'ratio': _selectedRatioIndex == 0 ? '9:16' : (_selectedRatioIndex == 1 ? '1:1' : '16:9'),
            'theme': _themes[_selectedThemeIndex]['name'],
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تجهيز ومشاركة البطاقة بنجاح! 🌿', style: TextStyle(fontFamily: 'Amiri')),
              backgroundColor: Color(0xFF2E7D32),
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = _themes[_selectedThemeIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'استوديو البطاقات والحالات 📸',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome_rounded, color: Color(0xFFE5C07B)),
            tooltip: 'آيات وأذكار مقترحة',
            onPressed: _showPresetsSheet,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Preview Card with RepaintBoundary
            Center(
              child: RepaintBoundary(
                key: _cardKey,
                child: _buildCardContent(theme),
              ),
            ),
            const SizedBox(height: 20),

            // Aspect Ratio Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildRatioChip(0, 'حالة واتساب 9:16', Icons.phone_android_rounded),
                const SizedBox(width: 8),
                _buildRatioChip(1, 'مربع 1:1', Icons.crop_square_rounded),
                const SizedBox(width: 8),
                _buildRatioChip(2, 'عريض 16:9', Icons.panorama_rounded),
              ],
            ),
            const SizedBox(height: 16),

            // Theme selector
            const Text(
              'اختر الطابع الجمالي:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 46,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _themes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final t = _themes[index];
                  final isSelected = _selectedThemeIndex == index;
                  return InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedThemeIndex = index);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: t['bgGradient']),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFE5C07B) : Colors.white24,
                          width: isSelected ? 2.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(t['icon'], color: t['accentColor'], size: 18),
                          const SizedBox(width: 6),
                          Text(
                            t['name'],
                            style: TextStyle(
                              color: t['textColor'],
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Controls: Text Size slider
            Row(
              children: [
                const Icon(Icons.format_size_rounded, size: 20),
                const SizedBox(width: 8),
                const Text('حجم الخط:', style: TextStyle(fontSize: 13)),
                Expanded(
                  child: Slider(
                    value: _fontSize,
                    min: 16,
                    max: 32,
                    divisions: 8,
                    label: _fontSize.round().toString(),
                    activeColor: const Color(0xFFD4AF37),
                    onChanged: (val) => setState(() => _fontSize = val),
                  ),
                ),
              ],
            ),

            // Edit Fields
            TextField(
              controller: _textController,
              maxLines: 3,
              style: const TextStyle(fontFamily: 'Amiri', fontSize: 16),
              decoration: InputDecoration(
                labelText: 'نص الآية أو الذكر',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.edit_note_rounded),
                isDense: true,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _sourceController,
                    decoration: InputDecoration(
                      labelText: 'المصدر (السورة / المرجع)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      isDense: true,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  icon: Icon(_showSignature ? Icons.verified_user_rounded : Icons.hide_source_rounded),
                  tooltip: _showSignature ? 'إخفاء التوقيع' : 'إظهار التوقيع',
                  onPressed: () => setState(() => _showSignature = !_showSignature),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Action Share Button
            ElevatedButton.icon(
              onPressed: _isExporting ? null : _shareCard,
              icon: _isExporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.share_rounded, size: 22),
              label: Text(
                _isExporting ? 'جارِ تجهيز البطاقة...' : 'مشاركة للحالة والواتساب 📲',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366), // WhatsApp Green
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 4,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildRatioChip(int index, String label, IconData icon) {
    final isSelected = _selectedRatioIndex == index;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.grey),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : null)),
        ],
      ),
      selected: isSelected,
      selectedColor: const Color(0xFFD4AF37),
      onSelected: (val) {
        if (val) {
          HapticFeedback.selectionClick();
          setState(() => _selectedRatioIndex = index);
        }
      },
    );
  }

  Widget _buildCardContent(Map<String, dynamic> theme) {
    double width;
    double height;

    if (_selectedRatioIndex == 0) {
      // 9:16 Story
      width = 300;
      height = 533;
    } else if (_selectedRatioIndex == 1) {
      // 1:1 Square
      width = 320;
      height = 320;
    } else {
      // 16:9 Landscape
      width = 340;
      height = 191;
    }

    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: theme['bgGradient'],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: (theme['borderColor'] as Color).withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Islamic ornament header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star_rounded, color: theme['accentColor'], size: 16),
              const SizedBox(width: 6),
              Text(
                'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: theme['subColor'],
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.star_rounded, color: theme['accentColor'], size: 16),
            ],
          ),

          // Center Text
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Text(
                  _textController.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: _fontSize,
                    height: 1.7,
                    fontWeight: FontWeight.bold,
                    color: theme['textColor'],
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom Source & Signature
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_sourceController.text.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: (theme['accentColor'] as Color).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (theme['accentColor'] as Color).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _sourceController.text,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme['accentColor'],
                    ),
                  ),
                ),
              if (_showSignature) ...[
                const SizedBox(height: 8),
                Text(
                  _signatureController.text,
                  style: TextStyle(
                    fontSize: 10,
                    color: (theme['textColor'] as Color).withOpacity(0.6),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showPresetsSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'اختر من الآيات والأدعية المقترحة 📜',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: _presets.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final p = _presets[index];
                    return ListTile(
                      title: Text(
                        p['text'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontFamily: 'Amiri', fontSize: 15),
                      ),
                      subtitle: Text(p['source']),
                      onTap: () {
                        setState(() {
                          _textController.text = p['text'];
                          _sourceController.text = p['source'];
                        });
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
