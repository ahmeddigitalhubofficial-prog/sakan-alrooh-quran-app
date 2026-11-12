# -*- coding: utf-8 -*-
"""
رئيس قطاع الإنتاج الإبداعي وصناعة الميديا (Creative & Video Production Director)
خبرة تفوق 20 عاماً في الإخراج الإعلاني، إيقاع الفيديوهات القصيرة وهندسة الخطافات البصرية.
"""

import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import arabic_reshaper
from bidi.algorithm import get_display

class MediaDirector:
    def __init__(self, workspace_path):
        self.name = "أ. زياد نور الدين (Creative Director)"
        self.workspace_path = workspace_path
        self.output_dir = os.path.join(workspace_path, "scripts", "autonomous_enterprise", "output")
        os.makedirs(self.output_dir, exist_ok=True)

    def _shape_ar(self, text):
        if not text:
            return ""
        try:
            return get_display(arabic_reshaper.reshape(text))
        except:
            return text

    def _get_font(self, font_name, size):
        font_paths = [
            f"C:/Windows/Fonts/{font_name}.ttf",
            "C:/Windows/Fonts/tahoma.ttf",
            "C:/Windows/Fonts/arial.ttf"
        ]
        for path in font_paths:
            if os.path.exists(path):
                try:
                    return ImageFont.truetype(path, size)
                except:
                    pass
        return ImageFont.load_default()

    def generate_promo_poster(self, title="سكن الروح", hook="واحتك الإيمانية الهادئة بدون إعلانات"):
        """توليد بوستر دعائي عمودي احترافي عالي الدقة (1080x1920) لقصص إنستغرام وريلز وتيك توك"""
        width, height = 1080, 1920
        # خلفية إسلامية ليلية متدرجة فخمة (كحلي ملكي وزيتي داكن)
        img = Image.new("RGBA", (width, height), (16, 44, 59, 255))
        draw = ImageDraw.Draw(img)

        # إضافة تدرج ناعم
        for y in range(height):
            alpha = int(255 * (y / height) * 0.45)
            draw.line([(0, y), (width, y)], fill=(6, 21, 31, alpha))

        # تحميل الشعار إن وجد
        icon_path = os.path.join(self.workspace_path, "store_assets", "app_icon_512x512.png")
        if os.path.exists(icon_path):
            try:
                icon = Image.open(icon_path).convert("RGBA").resize((220, 220), Image.Resampling.LANCZOS)
                # إضافة ظل ناعم للشعار
                img.paste(icon, ((width - 220) // 2, 180), icon)
            except:
                pass

        # تحميل لقطة شاشة حقيقية للتطبيق
        screenshot_path = os.path.join(self.workspace_path, "store_assets", "Pixel 8 new", "6(20).png")
        if os.path.exists(screenshot_path):
            try:
                screen = Image.open(screenshot_path).convert("RGBA")
                # تصغيرها لتناسب الشاشة
                sw, sh = 540, 1080
                screen = screen.resize((sw, sh), Image.Resampling.LANCZOS)
                img.paste(screen, ((width - sw) // 2, 580), screen)
            except:
                pass

        # نصوص الخطاف والعنوان بالخط العربي الفاخر
        font_title = self._get_font("tradbdo", 72)
        font_hook = self._get_font("tahomabd", 40)
        font_badge = self._get_font("tahomabd", 32)

        # عنوان البوستر
        t_text = self._shape_ar(title)
        draw.text((width // 2, 430), t_text, font=font_title, fill=(212, 175, 55), anchor="mm")

        # الخطاف التحفيزي
        h_text = self._shape_ar(hook)
        draw.text((width // 2, 510), h_text, font=font_hook, fill=(255, 255, 255), anchor="mm")

        # شريط التحميل بالأسفل
        draw.rounded_rectangle([(140, 1720), (width - 140, 1820)], radius=30, fill=(212, 175, 55))
        b_text = self._shape_ar("متوفر الآن مجاناً على Google Play")
        draw.text((width // 2, 1770), b_text, font=font_badge, fill=(10, 20, 30), anchor="mm")

        out_path = os.path.join(self.output_dir, "daily_promo_story.png")
        img.convert("RGB").save(out_path, "PNG", quality=95)
        return out_path
