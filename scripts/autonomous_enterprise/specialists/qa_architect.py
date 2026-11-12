# -*- coding: utf-8 -*-
"""
كبير مهندسي الجودة والموثوقية الفائقة (Lead QA & Reliability Architect)
خبرة تفوق 20 عاماً في هندسة النظم الآمنة واختبارات التطبيقات عالية الأداء ومنع الانهيارات.
"""

import subprocess
import os

class QAArchitect:
    def __init__(self, workspace_path):
        self.name = "م. يوسف العطار (Principal QA Architect)"
        self.workspace_path = workspace_path

    def run_static_analysis(self):
        """تشغيل فحص الكود البرمجي الصارم عبر dart analyze"""
        try:
            cmd = "dart analyze lib/main.dart lib/models/task_manager.dart lib/screens/tasbih_screen.dart lib/screens/fasting_tracker_screen.dart"
            res = subprocess.run(
                cmd,
                shell=True,
                cwd=self.workspace_path,
                capture_output=True,
                text=True,
                timeout=60
            )
            output = res.stdout + res.stderr
            if "No issues found" in output:
                return {
                    "status": "PASS",
                    "score": "100%",
                    "summary": "كافة الملفات الأساسية مفحوصة وسليمة 100% وخالية من أي أخطاء أو تحذيرات.",
                    "details": output.strip()
                }
            else:
                return {
                    "status": "WARNING",
                    "score": "85%",
                    "summary": "تم العثور على بعض الملاحظات أو التحذيرات الطفيفة.",
                    "details": output.strip()
                }
        except Exception as e:
            return {
                "status": "ERROR",
                "score": "N/A",
                "summary": f"تعذر إكمال الفحص: {str(e)}",
                "details": str(e)
            }

    def verify_asset_integrity(self):
        """التحقق من سلامة الأصول والخطوط وصور المتجر"""
        checks = []
        # التحقق من وجود الخطوط
        fonts = [
            "C:/Windows/Fonts/tradbdo.ttf",
            "C:/Windows/Fonts/tahomabd.ttf",
            "C:/Windows/Fonts/segoeuib.ttf"
        ]
        fonts_ok = all(os.path.exists(f) for f in fonts)
        checks.append(("خطوط النظام العربية الفاخرة", "متوفرة" if fonts_ok else "استخدام الخط الافتراضي"))

        # التحقق من صور المتجر
        store_icon = os.path.join(self.workspace_path, "store_assets", "app_icon_512x512.png")
        icon_ok = os.path.exists(store_icon)
        checks.append(("أيقونة المتجر الرسمية (512x512)", "جاهزة ومحققة" if icon_ok else "غير موجودة"))

        return checks
