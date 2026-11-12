// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/thawab_manager.dart';

class ThawabDedicationScreen extends StatefulWidget {
  const ThawabDedicationScreen({super.key});

  @override
  State<ThawabDedicationScreen> createState() => _ThawabDedicationScreenState();
}

class _ThawabDedicationScreenState extends State<ThawabDedicationScreen> {
  void _showAddSoulDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final duaCtrl = TextEditingController();
    String relation = 'متوفى';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'إضافة إهداء صدقة جارية 🤲',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'الاسم (مثال: الوالد رحمه الله / الحاج فلان)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('الصفة: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: relation,
                        items: const [
                          DropdownMenuItem(value: 'متوفى', child: Text('متوفى 🕊️')),
                          DropdownMenuItem(value: 'مريض', child: Text('مريض 🩺')),
                          DropdownMenuItem(value: 'والدين', child: Text('بر والدين 🤍')),
                          DropdownMenuItem(value: 'صديق', child: Text('صديق / محبة 🌿')),
                        ],
                        onChanged: (val) {
                          if (val != null) setModalState(() => relation = val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: duaCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'دعاء مخصص (اختياري)',
                      hintText: 'اللهم اجعل ثواب قراءتي في صحيفته...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (nameCtrl.text.trim().isNotEmpty) {
                        Provider.of<ThawabManager>(context, listen: false).addSoul(
                          nameCtrl.text.trim(),
                          relation,
                          duaCtrl.text.trim(),
                        );
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تمت إضافة بطاقة الإهداء بنجاح 🤲')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('حفظ بطاقة الصدقة الجارية', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _shareSoulDedication(DedicatedSoul soul) {
    final text = '🌿 صدقة جارية وإهداء ثواب:\n\n'
        'عن روح: "${soul.name}" (${soul.relationType})\n'
        '🤲 الدعاء: "${soul.customDua}"\n\n'
        '📊 إجمالي ما أُهدي له حتى الآن:\n'
        '• ${soul.totalPrayers} دعوات بظهر الغيب\n'
        '• ${soul.totalTasbih} تسبيحة وتهليلة\n\n'
        'نسألكم الدعاء له وقراءة ما تيسر من القرآن عبر تطبيق سكن الروح (Sakan Al-Rooh) 🕊️';
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final thawab = Provider.of<ThawabManager>(context);
    final souls = thawab.souls;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'إهداء الثواب والصدقة الجارية 🤲',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded, color: Color(0xFFE5C07B)),
            tooltip: 'إضافة إهداء جديد',
            onPressed: () => _showAddSoulDialog(context),
          ),
        ],
      ),
      body: souls.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite_border_rounded, size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text('لا توجد بطاقات إهداء مضافة حالياً'),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _showAddSoulDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('أضف متوفى أو مريض لتهدي له الثواب'),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: souls.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final soul = souls[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF1E2433), const Color(0xFF131822)]
                          : [const Color(0xFFFFFDF8), const Color(0xFFF7F2E7)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5C07B).withOpacity(0.35)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: const Color(0xFFD4AF37).withOpacity(0.2),
                                child: const Icon(Icons.spa_rounded, color: Color(0xFFD4AF37), size: 20),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                soul.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D32).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              soul.relationType,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF2E7D32), fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Dua text
                      Text(
                        soul.customDua,
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 15,
                          color: Color(0xFFB8860B),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Counters Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('الدعوات', '${soul.totalPrayers}', Icons.volunteer_activism_rounded),
                          _buildStatItem('التسبيحات', '${soul.totalTasbih}', Icons.touch_app_rounded),
                        ],
                      ),
                      const Divider(height: 24),

                      // Actions
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                thawab.recordDuaForSoul(soul.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('كتب الله أجرك! تم تسجيل دعوة بظهر الغيب 🤲'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.favorite_rounded, size: 16, color: Colors.redAccent),
                              label: const Text('دعوتُ له 🤲', style: TextStyle(fontSize: 13)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                thawab.recordDhikrForSoul(soul.id, count: 10);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('تم إهداء +10 تسبيحات لروحه 📿'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.touch_app_rounded, size: 16, color: Color(0xFFD4AF37)),
                              label: const Text('+10 تسبيحة', style: TextStyle(fontSize: 13)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.share_rounded, color: Color(0xFF25D366)),
                            tooltip: 'مشاركة بطاقة الصدقة الجارية',
                            onPressed: () => _shareSoulDedication(soul),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 6),
        Text('$label: ', style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
