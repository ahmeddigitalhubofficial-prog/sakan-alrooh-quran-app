// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/quiz_manager.dart';

class IslamicQuizScreen extends StatefulWidget {
  const IslamicQuizScreen({super.key});

  @override
  State<IslamicQuizScreen> createState() => _IslamicQuizScreenState();
}

class _IslamicQuizScreenState extends State<IslamicQuizScreen> {
  int? _selectedOptionIndex;
  bool _hasAnswered = false;

  void _onSelectOption(int index, QuizQuestion q, QuizManager manager) {
    if (_hasAnswered) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedOptionIndex = index;
      _hasAnswered = true;
    });

    if (index == q.correctIndex) {
      manager.recordCorrectAnswer();
    }
  }

  void _shareQuizQuestion(QuizQuestion q) {
    final text = '🧠 سؤال اليوم في الثقافة والمعلومات الإسلامية:\n\n'
        '❓ "${q.question}"\n\n'
        'خيارات الإجابة:\n'
        '1️⃣ ${q.options[0]}\n'
        '2️⃣ ${q.options[1]}\n'
        '3️⃣ ${q.options[2]}\n'
        '4️⃣ ${q.options[3]}\n\n'
        'هل تعرف الإجابة الصحيحة؟ اختبر معلوماتك وتحدَّ أصدقاءك عبر تطبيق سكن الروح (Sakan Al-Rooh) 🌿';
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<QuizManager>(context);
    final q = manager.todayQuestion;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'سؤال اليوم وتحدي الصديق 🧠',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Color(0xFFE5C07B)),
            tooltip: 'تحدَّ صديقك في هذا السؤال',
            onPressed: () => _shareQuizQuestion(q),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5C07B).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5C07B).withOpacity(0.4)),
                  ),
                  child: Text(
                    '📚 تصنيف: ${q.category}',
                    style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                Text(
                  'إجاباتك الصحيحة: ${manager.totalCorrect} 🏆',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Question Card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E2433), const Color(0xFF131822)]
                      : [const Color(0xFFFFFDF8), const Color(0xFFF7F2E7)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5C07B).withOpacity(0.35)),
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
                  const Icon(Icons.help_outline_rounded, color: Color(0xFFE5C07B), size: 36),
                  const SizedBox(height: 12),
                  Text(
                    q.question,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Options List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: q.options.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final optionText = q.options[index];
                final isSelected = _selectedOptionIndex == index;
                final isCorrect = index == q.correctIndex;

                Color borderColor = isDark ? Colors.white12 : Colors.black12;
                Color bgColor = isDark ? const Color(0xFF1A1F2C) : Colors.white;
                Widget? trailingIcon;

                if (_hasAnswered) {
                  if (isCorrect) {
                    borderColor = const Color(0xFF2E7D32);
                    bgColor = const Color(0xFF2E7D32).withOpacity(0.15);
                    trailingIcon = const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32));
                  } else if (isSelected) {
                    borderColor = Colors.redAccent;
                    bgColor = Colors.redAccent.withOpacity(0.15);
                    trailingIcon = const Icon(Icons.cancel_rounded, color: Colors.redAccent);
                  }
                }

                return InkWell(
                  onTap: _hasAnswered ? null : () => _onSelectOption(index, q, manager),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: const Color(0xFFE5C07B).withOpacity(0.2),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            optionText,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (trailingIcon != null) trailingIcon,
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Explanation box if answered
            if (_hasAnswered) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lightbulb_rounded, color: Color(0xFF2E7D32), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _selectedOptionIndex == q.correctIndex
                              ? 'إجابة صحيحة! أحسنت 🎉 (+30 حسنة)'
                              : 'معلومة وفائدة: 💡',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      q.explanation,
                      style: const TextStyle(fontSize: 13, height: 1.6),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Challenge Friend Button
            ElevatedButton.icon(
              onPressed: () => _shareQuizQuestion(q),
              icon: const Icon(Icons.sports_esports_rounded, size: 20),
              label: const Text(
                'تحدَّ صديقك في هذا السؤال عبر واتساب 📲',
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
