// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/good_deeds_challenge_manager.dart';

class GoodDeedsChallengeScreen extends StatelessWidget {
  const GoodDeedsChallengeScreen({super.key});

  void _shareDailyProgress(GoodDeedsChallengeManager manager) {
    final text = '🏆 تحدي الصحبة الصالحة اليومي:\n\n'
        '✨ لقد أتممت ${manager.completedCount} من أصل ${manager.quests.length} من طاعات اليوم بنجاح!\n'
        '🔥 سلسلة الالتزام: ${manager.streakDays} أيام متتالية\n\n'
        '«سَابِقُوا إِلَىٰ مَغْفِرَةٍ مِّن رَّبِّكُمْ وَجَنَّةٍ عَرْضُهَا كَعَرْضِ السَّمَاءِ وَالْأَرْضِ»\n\n'
        'تحدَّ نفسك وشاركنا التنافس في الطاعات عبر تطبيق سكن الروح (Sakan Al-Rooh) 🌿';
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<GoodDeedsChallengeManager>(context);
    final quests = manager.quests;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تحدي الصحبة الصالحة 🏆',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Color(0xFFE5C07B)),
            tooltip: 'مشاركة إنجاز اليوم',
            onPressed: () => _shareDailyProgress(manager),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Streak & Progress Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF141E30), Color(0xFF243B55)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.local_fire_department_rounded, color: Colors.orangeAccent, size: 28),
                          const SizedBox(width: 6),
                          Text(
                            'سلسلة الطاعات: ${manager.streakDays} أيام',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5C07B).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5C07B)),
                        ),
                        child: Text(
                          '${(manager.dailyProgress * 100).round()}% مكتمل',
                          style: const TextStyle(color: Color(0xFFE5C07B), fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: manager.dailyProgress,
                      minHeight: 10,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4ECCA3)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    manager.completedCount == quests.length
                        ? '🎉 مبارك! أتممت جميع تحديات اليوم ونلت الأجر كاملاً'
                        : 'أتممت ${manager.completedCount} من ${quests.length} مهام إيمانية اليوم',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'مهام اليوم الإيمانية 🌿',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),

            // Quests List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: quests.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final q = quests[index];
                return InkWell(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    manager.toggleQuest(q.id, context);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: q.isCompleted
                          ? const Color(0xFF2E7D32).withOpacity(isDark ? 0.2 : 0.1)
                          : (isDark ? const Color(0xFF1E2433) : Colors.white),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: q.isCompleted
                            ? const Color(0xFF2E7D32)
                            : (isDark ? Colors.white12 : Colors.black12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: q.isCompleted,
                          activeColor: const Color(0xFF2E7D32),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          onChanged: (val) {
                            HapticFeedback.mediumImpact();
                            manager.toggleQuest(q.id, context);
                          },
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                q.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  decoration: q.isCompleted ? TextDecoration.lineThrough : null,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                q.description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white60 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5C07B).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '+${q.pointsReward} حسنة',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB8860B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Share button
            ElevatedButton.icon(
              onPressed: () => _shareDailyProgress(manager),
              icon: const Icon(Icons.celebration_rounded, size: 20),
              label: const Text(
                'شارك إنجازك وشجع أصدقاءك 📲',
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
