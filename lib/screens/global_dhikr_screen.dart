// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/global_dhikr_manager.dart';

class GlobalDhikrScreen extends StatefulWidget {
  const GlobalDhikrScreen({super.key});

  @override
  State<GlobalDhikrScreen> createState() => _GlobalDhikrScreenState();
}

class _GlobalDhikrScreenState extends State<GlobalDhikrScreen> {
  int _selectedCampaignIndex = 0;

  void _onTapDhikr(GlobalDhikrManager manager, DhikrCampaign camp) {
    HapticFeedback.lightImpact();
    manager.incrementDhikr(camp.id);
  }

  void _shareCampaign(DhikrCampaign camp) {
    final text = '🌸 شارك معنا في: ${camp.title}\n\n'
        '📿 الذكر: "${camp.phrase}"\n'
        '📊 مجموع الأمة الآن: ${camp.currentCount} تسبيحة\n'
        '🎯 الهدف المشترك: ${camp.targetCount} تسبيحة\n\n'
        '${camp.rewardHadith}\n\n'
        'شاركنا الأجر والذكر الآن عبر تطبيق سكن الروح (Sakan Al-Rooh) 🌿';
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<GlobalDhikrManager>(context);
    final campaigns = manager.campaigns;
    final activeCamp = campaigns[_selectedCampaignIndex];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'عداد الأذكار الجماعي 📿',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Color(0xFFE5C07B)),
            tooltip: 'دعوة الأصدقاء للحملة',
            onPressed: () => _shareCampaign(activeCamp),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Campaign selector tabs
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: campaigns.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final camp = campaigns[index];
                  final isSelected = _selectedCampaignIndex == index;
                  return ChoiceChip(
                    label: Text(
                      camp.title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.black87 : null,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFFE5C07B),
                    onSelected: (val) {
                      if (val) {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedCampaignIndex = index);
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Active Campaign Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1A1F2C), const Color(0xFF111622)]
                      : [const Color(0xFFFFFDF5), const Color(0xFFF9F4E8)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5C07B).withOpacity(0.4)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    activeCamp.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    activeCamp.phrase,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD4AF37),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    activeCamp.rewardHadith,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: activeCamp.progress,
                      minHeight: 12,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'الإنجاز: ${(activeCamp.progress * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${activeCamp.currentCount} / ${activeCamp.targetCount}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // User Contribution Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite_rounded, color: Color(0xFF2E7D32), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'مساهمتك أنت في هذه الحملة: ${activeCamp.userContribution} تسبيحة',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2E7D32)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Big Interactive Tasbih Button
            Center(
              child: GestureDetector(
                onTap: () => _onTapDhikr(manager, activeCamp),
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Color(0xFFE5C07B), Color(0xFFB8860B), Color(0xFF8B6508)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE5C07B).withOpacity(0.45),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.touch_app_rounded, color: Colors.white, size: 36),
                      SizedBox(height: 6),
                      Text(
                        'اضغط للتسبيح',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '+1 تسبيحة للأمة',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // WhatsApp Share Action
            ElevatedButton.icon(
              onPressed: () => _shareCampaign(activeCamp),
              icon: const Icon(Icons.group_add_rounded, size: 20),
              label: const Text(
                'ادعُ أصدقاءك وعائلتك للمشاركة 📲',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
